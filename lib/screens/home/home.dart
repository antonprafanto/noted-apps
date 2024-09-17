// Impor file-file yang dibutuhkan dari modul lain.
import 'package:flutter/material.dart';
import 'package:flutter_crud_bc/screens/shared/topContainer.dart';
import 'package:flutter_crud_bc/models/noteModel.dart';
import 'package:flutter_crud_bc/screens/views/note_view.dart';
import 'package:flutter_crud_bc/services/database_helper.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';

class Home extends StatefulWidget {
  final String title;

  const Home({super.key, required this.title});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  // Buat instance dari pembantu database
  DatabaseHelper noteDatabase = DatabaseHelper.instance;
  List<NoteModel> notes = [];

  TextEditingController searchController = TextEditingController();
  bool isSearchTextNotEmpty = false;
  List<NoteModel> filteredNotes =
      []; // Pertahankan daftar untuk catatan yang difilter

  @override
  void initState() {
    refreshNotes();
    search();
    super.initState();
  }

  @override
  dispose() {
    // Tutup database ketika tidak lagi dibutuhkan
    noteDatabase.close();
    super.dispose();
  }

  // Metode pencarian
  search() {
    searchController.addListener(() {
      setState(() {
        isSearchTextNotEmpty = searchController.text.isNotEmpty;
        if (isSearchTextNotEmpty) {
          // Lakukan filtering dan perbarui daftar catatan yang difilter
          filteredNotes = notes.where((note) {
            return note.title!
                    .toLowerCase()
                    .contains(searchController.text.toLowerCase()) ||
                note.description!
                    .toLowerCase()
                    .contains(searchController.text.toLowerCase());
          }).toList();
        } else {
          // Bersihkan daftar catatan yang difilter
          filteredNotes.clear();
        }
      });
    });
  }

  // Ambil dan segarkan daftar catatan dari database
  refreshNotes() {
    noteDatabase.getAll().then((value) {
      setState(() {
        notes = value;
      });
    });
  }

  // Navigasi ke layar NoteView dan segarkan catatan setelahnya
  goToNoteDetailsView({int? id}) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => NoteView(noteId: id)),
    );
    refreshNotes();
  }

  deleteNote({int? id}) async {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Row(children: [
              Icon(
                Icons.delete_forever,
                color: Color.fromARGB(255, 255, 81, 0),
              ),
              Text('Hapus secara permanen!')
            ]),
            content: const SingleChildScrollView(
              child: ListBody(
                children: <Widget>[
                  Text('Apakah Anda yakin ingin menghapus catatan ini?'),
                ],
              ),
            ),
            actions: [
              ElevatedButton(
                style: ButtonStyle(
                    backgroundColor: WidgetStateProperty.all(Colors.red)),
                onPressed: () async {
                  await noteDatabase.delete(id!);
                  Navigator.pop(context);
                  setState(() {});
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                    content: Text("Catatan berhasil dihapus."),
                    backgroundColor: Color.fromARGB(255, 235, 108, 108),
                  ));
                  refreshNotes();
                },
                child: const Text('Ya'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Tidak'),
              ),
            ],
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: const Color.fromRGBO(247, 250, 252, 1.0),
      body: Column(
        children: <Widget>[
          TopContainer(
            height: 250,
            width: width,
            child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 0, vertical: 0.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: <Widget>[
                        CircularPercentIndicator(
                          radius: 80.0,
                          lineWidth: 5.0,
                          animation: true,
                          percent: 0.75,
                          circularStrokeCap: CircularStrokeCap.round,
                          progressColor: const Color.fromRGBO(251, 99, 64, 1.0),
                          backgroundColor:
                              const Color.fromRGBO(94, 114, 228, 1.0),
                          center: const CircleAvatar(
                            backgroundColor: Color.fromRGBO(82, 95, 127, 1.0),
                            radius: 45.0,
                            backgroundImage: AssetImage(
                              'assets/images/avatar.png',
                            ),
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            // ignore: avoid_unnecessary_containers
                            Container(
                              child: const Text(
                                'Anton Prafanto',
                                textAlign: TextAlign.start,
                                style: TextStyle(
                                  fontSize: 18.0,
                                  color: Color.fromRGBO(247, 250, 252, 1.0),
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                            const Text(
                              'Good software, takes time',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 12.0,
                                color: Colors.white70,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ],
                        )
                      ],
                    ),
                  )
                ]),
          ),
          // Kotak teks pencarian dengan Tombol Bersihkan Kondisional
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: searchController,
                    decoration: const InputDecoration(
                      hintText: 'Cari Catatan...',
                      prefixIcon: Icon(Icons.search),
                    ),
                  ),
                ),
                if (isSearchTextNotEmpty)
                  IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () {
                      // Bersihkan teks pencarian dan perbarui UI
                      searchController.clear();
                      // Atur ulang daftar catatan yang difilter dan segarkan catatan asli
                      filteredNotes.clear();
                      refreshNotes();
                    },
                  ),
              ],
            ),
          ),
          // Area dapat digulir untuk menampilkan catatan
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Container(
                    child: notes.isEmpty
                        ? const Padding(
                            padding: EdgeInsets.only(top: 50.0),
                            child: Text(
                              "Tidak ada catatan untuk ditampilkan",
                              style: TextStyle(
                                fontWeight: FontWeight.normal,
                                fontSize: 14,
                              ),
                            ),
                          )
                        : Column(
                            children: [
                              if (isSearchTextNotEmpty)
                                ...filteredNotes.map((note) {
                                  // Tampilkan catatan yang difilter
                                  return buildNoteCard(note);
                                }).toList()
                              else
                                ...notes.map((note) {
                                  // Tampilkan catatan asli saat tidak mencari
                                  return buildNoteCard(note);
                                }).toList(),
                            ],
                          ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      // Tombol aksi mengambang untuk membuat catatan baru
      floatingActionButton: FloatingActionButton(
        onPressed: goToNoteDetailsView,
        tooltip: 'Buat Catatan',
        child: const Icon(Icons.add),
      ),
    );
  }

  // Metode pembantu untuk membangun kartu catatan
  Widget buildNoteCard(NoteModel note) {
    return Card(
      child: GestureDetector(
        onTap: () => {},
        child: ListTile(
          leading: const Icon(
            Icons.note,
            color: Color.fromARGB(255, 253, 237, 89),
          ),
          title: Text(note.title ?? ""),
          subtitle: Text(note.description ?? ""),
          trailing: Wrap(
            children: [
              IconButton(
                onPressed: () => goToNoteDetailsView(id: note.id),
                icon: const Icon(Icons.arrow_forward_ios),
              ),
              IconButton(
                onPressed: () => deleteNote(id: note.id),
                icon: const Icon(
                  Icons.delete,
                  color: Color.fromARGB(255, 255, 81, 0),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Metode pembantu untuk mendefinisikan gaya teks subjudul
  Text subheading(String title) {
    return Text(
      title,
      style: const TextStyle(
          color: Color.fromRGBO(94, 114, 228, 1.0),
          fontSize: 20.0,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.2),
    );
  }
}
