// Impor plugin yang diperlukan dan model NoteModel.
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_crud_bc/models/noteModel.dart';
import 'package:flutter_crud_bc/services/database_helper.dart';

class NoteView extends StatefulWidget {
  const NoteView({super.key, this.noteId});
  final int? noteId;

  @override
  State<NoteView> createState() => _NoteViewState();
}

class _NoteViewState extends State<NoteView> {
  final formKey = GlobalKey<FormState>();

  // Buat instansi dari pembantu database
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

  // Dapatkan semua catatan dari database dan perbarui state jika noteId tidak null, jika null setel isNewNote menjadi true
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

  // Masukkan catatan baru ke dalam database
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

  // Perbarui catatan yang ada dalam database
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

  // Buat catatan baru
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

  // Hapus catatan dari database dan kembali ke layar sebelumnya
  deleteNote() {
    noteDatabase.delete(note.id!);
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      content: Text("Note berhasil dihapus."),
      backgroundColor: Color.fromARGB(255, 235, 108, 108),
    ));
    Navigator.pop(context);
  }

  // Validasi field judul
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
          isNewNote
              ? 'Tambah catatan'
              : 'Edit catatan', // Atur judul menjadi 'Tambah catatan' jika isNewNote benar, jika tidak setel menjadi 'Edit Catatan'
        ),
      ),
      body: Form(
        key: formKey,
        child: Container(
          padding: const EdgeInsets.all(30),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Kolom Judul
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
              const SizedBox(
                height: 20,
              ),
              // Kolom Deskripsi
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
              const SizedBox(
                height: 20,
              ),
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
                    visible:
                        !isNewNote, // Setel ini untuk menentukan apakah tombol harus terlihat
                    child: ElevatedButton(
                      onPressed: deleteNote,
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            const Color.fromARGB(255, 235, 108, 108),
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
                  ))
            ],
          ),
        ),
      ),
    );
  }
}
