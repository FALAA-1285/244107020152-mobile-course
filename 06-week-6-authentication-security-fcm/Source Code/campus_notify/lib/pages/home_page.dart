import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/auth_provider.dart';
import '../routes.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              ref.read(authStateProvider.notifier).logout();
            },
          ),
        ],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: () => context.go(AppRoutes.announcementDetail('1')),
                child: const Text('Lihat Pengumuman'),
              ),
              const SizedBox(height: 24),
              FutureBuilder<String?>(
                future: Firebase.apps.isNotEmpty
                    ? FirebaseMessaging.instance.getToken().catchError((_) => null)
                    : Future.value(null),
                builder: (context, snapshot) {
                  final token = snapshot.data;
                  final displayToken = (token != null && token.length >= 12)
                      ? '${token.substring(0, 12)}...'
                      : (Firebase.apps.isNotEmpty
                          ? 'Memuat token...'
                          : 'Firebase belum terhubung (google-services.json)');
                  return Card(
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        children: [
                          const Text(
                            'Debug FCM Token (Terpotong):',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            displayToken,
                            style: const TextStyle(fontFamily: 'monospace'),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
