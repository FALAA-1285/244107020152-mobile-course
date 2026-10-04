import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/local/note.dart';
import '../data/repositories/note_repository.dart';

final noteRepositoryProvider = Provider((ref) => NoteRepository());

final noteListProvider =
    AsyncNotifierProvider<NoteListNotifier, List<Note>>(NoteListNotifier.new);

class NoteListNotifier extends AsyncNotifier<List<Note>> {
  @override
  Future<List<Note>> build() =>
      ref.watch(noteRepositoryProvider).fetchNotes();

  Future<void> add(String title, String body) async {
    await ref.read(noteRepositoryProvider).addNote(title: title, body: body);
    ref.invalidateSelf();
  }

  Future<void> remove(int id) async {
    await ref.read(noteRepositoryProvider).deleteNote(id);
    ref.invalidateSelf();
  }
}

final dirtyCountProvider = FutureProvider<int>((ref) async {
  // bergantung pada noteListProvider agar otomatis refresh
  ref.watch(noteListProvider);
  final repo = ref.watch(noteRepositoryProvider);
  return repo.countDirty();
});

/// Simulasi sinkronisasi catatan kotor (dirty)
Future<int> syncNotes(NoteRepository repo) async {
  final dirtyCount = await repo.countDirty();
  if (dirtyCount == 0) return 0;
  // Simulasi upload: pada project nyata, kirim tiap catatan dirty
  // ke REST API di sini, lalu tandai bersih bila server menjawab 2xx.
  await Future.delayed(const Duration(seconds: 1));
  await repo.markAllSynced();
  return dirtyCount;
}

class NotesPage extends ConsumerWidget {
  const NotesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notesAsync = ref.watch(noteListProvider);
    final dirtyAsync = ref.watch(dirtyCountProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Catatan Offline'),
        actions: [
          // Badge dirty count
          dirtyAsync.when(
            data: (count) => count > 0
                ? Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ActionChip(
                      avatar: const Icon(Icons.sync, size: 18),
                      label: Text('$count belum sync'),
                      onPressed: () async {
                        final repo = ref.read(noteRepositoryProvider);
                        final synced = await syncNotes(repo);
                        ref.invalidate(noteListProvider);
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                                content:
                                    Text('$synced catatan berhasil disinkron')),
                          );
                        }
                      },
                    ),
                  )
                : const Padding(
                    padding: EdgeInsets.only(right: 16),
                    child: Icon(Icons.cloud_done, color: Colors.green),
                  ),
            loading: () => const Padding(
              padding: EdgeInsets.only(right: 16),
              child: SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
            error: (_, _) => const SizedBox.shrink(),
          ),
        ],
      ),
      body: notesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Error: $e'),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: () => ref.invalidate(noteListProvider),
                child: const Text('Coba lagi'),
              ),
            ],
          ),
        ),
        data: (notes) => notes.isEmpty
            ? const Center(child: Text('Belum ada catatan. Tekan + untuk menambah.'))
            : ListView.builder(
                itemCount: notes.length,
                itemBuilder: (context, index) {
                  final note = notes[index];
                  return ListTile(
                    leading: note.dirty
                        ? const Icon(Icons.cloud_off, color: Colors.orange)
                        : const Icon(Icons.cloud_done, color: Colors.green),
                    title: Text(note.title),
                    subtitle: Text(
                      note.body.isNotEmpty
                          ? note.body
                          : 'Diperbarui: ${note.updatedAt.toLocal()}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete_outline),
                      onPressed: () {
                        if (note.id != null) {
                          ref.read(noteListProvider.notifier).remove(note.id!);
                        }
                      },
                    ),
                  );
                },
              ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddDialog(context, ref),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showAddDialog(BuildContext context, WidgetRef ref) {
    final titleController = TextEditingController();
    final bodyController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Catatan Baru'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(labelText: 'Judul'),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: bodyController,
              decoration: const InputDecoration(labelText: 'Isi (opsional)'),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: () {
              final title = titleController.text.trim();
              if (title.isNotEmpty) {
                ref
                    .read(noteListProvider.notifier)
                    .add(title, bodyController.text.trim());
                Navigator.pop(ctx);
              }
            },
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
  }
}
