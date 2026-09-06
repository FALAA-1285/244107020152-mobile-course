# week 2 declarative ui responsive designDashboard
### Widget dasar
- `StatelessWidget` cocok untuk UI yang output-nya ditentukan oleh konfigurasi dari parent.
- `StatefulWidget` memiliki objek State untuk data yang dapat berubah selama lifecycle.
- `Container` menggabungkan ukuran, padding, margin, decoration, dan child.
- `Row` menyusun child secara horizontal, sedangkan Column secara vertikal.
- `Expanded` membagi ruang yang tersedia di dalam Row atau Column.

---
### Praktikum : Layout Sederhana (Warm-up)
#### Tujuan
- Memahami Penggunaan `Expanded` pada `Row`: Mengetahui bagaimana widget `Expanded` mendistribusikan ruang yang tersedia secara fleksibel.
- Memahami Pengaturan Ukuran (`mainAxisSize`): Perbedaan antara `MainAxisSize.min` (membuat tinggi/lebar kontainer menyesuaikan isi di dalamnya) dengan nilai defaultnya, yaitu `MainAxisSize.max` (membuat kontainer memenuhi ruang vertikal yang tersedia di induknya).
- Komposisi Widget Dasar: `Container`, `Column`, `Row`, `CircleAvatar`, dan `Text` untuk membangun antarmuka pengguna yang terstruktur rapi.[cite: 2]

### Hasil Run
![alt text](/02-week-2-declarative-ui-responsive-design/screenshoots/WarmUp.jpeg)
![alt text](/02-week-2-declarative-ui-responsive-design/screenshoots/WarmUp2.jpeg)
---
### Praktikum: Dashboard Responsif

#### Tujuan
- Memanfaatkan widget `LayoutBuilder` dan `GridView.count` untuk mengatur jumlah kolom secara dinamis berdasarkan lebar layar[cite: 2]
- Mengubah widget dari `StatelessWidget` menjadi `StatefulWidget` guna menyimpan dan mengontrol status aktif aplikasi, seperti pengaturan mode tema terang atau gelap[cite: 2]
- Mengenal dan mempraktikkan penggunaan `CupertinoSwitch` (gaya iOS) di dalam aplikasi berbasis Material Design, serta memahami cara meneruskan fungsi callback antar-widget.[cite: 2]
- Memahami pentingnya penambahan label `Semantics` agar elemen penting pada antarmuka dapat dibaca dengan baik oleh screen reader[cite: 2]

#### Hasil Run
![alt text](/02-week-2-declarative-ui-responsive-design/screenshoots/PraktikumLight.jpeg)
![alt text](/02-week-2-declarative-ui-responsive-design/screenshoots/PraktikumDark.jpeg)
![alt text](/02-week-2-declarative-ui-responsive-design/screenshoots/PraktikumLightDesktop.jpeg)
![alt text](/02-week-2-declarative-ui-responsive-design/screenshoots/PraktikumDarkDesktop.jpeg)
---
### Tugas dan AI design exploration
##### Tugas utama
Kembangkan dashboard menjadi halaman Academic Overview dengan ketentuan:
- Memiliki header profil dan minimal empat kartu informasi.
- Menggunakan Row, Column, Expanded, dan Container.
- Menampilkan satu kolom pada layar sempit dan dua kolom pada layar lebar.
- Menyediakan light theme dan dark theme yang tetap terbaca, dengan toggle tema (misal CupertinoSwitch atau Switch.adaptive).
- Memiliki label aksesibilitas untuk informasi atau tombol penting.
- Menyertakan screenshot layar sempit dan lebar pada folder screenshots/.

##### Hasil Run
![alt text](/02-week-2-declarative-ui-responsive-design/screenshoots/TugasLight.jpeg)
![alt text](/02-week-2-declarative-ui-responsive-design/screenshoots/TugasDark.jpeg)

### Refactoring challenge
Setelah tugas utama berjalan, rapikan kode Anda:

- Ekstrak kartu informasi menjadi widget reusable (misal InfoCard) yang menerima title dan value, sehingga tidak ada duplikasi widget.
- Ganti warna dan ukuran yang di-hardcode dengan Theme.of(context) agar mengikuti tema terang/gelap secara otomatis.
- Pindahkan breakpoint ke satu konstanta bernama (misal const kWideBreakpoint = 700;) agar hanya didefinisikan satu kali.
- Jalankan flutter analyze dan pastikan tidak ada error maupun warning baru.

##### Hasil Run
![alt text](/02-week-2-declarative-ui-responsive-design/screenshoots/RefactoringLight.jpeg)
![alt text](/02-week-2-declarative-ui-responsive-design/screenshoots/RefactoringDark.jpeg)

### Refleksi
1. Apa perbedaan cara berpikir imperative dan declarative saat membangun UI?
Imperatif mengubah UI secara manual langkah demi langkah. Deklaratif membiarkan framework memperbarui UI secara otomatis saat state (data) berubah.

2. Kapan Expanded membantu dan kapan penggunaannya justru menghasilkan layout error?
Membantu mendistribusikan sisa ruang pada wadah dengan batas pasti (bounded) seperti Row atau Column. Akan menyebabkan error (overflow) jika diletakkan di wadah tanpa batas (unbounded) seperti SingleChildScrollView.

3. Bagaimana breakpoint dan theme memengaruhi pengalaman pengguna?
Breakpoint mengadaptasi tata letak agar tetap proporsional dari layar sempit hingga lebar. Theme menjaga konsistensi kontras, keterbacaan, dan kenyamanan visual pengguna (misal: perpindahan ke Dark Mode).

4. Apa yang Anda verifikasi dari rekomendasi AI setelah tugas inti selesai?
Memastikan tidak ada kode usang (deprecated), menguji tata letak pada ukuran layar dan font ekstrem, memvalidasi penggunaan widget bawaan Flutter, serta mengecek keakuratan label Semantics untuk aksesibilitas.