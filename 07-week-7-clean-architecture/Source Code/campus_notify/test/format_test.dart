import 'package:flutter_test/flutter_test.dart';
import 'package:campus_notify/core/format.dart';

void main() {
  group('formatDate', () {
    test('mengembalikan tanda strip jika date null', () {
      expect(formatDate(null), '-');
    });

    test('memformat DateTime menjadi YYYY-MM-DD secara presisi', () {
      final date = DateTime(2026, 10, 18);
      expect(formatDate(date), '2026-10-18');
    });
  });

  group('routeFromMessage', () {
    test('menambahkan leading slash jika belum ada', () {
      expect(routeFromMessage({'route': 'pengumuman/123'}), '/pengumuman/123');
    });

    test('mempertahankan route jika sudah ada leading slash', () {
      expect(routeFromMessage({'route': '/pengumuman/123'}), '/pengumuman/123');
    });

    test('mengembalikan default slash jika route kosong atau null', () {
      expect(routeFromMessage({}), '/');
    });
  });
}
