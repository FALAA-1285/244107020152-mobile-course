import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'messaging/push_service.dart';
import 'pages/announcement_page.dart';
import 'pages/home_page.dart';
import 'pages/login_page.dart';
import 'providers/auth_provider.dart';
import 'routes.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  bool isFirebaseReady = false;
  try {
    await Firebase.initializeApp();
    isFirebaseReady = Firebase.apps.isNotEmpty;
    if (isFirebaseReady) {
      registerBackgroundHandler();
      await requestNotificationPermission();
      await initLocalNotifications();
    }
  } catch (e) {
    debugPrint('Firebase initialize error: $e');
  }

  final container = ProviderContainer();

  final authRefreshListenable = ValueNotifier<int>(0);
  container.listen<AsyncValue<bool>>(
    authStateProvider,
    (previous, next) {
      authRefreshListenable.value++;
    },
  );

  final router = GoRouter(
    refreshListenable: authRefreshListenable,
    redirect: (context, state) {
      final loggedIn =
          container.read(authStateProvider).value ?? false;

      final goingLogin = state.matchedLocation == AppRoutes.login;
      if (!loggedIn && !goingLogin) return AppRoutes.login;
      if (loggedIn && goingLogin) return AppRoutes.home;
      return null;
    },
    routes: [
      GoRoute(path: AppRoutes.login, builder: (context, state) => const LoginPage()),
      GoRoute(path: AppRoutes.home, builder: (context, state) => const HomePage()),
      GoRoute(
        path: AppRoutes.announcement,
        builder: (context, state) =>
            AnnouncementPage(id: state.pathParameters['id'] ?? ''),
      ),
    ],
  );

  if (isFirebaseReady) {
    try {
      listenForeground((route) => router.go(route));
      await handleTerminated((route) => router.go(route));
      await initFcmToken(
        onToken: (token) async {
          debugPrint('FCM Token: $token');
        },
      );
    } catch (e) {
      debugPrint('FCM setup error: $e');
    }
  }

  runApp(
    UncontrolledProviderScope(
      container: container,
      child: MyApp(router: router),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key, required this.router});

  final GoRouter router;

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routerConfig: router,
    );
  }
}
