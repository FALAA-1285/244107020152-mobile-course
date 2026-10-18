export 'core/format.dart' show routeFromMessage;

class AppRoutes {
  static const String login = '/login';
  static const String home = '/';
  static const String announcement = '/pengumuman/:id';

  static String announcementDetail(String id) => '/pengumuman/$id';
}
