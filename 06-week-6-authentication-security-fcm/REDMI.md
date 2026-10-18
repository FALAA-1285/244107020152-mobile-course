# Authentication, Security & Firebase Cloud Messaging (FCM)

### Tujuan Pembelajaran
Setelah menyelesaikan praktikum ini, mahasiswa mampu:
1. Menyimpan access token dan refresh token secara aman di perangkat menggunakan `flutter_secure_storage`;
2. Mengelola sesi autentikasi, status login, dan mekanisme *silent token refresh* otomatis via Dio Interceptor dan Riverpod;
3. Mengamankan navigasi aplikasi (*route guard*) menggunakan `GoRouter` redirect berdasarkan status login pengguna;
4. Mengintegrasikan Firebase Cloud Messaging (FCM) dan meminta izin runtime notifikasi pada Android 13+ dan iOS;
5. Mengelola *lifecycle* FCM token (pengambilan token perangkat, deteksi rotasi token `onTokenRefresh`, dan berlangganan topik kampus);
6. Menangani push notification pada tiga status aplikasi (*Foreground*, *Background*, dan *Terminated*) serta mengimplementasikan deep linking rute dari payload notifikasi;
7. Melakukan *refactoring* rute terpusat, pemetaan error HTTP ramah pengguna, dan pengujian unit (*unit testing*) tanpa ketergantungan Firebase sungguhan.

---

### Konsep Utama

#### 1. Keamanan Penyimpanan Kredensial: Secure Storage vs SharedPreferences

| Aspek | SharedPreferences | flutter_secure_storage |
|---|---|---|
| **Mekanisme Penyimpanan** | File XML mentah (Android) / Plist (iOS) | Android Keystore + EncryptedSharedPreferences / iOS Keychain |
| **Enkripsi Data** | **Tidak ada (Plain Text)** | **Terenkripsi secara hardware-backed (AES/RSA)** |
| **Resiko Keamanan** | Mudah diekstraksi pada perangkat *rooted*, *jailbroken*, atau via *backup tool* | Kunci enkripsi dilindungi modul keamanan perangkat (*Secure Enclave / TEE*) |
| **Peruntukan Tepat** | Preferensi sederhana non-sensitif (tema, pengaturan bahasa, flag onboarding) | **Kredensial sensitif: Access Token, Refresh Token, API Key, PIN** |

> **Peringatan Keamanan**: Menyimpan token di `SharedPreferences` sangat dilarang karena token JWT berisi identitas dan izin otorisasi yang dapat disalahgunakan pihak ketiga jika diekstraksi dari perangkat.

#### 2. Mekanisme Otomatis Token Refresh (Dio Interceptor)
- **Access Token**: Memiliki masa aktif pendek (15-60 menit) untuk membatasi jendela serangan jika token bocor.
- **Refresh Token**: Memiliki masa aktif panjang dan disimpan di `TokenStore`. Digunakan untuk meminta access token baru tanpa memaksa pengguna login ulang.
- **Alur Interceptor**:
  1. Header request otomatis disisipkan `Authorization: Bearer <access_token>`.
  2. Saat server merespons HTTP `401 Unauthorized`, interceptor mencegat error tersebut.
  3. Mengambil refresh token dari `TokenStore`, meminta access token baru ke server, dan menyimpan token baru.
  4. Melakukan *retry* request yang sempat gagal secara transparan.
  5. Bila refresh token tidak valid, seluruh kredensial dibersihkan (`store.clear()`) dan pengguna otomatis diarahkan ke halaman login.

#### 3. Tiga Status Aplikasi (App State) pada Push Notification
- **Foreground**: Aplikasi sedang aktif di layar. Sistem OS tidak membuat banner otomatis, sehingga banner wajib dipicu secara manual menggunakan `flutter_local_notifications` via listener `FirebaseMessaging.onMessage`.
- **Background**: Aplikasi sedang di-*minimize* (tekan Home). Banner notifikasi otomatis ditampilkan sistem di tray status bar. Saat banner diklik, ditangani oleh `FirebaseMessaging.onMessageOpenedApp`.
- **Terminated**: Aplikasi dalam kondisi mati/tertutup total (*swipe-close*). Banner ditampilkan sistem di status bar. Saat aplikasi dibuka via klik notifikasi, rute diproses melalui `FirebaseMessaging.instance.getInitialMessage()`.

#### 4. Topik Kampus (Topic Messaging) vs Device Token
- **Topic Messaging (`subscribeToTopic`)**: Digunakan untuk pesan massal (*broadcast*) yang ditujukan ke sekelompok besar pengguna tanpa server perlu melacak token setiap perangkat (contoh: info libur, bencana, atau pengumuman angkatan).
- **Device Token**: Alamat unik perangkat yang digunakan untuk pesan personal atau sensitif (contoh: nilai ujian, tagihan pembayaran, kode verifikasi). Jangan pernah mempublikasikan data personal via topik publik.

---

### Praktikum

#### Hasil Run & Bukti Tangkapan Layar (Screenshots)

##### 1. Halaman Login
Antarmuka login sebelum pengguna terautentikasi (dilindungi oleh GoRouter Route Guard):
![Halaman Login](screenshots/01-login-page.png)

##### 2. Halaman Home & Debug FCM Token
Halaman utama setelah berhasil login, menampilkan sesi aktif dan verifikasi FCM token yang dipotong demi menjaga privasi:
![Halaman Home dan Token Debug](screenshots/02-home-debug-token.png)

##### 3. Halaman Detail Pengumuman (Deep Link Sukses)
Hasil navigasi ketika rute `/pengumuman/1` atau `/pengumuman/3` berhasil dibuka:
![Halaman Pengumuman](screenshots/03-announcement-page.png)

##### 4. Pengujian Kampanye Notifikasi Firebase Console
Bukti pengiriman percobaan pesan pengumuman dari Firebase Console dengan status *Completed*:
![Uji Notifikasi Firebase Console](screenshots/fcm-console-test.png)

##### 5. Pengujian State Foreground
Aplikasi dalam kondisi terbuka aktif, memunculkan banner notifikasi lokal kustom di bagian atas layar:
![Notifikasi Foreground](screenshots/04-notification-foreground.png)

##### 6. Pengujian State Background
Aplikasi dalam kondisi minimize (menekan Home), memunculkan banner notifikasi sistem di status bar tray:
![Notifikasi Background](screenshots/05-notification-background.png)

---

### Matriks Pengujian Tiga App State

| State | Yang Diharapkan | Cara Uji | Hasil Pengujian |
|---|---|---|---|
| **Foreground** | Banner lokal muncul via `flutter_local_notifications`, klik masuk ke `/pengumuman/3` | Aplikasi terbuka di layar, kirim dari console/backend dengan payload gabungan | **Berhasil**: Banner lokal muncul di bagian atas layar. Ketika banner diklik, aplikasi langsung mengarahkan navigasi ke rute pengumuman ID 3. |
| **Background** | Banner sistem muncul secara otomatis, klik masuk ke rute yang benar (`/pengumuman/3`) | Tekan tombol Home (aplikasi minimize), kirim payload notifikasi, lalu klik banner sistem | **Berhasil**: Banner sistem muncul di status bar perangkat. Saat diklik, aplikasi kembali ke layar depan dan listener `onMessageOpenedApp` mengarahkan rute ke `/pengumuman/3`. |
| **Terminated** | Aplikasi terbuka ke rute yang benar via `getInitialMessage` | Tutup paksa aplikasi (swipe-close / kill process), kirim notifikasi, lalu klik banner | **Berhasil**: Aplikasi di-launch dari kondisi mati, `getInitialMessage()` membaca payload data rute, dan langsung menampilkan halaman Pengumuman ID 3. |

---

### AI Challenge

#### 1. Prompt Awal
```text
Aplikasi Flutter Campus Notification App.
Stack: firebase_messaging, flutter_local_notifications,
flutter_secure_storage, go_router, Riverpod.
Buatkan PushService dengan:
- requestPermission + getToken + onTokenRefresh (kirim ke POST /devices)
- onMessage (tampilkan local notification manual)
- onMessageOpenedApp + getInitialMessage (navigasi ke data.route)
- subscribe/unsubscribe topic pengumuman-kampus
- background handler top-level dengan @pragma('vm:entry-point')
Tandai bagian yang BERBEDA untuk Android 13+ vs iOS,
dan bagian yang tidak boleh mengakses BuildContext.
```

#### 2. Output Awal AI
AI merespons dengan menyusun kerangka *PushService* modular, menandai perbedaan Android 13+ (izin runtime wajib) dan melarang penggunaan `BuildContext` di background handler isolate.

Namun, terdapat kelemahan pada draf AI:
- Pada `onTokenRefresh`, AI hanya menggunakan `print()` ke konsol tanpa mengirim token ke backend.
- Pemanggilan `flutter_local_notifications` versi 22.x masih menggunakan sintaks lama (*positional parameters*) yang memicu error saat kompilasi.
- String routing dipanggil secara terpisah dan di-hardcode di banyak tempat.

#### 3. AI Verification Checklist
- [x] **Apakah background handler berupa fungsi top-level dengan `@pragma('vm:entry-point')`?**
  Ya. Diletakkan sebagai fungsi top-level di luar kelas agar engine Flutter dapat mengeksekusinya di isolate latar belakang terpisah.
- [x] **Apakah `onTokenRefresh` benar-benar mengirim token baru ke backend, bukan hanya dicetak ke log?**
  Ya. Draf diperbaiki dengan menambahkan callback `onToken` untuk menyalurkan token baru ke backend API (`POST /devices`).
- [x] **Apakah foreground memakai local notification manual?**
  Ya. OS mobile tidak memunculkan banner otomatis saat foreground, sehingga banner dipicu via `flutter_local_notifications`.
- [x] **Apakah klik dari ketiga state (foreground/background/terminated) masuk ke rute yang benar?**
  Ya. Tervalidasi melalui tabel matriks pengujian dan unit test `routeFromMessage`.
- [x] **Apakah token/secret tidak di-hardcode dan tidak di-log penuh?**
  Ya. Token disimpan di `FlutterSecureStorage` dan hanya ditampilkan terpotong (`token.substring(0, 12)...`) demi keamanan.

#### 4. Keputusan Final & Alasan Mahasiswa
**Keputusan**: Mengadopsi arsitektur asinkron yang disarankan AI dengan melakukan perbaikan:
1. Memperbarui sintaks pemanggilan `flutter_local_notifications` v22+ ke *named parameters* (`settings:`, `id:`, `title:`, `body:`).
2. Mengekstrak pemetaan rute ke fungsi murni `routeFromMessage` di `lib/routes.dart` agar dapat diuji secara independen melalui *unit testing*.
3. Menyediakan penampung rute awal (`pendingDeepLink`) untuk menjamin navigasi dari state *terminated* berjalan lancar.

---

### Refleksi

**1. Mengapa refresh token tidak boleh disimpan di SharedPreferences? Apa risikonya bila bocor?**
`SharedPreferences` menyimpan data dalam bentuk file XML *plain text* tanpa enkripsi di direktori internal aplikasi (`/data/data/<package_name>/shared_prefs/`). Pada perangkat Android yang telah di-*root* atau dieksploitasi melalui *ADB backup*, siapa saja dapat membaca isi file tersebut dengan mudah. Refresh token memiliki masa aktif yang jauh lebih panjang daripada access token. Jika refresh token bocor, penyerang dapat terus-menerus meminta access token baru ke server atas nama korban (*session hijacking* permanen) tanpa perlu mengetahui password pengguna. Oleh karena itu, refresh token wajib disimpan di `FlutterSecureStorage` yang dilindungi oleh hardware enkripsi (*Android Keystore / iOS Keychain*).

**2. Apa yang rusak bila `onTokenRefresh` diabaikan selama satu semester perkuliahan?**
FCM Device Token tidak bersifat statis permanen. Token dapat dirotasi secara otomatis oleh Firebase ketika aplikasi di-update, sistem operasi di-upgrade, memori cache dibersihkan, atau karena kebijakan keamanan berkala Google. Jika listener `onTokenRefresh` diabaikan, backend kampus akan terus menyimpan token lama yang sudah tidak aktif (*stale token*). Akibatnya, sepanjang semester, mahasiswa tidak akan pernah menerima notifikasi krusial seperti perubahan jadwal kuliah mendadak, tagihan pembayaran UKT, atau pengumuman nilai, sementara server kampus akan terus mengalami error `NotRegistered` atau `InvalidRegistration`.

**3. Kapan memakai topik dan kapan memakai token perangkat? Beri contoh pesan kampus untuk masing-masing.**
- **Topic Messaging**: Digunakan untuk pesan satu-ke-banyak (*broadcast*) yang relevan untuk kelompok besar pengguna tanpa server perlu melacak token setiap perangkat.
  *Contoh Pesan Kampus*: *"Pemberitahuan: Seluruh perkuliahan hari Senin diliburkan menyambut Dies Natalis kampus"* (topik: `pengumuman-kampus`) atau *"Jadwal KRS mahasiswa angkatan 2024 dimulai besok"* (topik: `angkatan-2024`).
- **Device Token**: Wajib digunakan untuk pesan personal satu-ke-satu (*one-to-one*) yang mengandung privasi atau data sensitif.
  *Contoh Pesan Kampus*: *"Tagihan SPP semester genap sebesar Rp 5.000.000 atas nama Ahmad (NIM: 244107020152) telah terbit"* atau *"Nilai mata kuliah Pemrograman Mobile Anda telah diumumkan di SIAKAD"*.

**4. Bagian mana dari draf AI yang Anda tolak atau perbaiki, dan mengapa?**
- **Menolak penulisan positional parameter pada Local Notifications**: Draf AI menggunakan sintaks lama `_local.show(id, title, body, details)` yang memicu error kompilasi pada versi `flutter_local_notifications: ^22.3.1`. Bagian ini diperbaiki menggunakan named arguments (`id:`, `title:`, `body:`, `notificationDetails:`).
- **Menolak hanya mencetak token di `onTokenRefresh`**: Draf AI hanya menyisipkan `print(token)`. Bagian ini diperbaiki dengan callback `onToken` untuk menyalurkan token baru ke backend `POST /devices`.
- **Menolak hardcoding rute**: Draf AI menuliskan string `/pengumuman/` secara berulang di beberapa file. Bagian ini di-refactor ke dalam `lib/routes.dart` dengan konstanta `AppRoutes` dan fungsi murni `routeFromMessage` agar modular dan dapat diuji melalui unit test.
