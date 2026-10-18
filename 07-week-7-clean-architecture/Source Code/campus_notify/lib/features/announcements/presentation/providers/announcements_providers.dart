import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/announcement_repository_impl.dart';
import '../../domain/entities/announcement.dart';
import '../../domain/repositories/announcement_repository.dart';
import '../../domain/usecases/get_announcement_detail.dart';
import '../../domain/usecases/get_announcements.dart';

final announcementRepositoryProvider = Provider<AnnouncementRepository>((ref) {
  return const AnnouncementRepositoryImpl();
});

final getAnnouncementsProvider = Provider<GetAnnouncements>((ref) {
  return GetAnnouncements(ref.watch(announcementRepositoryProvider));
});

final getAnnouncementDetailProvider = Provider<GetAnnouncementDetail>((ref) {
  return GetAnnouncementDetail(ref.watch(announcementRepositoryProvider));
});

final announcementsProvider = FutureProvider<List<Announcement>>((ref) async {
  final result = await ref.watch(getAnnouncementsProvider).call();
  if (result.failure != null) throw Exception(result.failure!.message);
  return result.announcements;
});

final announcementDetailProvider =
    FutureProvider.family<Announcement?, String>((ref, id) async {
  final result = await ref.watch(getAnnouncementDetailProvider).call(id);
  if (result.failure != null) throw Exception(result.failure!.message);
  return result.announcement;
});
