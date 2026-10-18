import '../../../../core/failures.dart';
import '../entities/announcement.dart';

abstract class AnnouncementRepository {
  Future<({List<Announcement> announcements, Failure? failure})> getAnnouncements();
  Future<({Announcement? announcement, Failure? failure})> getAnnouncementDetail(String id);
}
