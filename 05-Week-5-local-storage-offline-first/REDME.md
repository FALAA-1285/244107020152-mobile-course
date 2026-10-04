# Local Storage & Offline-First
Tujuan pembelajaran
Setelah menyelesaikan codelab ini, mahasiswa mampu:
1. menjelaskan perbedaan penyimpanan key-value, relasional, dan NoSQL di perangkat;
2. menyimpan preferensi sederhana (tema, terakhir dibuka) dengan SharedPreferences;
3. menerapkan CRUD catatan dengan SQLite (sqflite) melalui repository lokal;
4. menerapkan pola offline-first: cache-first read, dirty flag, dan antrean sinkronisasi;
5. menampilkan state loading, error, empty, dan success untuk data lokal dengan Riverpod;
6. menguji repository lokal dengan repository palsu (tanpa database sungguhan).

---
### Konsep Local Storage dan Offline-First

#### Jenis Penyimpanan Lokal

Aturan praktis memilih storage:

| Kebutuhan | Pilihan | Contoh |
|---|---|---|
| Pengaturan kecil key-value | SharedPreferences | tema gelap/terang, bahasa, waktu terakhir dibuka |
| Data terstruktur relasional | SQLite via sqflite | catatan, tugas, transaksi |
| NoSQL ringan embedded | Hive | cache objek, kotak (box) sederhana |
| Relasional reaktif & type-safe | Drift | aplikasi besar dengan query kompleks + stream |

Codelab ini memakai **SharedPreferences + SQLite (sqflite)**: kombinasi paling umum di industri untuk aplikasi offline notes.

**Mengapa tidak simpan semuanya di SharedPreferences?** SharedPreferences hanya untuk nilai primitif kecil. Menyimpan daftar catatan sebagai satu string JSON di sana membuat query, update parsial, dan sinkronisasi menjadi rapuh dan lambat. Data koleksi selalu masuk database.

#### Offline-First, Bukan Offline-Only

Offline-first berarti aplikasi selalu bisa dibaca dan ditulis meski tanpa internet, lalu disinkronkan saat koneksi kembali. Tiga mekanisme intinya:

1. **Cache-first read**: tampilkan data lokal seketika, lalu refresh dari jaringan di background dan simpan hasilnya.
2. **Dirty flag**: setiap perubahan lokal yang belum terkirim ditandai (`dirty = 1`) agar bisa di-sync belakangan.
3. **Antrean sinkronisasi**: operasi tertunda diproses berurutan saat online; konflik diselesaikan dengan aturan eksplisit (misalnya last-write-wins berdasarkan `updated_at`).


#### Repository untuk Data Lokal

Aturan arsitektur yang sama seperti Minggu 4 tetap berlaku, hanya sumber datanya berubah:

- **UI tidak boleh** memanggil SQLite/SharedPreferences secara langsung. UI hanya membaca provider.
- **Repository lokal** adalah satu-satunya pintu ke database dan preferensi. Ia mengubah exception platform menjadi kegagalan bermakna bagi UI.
- **Provider Riverpod** mengekspos `AsyncValue` (loading/error/data) dan fungsi invalidate untuk refresh.

---
### Praktikum
#### Hasil run:
![alt text](<screenshots/Screenshot 2026-10-04 212247.png>)
![alt text](<screenshots/Screenshot 2026-10-04 212418.png>)
![alt text](<screenshots/Screenshot 2026-10-04 212551.png>)
![alt text](<screenshots/Screenshot 2026-10-04 212650.png>)
![alt text](<screenshots/Screenshot 2026-10-04 212713.png>)
![alt text](<screenshots/Screenshot 2026-10-04 212731.png>)

---
### AI Challenge
#### 1. Prompt Awal
```text
Aplikasi Flutter Offline Notes: CRUD catatan + preferensi tema. Bandingkan SharedPreferences, Hive, sqflite (SQLite), dan Drift untuk dua kebutuhan ini. Requirements: - Kriteria: kompleksitas query, kebutuhan relasi, reaktivitas (stream), type-safety, ukuran boilerplate, dan kemudahan testing. - Beri rekomendasi final: mana untuk preferensi, mana untuk catatan, beserta alasannya dalam 1 tabel. - Tunjukkan skema tabel/kotak untuk 1000+ catatan. Jelaskan trade-off setiap pilihan.
```

#### 2. Output Awal AI
AI merespons dengan membandingkan keempat storage secara mendetail, di mana AI merekomendasikan **SharedPreferences** khusus untuk preferensi tema dan sangat menyarankan **Drift** (keluarga SQLite) untuk daftar catatan karena memiliki kelebihan berupa dukungan reaktivitas Stream (`.watch()`) yang membuat UI *real-time*, ditambah *Type-Safety* saat *compile-time*. 

AI juga menyediakan tabel skema untuk mekanisme *Offline-First* yang mencakup kolom `sync_status` (sebagai *dirty flag*), `updated_at`, dan `is_deleted`. (Tabel komparasi lengkap serta skema telah disimpan pada dokumen terpisah di dalam folder `docs/ai_recommendation.md`).

#### 3. AI Verification Checklist
- [x] **Apakah AI menempatkan daftar catatan di SharedPreferences?**
  Tidak. AI menolak penggunaannya untuk koleksi data besar karena rentan dan tidak bisa di-query, melainkan menempatkannya di Drift/SQLite.
- [x] **Apakah skema AI mendukung antrean sync (dirty flag / updated_at)?**
  Ya. Skema AI mencakup `sync_status` (1 = *pending*, 0 = *synced*), `updated_at` (resolusi konflik), dan `is_deleted` (soft delete).
- [x] **Apakah klaim "real-time" AI didukung stream?**
  Ya. Rekomendasi utama AI (Drift), secara *native* mendukung Stream lewat `.watch()`.
- [x] **Apakah estimasi boilerplate AI masuk akal?**
  Ya. AI memaparkan bahwa *trade-off* Drift adalah *boilerplate code generation* awal yang tinggi (ketergantungan ke `build_runner`), sedangkan sqflite murni memiliki *boilerplate* untuk mapping JSON dan *parsing query string* manual.

#### 4. Keputusan Final & Alasan Mahasiswa
**Kombinasi yang Dipilih**: SharedPreferences + SQLite (sqflite murni)
**Alasan Praktikal (Sesuai Codelab)**: 
Meskipun AI merekomendasikan Drift untuk kemudahan *Stream*, saya tetap memutuskan menggunakan **SharedPreferences + SQLite (sqflite)**. SharedPreferences dirasa yang paling pas untuk preferensi tema. Sedangkan untuk CRUD, sqflite murni merupakan standar fundamental industri untuk berinteraksi dengan database relasional (SQL) di mobile. Untuk aplikasi dengan *scope* belajar dan skala yang belum masif, sqflite jauh lebih efisien di-setup tanpa butuh *overhead library tambahan* (seperti `build_runner` / code generator dari Drift), dan sudah cukup andal dipadukan dengan arsitektur *provider/repository* yang terpisah untuk me-refresh data UI.

---
### 💡 Jawaban Refleksi

**1. Mengapa daftar catatan tidak boleh disimpan di SharedPreferences? Apa yang rusak jika aturan ini dilanggar?**
`SharedPreferences` didesain untuk menyimpan nilai primitif tunggal (*String, Boolean, Integer*). Untuk menyimpan *list* catatan, kita harus mengonversi seluruh koleksi tersebut menjadi satu buah String panjang berbentuk JSON. Jika aturan ini dilanggar, maka setiap kali membaca atau mengubah satu catatan kecil saja, aplikasi harus me-load keseluruhan teks JSON ke RAM, mengubahnya, lalu menimpanya lagi. Ini menyebabkan *Performance Bottleneck* (UI patah-patah), *memory leak*, dan aplikasi bisa *crash* (`OutOfMemoryError`) ketika list membesar. Selain itu, Anda kehilangan fitur filter data secara spesifik (`WHERE`).

**2. Kapan cache-first cukup, dan kapan Anda membutuhkan strategi lain (misalnya network-first untuk data harga real-time)?**
- **Cache-first** cukup jika kita berurusan dengan data statis / semi-statis yang menoleransi jeda perubahan, misalnya: catatan pribadi, artikel bacaan, feed media sosial. Yang diprioritaskan adalah UX yang cepat saat memuat halaman pertama kali.
- **Network-first** diwajibkan untuk aplikasi krusial yang menuntut validitas mutlak, seperti pergerakan harga saham, transaksi e-commerce, atau ketersediaan tiket pesawat, untuk mencegah kerugian finansial akibat menampilkan saldo/harga (*stale data*) yang tertinggal.

**3. Bagaimana dirty flag berubah menjadi antrean sync tanpa memblokir UI? Kapan antrean terpisah (tabel outbox) menjadi perlu?**
- *Dirty flag* (`sync_status = 1`) berfungsi sebagai indikator bagi sebuah fungsi *background worker* (biasanya *isolate/thread* terpisah). Pekerja asinkron ini otomatis mencari semua catatan `WHERE sync_status = 1`, mengirimkannya via API, lalu mengubahnya menjadi `0` di belakang layar tanpa memblokir *Main Isolate* sehingga UI tetap *smooth*.
- **Tabel Outbox (Antrean Terpisah)** sangat dibutuhkan saat Anda tidak hanya menyelaraskan keadaan data akhir, tetapi juga harus menjaga **urutan instruksi** ( *sequence of events* ). Misalnya: "Update nama", lalu "Kirim Lampiran Foto 50MB", lalu "Kirim Notifikasi". Tabel outbox menjamin instruksi yang tereksekusi sesuai dengan kronologis urutan aksinya.

**4. Bagian mana dari rekomendasi AI yang Anda tolak, dan mengapa?**
Rekomendasi AI untuk mengimplementasikan **Drift** pada catatan telah ditolak. Meskipun Drift menjanjikan performa `.watch()` *Stream* untuk mendukung UI yang reaktif secara bawaan, instalasinya memerlukan *code generator* (`build_runner`) yang dapat memperberat ukuran *project* serta memperlama proses iterasi kompilasi. Dengan menggunakan sqflite murni + *Riverpod Provider* yang dirancang secara tepat, kita tetap bisa mencapai kualitas performa *offline-first* reaktif standar industri dengan *overhead library* yang lebih minim untuk scope project ini.
