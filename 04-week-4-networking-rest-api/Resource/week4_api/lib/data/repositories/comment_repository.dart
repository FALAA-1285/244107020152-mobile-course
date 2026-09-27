import 'package:dio/dio.dart';
import '../models/comment.dart';

/// Repository untuk mengakses endpoint /comments dari JSONPlaceholder.
///
/// Menggunakan repository pattern: UI tidak memanggil Dio secara langsung,
/// melainkan melalui class ini. Dio instance diterima via constructor
/// injection — memudahkan testing dengan mock.
class CommentRepository {
  CommentRepository(this._dio);

  /// Instance Dio yang sudah dikonfigurasi (baseUrl, timeout, interceptor)
  /// secara terpusat di api_client.dart, bukan di tiap method repository.
  final Dio _dio;

  /// Mengambil daftar komentar berdasarkan [postId].
  ///
  /// Endpoint: GET /comments?postId={postId}
  /// - Timeout 10 detik sudah dikonfigurasi di Dio client (api_client.dart).
  /// - Response di-parse ke `List<Comment>` dengan null-safe fromJson.
  /// - Exception (timeout, connection error, dll.) dibiarkan naik ke
  ///   provider layer untuk ditangani sebagai AsyncError.
  Future<List<Comment>> fetchComments(int postId) async {
    final response = await _dio.get<List>(
      '/comments',
      queryParameters: {'postId': postId},
    );
    final data = response.data ?? [];
    return data
        .whereType<Map<String, dynamic>>()
        .map(Comment.fromJson)
        .toList();
  }
}
