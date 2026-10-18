import '../../domain/entities/announcement.dart';

class AnnouncementModel extends Announcement {
  const AnnouncementModel({
    required super.id,
    required super.title,
    super.body = '',
    super.date,
  });

  Map<String, Object?> toMap() => {
        'id': id,
        'title': title,
        'body': body,
        'date': date?.toIso8601String(),
      };

  factory AnnouncementModel.fromMap(Map<String, Object?> map) {
    return AnnouncementModel(
      id: map['id']?.toString() ?? '',
      title: map['title'] as String? ?? '',
      body: map['body'] as String? ?? '',
      date: map['date'] != null ? DateTime.tryParse(map['date'] as String) : null,
    );
  }

  Announcement toEntity() => Announcement(
        id: id,
        title: title,
        body: body,
        date: date,
      );
}
