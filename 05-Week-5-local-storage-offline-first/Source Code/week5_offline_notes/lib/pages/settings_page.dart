import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/prefs.dart';

final prefsRepositoryProvider = Provider((ref) => PrefsRepository());
final darkModeProvider =
    AsyncNotifierProvider<DarkModeNotifier, bool>(DarkModeNotifier.new);

class DarkModeNotifier extends AsyncNotifier<bool> {
  @override
  Future<bool> build() =>
      ref.watch(prefsRepositoryProvider).getDarkMode();

  Future<void> toggle() async {
    final next = !(state.value ?? false);
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref.read(prefsRepositoryProvider).setDarkMode(next);
      return next;
    });
  }
}

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final darkModeAsync = ref.watch(darkModeProvider);
    final prefsRepo = ref.watch(prefsRepositoryProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Pengaturan')),
      body: ListView(
        children: [
          darkModeAsync.when(
            loading: () => const ListTile(
              title: Text('Mode Gelap'),
              trailing: CircularProgressIndicator(),
            ),
            error: (e, _) => ListTile(
              title: const Text('Mode Gelap'),
              subtitle: Text('Error: $e'),
            ),
            data: (isDark) => SwitchListTile(
              title: const Text('Mode Gelap'),
              subtitle: Text(isDark ? 'Aktif' : 'Nonaktif'),
              value: isDark,
              onChanged: (_) =>
                  ref.read(darkModeProvider.notifier).toggle(),
            ),
          ),
          const Divider(),
          ListTile(
            title: const Text('Terakhir dibuka'),
            subtitle: FutureBuilder<String?>(
              future: prefsRepo.getLastOpened(),
              builder: (context, snap) {
                if (snap.connectionState == ConnectionState.waiting) {
                  return const Text('Memuat...');
                }
                return Text(snap.data ?? 'Belum pernah dicatat');
              },
            ),
          ),
        ],
      ),
    );
  }
}