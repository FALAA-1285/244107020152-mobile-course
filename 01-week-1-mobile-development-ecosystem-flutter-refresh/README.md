# Week 1: Mobile Development Ecosystem & Flutter Refresh

Repositori ini berisi proyek praktikum modul pertama yang berfokus pada pengenalan ekosistem pengembangan perangkat lunak seluler menggunakan kerangka kerja Flutter, penyegaran sintaks bahasa pemrograman Dart, serta pembuatan antarmuka profil mahasiswa sederhana.

---

## Tujuan Praktikum
1. Memahami dan menyiapkan lingkungan kerja (*development ecosystem*) Flutter yang terverifikasi menggunakan `flutter doctor`.
2. Menguasai sintaks dasar pemrograman Dart, termasuk pembuatan fungsi, kelas, serta penanganan variabel opsional (*nullable*).
3. Mengganti *template* bawaan aplikasi *counter* Flutter dengan antarmuka kustom menggunakan widget dasar.
4. Memahami perbedaan dan implementasi *hot reload* dan *hot restart* dalam proses pengembangan aplikasi.
5. Menulis dan menjalankan skrip pengujian otomatis (*widget testing*) dasar.

---

## Fitur Utama
* **Halaman Profil Mahasiswa:** Antarmuka visual sederhana yang menampilkan ikon, Nama (Ahmad Falahi), NIM, keterangan minggu kuliah, serta informasi jurusan dan kampus tempat mahasiswa menempuh studi.
* **Pengujian Widget Otomatis:** Skrip *testing* terintegrasi yang memverifikasi bahwa elemen teks spesifik (Nama dan NIM) dirender dengan benar oleh aplikasi.
* **Struktur Kode Deklaratif:** Penggunaan widget dasar (seperti `Scaffold`, `AppBar`, `Column`, `Icon`, `Text`, dan `SizedBox`) untuk menyusun hierarki antarmuka secara rapi.

---

## Stack Teknologi
* **Bahasa Pemrograman:** Dart
* **Framework:** Flutter (Channel stable)
* **Peralatan Bantu:** Visual Studio Code, Git, dan Flutter CLI
* **Target Perangkat Uji:** Windows Desktop dan Web (Chrome/Edge)

---

## Cara Menjalankan Aplikasi
1. Buka terminal lalu arahkan direktori ke dalam folder proyek ini
2. Jalankan aplikasi pada perangkat yang tersedia (flutter run)

## Hasil yang Dicapai & Evaluasi Praktikum

Berdasarkan praktikum dan *mini assignment* yang telah didokumentasikan, berikut adalah pencapaian proyek ini:

### 1. Checklist Verifikasi Lingkungan
* **`flutter doctor`:** Tidak mendeteksi adanya masalah (*No issues found!*). Seluruh komponen, termasuk *Android toolchain* (versi 36.0.0), Windows, dan lisensi telah terverifikasi.
* **`flutter devices`:** Sukses mendeteksi target perangkat keras/lunak yang siap digunakan untuk *debugging* (Windows-x64, Chrome, dan Edge).

### 2. Implementasi Antarmuka (UI)
* Aplikasi berhasil dibangun dengan struktur UI kustom secara deklaratif menggunakan perpaduan widget dasar (`Scaffold`, `AppBar`, `Column`, `Icon`, `Text`, dan `SizedBox`). *Template* aplikasi bawaan telah berhasil digantikan sepenuhnya.

### 3. Analisis Performa: Hot Reload vs Hot Restart
Berdasarkan log terminal saat percobaan pengembangan:
* **Hot Reload (~115 ms):** Memproses pembaruan dengan sangat cepat karena hanya menyuntikkan perubahan kode antarmuka (UI) secara instan ke dalam mesin virtual tanpa mereset *state* atau memori data aplikasi.
* **Hot Restart (~294 ms):** Membutuhkan waktu sedikit lebih lama karena harus memuat ulang fungsi utama `main()` secara keseluruhan. Diperlukan untuk mereset *state*, menginisialisasi ulang variabel global, atau memuat aset/pustaka baru.

### 4. Hasil Pengujian Otomatis (*Testing*)
Hasil eksekusi `flutter test` menunjukkan output **`00:06 +1: All tests passed!`**, membuktikan bahwa seluruh elemen *widget* berhasil diverifikasi tanpa *error*.
   