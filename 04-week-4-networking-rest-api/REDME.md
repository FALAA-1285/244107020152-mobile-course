## Networking & Rest API
Tujuan pembelajaran Setelah menyelesaikan codelab ini, mahasiswa mampu::
1. Menjelaskan konsep HTTP, REST API, dan JSON.
2. memetakan JSON ke model Dart (serialization) dengan aman null.
3. menerapkan repository pattern dasar sehingga UI tidak memanggil API secara langsung.
4. mengonfigurasi Dio (base URL, timeout, interceptor) dan menangani error jaringan.
5. menampilkan state loading, error, empty, dan success pada UI dengan AsyncValue + Riverpod.P
6. menerapkan pagination dasar (infinite scroll).
---
### HTTP dan REST API
HTTP adalah protokol request–response: client mengirim request (method + URL + header + body), server membalas dengan status code + body. REST adalah gaya arsitektur yang memetakan operasi ke resource melalui URL dan method HTTP:
Berikut adalah isi dari tabel pada gambar `image_4b7774.png` yang disajikan dalam format teks Markdown:

| Method | Makna pada koleksi resource | Contoh |
| --- | --- | --- |
| GET | Membaca data (tanpa efek samping).| `GET /posts` , `GET /posts/1`<br> |
| POST| Membuat resource baru.| `POST /posts`<br> |
| PUT / PATCH | Mengganti / memperbarui sebagian resource. | `PUT /posts/1`<br> |
| DELETE | Menghapus resource. | `DELETE /posts/1`<br> |

---

### Praktikum 2: Provider dan Error Handling

Pada praktikum ini kita menerapkan **state management dengan Riverpod** dan **error handling yang ramah pengguna**. Alur utamanya:

1. **Provider & AsyncNotifier** (`lib/data/providers.dart`) — `PostListNotifier` menggunakan `AsyncNotifier<List<Post>>` dari Riverpod. Method `build()` otomatis memanggil `fetchPosts()` dari repository, sehingga UI tinggal me-watch state-nya. Method `refresh()` disediakan untuk pull-to-refresh.

2. **Pesan error ramah pengguna** — Fungsi `friendlyErrorMessage()` mengubah exception teknis (seperti `DioException`) menjadi pesan yang bisa dipahami pengguna, misalnya *"Koneksi lambat atau timeout"* atau *"Tidak dapat terhubung ke server"*, bukan pesan stack trace mentah.

3. **UI empat state** (`lib/pages/post_list_page.dart`) — Menggunakan `AsyncValue.when()` untuk menampilkan tampilan yang berbeda sesuai kondisi:
   - **Loading**: `CircularProgressIndicator` di tengah layar.
   - **Error**: Pesan ramah + tombol "Coba lagi".
   - **Empty**: Teks "Belum ada data dari server."
   - **Success**: `ListView` dengan `RefreshIndicator` untuk pull-to-refresh.

4. **Entry point** (`lib/main.dart`) — Membungkus app dengan `ProviderScope` agar seluruh widget tree bisa mengakses Riverpod provider.

**Screenshot Praktikum 2:**

![Praktikum 2 - Daftar Posts berhasil dimuat](Srceenshot/Praktikum%202.png)

![Praktikum 2 - Error saat tidak ada internet](Srceenshot/Praktikum%202%20No%20Internet.png)

![Praktikum 2 - Error saat URL salah / tidak ada internet](Srceenshot/Praktikum%202%20URL%20No%20Internet.png)

---

### Praktikum 3: Pagination Dasar (Infinite Scroll)

Pada praktikum ini kita menerapkan **pagination** agar data dari API tidak dimuat sekaligus, melainkan per halaman. JSONPlaceholder mendukung query `?_page=N&_limit=M`.

1. **Repository paginated** (`lib/data/repositories/post_repository.dart`) — Ditambahkan method `fetchPostsPage({required int page, int limit = 10})` yang mengirim query parameter `_page` dan `_limit` ke endpoint `/posts`.

2. **State & Notifier** (`lib/data/paged_posts.dart`) — `PagedPostsState` menyimpan: daftar item, halaman saat ini, status loading, flag `hasMore`, dan error. `PagedPostsNotifier` memiliki dua method utama:
   - `loadFirstPage()` — Memuat halaman pertama saat provider pertama kali dibaca.
   - `loadNextPage()` — Memuat halaman berikutnya. Dilengkapi **guard ganda**: `if (state.isLoadingMore || !state.hasMore) return;` untuk mencegah request duplikat dan menghentikan request saat data habis. Data lama tetap dipertahankan jika terjadi error.

3. **UI Infinite Scroll** (`lib/pages/paged_post_page.dart`) — Menggunakan `ScrollController` yang memicu `loadNextPage()` saat posisi scroll mencapai **200px sebelum ujung list**. Di bagian bawah list:
   - Jika masih ada data → tampilkan `CircularProgressIndicator`.
   - Jika data habis (`!hasMore`) → tampilkan teks "Semua data termuat."
   - Jika error di awal → tampilkan pesan error + tombol "Coba lagi".

**Screenshot Praktikum 3:**
![alt text](<Srceenshot/Praktikum 3.png>)
![alt text](<Srceenshot/Praktikum 3_.png>)

---

### AI Prompt Challenge: Comment Repository Layer

#### Prompt yang Digunakan

```
Buatkan repository layer Flutter untuk endpoint GET /comments?postId={id}
dari JSONPlaceholder menggunakan Dio + flutter_riverpod.
Requirements:
- Model Comment dengan fromJson aman null (postId, id, name, email, body).
- CommentRepository dengan method fetchComments(postId) + timeout 10 detik.
- AsyncNotifierProvider dengan penanganan error otomatis (AsyncError)
  dan fungsi pesan error ramah pengguna untuk timeout, connection error, 404, dan 500.
- Satu unit test untuk fromJson dengan field yang hilang.
Jelaskan setiap bagian kode dalam komentar.
```

#### Output Awal AI

AI menghasilkan 5 file:

| File | Deskripsi |
|---|---|
| `lib/data/models/comment.dart` | Model Comment dengan `fromJson` dan `toJson` |
| `lib/data/repositories/comment_repository.dart` | Repository dengan method `fetchComments(postId)` |
| `lib/data/comment_providers.dart` | Provider Riverpod untuk Comment |
| `lib/pages/comment_list_page.dart` | Halaman UI daftar komentar |
| `test/comment_test.dart` | Unit test: 5 test case termasuk edge case |

#### Perbaikan yang Dilakukan

**1. `fromJson` tidak benar-benar aman dari tipe salah**

Output awal AI menggunakan pola `as num?` (direct cast):
```dart
// SALAH Output awal AI — crash jika field bertipe salah (misal String)
postId: (json['postId'] as num?)?.toInt() ?? 0,
```

Saat diuji dengan edge case test (field bertipe salah seperti `'postId': 'bukan angka'`), hasilnya **crash** dengan error:
```
type 'String' is not a subtype of type 'num?' in type cast
```

**Perbaikan**: menggunakan pengecekan `is` sebelum cast:
```dart
// BENAR Perbaikan — aman dari tipe salah
postId: json['postId'] is num ? (json['postId'] as num).toInt() : 0,
```

**2. `FamilyAsyncNotifier` tidak tersedia di Riverpod 3**

Output awal AI menggunakan `FamilyAsyncNotifier<List<Comment>, int>` yang **tidak ada di Riverpod 3.4.3**. Ini menyebabkan **9 error** saat `flutter analyze`.

**Perbaikan**: menggunakan `FutureProvider.family` yang lebih sederhana dan kompatibel:
```dart
// SALAH Output awal — tidak ada di Riverpod 3
class CommentListNotifier extends FamilyAsyncNotifier<List<Comment>, int> { ... }

// Perbaikan — kompatibel dengan Riverpod 3.4.3
final commentListProvider = FutureProvider.family<List<Comment>, int>((ref, postId) {
  final repository = ref.watch(commentRepositoryProvider);
  return repository.fetchComments(postId);
});
```

#### AI Verification Checklist

| No | Pertanyaan Verifikasi | Hasil |
|---|---|---|
| 1 | Apakah UI memanggil Dio secara langsung (dilarang) atau lewat repository? | LOLOS. **Lewat repository** — UI hanya mengakses `commentListProvider`, tidak ada import Dio di halaman UI |
| 2 | Apakah `fromJson` aman null, atau masih memakai cast langsung yang bisa crash? | DIPERBAIKI. **Awalnya pakai `as num?` yang crash pada tipe salah**, diperbaiki menjadi pengecekan `is` |
| 3 | Apakah semua tipe `DioExceptionType` dipetakan ke pesan pengguna? | LOLOS. **Ya** — `friendlyErrorMessage()` di `providers.dart` menangani: timeout, connectionError, badResponse (404, 401/403, lainnya), dan default |
| 4 | Apakah baseUrl/timeout terpusat di satu client? | LOLOS. **Ya** — dikonfigurasi di `api_client.dart` (baseUrl + timeout 10 detik), bukan di tiap method repository |
| 5 | Apakah test menguji kasus field hilang + edge case? | LOLOS. **Ya** — 5 test: happy path, field hilang, JSON kosong, tipe field salah, dan toJson roundtrip |
| 6 | Apakah `flutter analyze` dan `flutter test` lolos? | DIPERBAIKI. **Awalnya gagal** (9 error analyze + 1 test gagal), setelah perbaikan: **No issues found** dan **All 5 tests passed** |

#### Hasil Testing

```
flutter analyze:
  Analyzing week4_api...
  No issues found! (ran in 1.0s)

flutter test test/comment_test.dart:
  00:00 +0: Comment.fromJson parsing JSON lengkap menghasilkan Comment yang benar
  00:00 +1: Comment.fromJson field yang hilang menggunakan nilai default tanpa crash
  00:00 +2: Comment.fromJson JSON kosong menghasilkan semua nilai default
  00:00 +3: Comment.fromJson tipe field salah menggunakan fallback default tanpa crash
  00:00 +4: Comment.fromJson toJson menghasilkan Map yang sesuai
  00:00 +5: All tests passed!
```

#### Kesimpulan

AI berhasil menghasilkan struktur kode yang baik (repository pattern, provider layer, UI terpisah), namun terdapat **3 masalah** yang membutuhkan perbaikan manual:
1. `fromJson` tidak benar-benar aman dari tipe field yang salah — hanya aman dari null, bukan wrong type.
2. API Riverpod yang digunakan (`FamilyAsyncNotifier`) tidak tersedia di versi 3.4.3 — AI tidak memeriksa kompatibilitas versi.
3. Doc comment mengandung angle bracket yang diinterpretasikan sebagai HTML.

**Pelajaran**: Output AI harus selalu diverifikasi dengan `flutter analyze`, `flutter test`, dan edge case testing sebelum diterima. Jangan langsung menerima kode AI tanpa menjalankan dan mengujinya.

---

### Refactoring dan Testing

#### Refactoring yang Dilakukan

**1. Ekstrak PostTile widget** (`lib/widgets/post_tile.dart`)

Baris post di dalam `ListView.builder` diekstrak menjadi widget `PostTile` tersendiri. Hal ini membuat builder lebih pendek dan widget mudah diuji secara terpisah. `PostTile` menerima parameter `post`, `onTap` (untuk navigasi ke detail), dan `showSubtitle` (opsional menampilkan body).

**2. Pindahkan friendlyErrorMessage** (`lib/data/network_errors.dart`)

Fungsi `friendlyErrorMessage()` dipindahkan dari `providers.dart` ke file terpisah `network_errors.dart`. File `providers.dart` tetap melakukan re-export agar kode lama tidak perlu diubah import-nya. Sekarang fungsi ini bisa dipakai ulang di halaman paged, non-paged, dan comment.

**3. Halaman detail post dengan GoRouter** (`lib/pages/post_detail_page.dart`)

Ditambahkan rute `/post/:id` menggunakan GoRouter. `PostDetailPage` menampilkan title dan body post secara lengkap. State detail diambil dari list yang sudah dimuat (`postListProvider`). `main.dart` diubah dari `MaterialApp` biasa menjadi `MaterialApp.router` dengan konfigurasi GoRouter:
- `/` : halaman utama (PagedPostPage)
- `/post/:id` : halaman detail post

#### Testing: Unit Test Model + Mock Repository

File `test/post_test.dart` berisi 4 test menggunakan `FakePostRepository` (repository palsu tanpa HTTP sungguhan):

| No | Test | Yang Diuji |
|---|---|---|
| 1 | `fromJson aman terhadap field yang hilang` | Parsing Post dari JSON dengan field tidak lengkap, fallback ke default |
| 2 | `friendlyErrorMessage untuk connection error` | Mapping DioException connectionError ke pesan "terhubung" |
| 3 | `provider sukses dengan repository palsu` | Override postRepositoryProvider dengan FakePostRepository, verifikasi data dimuat |
| 4 | `provider error dengan repository palsu` | Override dengan FakePostRepository yang throwError, verifikasi error tertangkap |

Pola `FakePostRepository` menggunakan override provider: tidak ada request HTTP sungguhan di dalam test. Pola ini menjadi fondasi mock API yang akan dipakai lagi di Minggu 12 (Testing & QA).

#### Hasil Testing

```
flutter analyze:
  Analyzing week4_api...
  No issues found! (ran in 1.6s)

flutter test:
  comment_test.dart: 5 tests passed (fromJson happy path, field hilang, JSON kosong, tipe salah, toJson)
  post_test.dart: 4 tests passed (fromJson, friendlyErrorMessage, provider sukses, provider error)
  Total: All 9 tests passed!
```

#### Checklist Verifikasi Mandiri

| No | Kriteria | Status |
|---|---|---|
| 1 | UI tidak memanggil Dio langsung, semua akses lewat repository + provider | Terpenuhi |
| 2 | Empat state tampil benar: loading, error (+ retry), empty, success | Terpenuhi |
| 3 | Pagination: data bertambah saat scroll, tidak ada request ganda, ada indikator akhir data | Terpenuhi |
| 4 | `flutter analyze` tanpa issue dan semua test lulus | Terpenuhi (0 issue, 9 test lulus) |
| 5 | Hasil AI diverifikasi dan didokumentasikan | Terpenuhi (lihat bagian AI Challenge di atas) |

---

### Refleksi

**1. Mengapa UI dilarang memanggil Dio langsung? Apa yang rusak jika aturan ini dilanggar?**

Karena UI seharusnya hanya menampilkan state, bukan mengurus detail jaringan. Kalau UI memanggil Dio langsung: konfigurasi (baseUrl, timeout, interceptor) dan parsing JSON tersebar di banyak widget, error handling jadi tidak konsisten, widget tidak bisa diuji tanpa HTTP sungguhan (tidak bisa override dengan `FakePostRepository`), dan jika API berubah, banyak file UI ikut diubah.

**2. Kapan pagination client-side cukup, dan kapan harus mengandalkan pagination server (`_page`/`_limit`)?**

Client-side cukup jika datanya kecil dan sudah diambil sekaligus (misalnya puluhan item statis), jadi hanya dipotong untuk tampilan. Pagination server wajib jika datanya besar atau terus bertambah, supaya tidak mengunduh semua data sekaligus, menghemat bandwidth dan memori, dan halaman pertama tampil lebih cepat.

**3. Bagaimana exception repository berubah menjadi `AsyncError` tanpa try/catch di setiap widget? Kapan try/catch eksplisit tetap dibutuhkan?**

`AsyncNotifier.build()` dan `FutureProvider` otomatis menangkap exception dari `Future` yang di-await (seperti `fetchPosts()`) lalu menyimpannya sebagai `AsyncError`. UI cukup menangani cabang `error:` di `AsyncValue.when()`. Try/catch eksplisit tetap dibutuhkan saat kita ingin mempertahankan data lama ketika error, misalnya `loadNextPage()` di pagination (list tetap tampil, error disimpan di state). Juga dibutuhkan saat aksi dipicu user (submit, delete) yang perlu menampilkan SnackBar atau retry tanpa mengganti seluruh state, atau saat perlu mengubah exception teknis menjadi exception domain.

**4. Bagian mana dari hasil AI yang Anda perbaiki, dan mengapa?**

- **`fromJson`**: `as num?` diganti pengecekan `is num` karena cast langsung crash jika tipe field salah (misal String), bukan hanya null.
- **Provider**: `FamilyAsyncNotifier` diganti `FutureProvider.family` karena API tersebut tidak ada di Riverpod 3.4.3 dan menyebabkan 9 error `flutter analyze`.
- **Doc comment**: angle bracket (`<...>`) diperbaiki karena dibaca sebagai HTML oleh analyzer.

Semua perbaikan ditemukan lewat `flutter analyze`, `flutter test`, dan edge case test. Artinya output AI tidak boleh diterima sebelum dijalankan dan diuji.