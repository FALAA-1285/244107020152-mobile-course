import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ai_challenge/stats_page.dart'; // Pastikan sesuai dengan nama package di pubspec.yaml

// Mock class untuk mengontrol hasil fetch agar bisa mensimulasikan sukses (tanpa delay/acak)
class MockStatsNotifierSuccess extends StatsNotifier {
  @override
  Future<List<StatData>> fetchStatsData() async {
    // Kembalikan data secara instan
    return [
      StatData('Test', '100'),
    ];
  }
}

// Mock class untuk mensimulasikan kegagalan (error)
class MockStatsNotifierError extends StatsNotifier {
  @override
  Future<List<StatData>> fetchStatsData() async {
    // Lemparkan exception secara instan
    throw Exception('Simulasi error jaringan');
  }
}

// Mock class untuk mensimulasikan logika dinamis pada retry
class MockStatsNotifierRetry extends StatsNotifier {
  final List<StatData> Function() onFetch;

  MockStatsNotifierRetry({required this.onFetch});

  @override
  Future<List<StatData>> fetchStatsData() async {
    return onFetch();
  }
}

void main() {
  group('StatsNotifier Unit Tests', () {
    test('State awal harus AsyncData jika pengambilan data berhasil', () async {
      final container = ProviderContainer(
        overrides: [
          statsProvider.overrideWith(() => MockStatsNotifierSuccess()),
        ],
      );
      addTearDown(container.dispose);

      final listener = container.listen(statsProvider, (_, _) {});
      
      // Beri waktu bagi Future untuk selesai
      await Future.delayed(const Duration(milliseconds: 100));

      final state = container.read(statsProvider);
      expect(state.hasValue, true);
      expect(state.value, [StatData('Test', '100')]);
      
      listener.close();
    });

    test('State harus memiliki error jika pengambilan data gagal', () async {
      final container = ProviderContainer(
        overrides: [
          statsProvider.overrideWith(() => MockStatsNotifierError()),
        ],
      );
      addTearDown(container.dispose);

      final listener = container.listen(statsProvider, (_, _) {});

      // Beri waktu bagi event loop untuk menangani eksepsi asinkron
      await Future.delayed(const Duration(milliseconds: 100));

      final state = container.read(statsProvider);
      // Pada Riverpod 2.x, error saat inisialisasi menghasilkan state yang .hasError bernilai true
      expect(state.hasError, true);
      expect(state.error.toString(), contains('Simulasi error jaringan'));
      
      listener.close();
    });

    test('Fungsi retry mengubah state dari error menjadi data jika kali kedua berhasil', () async {
      int callCount = 0;
      final container = ProviderContainer(
        overrides: [
          statsProvider.overrideWith(() => MockStatsNotifierRetry(
            onFetch: () {
              callCount++;
              if (callCount == 1) {
                throw Exception('Gagal pertama kali');
              }
              return [StatData('Retry Sukses', '200')];
            }
          )),
        ],
      );
      addTearDown(container.dispose);

      final listener = container.listen(statsProvider, (_, _) {});
      
      // Tunggu inisialisasi awal yang akan gagal
      await Future.delayed(const Duration(milliseconds: 100));
      
      var state = container.read(statsProvider);
      expect(state.hasError, true);

      // Panggil fungsi retry dan tunggu selesai
      final notifier = container.read(statsProvider.notifier);
      await notifier.retry();

      // Beri waktu untuk memastikan state ter-update
      await Future.delayed(const Duration(milliseconds: 100));

      state = container.read(statsProvider);
      expect(state.hasValue, true);
      expect(state.value, [StatData('Retry Sukses', '200')]);
      
      listener.close();
    });
  });
}
