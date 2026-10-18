import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/announcements_providers.dart';

class AnnouncementPage extends ConsumerWidget {
  const AnnouncementPage({super.key, required this.id});

  final String id;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detailState = ref.watch(announcementDetailProvider(id));

    return Scaffold(
      appBar: AppBar(title: const Text('Pengumuman')),
      body: Center(
        child: detailState.when(
          loading: () => const CircularProgressIndicator(),
          error: (err, _) => Text('Error: '),
          data: (announcement) => Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Pengumuman ID: ',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                if (announcement != null) ...[
                  const SizedBox(height: 12),
                  Text(
                    announcement.title,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    announcement.body,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.black87),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
