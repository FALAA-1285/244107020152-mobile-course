void main() {
  String nama = 'Alya';
  int semester = 3;
  final bool aktif = true;
  print(sapa(nama, semester));
  final mahasiswa = Mahasiswa(nama: nama, aktif: aktif);
  print(mahasiswa.status());

  // Memanggil fungsi hitungLuasPersegiPanjang dan class profil
  print(hitungLuasPersegiPanjang(4, 7));
  final profil = Profil(nama: 'Ahmad Falahi', nim: '2441020152');
  print('Nama: ${profil.nama}, NIM: ${profil.nim}, Email: ${profil.email ?? 'Tidak ada email'}');
}

String sapa(String nama, int semester) => 'Halo $nama, semester $semester';

class Mahasiswa {
  Mahasiswa({required this.nama, required this.aktif});
  final String nama;
  final bool aktif;
  String status() => aktif ? '$nama aktif' : '$nama tidak aktif';
}

// Fungsi hitungLuasPersegiPanjang 
double hitungLuasPersegiPanjang(double panjang, double lebar) {
  return panjang * lebar;
}

// class Profil dengan properti nama, nim, dan email yang boleh kosong.
class Profil {
  Profil({this.nama, this.nim, this.email});
  String? nama;
  String? nim;
  String? email;
}
