import 'package:flutter_test/flutter_test.dart';
import 'package:week4_api/data/models/comment.dart';

void main() {
  group('Comment.fromJson', () {
    // Test 1: Happy path — semua field ada dan bertipe benar.
    test('parsing JSON lengkap menghasilkan Comment yang benar', () {
      final json = {
        'postId': 1,
        'id': 5,
        'name': 'vero eaque aliquid doloribus',
        'email': 'Hayden@althea.biz',
        'body': 'harum non quasi et ratione',
      };

      final comment = Comment.fromJson(json);

      expect(comment.postId, 1);
      expect(comment.id, 5);
      expect(comment.name, 'vero eaque aliquid doloribus');
      expect(comment.email, 'Hayden@althea.biz');
      expect(comment.body, 'harum non quasi et ratione');
    });

    // Test 2: Field hilang sebagian — harus fallback ke default, bukan crash.
    test('field yang hilang menggunakan nilai default tanpa crash', () {
      final json = <String, dynamic>{
        'postId': 3,
        // 'id' hilang
        // 'name' hilang
        'email': 'test@mail.com',
        // 'body' hilang
      };

      final comment = Comment.fromJson(json);

      expect(comment.postId, 3);
      expect(comment.id, 0); // default int
      expect(comment.name, ''); // default String
      expect(comment.email, 'test@mail.com');
      expect(comment.body, ''); // default String
    });

    // Test 3: JSON kosong total — semua field harus default.
    test('JSON kosong menghasilkan semua nilai default', () {
      final comment = Comment.fromJson(<String, dynamic>{});

      expect(comment.postId, 0);
      expect(comment.id, 0);
      expect(comment.name, '');
      expect(comment.email, '');
      expect(comment.body, '');
    });

    // Test 4 (Edge case tambahan): Tipe field salah — misalnya
    // 'postId' berupa String alih-alih int. fromJson harus tetap
    // aman (fallback ke default) karena menggunakan safe cast.
    test('tipe field salah menggunakan fallback default tanpa crash', () {
      final json = <String, dynamic>{
        'postId': 'bukan angka', // seharusnya int
        'id': null, // null eksplisit
        'name': 12345, // seharusnya String
        'email': true, // seharusnya String
        'body': ['array'], // seharusnya String
      };

      final comment = Comment.fromJson(json);

      // Semua field harus fallback ke default karena tipe tidak cocok.
      expect(comment.postId, 0);
      expect(comment.id, 0);
      expect(comment.name, '');
      expect(comment.email, '');
      expect(comment.body, '');
    });

    // Test 5: toJson roundtrip — memastikan serialisasi konsisten.
    test('toJson menghasilkan Map yang sesuai', () {
      final comment = Comment(
        postId: 2,
        id: 10,
        name: 'Test Name',
        email: 'test@test.com',
        body: 'Test body content',
      );

      final json = comment.toJson();

      expect(json['postId'], 2);
      expect(json['id'], 10);
      expect(json['name'], 'Test Name');
      expect(json['email'], 'test@test.com');
      expect(json['body'], 'Test body content');
    });
  });
}
