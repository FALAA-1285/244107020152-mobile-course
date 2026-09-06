# Analisis Layout Dashboard Akademik Flutter

## 1. Perbandingan GridView dan LayoutBuilder + Column

Pada dashboard akademik Flutter, terdapat dua pendekatan layout yang dapat digunakan, yaitu **GridView** dan **LayoutBuilder + Column**.

### GridView

`GridView` cocok digunakan untuk menampilkan beberapa kartu informasi dalam bentuk grid. Keuntungannya adalah penggunaan ruang layar lebih efisien dan tampilan menjadi lebih terstruktur.

Kelebihan:

- Cocok untuk menampilkan banyak kartu informasi.
- Penggunaan ruang horizontal lebih efisien.
- Tampilan dashboard terlihat lebih rapi.
- Jumlah kolom dapat dibuat dinamis berdasarkan ukuran layar.

Kekurangan:

- Jika jumlah kolom terlalu banyak pada layar kecil, kartu dapat menjadi terlalu sempit.
- Teks dan informasi di dalam kartu berpotensi sulit dibaca.
- Perlu pengaturan breakpoint agar tetap responsif.

### LayoutBuilder + Column

`LayoutBuilder` dapat digunakan untuk mengetahui ukuran ruang yang tersedia, kemudian `Column` dapat digunakan untuk menyusun komponen secara vertikal.

Kelebihan:

- Sangat sesuai untuk perangkat dengan layar kecil.
- Informasi lebih mudah dibaca karena setiap komponen mendapatkan lebar yang lebih besar.
- Risiko teks terpotong atau terlalu sempit lebih kecil.
- Struktur layout relatif sederhana.

Kekurangan:

- Membutuhkan ruang vertikal yang lebih panjang.
- Kurang efisien jika dashboard memiliki banyak kartu.
- Pada layar besar, tampilan dapat terlihat terlalu kosong jika seluruh konten hanya disusun dalam satu kolom.

### Perbandingan

| Aspek | GridView | LayoutBuilder + Column |
|---|---|---|
| Responsivitas | Baik jika jumlah kolom dinamis | Sangat baik untuk layar kecil |
| Penggunaan ruang | Lebih efisien | Membutuhkan ruang vertikal lebih banyak |
| Layar kecil | Berpotensi terlalu sempit | Lebih nyaman |
| Aksesibilitas | Baik jika ukuran kartu mencukupi | Cenderung lebih mudah dibaca |
| Banyak data | Sangat cocok | Kurang efisien |
| Tampilan dashboard | Lebih ringkas | Lebih panjang |

Pada `main.dart`, pendekatan yang digunakan sebenarnya merupakan kombinasi **LayoutBuilder + GridView**. `LayoutBuilder` menentukan jumlah kolom berdasarkan lebar layar, sedangkan `GridView.count` menampilkan kartu statistik.

Kode tersebut menggunakan:

```dart
final columns = constraints.maxWidth >= 700 ? 2 : 1;
```

Artinya:

- Lebar `< 700 px` → 1 kolom.
- Lebar `>= 700 px` → 2 kolom.

Pendekatan ini memberikan kompromi yang baik antara efisiensi ruang dan responsivitas.

---

## 2. Kapan Expanded Menyebabkan Overflow pada Row?

`Expanded` digunakan untuk membuat widget mengisi ruang yang tersedia di dalam `Row` atau `Column`.

Namun, `Expanded` dapat menyebabkan **overflow** apabila isi di dalamnya membutuhkan ruang minimum yang lebih besar daripada ruang yang tersedia.

Contoh kode yang berpotensi mengalami overflow:

```dart
Row(
  children: [
    const Icon(Icons.person, size: 40),
    const SizedBox(width: 20),
    Expanded(
      child: Row(
        children: [
          const Text(
            'Nama mahasiswa yang sangat panjang',
            maxLines: 1,
          ),
          const SizedBox(width: 100),
          ElevatedButton(
            onPressed: () {},
            child: const Text('Lihat Detail'),
          ),
        ],
      ),
    ),
  ],
)
```

Pada contoh tersebut, `Expanded` memang mengambil sisa ruang dari `Row` utama. Namun, `Row` yang berada di dalam `Expanded` memiliki beberapa elemen yang membutuhkan lebar tertentu.

Jika total kebutuhan lebar melebihi ruang yang tersedia, Flutter dapat menghasilkan error:

```text
A RenderFlex overflowed by ... pixels on the right.
```

### Perbaikan

Salah satu solusi adalah menyusun informasi secara vertikal dan membatasi teks:

```dart
Row(
  children: [
    const Icon(Icons.person, size: 40),
    const SizedBox(width: 20),
    Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Nama mahasiswa yang sangat panjang',
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
          const SizedBox(height: 8),
          ElevatedButton(
            onPressed: () {},
            child: const Text('Lihat Detail'),
          ),
        ],
      ),
    ),
  ],
)
```

Pada `main.dart`, penggunaan `Expanded` pada bagian profil mahasiswa sudah tepat. `CircleAvatar` memiliki ukuran tetap, kemudian `Expanded` digunakan untuk memberikan sisa ruang kepada informasi mahasiswa.

`Expanded` juga digunakan pada `DashboardCard` agar teks judul dan nilai menggunakan ruang yang tersisa setelah ikon.

Dengan demikian, **`Expanded` tidak selalu menyebabkan overflow**. Masalah muncul ketika konten di dalam `Expanded` memiliki kebutuhan ukuran yang tidak dapat dipenuhi oleh ruang yang tersedia.

---

## 3. Pemeriksaan Kembali Responsivitas, Aksesibilitas, dan Flutter Stable

### a. Apakah tetap responsif di bawah 600 px?

Ya. Berdasarkan implementasi pada `main.dart`, layout tetap responsif pada layar di bawah 600 px.

Breakpoint yang digunakan bahkan lebih besar, yaitu **700 px**:

```dart
final columns = constraints.maxWidth >= 700 ? 2 : 1;
```

Sehingga pada layar:

```text
< 700 px  → 1 kolom
>= 700 px → 2 kolom
```

Dengan demikian, layar berukuran 600 px maupun lebih kecil akan menggunakan satu kolom.

`GridView` juga menggunakan:

```dart
shrinkWrap: true,
physics: const NeverScrollableScrollPhysics(),
```

Hal tersebut sesuai karena `GridView` ditempatkan di dalam `SingleChildScrollView`.

Namun, `childAspectRatio` pada layar sempit tetap perlu diperhatikan:

```dart
childAspectRatio: constraints.maxWidth >= 700 ? 2.5 : 3.0,
```

Jika tinggi kartu terlalu kecil, teks dapat menjadi kurang nyaman untuk dibaca. Oleh karena itu, responsivitas sebaiknya tidak hanya mempertimbangkan lebar layar, tetapi juga memastikan tinggi komponen cukup.

---

### b. Apakah layout mengurangi aksesibilitas?

Tidak secara langsung. Bahkan, implementasi yang diberikan sudah menerapkan beberapa prinsip aksesibilitas.

Contohnya, switch untuk tema gelap diberikan label melalui `Semantics`:

```dart
Semantics(
  label: 'Toggle tema gelap',
  child: Switch.adaptive(
    value: isDark,
    onChanged: onDarkChanged,
  ),
)
```



Kartu statistik juga mempunyai semantic label. Contohnya:

```dart
semanticLabel: 'Indeks Prestasi Kumulatif 3.85'
```



Selain itu, ikon tema dikeluarkan dari semantic tree menggunakan:

```dart
ExcludeSemantics(
  child: Icon(...),
)
```

Hal tersebut mencegah screen reader membaca ikon dekoratif yang tidak memberikan informasi tambahan.

Meskipun demikian, masih perlu diperhatikan:

- Ukuran teks.
- Kontras warna teks dan background.
- Tinggi kartu pada layar kecil.
- Ukuran area interaksi.
- Kemudahan navigasi menggunakan screen reader.
- Teks yang terlalu panjang.

Jadi, **layout yang responsif belum tentu otomatis aksesibel**.

---

### c. Apakah ada widget yang tidak tersedia di Flutter Stable?

Berdasarkan kode yang diberikan, tidak terdapat widget eksperimental atau widget yang secara khusus membutuhkan Flutter versi non-stable.

Widget yang digunakan antara lain:

- `Scaffold`
- `AppBar`
- `Row`
- `Column`
- `Expanded`
- `LayoutBuilder`
- `GridView.count`
- `SingleChildScrollView`
- `Semantics`
- `ExcludeSemantics`
- `Switch.adaptive`
- `CircleAvatar`
- `Container`

Widget-widget tersebut merupakan bagian dari Flutter dan dapat digunakan pada Flutter stable.

Penggunaan Material 3:

```dart
ThemeData(
  useMaterial3: true,
)
```

juga digunakan secara valid dalam aplikasi tersebut.

---

## Kesimpulan

Berdasarkan pemeriksaan terhadap `main.dart`, pendekatan **LayoutBuilder + GridView** merupakan pilihan yang cukup baik untuk dashboard akademik karena dapat menyesuaikan jumlah kolom berdasarkan lebar layar.

Pada layar di bawah 700 px, dashboard berubah menjadi satu kolom sehingga tetap nyaman digunakan pada perangkat kecil.

Penggunaan `Expanded` juga sudah tepat pada bagian profil dan kartu statistik selama konten di dalamnya tidak memiliki kebutuhan ukuran yang melebihi ruang yang tersedia.

Dari sisi aksesibilitas, penggunaan `Semantics`, `ExcludeSemantics`, dan semantic label pada kartu merupakan implementasi yang baik.

**Kesimpulan akhir:**

> Layout yang digunakan sudah responsif untuk layar kecil, cukup memperhatikan aksesibilitas, dan menggunakan widget yang tersedia pada Flutter stable. Namun, pengujian lebih lanjut tetap diperlukan pada perangkat dengan ukuran layar berbeda, terutama untuk memastikan ukuran teks, tinggi kartu, kontras warna, dan screen reader tetap nyaman digunakan.