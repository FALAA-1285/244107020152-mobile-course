class Announcement {
  const Announcement({
    required this.id,
    required this.title,
    this.body = '',
    this.date,
  });

  final String id;
  final String title;
  final String body;
  final DateTime? date;
}
