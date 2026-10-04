import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sqflite/sqflite.dart';

import 'data/local/db.dart';
import 'pages/notes_page.dart';
import 'pages/settings_page.dart';

// ─── Praktikum 3: Cache-first dan antrean sync ───

/// Model Post sederhana dari JSONPlaceholder
class Post {
  final int id;
  final String title;
  final String body;

  const Post({required this.id, required this.title, required this.body});

  factory Post.fromJson(Map<String, dynamic> json) => Post(
        id: (json['id'] as num?)?.toInt() ?? 0,
        title: json['title'] as String? ?? '',
        body: json['body'] as String? ?? '',
      );

  Map<String, dynamic> toJson() => {'id': id, 'title': title, 'body': body};
}

/// Toggle forceOffline agar demo dan testing tidak bergantung pada kondisi Wi-Fi
final forceOfflineProvider =
    NotifierProvider<ForceOfflineNotifier, bool>(ForceOfflineNotifier.new);

class ForceOfflineNotifier extends Notifier<bool> {
  @override
  bool build() => false;

  void set(bool value) => state = value;
}

/// Membaca cached posts dari tabel cached_posts
Future<List<Post>> readCachedPosts() async {
  final db = await openNotesDb();
  final rows = await db.query('cached_posts', orderBy: 'id ASC');
  return rows.map((row) {
    final payload = jsonDecode(row['payload'] as String) as Map<String, dynamic>;
    return Post.fromJson(payload);
  }).toList();
}

/// Menyimpan posts ke tabel cached_posts
Future<void> saveCachedPosts(List<Post> posts) async {
  final db = await openNotesDb();
  final batch = db.batch();
  // Hapus cache lama
  batch.delete('cached_posts');
  for (final post in posts) {
    batch.insert('cached_posts', {
      'id': post.id,
      'payload': jsonEncode(post.toJson()),
      'cached_at': DateTime.now().toIso8601String(),
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }
  await batch.commit(noResult: true);
}

/// Fetch posts dari network (simulasi JSONPlaceholder dengan data statis)
Future<List<Post>> fetchPostsFromNetwork() async {
  // Simulasi network delay
  await Future.delayed(const Duration(seconds: 1));
  // Data statis simulasi JSONPlaceholder GET /posts (5 item)
  return const [
    Post(id: 1, title: 'sunt aut facere repellat', body: 'quia et suscipit suscipit recusandae'),
    Post(id: 2, title: 'qui est esse', body: 'est rerum tempore vitae sequi sint nihil'),
    Post(id: 3, title: 'ea molestias quasi', body: 'et iusto sed quo iure voluptatem'),
    Post(id: 4, title: 'eum et est occaecati', body: 'ullam et saepe reiciendis voluptatem adipisci'),
    Post(id: 5, title: 'nesciunt quas odio', body: 'repudiandae veniam quaerat sunt sed'),
  ];
}

/// Cache-first read: tampilkan cache lokal seketika, refresh dari jaringan di background
final cachedPostsProvider =
    AsyncNotifierProvider<CachedPostsNotifier, List<Post>>(
        CachedPostsNotifier.new);

class CachedPostsNotifier extends AsyncNotifier<List<Post>> {
  @override
  Future<List<Post>> build() async {
    // 1. Segera kembalikan cache agar UI tidak blank saat offline.
    final cached = await readCachedPosts();
    if (cached.isNotEmpty) {
      // 2. Di background: fetch jaringan -> simpan ke cached_posts -> invalidate.
      _refreshInBackground();
      return cached;
    }
    // Jika cache kosong, coba fetch dari network langsung
    final isOffline = ref.watch(forceOfflineProvider);
    if (isOffline) return [];
    try {
      final posts = await fetchPostsFromNetwork();
      await saveCachedPosts(posts);
      return posts;
    } catch (_) {
      return [];
    }
  }

  Future<void> _refreshInBackground() async {
    final isOffline = ref.read(forceOfflineProvider);
    if (isOffline) return;
    try {
      final posts = await fetchPostsFromNetwork();
      await saveCachedPosts(posts);
      state = AsyncData(posts);
    } catch (_) {
      // Tetap pakai cache jika network gagal
    }
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final isOffline = ref.read(forceOfflineProvider);
      if (isOffline) {
        return readCachedPosts();
      }
      final posts = await fetchPostsFromNetwork();
      await saveCachedPosts(posts);
      return posts;
    });
  }
}

// ─── Main App ───

void main() {
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final darkModeAsync = ref.watch(darkModeProvider);
    final isDark = darkModeAsync.value ?? false;

    // Catat waktu dibuka
    ref.read(prefsRepositoryProvider).markOpenedNow();

    return MaterialApp(
      title: 'Week 5 - Offline Notes',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
          brightness: isDark ? Brightness.dark : Brightness.light,
        ),
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  int _currentIndex = 0;

  final _pages = const [
    NotesPage(),
    CachedPostsPage(),
    SettingsPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) =>
            setState(() => _currentIndex = index),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.note),
            label: 'Catatan',
          ),
          NavigationDestination(
            icon: Icon(Icons.cloud_download),
            label: 'Cache Posts',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings),
            label: 'Pengaturan',
          ),
        ],
      ),
    );
  }
}

// ─── Halaman Cache Posts (Praktikum 3) ───

class CachedPostsPage extends ConsumerWidget {
  const CachedPostsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final postsAsync = ref.watch(cachedPostsProvider);
    final isOffline = ref.watch(forceOfflineProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Cached Posts'),
        actions: [
          // Toggle forceOffline
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                isOffline ? Icons.airplanemode_active : Icons.wifi,
                size: 18,
              ),
              Switch(
                value: isOffline,
                onChanged: (val) {
                  ref.read(forceOfflineProvider.notifier).set(val);
                  // Refresh posts setelah toggle
                  ref.read(cachedPostsProvider.notifier).refresh();
                },
              ),
            ],
          ),
        ],
      ),
      body: postsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Error: $e'),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: () =>
                    ref.read(cachedPostsProvider.notifier).refresh(),
                child: const Text('Coba lagi'),
              ),
            ],
          ),
        ),
        data: (posts) => posts.isEmpty
            ? Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('Tidak ada data cached.'),
                    const SizedBox(height: 8),
                    if (!isOffline)
                      ElevatedButton(
                        onPressed: () =>
                            ref.read(cachedPostsProvider.notifier).refresh(),
                        child: const Text('Muat dari jaringan'),
                      ),
                  ],
                ),
              )
            : RefreshIndicator(
                onRefresh: () =>
                    ref.read(cachedPostsProvider.notifier).refresh(),
                child: ListView.builder(
                  itemCount: posts.length,
                  itemBuilder: (context, index) {
                    final post = posts[index];
                    return ListTile(
                      leading: CircleAvatar(child: Text('${post.id}')),
                      title: Text(post.title),
                      subtitle: Text(
                        post.body,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    );
                  },
                ),
              ),
      ),
    );
  }
}
