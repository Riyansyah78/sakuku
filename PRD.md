# PRD — SakuKu

Aplikasi pencatat keuangan pribadi untuk Android. Fokusnya satu hal: mencatat pemasukan dan pengeluaran harian secepat mungkin, lalu menunjukkan ke mana uang pergi.

| | |
|---|---|
| Versi | 0.1 (draft) |
| Tanggal | 1 November 2026 |
| Platform | Android (iOS menyusul) |
| Mode data | Offline-first, data tersimpan di perangkat |
| Dokumen terkait | `DESIGN.md` (visual), `AGENT.md` (panduan implementasi) |

> Nama produk: "SakuKu".

---

## 1. Latar belakang dan masalah

Banyak orang muda baru sadar uangnya habis di akhir bulan, tanpa tahu habis untuk apa. Aplikasi pencatat yang ada sering terlalu rumit (isian banyak, iklan, fitur yang jarang dipakai), sehingga orang berhenti mencatat setelah beberapa hari.

SakuKu menjawab masalah itu dengan pencatatan yang cepat dan ringkas, serta laporan yang langsung bisa dibaca tanpa perlu menganalisis sendiri.

## 2. Tujuan dan metrik keberhasilan

| Tujuan | Metrik | Target |
|---|---|---|
| G1. Mencatat transaksi dengan cepat | Waktu dari membuka aplikasi sampai transaksi tersimpan (kasus umum) | ≤ 10 detik |
| G2. Selalu tahu posisi keuangan | Saldo total dan sisa anggaran terlihat di layar pertama tanpa scroll | Terpenuhi |
| G3. Memahami pola pengeluaran | Laporan bulanan menampilkan pengeluaran per kategori dan perbandingan dengan bulan lalu | Terpenuhi |
| G4. Tetap berguna tanpa internet dan akun | Semua fitur MVP berjalan offline | 100% |
| G5. Stabil | Sesi tanpa crash | ≥ 99% |
| G6. Konsisten dengan desain | Layar yang dibangun sesuai desain Stitch dan `DESIGN.md` | Semua layar MVP |

## 3. Di luar lingkup (MVP)

- Login, akun online, dan sinkronisasi cloud
- Multi mata uang (MVP hanya Rupiah)
- Impor mutasi bank, baca SMS atau notifikasi bank
- Scan struk (OCR)
- Dompet bersama / keluarga
- Utang-piutang, investasi, dan target tabungan
- Widget layar utama dan wearable

## 4. Pengguna sasaran

**Dina, 20, mahasiswa.** Menerima uang saku atau beasiswa tiap bulan. Sering kehabisan uang sebelum tanggal tua dan tidak tahu penyebabnya. Butuh pencatatan cepat dan anggaran bulanan yang sederhana.

**Raka, 25, karyawan.** Gaji bulanan, tagihan rutin, dan beberapa e-wallet. Butuh memisahkan dompet (tunai, bank, e-wallet) dan melihat laporan per kategori.

## 5. Kebutuhan fungsional

Prioritas: **Must** (wajib MVP), **Should** (diusahakan MVP), **Could** (setelah MVP).

| ID | Prioritas | Kebutuhan | Kriteria penerimaan |
|---|---|---|---|
| FR-01 | Must | **Tambah transaksi.** Pengguna mengisi nominal, tipe (pemasukan/pengeluaran), kategori, tanggal (default hari ini), dompet (default dompet terakhir dipakai), dan catatan opsional. | Tombol "Simpan Transaksi" nonaktif sampai nominal > 0 dan kategori dipilih. Setelah disimpan, pengguna kembali ke layar sebelumnya dan saldo langsung ter-update. Kasus umum selesai dengan ≤ 4 ketukan di luar mengetik nominal. |
| FR-02 | Must | **Ubah dan hapus transaksi.** | Ketuk transaksi untuk mengubah. Hapus meminta konfirmasi, lalu menampilkan snackbar "Urungkan" selama 5 detik. Saldo dan laporan ikut ter-update. |
| FR-03 | Must | **Dompet.** Bawaan: Tunai, Bank, E-Wallet. Pengguna dapat menambah, mengubah, dan mengarsipkan dompet, serta mengisi saldo awal. | Saldo total = jumlah saldo semua dompet aktif. Dompet yang sudah punya transaksi hanya bisa diarsipkan, tidak dihapus. |
| FR-04 | Should | **Transfer antar dompet.** Nominal, dari, ke, tanggal, catatan. | Transfer tidak dihitung sebagai pemasukan atau pengeluaran di dashboard dan laporan. Saldo kedua dompet berubah. |
| FR-05 | Must | **Kategori.** Kategori bawaan pengeluaran dan pemasukan; pengguna bisa menambah kategori kustom (nama, ikon, warna). | Kategori yang sudah dipakai tidak bisa dihapus, hanya diarsipkan. Kategori arsip tidak muncul di pilihan baru tetapi tetap tampil di riwayat. |
| FR-06 | Must | **Dashboard.** Saldo total, pemasukan dan pengeluaran bulan ini, donut pengeluaran per kategori (5 teratas + lainnya), 5 transaksi terbaru, aksi cepat. | Semua terlihat di layar pertama saat aplikasi dibuka, dan angka cocok dengan data riwayat. |
| FR-07 | Must | **Riwayat transaksi.** Dikelompokkan per tanggal dengan subtotal harian, pemilih bulan, filter (Semua/Pemasukan/Pengeluaran), dan pencarian. | Pencarian mencocokkan catatan dan nama kategori. Daftar tetap lancar dengan 5.000 transaksi (lazy list). |
| FR-08 | Must | **Laporan.** Tab Mingguan/Bulanan/Tahunan, grafik batang pemasukan vs pengeluaran, selisih periode, peringkat kategori dengan persentase, dan satu insight perbandingan dengan periode sebelumnya. | Total di laporan sama dengan total di riwayat untuk periode yang sama. Insight tidak tampil jika data periode sebelumnya belum ada. |
| FR-09 | Must | **Anggaran.** Batas pengeluaran per kategori per bulan, dengan progres dan status. | Status: normal (< 80%), peringatan (80–99%), terlampaui (≥ 100%). Anggaran bulan berjalan otomatis disalin ke bulan berikutnya (dapat diubah). |
| FR-10 | Should | **Notifikasi anggaran** (lokal). | Muncul saat mencapai 80% dan 100%. Dapat dimatikan di pengaturan. |
| FR-11 | Should | **Ekspor CSV** untuk rentang tanggal tertentu. | File dapat dibagikan lewat share sheet Android. Kolom: tanggal, tipe, kategori, dompet, nominal, catatan. |
| FR-12 | Should | **Mode gelap.** | Ikuti sistem atau pilih manual di pengaturan. |
| FR-13 | Could | **Kunci aplikasi** dengan PIN atau biometrik. | — |
| FR-14 | Could | **Transaksi berulang** (langganan, tagihan bulanan). | — |
| FR-15 | Must | **Profil dan pengaturan.** Nama tampilan, tema, notifikasi, ekspor, hapus semua data. | Hapus semua data meminta konfirmasi eksplisit dan tidak bisa diurungkan. |

## 6. Aturan bisnis

1. Nominal disimpan sebagai bilangan bulat dalam Rupiah (tanpa desimal). Nominal harus > 0 dan ≤ 9.999.999.999.
2. Saldo dompet = saldo awal + pemasukan − pengeluaran + transfer masuk − transfer keluar.
3. Tanggal transaksi tidak boleh di masa depan.
4. Periode laporan mengikuti bulan kalender dan zona waktu perangkat.
5. Transfer tidak masuk hitungan pemasukan/pengeluaran, kategori, maupun anggaran.
6. Progres anggaran = total pengeluaran kategori pada bulan itu ÷ batas anggaran.
7. Menghapus data (transaksi, dompet, kategori) tidak boleh meninggalkan data yatim; gunakan arsip bila masih direferensikan.

## 7. Kebutuhan non-fungsional

- **Performa:** cold start < 2 detik di perangkat kelas menengah; scroll riwayat 60 fps.
- **Offline-first:** seluruh fitur MVP berjalan tanpa internet.
- **Privasi:** data hanya tersimpan di perangkat; tidak ada analitik atau iklan pihak ketiga di MVP.
- **Aksesibilitas:** target sentuh ≥ 48dp, kontras minimal WCAG AA, mendukung skala teks hingga 130%, dan tidak mengandalkan warna saja (nominal diberi tanda + / −).
- **Lokalisasi:** Bahasa Indonesia, format Rupiah (`Rp 1.250.000`), tanggal lokal `id_ID`.
- **Kompatibilitas:** Android 8.0 (API 26) ke atas.

## 8. Daftar layar dan alur utama

| Layar | Tab / akses | Status desain |
|---|---|---|
| Home / Dashboard | Tab Home | Ada di Stitch |
| Tambah Transaksi | Tombol (+) | Ada di Stitch |
| Transaksi (riwayat) | Tab Transactions | Ada di Stitch |
| Laporan | Tab Reports | Ada di Stitch |
| Anggaran | Dari Home / Profil | Ada di Stitch |
| Dompet (daftar, tambah/ubah) | Dari Home / Profil | Belum didesain |
| Transfer | Aksi cepat di Home | Belum didesain |
| Kelola kategori | Dari Profil | Belum didesain |
| Profil dan pengaturan | Tab Profile | Belum didesain |

**Alur utama, mencatat pengeluaran:** Home → ketuk (+) → isi nominal → pilih kategori → Simpan Transaksi → kembali ke Home dengan snackbar "Transaksi disimpan".

## 9. Model data

**Account (Dompet):** `id`, `name`, `type` (cash | bank | ewallet), `initial_balance` (int), `icon`, `color`, `archived`, `created_at`

**Category:** `id`, `name`, `type` (expense | income), `icon`, `color`, `is_default`, `archived`

**Transaction:** `id`, `type` (expense | income | transfer), `amount` (int, Rupiah), `category_id` (null untuk transfer), `account_id`, `to_account_id` (hanya transfer), `occurred_at` (tanggal), `note`, `created_at`, `updated_at`

**Budget:** `id`, `category_id`, `month` (`YYYY-MM`), `limit_amount` (int). Unik per (`category_id`, `month`).

**Setting:** `key`, `value`

Kategori bawaan pengeluaran: Makan, Transport, Belanja, Tagihan, Hiburan, Kesehatan, Pendidikan, Lainnya. Kategori bawaan pemasukan: Gaji, Bonus, Freelance, Hadiah, Lainnya.

## 10. Tahapan pengerjaan

| Tahap | Isi |
|---|---|
| M1. Fondasi | Tema dan token desain, database lokal, navigasi dan bottom bar |
| M2. Pencatatan | FR-01, FR-02, FR-03, FR-05 |
| M3. Dashboard dan riwayat | FR-06, FR-07 |
| M4. Laporan dan anggaran | FR-08, FR-09, FR-15 |
| M5. Penyempurnaan | FR-04, FR-10, FR-11, FR-12, pengujian, ikon aplikasi, rilis |

## 11. Risiko dan pertanyaan terbuka

| Hal | Usulan |
|---|---|
| Stack teknologi belum final | `AGENT.md` memakai Flutter + SQLite lokal sebagai default; ubah bila tim memilih lain. |
| Perlu login dan sinkronisasi di rilis berikutnya? | Tunda; rancang tabel dengan `id` yang stabil agar mudah disinkronkan nanti. |
| Apakah saldo awal wajib diisi? | Tidak wajib; default Rp 0. |
| Pengguna kehilangan data karena ganti HP | Ekspor CSV di MVP; backup/restore penuh di roadmap. |

## 12. Roadmap setelah MVP

Backup dan restore, kunci aplikasi, transaksi berulang, login dan sinkronisasi cloud, widget layar utama, dan dukungan iOS.
