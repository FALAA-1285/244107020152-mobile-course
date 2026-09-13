# Navigation adn State Management
Tujuan pembelajaran
Setelah menyelesaikan codelab ini, mahasiswa mampu:
1. menjelaskan konsep navigasi, route, dan perbedaan Navigator 1.0 dengan GoRouter;
2. menerapkan navigasi multi-page dengan GoRouter, termasuk passing argument dan deep link sederhana;
3. menjelaskan mengapa state management diperlukan dan cara kerja Riverpod (Provider, ConsumerWidget, Notifier);
4. menggunakan AsyncValue untuk menangani state loading, error, dan success pada UI;
5. membangun aplikasi ToDo dengan navigasi dan Riverpod, lalu memverifikasi hasilnya dengan widget test sederhana.

---
### Praktikum 1 Aplikasi multi-page dengan GoRouter
#### GoRouter
GoRouter adalah router deklaratif yang direkomendasikan Flutter. Konsep utamanya:
| Konsep | Penjelasan |
|---|---|
| `GoRoute` | Definisi path dan widget tujuan, misal `/`, `/detail/:id`. |
| `context.go()` | Pindah route (mengganti stack, cocok untuk redirect login). |
| `context.push()` | Tumpuk route baru di atas stack (cocok untuk detail). |
| `path parameter` | Nilai dinamis pada path, diakses lewat `state.pathParameters`. |
| `extra` | Mengirim objek antar route (gunakan hati-hati, tidak tersimpan saat proses restart web). |
| `redirect` | Guard navigasi terpusat, misal cek status login. |

#### Hasil Run
![alt text](/03-week-3-Navigation-and-State-Management/screenshots/Praktikum1.jpeg)
![alt text](/03-week-3-Navigation-and-State-Management/screenshots/Praktikum1_Detail.jpeg)

#### Hasil Pengamatan 
Penggunaan go_router membuat manajemen navigasi aplikasi Flutter menjadi lebih terstruktur dan berbasis URL (URL-driven). Pemisahan antara UI (Halaman Home & Detail) dengan logika routing (di main.dart) membuat codebase menjadi lebih rapi, terpusat, dan sangat siap untuk diimplementasikan ke platform Web atau aplikasi yang membutuhkan deep link.

---
### Praktikum 2 Aplikasi ToDo dengan Riverpod

#### State Management
State management adalah pola pengelolaan data yang memindahkan state keluar dari *widget tree* agar mudah dibagikan antar halaman tanpa kerumitan *prop drilling*. Konsep utamanya:
* **Konsistensi UI:** Antarmuka dapat dibangun ulang dari sumber state yang sama secara konsisten (UI deklaratif = f(state)).
* **Pengujian Mudah:** Logika bisnis dan state dapat diuji secara independen tanpa perlu membangun UI.
* **Persistensi Data:** State tetap hidup dan menyimpan nilai terakhirnya meskipun widget sudah tidak tampil di layar.

#### Riverpod
Riverpod adalah *state management* yang bersifat *compile-safe*, tidak bergantung pada `BuildContext`, dan mudah diuji. Konsep utamanya:

| Konsep | Penjelasan |
| :--- | :--- |
| **ProviderScope** | Wadah global yang menyimpan semua provider, membungkus root aplikasi. |
| **Provider** | Nilai *read-only* atau *immutable* (misal konfigurasi, service). |
| **Notifier + NotifierProvider** | State yang bisa berubah melalui *method*; UI memanggil *method*, bukan mengubah state langsung. |
| **ConsumerWidget** | Widget yang bisa membaca provider lewat objek `ref`. |
| **ref.watch vs ref.read** | **`ref.watch`**: *Build* ulang saat state berubah (digunakan di dalam *method* `build`).<br>**`ref.read`**: Sekali baca tanpa berlangganan (digunakan di *callback* atau *event*). |

#### Hasil run
![alt text](/03-week-3-Navigation-and-State-Management/screenshots/Praktikum2.png)
![alt text](/03-week-3-Navigation-and-State-Management/screenshots/Praktikum2_.png)
---

### Praktikum 3 AsyncValue: loading, error, success
#### AsyncValue
Banyak state di dalam aplikasi berasal dari proses asinkron (seperti memanggil API eksternal atau membaca database lokal). Mengelola status asinkron secara manual menggunakan banyak variabel boolean (seperti `isLoading` dan `hasError`) rawan menyebabkan *bug* dan *state* yang tidak konsisten. 

Riverpod menyelesaikan permasalahan ini melalui tipe `AsyncValue<T>`, yang memodelkan ketiga kondisi tersebut ke dalam satu tipe data yang aman (*compile-safe*):

| Konsep | Penjelasan |
| :--- | :--- |
| **AsyncLoading** | State saat proses asinkron sedang berjalan. Pada sisi UI, ini ditangani di dalam *callback* `loading:` (biasanya menampilkan indikator *loading*). |
| **AsyncError** | State saat proses asinkron mengalami kegagalan atau melempar *exception*. Ditangani di *callback* `error:` (biasanya menampilkan pesan gagal dan tombol *retry*). |
| **AsyncData** | State saat proses asinkron berhasil diselesaikan dan data siap. Ditangani di *callback* `data:` (merender data ke dalam UI, misal ke dalam *ListView*). |
| **ref.invalidate()** | Membuang (*dispose*) state yang lama dan memaksa provider untuk me-restart *method* pembentukannya. Sangat berguna untuk mengimplementasikan fitur "Coba lagi" atau *pull-to-refresh*. |

#### Hasil run
![alt text](/03-week-3-Navigation-and-State-Management/screenshots/Praktikum3.png)
![alt text](/03-week-3-Navigation-and-State-Management/screenshots/Praktikum3_.png)
---
### AI Challenge
#### 1. Prompt Awal
```text
Buatkan halaman Flutter bernama StatsPage menggunakan flutter_riverpod.
Requirements:
- ConsumerWidget dengan satu AsyncNotifierProvider yang mensimulasikan
  pengambilan data statistik (delay 2 detik, kadang gagal 30%).
- UI harus menangani loading (spinner), error (pesan + tombol retry),
  dan success (ListView 3 item).
- Berikan unit test untuk notifier-nya.
Jelaskan setiap bagian kode dalam komentar.
```

#### 2. Output Awal AI
AI merespons dengan meng-install paket `flutter_riverpod` dan men-_generate_ dua file baru, yaitu:
- **`lib/stats_page.dart`**: Implementasi model `StatData`, kelas `StatsNotifier` (turunan `AsyncNotifier`) yang memiliki _method_ tersendiri untuk _fetch_ API tersimulasi, serta widget UI (`ConsumerWidget`) yang mengelola fungsionalitas UI _loading_, _error_, dan _success data list_ menggunakan pola _pattern matching_ `.when()`.
- **`test/stats_page_test.dart`**: Sebuah kerangka _unit test_ awal menggunakan `ProviderContainer` milik Riverpod yang mengujicobakan 3 kondisi: data sukses dimuat, pengambilan data gagal dilempar via Mock, serta mekanisme *retry* ketika terjadi _error_. 

Pada versi awal tes ini, asersi menggunakan _type checking_ statis seperti `isA<AsyncError<List<StatData>>>()` dan kode mengeksekusi asersi dengan me-_wait_ properti masa depan _provider_-nya, contoh: `await container.read(statsProvider.future)`.

#### 3. Perbaikan yang Dilakukan
Ketika tes awal dijalankan, ditemukan galat bertipe `TimeoutException` yang membuat _test_ menjadi _hang_. Hal ini karena mekanisme internal `flutter_test` menelan _unhandled exception_ ketika melakukan eksekusi asynchronous yang dikelola oleh _future_ bawaan Riverpod. Saya lantas melakukan serangkaian _troubleshooting_ dan mengaplikasikan perbaikan berikut:

1. **Perubahan Metode Pengecekan Error:** Pada Riverpod 2.0, ketika _error_ terjadi di waktu _build_ (inisialisasi), _state_ internal bisa berwujud `AsyncLoading` dengan memuat `.error` di dalamnya (sehingga pengecekan `isA<AsyncError>` menjadi salah secara struktur). Solusinya adalah mengubah asersi menjadi `expect(state.hasError, true)` dan `expect(state.hasValue, true)`.
2. **Pencegahan Timeout di Flutter Test:** Menghilangkan baris `await container.read(statsProvider.future);` pada skenario yang dijamin terjadi _error_, karena ini menghentikan sisa kode dari mengeksekusi tes secara normal pada lingkungan _test_. Sebagai gantinya, diberikan pemicu _listener_ untuk membangun _provider_, lalu ditunggu secukupnya dengan `await Future.delayed(const Duration(milliseconds: 100));` agar _event loop_ sempat menyelesaikan _microtask_-nya tanpa membuat _test_-nya bergantung selamanya pada _exception_.

#### 4. Hasil Testing
Setelah perbaikan tes diaplikasikan, `flutter test test/stats_page_test.dart` memunculkan hasil yang stabil dan sukses sebagai berikut:

```text
00:00 +0: loading C:/Coolyeah/Semester 5/Pemrograman-Mobile/244107020152-mobile-course/03-week-3-Navigation-and-State-Management/Resource/ai_challenge/test/stats_page_test.dart
00:00 +0: StatsNotifier Unit Tests State awal harus AsyncData jika pengambilan data berhasil
00:00 +1: StatsNotifier Unit Tests State harus memiliki error jika pengambilan data gagal
00:00 +2: StatsNotifier Unit Tests Fungsi retry mengubah state dari error menjadi data jika kali kedua berhasil
00:00 +3: All tests passed!
```
#### Verifikasi Implementasi AI (Checklist Riverpod)

- **Apakah state diubah secara immutable?** Ya, state diubah dengan meng-assign _instance_ baru (misalnya `state = const AsyncValue.loading()` dan `state = await AsyncValue.guard(...)`) tanpa melakukan mutasi variabel internal secara langsung (seperti metode `.add()`).
- **Apakah ref.watch hanya dipakai di dalam build, dan ref.read di callback?** Ya, pemantauan state (`ref.watch(statsProvider)`) dipanggil langsung dalam metode `build()` pada `StatsPage`, sedangkan fungsi pemicu (`ref.read(statsProvider.notifier).retry()`) secara eksklusif ditempatkan di dalam _callback_ tombol `onPressed`.
- **Apakah ketiga state AsyncValue benar-benar ditangani?** Ya, melalui `.when()`, UI dengan sadar merespons ketiga kondisi state tanpa terlewat: `data:` menampilkan ListView, `error:` merender pesan dan opsi `retry`, dan `loading:` memutar _spinner_ `CircularProgressIndicator`.
- **Apakah provider dideklarasikan dengan tipe eksplisit dan tidak duplikat?** Ya, variabel global memuat spesifikasi tipe generik yang eksplisit `AsyncNotifierProvider<StatsNotifier, List<StatData>>`, dan tidak tercampur / diduplikasi fungsinya.
- **Apakah kode AI memakai API Riverpod versi lama?** Tidak. Implementasinya modern; 100% menggunakan arsitektur Riverpod 2.x dengan `AsyncNotifier` (bukan pewaris tua `StateNotifier` apalagi pola _antipattern_ `StateProvider`) beserta widget reaktif masa kini `ConsumerWidget`.
- **Jalankan flutter analyze dan flutter test, apakah hasil AI lolos tanpa warning?** Ya. Sempat ada warning analitik yaitu `unnecessary_underscores` pada sintaksis penangkapan observer `(_, __)` di Unit Test, yang akhirnya telah diperbaiki menjadi `(_, _)`. `flutter analyze` lantas lolos bersih, begitu juga dengan evaluasi akhir `flutter test` yang mencetak "All tests passed!".
---
### Refactoring dan testing

Lakukan refactoring berikut pada aplikasi ToDo Anda, lalu commit dengan pesan yang jelas:
1. Pisahkan widget bar ToDo menjadi TodoTile tersendiri agar build lebih pendek dan mudah diuji.
2. Ekstrak logika filter (misal tampilkan hanya yang belum selesai) menjadi Provider turunan yang membaca todoListProvider.
3. Integrasikan aplikasi ToDo dengan GoRouter: / untuk daftar dan /stats untuk halaman statistik, tambahkan NavigationBar untuk berpindah.
#### Hasil Run
![alt text](/03-week-3-Navigation-and-State-Management/screenshots/Refactoring.jpeg)
![alt text](/03-week-3-Navigation-and-State-Management/screenshots/Refactoring_.jpeg)
#### Hasil Testing
```text
PS C:\Coolyeah\Semester 5\Pemrograman-Mobile\244107020152-mobile-course\03-week-3-Navigation-and-State-Management\Resource\todo> flutter analyze
Analyzing todo...                                                       
No issues found! (ran in 2.8s)
PS C:\Coolyeah\Semester 5\Pemrograman-Mobile\244107020152-mobile-course\03-week-3-Navigation-and-State-Management\Resource\todo> flutter test
00:02 +1: All tests passed!
```
---
### Tugas, refleksi, dan referensi

Bangun aplikasi ToDo dengan navigasi dan Riverpod sebagai tugas minggu ini:
1. Minimal 2 halaman dengan GoRouter: daftar tugas, halaman detail/statistik.
State dikelola Riverpod (Notifier), UI menggunakan ConsumerWidget.
2. Tambahkan fitur simulasi asinkron dengan AsyncValue: state loading, error, dan success tampil dengan benar.
3. Sertakan minimal 1 unit/widget test yang lulus.
4. Kerjakan bagian AI Challenge dan dokumentasikan prompt, hasil AI, perbaikan, serta alasan keputusan teknis Anda.
5. Push ke repository portfolio pada folder 03-week-3-navigation-state-management/ dengan struktur lib/, test/, README.md, dan screenshots/. README menjelaskan tujuan, fitur utama, stack teknologi, cara menjalankan, dan hasil yang dicapai.

#### Hasil Run
![alt text](/03-week-3-Navigation-and-State-Management/screenshots/Refactoring.jpeg)
![alt text](/03-week-3-Navigation-and-State-Management/screenshots/Refactoring_.jpeg)
#### Hasil Testing
````text
PS C:\Coolyeah\Semester 5\Pemrograman-Mobile\244107020152-mobile-course\03-week-3-Navigation-and-State-Management\Resource\todo> flutter test
00:02 +1: All tests passed!
````

### Refleksi
- **Kapan setState masih cukup, dan kapan state harus naik ke Riverpod?**
setState: Buat hal sepele yang cuma ngaruh di satu halaman itu saja. Contoh: efek warna tombol saat ditekan, atau buka-tutup menu dropdown.
Riverpod: Buat data penting yang dipakai nyambung ke banyak halaman. Contoh: keranjang belanja, data profil user, atau daftar ToDo (karena dipakai di halaman utama dan halaman statistik).
- **Apa perbedaan context.go dan context.push, dan kapan masing-masing tepat digunakan?**
context.go: Kayak "lompat" ke menu baru. Biasanya buat pindah tab utama. Kalau pakai ini, pengguna tidak bisa pencet tombol "Back/Kembali" ke tab sebelumnya.
context.push: Kayak "numpuk" halaman baru di atas halaman lama. Biasanya buat buka rincian tugas. Pengguna bisa pencet tombol "Back/Kembali" ke halaman sebelumnya.
- **Bagaimana AsyncValue mencegah bug dibanding tiga boolean terpisah?**
Kalau bikin 3 status terpisah, aplikasi kadang bisa eror/bingung karena gak sengaja berstatus "lagi loading, tapi juga lagi error". Nah, AsyncValue ibarat saklar kipas angin: statusnya pasti cuma bisa salah satu (Loading SAJA, Error SAJA, atau Sukses SAJA). Nggak mungkin bentrok.
- **Bagian mana dari hasil AI yang Anda perbaiki, dan mengapa?**
Tipe Data: Memperjelas bentuk data ke aplikasi agar tidak bingung membedakan mana teks biasa dan mana bentuk tugas (ToDo).
Kata Kunci: Memperbaiki kata kunci penarik data (valueOrNull diubah jadi .value) karena sistem Riverpod versi ini punya aturan penamaan yang beda.