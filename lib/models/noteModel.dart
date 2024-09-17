class NoteModel {
  // Mendefinisikan properti kelas
  int? id; // ID pengguna
  String? title; // Nama pengguna
  String? description; // Email pengguna

  // Konstruktor dengan parameter 'id' opsional
  NoteModel(this.title, this.description, {this.id});

  // Mengubah objek Note menjadi Map. Kunci harus sesuai dengan nama
  // kolom dalam database.
  NoteModel.fromJson(Map<String, dynamic> map) {
    id = map['id'];
    title = map['title'];
    description = map['description'];
  }

  // Metode untuk mengubah 'NoteModel' menjadi map
  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
    };
  }
}
