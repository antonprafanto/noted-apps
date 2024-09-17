// Impor plugin Path provider dan SQLite.
import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart';
import 'dart:io' as io;

// Impor UserModel
import 'package:flutter_crud_bc/models/noteModel.dart';

class DatabaseHelper {
  // Instansi database SQLite
  static final DatabaseHelper instance = DatabaseHelper._internal();
  static Database? _database;

  DatabaseHelper._internal();

  // Nama database dan versi
  static const String databaseName = 'database.db';

  // Set versi. Ini menjalankan fungsi onCreate dan menyediakan
  // jalur untuk melakukan upgrade dan downgrade database.
  static const int versionNumber = 1;

  // Nama tabel
  static const String tableNotes = 'Notes';

  // Kolom tabel (Users)
  static const String colId = 'id';
  static const String colTitle = 'title';
  static const String colDescription = 'description';

  // Definisikan getter untuk mengakses database secara asinkron.
  Future<Database> get database async {
    // Jika instansi database sudah diinisialisasi, kembalikan.
    if (_database != null) {
      return _database!;
    }

    // Jika instansi database belum diinisialisasi, panggil metode inisialisasi.
    _database = await _initDatabase();

    // Kembalikan instansi database yang telah diinisialisasi.
    return _database!;
  }

  _initDatabase() async {
    io.Directory documentsDirectory = await getApplicationDocumentsDirectory();

    // Setel path ke database. Catatan: Menggunakan fungsi `join` dari
    // paket `path` adalah praktik terbaik untuk memastikan path dibangun
    // dengan benar untuk setiap platform.
    String path = join(documentsDirectory.path, databaseName);
    // Ketika database pertama kali dibuat, buat tabel untuk menyimpan Catatan.
    var db =
        await openDatabase(path, version: versionNumber, onCreate: _onCreate);
    return db;
  }

  // Jalankan pernyataan CREATE TABLE pada database.
  _onCreate(Database db, int intVersion) async {
    await db.execute("CREATE TABLE IF NOT EXISTS $tableNotes ("
        " $colId INTEGER PRIMARY KEY AUTOINCREMENT, "
        " $colTitle TEXT NOT NULL, "
        " $colDescription TEXT"
        ")");
  }

  // Metode yang mengambil semua catatan dari tabel Notes.
  Future<List<NoteModel>> getAll() async {
    // Dapatkan referensi ke database.
    final db = await database;

    // Query tabel untuk semua Catatan. {SELECT * FROM Notes ORDER BY Id ASC}
    final result = await db.query(tableNotes, orderBy: '$colId ASC');

    // Konversi List<Map<String, dynamic>> menjadi List<Note>.
    return result.map((json) => NoteModel.fromJson(json)).toList();
  }

  // Cari catatan berdasarkan Id
  Future<NoteModel> read(int id) async {
    final db = await database;
    final maps = await db.query(
      tableNotes,
      where: '$colId = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return NoteModel.fromJson(maps.first);
    } else {
      throw Exception('ID $id not found');
    }
  }

  // Definisikan fungsi yang memasukkan catatan ke dalam database
  Future<void> insert(NoteModel note) async {
    // Dapatkan referensi ke database.
    final db = await database;

    // Masukkan Catatan ke tabel yang benar. Anda juga dapat menentukan
    // `conflictAlgorithm` untuk digunakan jika Catatan yang sama dimasukkan dua kali.
    //
    // Dalam hal ini, ganti data sebelumnya.
    await db.insert(tableNotes, note.toJson(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  // Definisikan fungsi untuk memperbarui catatan
  Future<int> update(NoteModel note) async {
    // Dapatkan referensi ke database.
    final db = await database;

    // Perbarui Catatan yang diberikan.
    var res = await db.update(tableNotes, note.toJson(),
        // Pastikan Catatan memiliki id yang sesuai.
        where: '$colId = ?',
        // Berikan id Catatan sebagai whereArg untuk mencegah SQL injection.
        whereArgs: [note.id]);
    return res;
  }

  // Definisikan fungsi untuk menghapus catatan
  Future<void> delete(int id) async {
    // Dapatkan referensi ke database.
    final db = await database;
    try {
      // Hapus Catatan dari database.
      await db.delete(tableNotes,
          // Gunakan klausa `where` untuk menghapus Catatan tertentu.
          where: "$colId = ?",
          // Berikan id Catatan sebagai whereArg untuk mencegah SQL injection.
          whereArgs: [id]);
    } catch (err) {
      debugPrint("Terjadi kesalahan saat menghapus item: $err");
    }
  }

  Future close() async {
    final db = await database;
    db.close();
  }
}
