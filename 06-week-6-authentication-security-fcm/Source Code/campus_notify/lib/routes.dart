class AppRoutes {
  static const String login = '/login';
  static const String home = '/';
  static const String announcement = '/pengumuman/:id';

  static String announcementDetail(String id) => '/pengumuman/$id';
}

/// Fungsi murni untuk mengekstrak dan memformat rute dari data RemoteMessage.
/// Dapat diuji secara unit-test tanpa inisialisasi Firebase.
String routeFromMessage(Map<String, dynamic> data) {
  final route = data['route']?.toString() ?? '/';
  return route.startsWith('/') ? route : '/$route';
}
