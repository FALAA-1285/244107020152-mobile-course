import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/models/post.dart';
import '../data/providers.dart';

/// Halaman detail post yang menampilkan title dan body lengkap.
///
/// State detail diambil dari daftar yang sudah dimuat (postListProvider).
/// Jika tidak ditemukan (misalnya halaman dibuka langsung via URL),
/// data di-fetch ulang via repository.
class PostDetailPage extends ConsumerWidget {
  const PostDetailPage({super.key, required this.postId});

  final int postId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Coba ambil dari list yang sudah dimuat.
    final postsAsync = ref.watch(postListProvider);

    return postsAsync.when(
      loading: () => Scaffold(
        appBar: AppBar(title: const Text('Detail Post')),
        body: const Center(child: CircularProgressIndicator()),
      ),
      error: (err, _) => Scaffold(
        appBar: AppBar(title: const Text('Detail Post')),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(friendlyErrorMessage(err),
                  textAlign: TextAlign.center),
              const SizedBox(height: 12),
              FilledButton(
                onPressed: () => ref.invalidate(postListProvider),
                child: const Text('Coba lagi'),
              ),
            ],
          ),
        ),
      ),
      data: (posts) {
        // Cari post dari list yang sudah dimuat.
        final Post? post = _findPost(posts, postId);

        if (post == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('Detail Post')),
            body: Center(
              child: Text('Post #$postId tidak ditemukan.'),
            ),
          );
        }

        return Scaffold(
          appBar: AppBar(title: Text('Post #${post.id}')),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Judul post
                Text(
                  post.title,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 8),
                // Info user
                Text(
                  'User ID: ${post.userId}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.outline,
                      ),
                ),
                const Divider(height: 24),
                // Body lengkap
                Text(
                  post.body,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Post? _findPost(List<Post> posts, int id) {
    for (final post in posts) {
      if (post.id == id) return post;
    }
    return null;
  }
}
