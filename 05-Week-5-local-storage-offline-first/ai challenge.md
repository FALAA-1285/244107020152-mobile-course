Berikut adalah analisis lengkap sesuai dengan permintaan Anda terkait perbandingan penyimpanan lokal di Flutter untuk aplikasi *Offline Notes*.

### 1. Perbandingan SharedPreferences, Hive, sqflite, dan Drift

| Kriteria | SharedPreferences | Hive | sqflite (SQLite) | Drift |
| :--- | :--- | :--- | :--- | :--- |
| **Kompleksitas Query** | Sangat rendah. Hanya menyimpan *Key-Value*. Tidak bisa menggunakan *filter* pencarian. | Rendah - Sedang. Bisa melakukan *filtering* pada list, tapi lambat jika harus mencari *substring* spesifik. | Tinggi. Mendukung *syntax* SQL lengkap (`WHERE`, `LIKE`, dll). | Tinggi. Mengabstraksi SQLite, mendukung query yang sangat rumit. |
| **Kebutuhan Relasi** | Tidak ada. | Terbatas (menggunakan `HiveList`), agak kaku untuk relasi yang dinamis. | Sangat baik. Mendukung relasi SQL penuh (*Foreign Keys*, `JOIN`). | Sangat baik. Validasi tabel dan *JOIN* langsung di saat *compile-time*. |
| **Reaktivitas (Stream)**| Tidak bawaan. | Mendukung reaktivitas UI dengan `ValueListenable`. | Tidak bawaan. Harus dikonfigurasi secara manual. | **Sangat Baik**. Mendukung `.watch()` bawaan yang memancarkan `Stream`. |
| **Type-Safety** | Rendah. Membutuhkan konversi manual dan rentan salah tipe data. | Sedang. Menggunakan *TypeAdapter*. | Rendah. Rawan terjadi *typo* pada string query SQL (*runtime error*). | **Sangat Tinggi**. *Code generator* membuat class ber-tipe kuat secara otomatis. |
| **Ukuran Boilerplate** | Sangat rendah. Nyaris 0 konfigurasi. | Sedang. Membutuhkan *generate* untuk *TypeAdapter*. | Tinggi. Butuh migrasi manual, dan mengonversi `Map` dari dan ke dalam bentuk Objek. | Tinggi. Membutuhkan konfigurasi *code generation* via `build_runner`. |
| **Kemudahan Testing** | Mudah. Mudah di-*mock* dan di-stub. | Mudah. Bisa di-*setup in-memory*. | Cukup rumit. Butuh library tambahan (seperti FFI) untuk unit testing. | Sedang. Menyediakan fitur *in-memory* khusus untuk *testing*. |

---

### 2. Rekomendasi Final

| Kebutuhan | Pilihan Storage | Alasan Pemilihan & Justifikasi |
| :--- | :--- | :--- |
| **Preferensi Tema** | **SharedPreferences** | Preferensi hanya berupa pengaturan satu dimensi (contoh: `isDarkTheme = true/false`). *SharedPrefs* adalah opsi teringan, dan paling mudah diaplikasikan. (Menempatkan 1000+ data *notes* JSON di dalam *SharedPrefs* sangat beresiko merusak memori aplikasi). |
| **CRUD Catatan** | **Drift** | Sangat disarankan untuk 1000+ catatan karena berjalan di atas *engine* relasional (SQLite), hemat memori dan bisa dicari secara cepat (*indexed*). Yang paling krusial, Drift memberikan fitur `.watch()` otomatis. Fitur Stream ini esensial untuk aplikasi yang harus me-render antarmuka (UI) secara otomatis saat data catatan disinkronisasi. |

---

### 3. Skema Data (*Offline-First* dengan Antrean Sync)

Untuk menangani 1000+ catatan yang tangguh terhadap kondisi luring (*offline*) maupun *online*, dibutuhkan implementasi *dirty flag* untuk antrean. 

**Tabel `Notes`:**
| Kolom | Tipe | Keterangan & Peran |
| :--- | :--- | :--- |
| `id` | TEXT | Primary Key. Harus menggunakan format *UUID* statis buatan *client/local* agar tidak bentrok dengan ID milik server. |
| `title` | TEXT | Judul spesifik catatan. |
| `content` | TEXT | Seluruh isi teks catatan. |
| `created_at` | INTEGER | Waktu *epoch/timestamp* saat baris dibuat. |
| `updated_at` | INTEGER | Waktu terakhir entri berubah (*timestamp*). Berperan besar untuk memutuskan data mana yang lebih "valid" dan baru jika terjadi tabrakan antara server dan lokal. |
| `is_deleted` | INTEGER | Flag 0 / 1 (*Soft-Delete*). Jika pengguna menghapus *offline*, set ke 1, jangan tampilkan di UI, dan tunggu HTTP Delete dikirim saat *online*. |
| `sync_status`| INTEGER | 0 = *Synced* (identik server). 1 = *Dirty* / Sedang mengantre karena baru saja diubah secara lokal. |

---

### 4. Trade-Off Setiap Pilihan

1. **SharedPreferences**:
   *Trade-off*: Sangat mudah, tetapi **hanya** dikhususkan untuk nilai primitif (*boolean, string, integer*). Memaksakan menaruh list *object* catatan akan memperberat laju pembacaan memori karena semuanya dibaca sekaligus dalam satu key.
2. **Hive**:
   *Trade-off*: Kecepatannya luar biasa tinggi karena melakukan iterasi *memory*, tetapi performa aplikasi beresiko menurun saat isi catatan semakin membengkak. Pengorganisasian relasional (contoh: tag pada catatan) akan membingungkan seiring aplikasi meluas.
3. **sqflite (SQLite)**:
   *Trade-off*: Cepat, stabil, dan bisa menangani query paling rumit sekalipun. Namun, *developer* dituntut tahan banting dengan kode *boilerplate* (memasukkan variabel ke kueri mentah SQL dan *parsing JSON* yang bisa saja keliru). Selain itu ia tak reaktif secara bawaan tanpa dibungkus *State Management* lain.
4. **Drift**:
   *Trade-off*: Modern, 100% *type-safe*, serta UI bisa *realtime*. Kelemahan terbesarnya adalah waktu kompilasi program (*build time*) memanjang. Setiap ada pengubahan kolom database, developer *wajib* menjalankan `flutter pub run build_runner build` di konsol agar *file logic*-nya terbentuk.

Viewed REDME.md:70-82