# ToDo App - Minggu 3 (Navigation & State Management)

Ini adalah proyek mini untuk mensimulasikan pengembangan aplikasi *ToDo* berskala industri dengan implementasi *Navigation* dan *State Management*.

## Fitur
1. **Navigasi GoRouter**: Memiliki dua rute utama `/` (Daftar Tugas) dan `/stats` (Statistik Tugas), diatur menggunakan `ShellRoute` dan `NavigationBar`.
2. **State Management Riverpod**: Menggunakan `AsyncNotifierProvider` untuk mensimulasikan asinkronisitas, serta `Provider` turunan (`uncompletedTodosProvider` dan `completedTodosProvider`) untuk menyaring data secara reaktif.
3. **Penanganan AsyncValue UI**: Menggunakan metode `.when(data: ..., loading: ..., error: ...)` sehingga status pengambilan data yang asinkron dapat divisualisasikan dengan `CircularProgressIndicator` ataupun pesan _Error_.
4. **Widget Testing**: Dilengkapi dengan pengujian UI untuk _flow_ penambahan tugas yang mematuhi simulasi `AsyncValue` (penggunaan `pumpAndSettle`).

---

## 🤖 AI Challenge Documentation

Bagian ini mendokumentasikan proses _AI Challenge_ yang telah dilakukan untuk memenuhi persyaratan integrasi asinkron dan verifikasi mandiri.

### 1. Prompt yang Digunakan
**Prompt Awal**:
> "Pisahkan widget bar ToDo menjadi TodoTile tersendiri agar build lebih pendek dan mudah diuji.
Ekstrak logika filter (misal tampilkan hanya yang belum selesai) menjadi Provider turunan yang membaca todoListProvider.
Integrasikan aplikasi ToDo dengan GoRouter: / untuk daftar dan /stats untuk halaman statistik, tambahkan NavigationBar untuk berpindah."

**Prompt Lanjutan (Async Challenge)**:
> "Mini project / Industry Challenge
Bangun aplikasi ToDo dengan navigasi dan Riverpod sebagai tugas minggu ini:
Minimal 2 halaman dengan GoRouter: daftar tugas, halaman detail/statistik.
State dikelola Riverpod (Notifier), UI menggunakan ConsumerWidget.
Tambahkan fitur simulasi asinkron dengan AsyncValue: state loading, error, dan success tampil dengan benar.
Sertakan minimal 1 unit/widget test yang lulus.
Kerjakan bagian AI Challenge dan dokumentasikan prompt, hasil AI, perbaikan, serta alasan keputusan teknis Anda."

### 2. Hasil AI & Perbaikan (Before vs After)

- **Sebelumnya**: State management dikelola menggunakan _synchronous_ `Notifier<List<Todo>>`. Saat pengguna menekan *toggle* atau tombol *tambah*, perubahan langsung diterapkan pada UI. Pemfilteran dilakukan pada `todo_page.dart` atau mengandalkan _provider_ sinkron.
- **Hasil AI (Setelah Iterasi)**:
  1. `Notifier<List<Todo>>` direfaktor menjadi `AsyncNotifier<List<Todo>>` untuk menyimulasikan lingkungan _real-world_ (memanggil API/Database).
  2. _Method mutation_ (`add`, `toggleTodo`, `removeTodo`) dimodifikasi dengan penambahan delay `Future.delayed`, yang mengembalikan objek `AsyncValue.loading()` sementara memproses permintaan, lalu me-return _list_ baru menggunakan pembungkus `AsyncValue.guard`.
  3. Provider turunan seperti `uncompletedTodosProvider` memproses properti _AsyncValue_ dengan `whenData(...)`. 
  4. Perbaikan _compilation error_ tipe *List* (dari dinamik menjadi `List<Todo>`) dan penggantian fungsi getter menjadi `state.value` dilakukan seiring dengan ketatnya tipe yang diterapkan Riverpod.

### 3. Alasan Keputusan Teknis
- **Penggunaan AsyncNotifier vs FutureProvider**: Menggunakan `AsyncNotifier` diputuskan jauh lebih *scalable* daripada `FutureProvider` karena memungkinkan kemudahan operasi _mutation_ (menambah, mengubah, menghapus) pada _state_ yang dinamis. 
- **Menggunakan `todos.when` pada Level Halaman (UI)**: Disematkan langsung di dalam *body Scaffold* di `todo_page.dart` dan `stats_page.dart` sehingga _widget tree_ bisa langsung menyesuaikan diri (me-return _Loading Indicator_) ketika operasi _asynchronous_ diaktifkan.
- **Modifikasi Test Environment**: Di dalam pengujian UI (`widget_test.dart`), panggilan `await tester.pumpAndSettle(const Duration(seconds: 1));` sengaja ditambahkan agar tes menunggu selesainya jeda inisialisasi _loading_ awal (1 detik) sebelum memeriksa status data `find.text('Belum ada tugas')`. Tanpa transisi ini, tes akan gagal karena layar hanya berisikan `CircularProgressIndicator`.
