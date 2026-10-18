import '../../../../core/failures.dart';
import '../../domain/entities/announcement.dart';
import '../../domain/repositories/announcement_repository.dart';
import '../models/announcement_model.dart';

class AnnouncementRepositoryImpl implements AnnouncementRepository {
  const AnnouncementRepositoryImpl();

  @override
  Future<({List<Announcement> announcements, Failure? failure})> getAnnouncements() async {
    try {
      final items = [
        const AnnouncementModel(
          id: '1',
          title: 'Perubahan Jadwal Kuliah',
          body: 'Kelas Pemrograman Mobile ruang A2 jam 13.00.',
        ),
        const AnnouncementModel(
          id: '3',
          title: 'Pengumuman Kuliah Pengganti',
          body: 'Kelas Mobile pindah ke Ruang LKJ jam 13.00.',
        ),
      ];
      return (
        announcements: items.map((e) => e.toEntity()).toList(),
        failure: null,
      );
    } catch (e) {
      return (
        announcements: const <Announcement>[],
        failure: LocalFailure('Gagal memuat daftar pengumuman: '),
      );
    }
  }

  @override
  Future<({Announcement? announcement, Failure? failure})> getAnnouncementDetail(String id) async {
    try {
      final item = AnnouncementModel(
        id: id,
        title: 'Detail Pengumuman #',
        body: 'Rincian pengumuman jadwal kuliah untuk ID .',
      );
      return (announcement: item.toEntity(), failure: null);
    } catch (e) {
      return (
        announcement: null,
        failure: LocalFailure('Gagal memuat detail pengumuman: '),
      );
    }
  }
}
