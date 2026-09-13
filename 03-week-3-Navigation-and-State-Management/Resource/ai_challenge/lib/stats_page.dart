import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// 1. Definisikan model data untuk statistik
class StatData {
  final String title;
  final String value;
  
  StatData(this.title, this.value);
  
  // Membantu pengecekan kesamaan saat unit testing
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is StatData &&
          runtimeType == other.runtimeType &&
          title == other.title &&
          value == other.value;

  @override
  int get hashCode => title.hashCode ^ value.hashCode;
}

// 2. Buat Notifier menggunakan AsyncNotifier
// AsyncNotifier digunakan karena pengambilan data API bersifat asynchronous
class StatsNotifier extends AsyncNotifier<List<StatData>> {
  
  // Fungsi dipisahkan agar mudah di-mock/di-override saat unit testing
  Future<List<StatData>> fetchStatsData() async {
    // Simulasi delay jaringan selama 2 detik
    await Future.delayed(const Duration(seconds: 2));

    // Simulasi kegagalan acak sebesar 30%
    final random = Random();
    // random.nextDouble() menghasilkan angka antara 0.0 sampai 1.0
    if (random.nextDouble() < 0.3) {
      throw Exception('Gagal mengambil data dari server');
    }

    // Jika berhasil (70% peluang), kembalikan daftar data statistik (3 item)
    return [
      StatData('Total Pengguna', '1,250'),
      StatData('Pendapatan', 'Rp 15.000.000'),
      StatData('Rating Rata-rata', '4.8/5.0'),
    ];
  }

  @override
  Future<List<StatData>> build() async {
    // Saat notifier diinisialisasi pertama kali, panggil fetchStatsData
    // Ini otomatis akan mengubah state menjadi AsyncLoading() lalu AsyncData() jika berhasil
    return fetchStatsData();
  }

  // Fungsi untuk memicu pengambilan data ulang (retry)
  Future<void> retry() async {
    // Set state ke AsyncLoading() agar UI menampilkan indikator loading kembali
    state = const AsyncValue.loading();
    // AsyncValue.guard secara otomatis menangani try-catch dan mengembalikan AsyncData atau AsyncError
    state = await AsyncValue.guard(() => fetchStatsData());
  }
}

// 3. Buat Provider untuk notifier yang sudah kita buat di atas
final statsProvider = AsyncNotifierProvider<StatsNotifier, List<StatData>>(() {
  return StatsNotifier();
});

// 4. Buat halaman UI menggunakan ConsumerWidget
// ConsumerWidget memungkinkan kita memantau dan bereaksi terhadap perubahan state di Provider
class StatsPage extends ConsumerWidget {
  const StatsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // ref.watch memantau state dari statsProvider
    // Tiap kali state berubah, widget ini akan me-rebuild secara otomatis
    final statsState = ref.watch(statsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Statistik'),
      ),
      // AsyncValue.when mewajibkan penanganan ketiga kemungkinan state:
      // data berhasil dimuat (data), error (error), dan sedang memuat (loading)
      body: statsState.when(
        // Kondisi 1: Data berhasil diambil
        data: (stats) {
          return ListView.builder(
            itemCount: stats.length,
            itemBuilder: (context, index) {
              final stat = stats[index];
              return ListTile(
                leading: const Icon(Icons.analytics),
                title: Text(stat.title),
                subtitle: Text(stat.value),
              );
            },
          );
        },
        // Kondisi 2: Terjadi error saat mengambil data
        error: (error, stackTrace) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, color: Colors.red, size: 48),
                const SizedBox(height: 16),
                Text(
                  'Terjadi Kesalahan:\n$error',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.red),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  // Memanggil fungsi retry dari notifier
                  // Menggunakan ref.read karena dipanggil dari callback (onPressed)
                  onPressed: () => ref.read(statsProvider.notifier).retry(),
                  child: const Text('Coba Lagi'),
                ),
              ],
            ),
          );
        },
        // Kondisi 3: Data sedang dimuat (atau saat sedang inisialisasi)
        loading: () {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('Memuat data statistik...'),
              ],
            ),
          );
        },
      ),
    );
  }
}
