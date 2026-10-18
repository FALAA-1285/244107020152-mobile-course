library;

/// Pure utility functions for formatting dates and parsing routes.
/// These functions do not depend on Flutter widgets or external frameworks.

/// Memformat objek DateTime menjadi string tanggal standar YYYY-MM-DD
String formatDate(DateTime? date) {
  if (date == null) return '-';
  final year = date.year.toString();
  final month = date.month.toString().padLeft(2, '0');
  final day = date.day.toString().padLeft(2, '0');
  return '$year-$month-$day';
}

/// Mengekstrak dan memvalidasi rute dari payload push notification
String routeFromMessage(Map<String, dynamic> data) {
  final route = data['route']?.toString() ?? '/';
  return route.startsWith('/') ? route : '/$route';
}
