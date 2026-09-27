import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'models/comment.dart';
import 'providers.dart'; // untuk dioProvider & friendlyErrorMessage
import 'repositories/comment_repository.dart';

/// Provider untuk CommentRepository.
/// Mengambil Dio instance dari dioProvider yang sudah dikonfigurasi
/// secara terpusat (baseUrl, timeout 10 detik, interceptor log).
final commentRepositoryProvider = Provider<CommentRepository>(
  (ref) => CommentRepository(ref.watch(dioProvider)),
);

/// FutureProvider family: satu provider per postId.
///
/// Menggunakan .family agar setiap post memiliki state komentar
/// yang independen. Exception dari repository otomatis menjadi
/// AsyncError — UI tinggal me-watch dan menampilkan state yang sesuai.
///
/// Contoh penggunaan: ref.watch(commentListProvider(1))
/// akan mengambil komentar dari /comments?postId=1.
final commentListProvider =
    FutureProvider.family<List<Comment>, int>((ref, postId) {
  // postId diteruskan ke repository.
  // Exception (timeout, connection error, dll.) otomatis
  // ditangkap oleh Riverpod dan diubah jadi AsyncError.
  final repository = ref.watch(commentRepositoryProvider);
  return repository.fetchComments(postId);
});
