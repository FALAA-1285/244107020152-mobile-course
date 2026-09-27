import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/comment_providers.dart';
import '../data/providers.dart'; // untuk friendlyErrorMessage

/// Halaman yang menampilkan daftar komentar untuk satu post.
///
/// Menerima [postId] sebagai parameter, kemudian menggunakan
/// commentListProvider(postId) untuk fetch dan menampilkan komentar.
/// Menangani 4 state: loading, error, empty, dan success.
class CommentListPage extends ConsumerWidget {
  const CommentListPage({super.key, required this.postId});

  final int postId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch provider family dengan postId sebagai argumen.
    final commentsAsync = ref.watch(commentListProvider(postId));

    return Scaffold(
      appBar: AppBar(
        title: Text('Komentar Post #$postId'),
        actions: [
          // Tombol refresh manual di AppBar — invalidate memaksa fetch ulang.
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () =>
                ref.invalidate(commentListProvider(postId)),
          ),
        ],
      ),
      body: commentsAsync.when(
        // STATE: Loading — tampilkan indikator loading di tengah.
        loading: () => const Center(child: CircularProgressIndicator()),

        // STATE: Error — tampilkan pesan ramah + tombol "Coba lagi".
        // friendlyErrorMessage() mengubah DioException teknis
        // (timeout, connectionError, badResponse 404/500) menjadi
        // pesan yang bisa dipahami pengguna.
        error: (err, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  friendlyErrorMessage(err),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                FilledButton(
                  onPressed: () =>
                      ref.invalidate(commentListProvider(postId)),
                  child: const Text('Coba lagi'),
                ),
              ],
            ),
          ),
        ),

        // STATE: Data berhasil dimuat.
        data: (comments) {
          // Sub-state: Empty — tidak ada komentar untuk post ini.
          if (comments.isEmpty) {
            return const Center(
              child: Text('Belum ada komentar untuk post ini.'),
            );
          }
          // Sub-state: Success — tampilkan list dengan pull-to-refresh.
          return RefreshIndicator(
            onRefresh: () async =>
                ref.invalidate(commentListProvider(postId)),
            child: ListView.builder(
              itemCount: comments.length,
              itemBuilder: (context, index) {
                final comment = comments[index];
                return Card(
                  margin:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Header: ID komentar + nama
                        Row(
                          children: [
                            CircleAvatar(
                              radius: 16,
                              child: Text(
                                comment.id.toString(),
                                style: const TextStyle(fontSize: 12),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                comment.name,
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        // Email penulis komentar
                        Text(
                          comment.email,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.primary,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 8),
                        // Isi komentar
                        Text(comment.body),
                      ],
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
