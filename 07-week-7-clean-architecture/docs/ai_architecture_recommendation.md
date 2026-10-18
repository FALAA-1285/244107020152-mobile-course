# Dokumentasi AI Challenge: Arsitektur Feature-First Clean Architecture

Dokumen ini mencatat evaluasi teknis, verifikasi arsitektur, dan perbandingan usulan AI dengan keputusan final implementasi pada proyek **campus_notify** (Minggu 7).

---

## 1. Prompt AI Challenge
Berikut prompt terstruktur yang diajukan ke AI coding assistant:

> **Project Flutter:** campus_notify (auth + FCM + pengumuman kampus)  
> **Kondisi awal:** folder `lib/{data, providers, pages, messaging}`, repository tercampur dengan implementasi, widget memanggil Dio langsung.  
> **Tugas:**  
> 1. Usulkan struktur feature-first Clean Architecture (`presentation/domain/data`) untuk fitur auth + announcements.  
> 2. Untuk tiap file lama, sebutkan tujuan barunya (pindah/pecah/hapus).  
> 3. Tandai bagian yang over-engineering bila diterapkan ke CRUD sederhana, dan jelaskan kapan use case benar-benar dibutuhkan vs repository langsung.  
> 4. Tunjukkan wiring DI dengan Riverpod (tanpa package DI tambahan).  
> Jelaskan trade-off setiap keputusan.

---

## 2. Checklist Verifikasi AI
Sebelum usulan AI diadopsi, dilakukan verifikasi kepatuhan arsitektur Clean Architecture:

| Kriteria Evaluasi | Status | Catatan Verifikasi |
|---|:---:|---|
| **Interface di Domain, Impl di Data?** | **Lolos** | Kontrak abstraksi diletakkan di `domain/repositories/` dan implementasi teknis di `data/repositories/`. Tidak disatukan dalam satu folder. |
| **Domain Steril dari Framework & Package?** | **Lolos** | Diperiksa via grep: 0 import `package:flutter`, `package:dio`, `package:sqflite`, maupun `package:firebase` di folder domain & core. |
| **Bebas dari Over-Engineering CRUD Satu-Baris?** | **Lolos** | Use case hanya dipertahankan untuk alur yang memiliki validasi bisnis / orkestrasi (seperti validasi panjang password pada `LoginUser` dan filter ID pada `GetAnnouncementDetail`). Operasi direct read sederhana dapat langsung diakses notifier bila tidak ada aturan bisnis. |
| **Entity Bebas dari Mapping?** | **Lolos** | Entity di `domain/` murni tanpa method `toMap()`, `fromMap()`, atau `toJson()`. Seluruh serialisasi dikarantina di `AnnouncementModel` (`data/`). |
| **Wiring DI Terpusat di Riverpod Provider?** | **Lolos** | Widget tidak pernah memanggil `new Repository()`. Semua dependency disuntikkan via Riverpod `Provider` dan dikonsumsi UI via `ref.watch()`. |

---

## 3. Tabel Pemetaan File Lama vs Tujuan Baru

| File Lama | Status Tindakan | Lokasi Baru | Alasan Teknis |
|---|:---:|---|---|
| `pages/login_page.dart` | Pindah & Refactor | `features/auth/presentation/pages/login_page.dart` | Mengonsumsi state via Riverpod notifier, bebas logika auth langsung. |
| `pages/home_page.dart` | Pindah & Refactor | `features/auth/presentation/pages/home_page.dart` | Menampilkan UI profil & token status dengan guard state. |
| `pages/announcement_page.dart` | Pindah & Refactor | `features/announcements/presentation/pages/announcement_page.dart` | Menampilkan data pengumuman melalui `announcementDetailProvider(id)`. |
| `data/auth_repository.dart` | Pecah Jadi 2 | `domain/repositories/auth_repository.dart` (kontrak)<br>`data/repositories/auth_repository_impl.dart` (impl) | Mematuhi Dependency Inversion Principle (DIP). |
| `providers/auth_provider.dart` | Pindah & Refactor | `features/auth/presentation/providers/auth_providers.dart` | Menggunakan use case / repository interface untuk state management. |
| `messaging/push_service.dart` | Pertahankan | `messaging/push_service.dart` | Layanan infrastruktur aplikasi global untuk push notification FCM. |
| `routes.dart` | Refactor | `routes.dart` | Ekstrak fungsi parsing rute ke `core/format.dart` agar murni dan testable. |

---

## 4. Analisis Over-Engineering: Kapan Use Case Dibutuhkan?

- **Kapan Use Case Benar-Benar Dibutuhkan:**
  1. Terdapat validasi bisnis pra-eksekusi (misal: validasi panjang password dan format email sebelum request API).
  2. Melibatkan orkestrasi beberapa repository (misal: simpan catatan lalu perbarui status sync di database lokal).
  3. Memerlukan penanganan failure khusus lintas domain.

- **Kapan Repository Langsung ke Notifier Cukup:**
  - Operasi pembacaan pasif (read-only query) tanpa filtering bisnis kompleks.
  - Untuk tim kecil, membuat kelas Use Case untuk setiap query CRUD 1 baris menambah *boilerplate* tanpa memberikan nilai fungsional nyata.

---

## 5. Keputusan Final & Rationale
1. **Pemisahan Modul per Fitur (Feature-First):** Fitur `auth` dan `announcements` diisolasi sepenuhnya sehingga tim dapat mengembangkan atau menghapus fitur tanpa efek samping ke fitur lain.
2. **Karantina Format & Parsing di `core/format.dart`:** Memastikan parsing rute push notification dan formatting tanggal tidak bergantung pada widget Flutter dan dapat diuji murni via unit test.
