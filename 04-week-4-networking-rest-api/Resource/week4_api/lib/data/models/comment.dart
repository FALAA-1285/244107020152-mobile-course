/// Model Comment merepresentasikan satu komentar dari JSONPlaceholder.
/// Endpoint: GET /comments?postId={id}
///
/// Contoh JSON response:
/// {
///   "postId": 1,
///   "id": 1,
///   "name": "id labore ex et quam laborum",
///   "email": "Eliseo@gardner.biz",
///   "body": "laudantium enim quasi est..."
/// }
class Comment {
  const Comment({
    required this.postId,
    required this.id,
    required this.name,
    required this.email,
    required this.body,
  });

  final int postId;   // ID post yang dikomentari
  final int id;       // ID unik komentar
  final String name;  // Judul/nama komentar
  final String email; // Email penulis komentar
  final String body;  // Isi komentar

  /// Factory constructor untuk parsing JSON secara aman null.
  /// Menggunakan pengecekan tipe 'is' sebelum cast — lebih aman dari
  /// 'as num?' yang crash jika field bertipe salah (misal String di
  /// tempat int). Ini adalah perbaikan dari output AI awal.
  factory Comment.fromJson(Map<String, dynamic> json) {
    return Comment(
      postId: json['postId'] is num ? (json['postId'] as num).toInt() : 0,
      id: json['id'] is num ? (json['id'] as num).toInt() : 0,
      name: json['name'] is String ? json['name'] as String : '',
      email: json['email'] is String ? json['email'] as String : '',
      body: json['body'] is String ? json['body'] as String : '',
    );
  }

  /// Mengonversi objek Comment kembali ke Map untuk serialisasi.
  Map<String, dynamic> toJson() => {
        'postId': postId,
        'id': id,
        'name': name,
        'email': email,
        'body': body,
      };
}
