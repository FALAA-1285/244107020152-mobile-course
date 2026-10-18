# Dokumentasi AI Challenge: PushService & FCM Architecture

## 1. AI Prompt Challenge
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

---

## 2. Draf Output Awal AI
Draf yang dihasilkan AI menyusun kelas `PushService` dengan method-method inisialisasi FCM dan penanganan notifikasi lokal, serta fungsi top-level background handler. Namun, terdapat beberapa catatan penting yang perlu ditinjau:
1. AI cenderung hanya mencetak token ke console (`print('FCM Token: $token')`) pada `onTokenRefresh` tanpa memanggil callback API `POST /devices`.
2. AI sering kali menggunakan method kelas alih-alih fungsi top-level untuk background handler, atau lupa menyematkan anotasi `@pragma('vm:entry-point')`.
3. Parameter pemanggilan `_local.initialize` dan `_local.show` pada `flutter_local_notifications` versi terbaru (v22+) telah berganti menjadi *named parameters*, sedangkan AI sering menggunakan sintaks versi lama (*positional parameters*).
4. AI kadang mencoba mengakses `BuildContext` atau `Navigator` di dalam listener background/terminated yang dapat memicu crash saat aplikasi belum memiliki tree widget.

---

## 3. AI Verification Checklist

| Kriteria Verifikasi | Status | Catatan Evaluasi & Temuan |
|---|:---:|---|
| **Background handler berupa top-level function + `@pragma('vm:entry-point')`?** | [x] **Lolos** | Handler diletakkan di luar kelas (`top-level`) agar engine Flutter dapat memanggilnya di isolate terpisah saat app background/mati. Tolak jika berupa method kelas. |
| **`onTokenRefresh` mengirim token baru ke backend?** | [x] **Lolos (Diperbaiki)** | Draf awal AI hanya memakai `print()`. Diperbaiki agar menerima callback `onToken` untuk dikirim via Dio ke endpoint `POST /devices`. |
| **Foreground memakai local notification manual?** | [x] **Lolos** | Menggunakan `flutter_local_notifications` via `_local.show(...)` di `onMessage` karena OS Android tidak memunculkan banner saat aplikasi di foreground. |
| **Navigasi ketiga state masuk ke rute yang benar?** | [x] **Lolos** | Terbukti melalui fungsi murni `routeFromMessage(message.data)` yang diuji dengan 4 unit test dan verifikasi manual di perangkat. |
| **Token/secret tidak di-hardcode & tidak di-log penuh?** | [x] **Lolos** | Kredensial disimpan di `FlutterSecureStorage`. Token FCM pada UI dan log selalu dipotong (`token.substring(0, 12)...`) demi privasi data. |

---

## 4. Analisis Teknis Perbedaan Android 13+ vs iOS

1. **Izin Notifikasi Runtime (Android 13+ vs iOS)**:
   - **Android 13+ (API 33+)**: Memerlukan deklarasi `<uses-permission android:name="android.permission.POST_NOTIFICATIONS"/>` di `AndroidManifest.xml` serta pemanggilan `requestPermission()` secara runtime.
   - **iOS**: Izin runtime diminta via `FirebaseMessaging.instance.requestPermission()` sejak versi awal. Selain itu, iOS memerlukan sertifikat/kunci APNs (*Apple Push Notification service*) yang diunggah di Firebase Console.

2. **Larangan Akses `BuildContext`**:
   - Di dalam `firebaseMessagingBackgroundHandler`: Dilarang keras mengakses `BuildContext` atau Riverpod karena berjalan di isolate latar belakang yang sama sekali tidak memiliki UI tree.
   - Di listener `onMessageOpenedApp` dan `getInitialMessage`: Hindari memanggil `context.go()` langsung bila context belum terpasang; gunakan GoRouter instance atau mekanisme penampung deep link (`pendingDeepLink`).

---

## 5. Keputusan Final & Alasan Mahasiswa
**Keputusan**: 
Mengadopsi kerangka kerja asinkron dari draf AI namun melakukan perbaikan (*refactoring*) menyeluruh pada:
1. Memperbaiki signature method `flutter_local_notifications` (v22.x) ke format named parameters (`settings:`, `id:`, `title:`, `body:`).
2. Mengekstrak pemetaan rute ke fungsi murni `routeFromMessage` di `lib/routes.dart` agar terbebas dari ketergantungan `BuildContext` dan dapat diuji melalui *unit testing*.
3. Mengamankan token agar hanya diekspos secara terpotong (*truncated*) untuk mematuhi prinsip *least privilege* dan keamanan data perangkat.
