import 'package:dio/dio.dart';

/// Memetakan DioException menjadi pesan ramah pengguna
/// agar UI hanya menerima pesan yang bermakna, bukan exception mentah.
String mapDioExceptionToMessage(DioException error) {
  switch (error.type) {
    case DioExceptionType.connectionTimeout:
    case DioExceptionType.sendTimeout:
    case DioExceptionType.receiveTimeout:
      return 'Koneksi waktu habis (timeout). Silakan periksa jaringan Anda dan coba lagi.';
    case DioExceptionType.connectionError:
      return 'Tidak ada koneksi internet (offline). Mohon periksa koneksi data atau Wi-Fi Anda.';
    case DioExceptionType.badResponse:
      final statusCode = error.response?.statusCode;
      if (statusCode == 401) {
        return 'Sesi autentikasi telah berakhir. Silakan login kembali.';
      } else if (statusCode == 403) {
        return 'Anda tidak memiliki hak akses untuk tindakan ini (403 Forbidden).';
      } else if (statusCode == 404) {
        return 'Data atau layanan yang diminta tidak ditemukan (404 Not Found).';
      } else if (statusCode != null && statusCode >= 500) {
        return 'Terjadi gangguan pada server kampus ($statusCode). Silakan coba beberapa saat lagi.';
      }
      return 'Terjadi kesalahan pada respon server ($statusCode).';
    case DioExceptionType.cancel:
      return 'Permintaan dibatalkan.';
    default:
      return 'Terjadi kesalahan jaringan yang tidak terduga. Silakan coba lagi.';
  }
}
