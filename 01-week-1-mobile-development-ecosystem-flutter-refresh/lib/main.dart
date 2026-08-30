import 'package:flutter/material.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(title: const Text('Profil Mahasiswa')),
        body: const Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.school, size: 72),
              SizedBox(height: 16),
              Text('Ahmad Falahi', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              SizedBox(height: 8),
              Text('NIM: 244107020152', style: TextStyle(fontSize: 16)),
              SizedBox(height: 4),
              Text('Pemrograman Mobile — Minggu 1', style: TextStyle(fontSize: 16)),
              SizedBox(height: 4),
              Text('Jurusan Teknologi Informasi — Politeknik Negeri Malang', style: TextStyle(fontSize: 14, color: Color.fromARGB(255, 41, 20, 165))),
            ],
          ),
        ),
      ),
    );
  }
}