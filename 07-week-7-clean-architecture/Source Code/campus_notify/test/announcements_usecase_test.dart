import 'package:flutter_test/flutter_test.dart';
import 'package:campus_notify/core/failures.dart';
import 'package:campus_notify/features/announcements/domain/entities/announcement.dart';
import 'package:campus_notify/features/announcements/domain/repositories/announcement_repository.dart';
import 'package:campus_notify/features/announcements/domain/usecases/get_announcements.dart';
import 'package:campus_notify/features/announcements/domain/usecases/get_announcement_detail.dart';

class FakeAnnouncementRepository implements AnnouncementRepository {
  List<Announcement> fakeList = [
    const Announcement(id: '1', title: 'Perubahan Jadwal', body: 'Ruang A2'),
    const Announcement(id: '3', title: 'Kuliah Pengganti', body: 'Ruang LKJ'),
  ];
  bool shouldFail = false;

  @override
  Future<({List<Announcement> announcements, Failure? failure})> getAnnouncements() async {
    if (shouldFail) {
      return (announcements: const <Announcement>[], failure: const LocalFailure('Gagal memuat'));
    }
    return (announcements: fakeList, failure: null);
  }

  @override
  Future<({Announcement? announcement, Failure? failure})> getAnnouncementDetail(String id) async {
    if (shouldFail) {
      return (announcement: null, failure: const LocalFailure('Gagal memuat detail'));
    }
    final item = fakeList.firstWhere(
      (e) => e.id == id,
      orElse: () => Announcement(id: id, title: 'Item '),
    );
    return (announcement: item, failure: null);
  }
}

void main() {
  late FakeAnnouncementRepository fakeRepository;
  late GetAnnouncements getAnnouncements;
  late GetAnnouncementDetail getAnnouncementDetail;

  setUp(() {
    fakeRepository = FakeAnnouncementRepository();
    getAnnouncements = GetAnnouncements(fakeRepository);
    getAnnouncementDetail = GetAnnouncementDetail(fakeRepository);
  });

  test('GetAnnouncements usecase mengembalikan list pengumuman dengan repository palsu', () async {
    final result = await getAnnouncements.call();
    expect(result.failure, isNull);
    expect(result.announcements.length, 2);
    expect(result.announcements.first.id, '1');
    expect(result.announcements.first.title, 'Perubahan Jadwal');
  });

  test('GetAnnouncements usecase menangani failure saat repository gagal', () async {
    fakeRepository.shouldFail = true;
    final result = await getAnnouncements.call();
    expect(result.failure, isA<LocalFailure>());
    expect(result.announcements, isEmpty);
  });

  test('GetAnnouncementDetail usecase mengembalikan detail pengumuman yang sesuai', () async {
    final result = await getAnnouncementDetail.call('3');
    expect(result.failure, isNull);
    expect(result.announcement?.id, '3');
    expect(result.announcement?.body, 'Ruang LKJ');
  });
}
