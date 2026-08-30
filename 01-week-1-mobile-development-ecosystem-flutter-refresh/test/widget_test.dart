import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_first_app/main.dart';

void main() {
  testWidgets('Profil Mahasiswa smoke test', (WidgetTester tester) async {
    // Memuat aplikasi
    await tester.pumpWidget(const MyApp());

    // Memverifikasi teks yang muncul di layar
    expect(find.text('Profil Mahasiswa'), findsOneWidget);
    expect(find.text('Ahmad Falahi'), findsOneWidget);
    expect(find.text('NIM: 244107020152'), findsOneWidget);
  });
}