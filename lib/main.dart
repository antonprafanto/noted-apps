import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_crud_bc/screens/home/home.dart';

void main() {
  // Atur gaya overlay UI sistem, yang mengontrol tampilan status bar dan navigation bar.
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    systemNavigationBarColor: Color.fromRGBO(94, 114, 228, 1.0),
    statusBarColor: Color.fromRGBO(94, 114, 228, 1.0),
  ));

  // Jalankan aplikasi Flutter dengan meluncurkan widget utama.
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // Widget ini adalah akar dari aplikasi Anda.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SQFLite Flutter - UDM', // Judul aplikasi
      theme: ThemeData(
        primarySwatch: Colors.blue, // Atur tema warna utama
      ),
      home: const Home(
        title: 'SQFLite Flutter - UDM', // Atur widget halaman awal
      ),
    );
  }
}
