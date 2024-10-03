## Membuat Aplikasi Catatan Sederhana dengan Flutter

### Pendahuluan

Dalam materi ini, kita akan belajar cara membuat sebuah aplikasi catatan sederhana menggunakan Flutter. Aplikasi ini memungkinkan pengguna untuk membuat, mengedit, dan menghapus catatan. Kita akan menggunakan SQLite sebagai database lokal untuk menyimpan catatan.

### Struktur Proyek

Berikut adalah struktur proyek yang kita gunakan:

```
lib
├── models
│   └── noteModel.dart
├── screens
│   ├── home
│   │   └── home.dart
│   └── shared
│       ├── taskColumn.dart
│       └── topContainer.dart
├── views
│   └── note_view.dart
├── services
│   └── database_helper.dart
└── main.dart
```

### 1. Pengenalan `main.dart`

File `main.dart` adalah titik awal dari aplikasi Flutter. Di sini kita akan menginisialisasi aplikasi dan mengatur rute serta layar awal.

```dart
import 'package:flutter/material.dart';
import 'screens/home/home.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Aplikasi Catatan',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: HomeScreen(),
    );
  }
}
```
#### Penjelasan:
- **`main()`**: Fungsi utama yang dijalankan ketika aplikasi dimulai. Fungsi ini memanggil `runApp(MyApp())` untuk memulai aplikasi.
- **`MyApp`**: Kelas `StatelessWidget` yang mendefinisikan aplikasi Flutter. Ini mengatur judul aplikasi, tema, dan layar awal (`HomeScreen`).

### 2. Model (`models/noteModel.dart`)

Model digunakan untuk mendefinisikan struktur data catatan. Kita akan membuat kelas `NoteModel`.

```dart
class NoteModel {
  int? id;
  String? title;
  String? description;

  NoteModel(this.title, this.description);

  Map<String, dynamic> toMap() {
    var map = <String, dynamic>{
      'title': title,
      'description': description,
    };
    if (id != null) {
      map['id'] = id;
    }
    return map;
  }

  NoteModel.fromMap(Map<String, dynamic> map) {
    id = map['id'];
    title = map['title'];
    description = map['description'];
  }
}
```
#### Penjelasan:
- **`NoteModel`**: Kelas yang mewakili model catatan. Memiliki properti `id`, `title`, dan `description`.
- **`toMap()`**: Mengubah objek `NoteModel` menjadi map yang dapat digunakan untuk operasi database.
- **`NoteModel.fromMap()`**: Membuat objek `NoteModel` dari map yang didapat dari database.

### 3. Database Helper (`services/database_helper.dart`)

Database Helper digunakan untuk mengelola operasi database seperti membuat, membaca, memperbarui, dan menghapus catatan.

```dart
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import '../models/noteModel.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();
  static Database? _database;

  DatabaseHelper._privateConstructor();

  Future<Database?> get database async {
    if (_database != null) return _database;
    _database = await _initDatabase();
    return _database;
  }

  Future<Database?> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'notes.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE notes(
        id INTEGER PRIMARY KEY,
        title TEXT,
        description TEXT
      )
    ''');
  }

  Future<List<NoteModel>> getNotes() async {
    Database? db = await instance.database;
    var notes = await db!.query('notes', orderBy: 'id');
    List<NoteModel> noteList = notes.isNotEmpty
        ? notes.map((c) => NoteModel.fromMap(c)).toList()
        : [];
    return noteList;
  }

  Future<int> add(NoteModel note) async {
    Database? db = await instance.database;
    return await db!.insert('notes', note.toMap());
  }

  Future<int> update(NoteModel note) async {
    Database? db = await instance.database;
    return await db!.update('notes', note.toMap(),
        where: 'id = ?', whereArgs: [note.id]);
  }

  Future<int> delete(int id) async {
    Database? db = await instance.database;
    return await db!.delete('notes', where: 'id = ?', whereArgs: [id]);
  }
}
```
#### Penjelasan:
- **`DatabaseHelper`**: Kelas singleton yang mengelola operasi database.
- **`_initDatabase()`**: Menginisialisasi dan membuka database.
- **`_onCreate()`**: Membuat tabel `notes` ketika database pertama kali dibuat.
- **`getNotes()`**: Mengambil semua catatan dari database.
- **`add()`**: Menambahkan catatan baru ke database.
- **`update()`**: Memperbarui catatan yang ada di database.
- **`delete()`**: Menghapus catatan dari database berdasarkan ID.

### 4. Layar Utama (`screens/home/home.dart`)

Layar utama menampilkan daftar catatan yang tersimpan di database.

```dart
import 'package:flutter/material.dart';
import '../../views/note_view.dart';
import '../../services/database_helper.dart';
import '../../models/noteModel.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<NoteModel> notes = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    refreshNotes();
  }

  Future refreshNotes() async {
    setState(() => isLoading = true);
    notes = await DatabaseHelper.instance.getNotes();
    setState(() => isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Catatan Saya'),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: notes.length,
              itemBuilder: (context, index) {
                final note = notes[index];
                return ListTile(
                  title: Text(note.title ?? ''),
                  subtitle: Text(note.description ?? ''),
                  onTap: () async {
                    await Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => NoteView(noteId: note.id),
                    ));
                    refreshNotes();
                  },
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.of(context).push(MaterialPageRoute(
            builder: (context) => NoteView(),
          ));
          refreshNotes();
        },
        child: Icon(Icons.add),
      ),
    );
  }
}
```
#### Penjelasan:
- **`HomeScreen`**: Kelas `StatefulWidget` yang mewakili layar utama aplikasi.
- **`refreshNotes()`**: Fungsi yang memuat ulang daftar catatan dari database.
- **`isLoading`**: Status untuk menunjukkan apakah catatan sedang dimuat.
- **`ListView.builder`**: Widget yang menampilkan daftar catatan dalam bentuk list.
- **`FloatingActionButton`**: Tombol untuk menambah catatan baru, yang mengarahkan ke `NoteView`.

### 5. Layar Tambah/Edit Catatan (`views/note_view.dart`)

Layar ini digunakan untuk menambah atau mengedit catatan.

```dart
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../models/noteModel.dart';
import '../services/database_helper.dart';

class NoteView extends StatefulWidget {
  const NoteView({super.key, this.noteId});
  final int? noteId;

  @override
  State<NoteView> createState() => _NoteViewState();
}

class _NoteViewState extends State<NoteView> {
  final formKey = GlobalKey<FormState>();
  DatabaseHelper noteDatabase = DatabaseHelper.instance;
  TextEditingController titleController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  late NoteModel note;
  bool isLoading = false;
  bool isNewNote = false;

  @override
  void initState() {
    refreshNotes();
    super.initState();
  }

  refreshNotes() {
    if (widget.noteId == null) {
      setState(() {
        isNewNote = true;
      });
      return;
    }
    noteDatabase.read(widget.noteId!).then((value) {
      setState(() {
        note = value;
        titleController.text = note.title!;
        descriptionController.text = note.description!;
      });
    });
  }

  insert(NoteModel model) {
    noteDatabase.insert(model).then((respond) async {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("Note berhasil ditambahkan."),
        backgroundColor: Color.fromARGB(255, 4, 160, 74),
      ));
      Navigator.pop(context, {
        'reload': true,
      });
    }).catchError((error) {
      if (kDebugMode) {
        print(error);
      }
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("Gagal menyimpan catatan."),
        backgroundColor: Color.fromARGB(255, 235, 108, 108),
      ));
    });
  }

  update(NoteModel model) {
    noteDatabase.update(model).then((respond) async {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("Note berhasil diperbarui."),
        backgroundColor: Color.fromARGB(255, 4, 160, 74),
      ));
      Navigator.pop(context, {
        'reload': true,
      });
    }).catchError((error) {
      if (kDebugMode) {
        print(error);
      }
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("Gagal memperbarui catatan."),
        backgroundColor: Color.fromARGB(255, 235, 108, 108),
      ));
    });
  }

  createNote() async {
    setState(() {
      isLoading = true;
    });

    if (formKey.currentState != null && formKey.currentState!.validate()) {
      formKey.currentState?.save();

      NoteModel model =
          NoteModel(titleController.text, descriptionController.text);

      if (isNewNote) {
        insert(model);
      } else {
        model.id = note.id;
        update(model);
      }
    }
    setState(() {
      isLoading = false;
    });
  }

  deleteNote() {
    noteDatabase.delete(note.id!);
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      content: Text("Note berhasil dihapus."),
      backgroundColor: Color.fromARGB(255, 235, 108, 108),
    ));
    Navigator.pop(context);
  }

  String? validateTitle(String? value) {
    if (value == null || value.isEmpty) {
      return 'Masukkan judul.';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromRGBO(247, 250, 252, 1.0),
      appBar: AppBar(
        backgroundColor: const Color.fromRGBO(94, 114, 228, 1.0),
        elevation: 0.0,
        title: Text(
          isNewNote ? 'Tambah catatan' : 'Edit catatan',
        ),
      ),
      body: Form(
        key: formKey,
        child: Container(
          padding: const EdgeInsets.all(30),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextFormField(
                    controller: titleController,
                    decoration: const InputDecoration(
                      hintText: "Masukkan judul",
                      labelText: 'Judul',
                      border: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: Colors.white,
                            width: 0.75,
                          ),
                          borderRadius: BorderRadius.all(
                            Radius.circular(10.0),
                          )),
                    ),
                    validator: validateTitle,
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextFormField(
                    controller: descriptionController,
                    decoration: const InputDecoration(
                      hintText: "Masukkan deskripsi",
                      labelText: 'Deskripsi',
                      border: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: Colors.white,
                            width: 0.75,
                          ),
                          borderRadius: BorderRadius.all(
                            Radius.circular(10.0),
                          )),
                    ),
                    keyboardType: TextInputType.multiline,
                    maxLines: 2,
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Container(
                width: double.infinity,
                margin: const EdgeInsets.all(10.0),
                child: ElevatedButton(
                  onPressed: createNote,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromRGBO(94, 114, 228, 1.0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    padding: const EdgeInsets.all(20),
                  ),
                  child: const Text(
                    "Simpan",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ),
              ),
              Container(
                width: double.infinity,
                margin: const EdgeInsets.all(10.0),
                child: Visibility(
                  visible: !isNewNote,
                  child: ElevatedButton(
                    onPressed: deleteNote,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(255, 235, 108, 108),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      padding: const EdgeInsets.all(20),
                    ),
                    child: const Text(
                      "Hapus",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
```
#### Penjelasan:
- **`NoteView`**: Kelas `StatefulWidget` yang digunakan untuk menambah atau mengedit catatan.
- **`formKey`**: Kunci untuk mengidentifikasi form.
- **`titleController` dan `descriptionController`**: Pengontrol teks untuk input judul dan deskripsi.
- **`refreshNotes()`**: Memuat ulang data catatan jika sedang dalam mode edit.
- **`insert()`**: Menambahkan catatan baru ke database.
- **`update()`**: Memperbarui catatan yang ada di database.
- **`createNote()`**: Menyimpan catatan baru atau memperbarui catatan yang ada berdasarkan apakah catatan baru atau edit.
- **`deleteNote()`**: Menghapus catatan dari database.
- **`validateTitle()`**: Validasi untuk memastikan judul tidak kosong.
- **`build()`**: Membangun UI untuk form input catatan, termasuk tombol simpan dan hapus.

### 6. Widget Bersama (`screens/shared/taskColumn.dart` dan `screens/shared/topContainer.dart`)

Ini adalah contoh widget yang digunakan bersama di berbagai bagian aplikasi.

#### `taskColumn.dart`

```dart
import 'package:flutter/material.dart';

class TaskColumn extends StatelessWidget {
  final String title;
  final List<Widget> children;

  TaskColumn({required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          title,
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        ...children,
      ],
    );
  }
}
```
#### Penjelasan:
- **`TaskColumn`**: Widget kustom yang digunakan untuk menampilkan kolom tugas dengan judul dan daftar widget anak.

#### `topContainer.dart`

```dart
import 'package:flutter/material.dart';

class TopContainer extends StatelessWidget {
  final double height;
  final Color color;
  final Widget child;

  TopContainer({required this.height, required this.color, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.only(
          bottomRight: Radius.circular(30.0),
          bottomLeft: Radius.circular(30.0),
        ),
      ),
      child: child,
    );
  }
}
```
#### Penjelasan:
- **`TopContainer`**: Widget yang digunakan untuk menampilkan bagian atas layar dengan latar belakang berwarna dan sudut melengkung.

### Kesimpulan

Dalam materi ini, kita telah belajar cara membuat aplikasi catatan sederhana dengan Flutter. Kita telah membahas berbagai komponen penting seperti model, helper database, layar utama, layar tambah/edit catatan, dan widget bersama. Dengan pemahaman ini, Anda dapat mengembangkan aplikasi lebih lanjut dan menambahkan fitur-fitur tambahan sesuai kebutuhan. Selamat mencoba!
