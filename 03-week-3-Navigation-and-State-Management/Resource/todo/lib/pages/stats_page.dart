import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/todo_provider.dart';

class StatsPage extends ConsumerWidget {
  const StatsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final allTodos = ref.watch(todoListProvider);
    final completedTodos = ref.watch(completedTodosProvider);
    final uncompletedTodos = ref.watch(uncompletedTodosProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Statistik')),
      body: allTodos.when(
        data: (allData) {
          final completed = completedTodos.value ?? [];
          final uncompleted = uncompletedTodos.value ?? [];
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Total Tugas: ${allData.length}',
                    style: Theme.of(context).textTheme.headlineSmall),
                const SizedBox(height: 16),
                Text('Selesai: ${completed.length}',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: Colors.green)),
                const SizedBox(height: 16),
                Text('Belum Selesai: ${uncompleted.length}',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: Colors.red)),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Error: $error', style: const TextStyle(color: Colors.red))),
      ),
    );
  }
}
