# SakuKu

Aplikasi pencatat keuangan pribadi untuk Android. Catat pemasukan, pengeluaran, dan transfer; pantau saldo dompet, anggaran, dan laporan tanpa akun atau koneksi internet.

## Fitur

- Dashboard saldo, ringkasan harian/bulanan, dan transaksi terbaru
- Catat, ubah, dan hapus transaksi pemasukan serta pengeluaran
- Kelola dompet dan transfer antar-dompet
- Kategori pemasukan/pengeluaran dan anggaran bulanan
- Riwayat transaksi, laporan, dan ekspor CSV
- Tema terang/gelap dan widget layar utama Android
- Bahasa Indonesia dan format Rupiah
- Data disimpan lokal di perangkat menggunakan SQLite

## Teknologi

- Flutter dan Dart
- Riverpod untuk state management
- Drift dan SQLite untuk penyimpanan lokal
- go_router untuk navigasi
- fl_chart untuk grafik
- home_widget untuk widget Android

Dependensi dan versinya tercatat di `pubspec.yaml` dan `pubspec.lock`. Aplikasi tidak memerlukan file `.env`, API key, atau layanan backend.

## Persyaratan

- Flutter SDK dengan Dart yang memenuhi constraint `^3.13.5` di `pubspec.yaml`
- Android SDK dan emulator atau perangkat Android untuk menjalankan aplikasi

## Menjalankan

```bash
flutter pub get
flutter run
```

Untuk membuat APK release:

```bash
flutter build apk --release
```

APK dibuat di `build/app/outputs/flutter-apk/app-release.apk`.

## Pemeriksaan

```bash
flutter analyze
flutter test
```

## Privasi

Data transaksi dan pengaturan disimpan di perangkat. Tidak ada login, sinkronisasi cloud, atau backend.
