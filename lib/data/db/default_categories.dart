import 'package:drift/drift.dart';
import 'app_database.dart';

/// All default categories seeded on first install or migration.
/// Covers comprehensive real-world expense & income types.
List<CategoriesTableCompanion> get defaultCategories => [
  // ─── PENGELUARAN (expense) ────────────────────────────────────────

  // Makanan & Minuman
  _exp('cat_makanan', 'Makanan & Minuman', 'restaurant', 0xFFF59E0B),
  _exp('cat_groceries', 'Groceries / Belanja Dapur', 'local_grocery_store', 0xFF84CC16),
  _exp('cat_kopi', 'Kopi & Cafe', 'local_cafe', 0xFF92400E),

  // Transportasi
  _exp('cat_transport', 'Transportasi', 'directions_bus', 0xFF3B82F6),
  _exp('cat_bensin', 'Bensin & BBM', 'local_gas_station', 0xFFEF4444),
  _exp('cat_parkir_tol', 'Parkir & Tol', 'local_parking', 0xFF64748B),
  _exp('cat_kendaraan', 'Perawatan Kendaraan', 'build', 0xFF78716C),

  // Tempat Tinggal
  _exp('cat_sewa', 'Sewa / Kos / KPR', 'home', 0xFF6366F1),
  _exp('cat_listrik_air', 'Listrik, Air & Gas', 'bolt', 0xFF0EA5E9),
  _exp('cat_internet', 'Internet & TV Kabel', 'wifi', 0xFF0284C7),
  _exp('cat_perbaikan_rumah', 'Perbaikan Rumah', 'home_repair_service', 0xFFA16207),

  // Belanja & Gaya Hidup
  _exp('cat_belanja', 'Belanja / Shopping', 'shopping_bag', 0xFFA855F7),
  _exp('cat_pakaian', 'Pakaian & Aksesoris', 'checkroom', 0xFFEC4899),
  _exp('cat_elektronik', 'Elektronik & Gadget', 'devices', 0xFF475569),
  _exp('cat_perawatan_diri', 'Perawatan Diri & Salon', 'spa', 0xFFF472B6),
  _exp('cat_laundry', 'Laundry & Dry Clean', 'local_laundry_service', 0xFF38BDF8),

  // Tagihan & Langganan
  _exp('cat_tagihan', 'Tagihan & Utilitas', 'receipt_long', 0xFF06B6D4),
  _exp('cat_pulsa', 'Pulsa & Paket Data', 'phone_android', 0xFF10B981),
  _exp('cat_langganan', 'Langganan (Streaming, SaaS)', 'subscriptions', 0xFF8B5CF6),
  _exp('cat_asuransi', 'Asuransi', 'health_and_safety', 0xFF059669),

  // Hiburan & Rekreasi
  _exp('cat_hiburan', 'Hiburan & Rekreasi', 'sports_esports', 0xFFEC4899),
  _exp('cat_liburan', 'Liburan & Travel', 'flight', 0xFF0891B2),
  _exp('cat_hotel', 'Hotel & Penginapan', 'hotel', 0xFF7C3AED),
  _exp('cat_olahraga', 'Olahraga & Gym', 'fitness_center', 0xFFDC2626),
  _exp('cat_hobi', 'Hobi & Kreativitas', 'palette', 0xFFF97316),

  // Kesehatan
  _exp('cat_kesehatan', 'Kesehatan & Medis', 'medical_services', 0xFF84CC16),
  _exp('cat_obat', 'Obat & Apotek', 'medication', 0xFF22C55E),

  // Pendidikan
  _exp('cat_pendidikan', 'Pendidikan & Kursus', 'school', 0xFF6366F1),
  _exp('cat_buku', 'Buku & Materi Belajar', 'menu_book', 0xFF4338CA),

  // Keluarga & Sosial
  _exp('cat_anak', 'Anak & Keluarga', 'child_care', 0xFFFB923C),
  _exp('cat_hadiah_keluar', 'Hadiah & Sumbangan', 'card_giftcard', 0xFFE11D48),
  _exp('cat_donasi', 'Donasi & Amal', 'volunteer_activism', 0xFF10B981),
  _exp('cat_zakat', 'Zakat & Infaq', 'mosque', 0xFF059669),

  // Hewan Peliharaan
  _exp('cat_peliharaan', 'Hewan Peliharaan', 'pets', 0xFFD97706),

  // Pajak & Pemerintah
  _exp('cat_pajak', 'Pajak', 'account_balance', 0xFF1E3A5F),
  _exp('cat_denda', 'Denda & Biaya Admin', 'gavel', 0xFFB91C1C),

  // Utang & Cicilan
  _exp('cat_cicilan', 'Cicilan & Kredit', 'credit_card', 0xFF7C3AED),
  _exp('cat_pinjaman', 'Bayar Pinjaman', 'payments', 0xFF4F46E5),

  // Tabungan & Investasi (outflow)
  _exp('cat_tabungan', 'Tabungan & Deposito', 'savings', 0xFF0D9488),
  _exp('cat_investasi_keluar', 'Investasi (Beli)', 'trending_up', 0xFF047857),

  // Bisnis & Pekerjaan
  _exp('cat_biaya_bisnis', 'Biaya Bisnis / Usaha', 'store', 0xFF1D4ED8),
  _exp('cat_alat_kerja', 'Alat & Perlengkapan Kerja', 'construction', 0xFF854D0E),
  _exp('cat_marketing', 'Marketing & Iklan', 'campaign', 0xFFDB2777),

  // Lainnya
  _exp('cat_darurat', 'Dana Darurat', 'warning', 0xFFDC2626),
  _exp('cat_lainnya_exp', 'Lainnya', 'more_horiz', 0xFF64748B),

  // ─── PEMASUKAN (income) ───────────────────────────────────────────

  // Gaji & Upah
  _inc('cat_gaji', 'Gaji Bulanan', 'payments', 0xFF10B981),
  _inc('cat_gaji_harian', 'Upah Harian / Mingguan', 'access_time', 0xFF059669),
  _inc('cat_lembur', 'Lembur & Overtime', 'schedule', 0xFF0D9488),
  _inc('cat_thr', 'THR & Bonus Tahunan', 'celebration', 0xFFF59E0B),
  _inc('cat_bonus', 'Bonus & Insentif', 'redeem', 0xFFEAB308),
  _inc('cat_komisi', 'Komisi & Fee', 'handshake', 0xFF0EA5E9),
  _inc('cat_tip', 'Tip & Service Charge', 'volunteer_activism', 0xFF14B8A6),

  // Freelance & Jasa
  _inc('cat_freelance', 'Freelance & Proyek', 'work', 0xFF3B82F6),
  _inc('cat_konsultasi', 'Konsultasi & Advisory', 'support_agent', 0xFF6366F1),
  _inc('cat_desain', 'Desain & Kreatif', 'palette', 0xFFA855F7),
  _inc('cat_programming', 'Programming & IT', 'code', 0xFF475569),
  _inc('cat_penulisan', 'Penulisan & Content', 'edit', 0xFF7C3AED),
  _inc('cat_fotografi', 'Fotografi & Videografi', 'camera_alt', 0xFFE11D48),
  _inc('cat_musik', 'Musik & Seni', 'music_note', 0xFFDB2777),
  _inc('cat_mengajar', 'Mengajar & Tutor', 'school', 0xFF2563EB),
  _inc('cat_jasa_lain', 'Jasa Lainnya', 'engineering', 0xFF64748B),

  // Bisnis & Usaha
  _inc('cat_penjualan', 'Penjualan / Jualan', 'store', 0xFF059669),
  _inc('cat_toko_online', 'Toko Online (E-Commerce)', 'shopping_cart', 0xFFF97316),
  _inc('cat_sewa_masuk', 'Pendapatan Sewa / Kos', 'apartment', 0xFF0891B2),
  _inc('cat_usaha', 'Laba Usaha / Bisnis', 'business_center', 0xFF1D4ED8),
  _inc('cat_waralaba', 'Waralaba & Franchise', 'storefront', 0xFF15803D),

  // Pertanian & Peternakan
  _inc('cat_pertanian', 'Pertanian & Perkebunan', 'grass', 0xFF16A34A),
  _inc('cat_peternakan', 'Peternakan & Perikanan', 'pets', 0xFF65A30D),

  // Investasi & Pasif
  _inc('cat_dividen', 'Dividen Saham', 'trending_up', 0xFF10B981),
  _inc('cat_bunga', 'Bunga Deposito / Tabungan', 'account_balance', 0xFF0284C7),
  _inc('cat_capital_gain', 'Capital Gain', 'show_chart', 0xFF047857),
  _inc('cat_crypto', 'Crypto & Digital Asset', 'currency_bitcoin', 0xFFF59E0B),
  _inc('cat_royalti', 'Royalti & Lisensi', 'copyright', 0xFF8B5CF6),
  _inc('cat_passive', 'Pendapatan Pasif Lain', 'auto_awesome', 0xFF14B8A6),

  // Transfer & Bantuan
  _inc('cat_kiriman', 'Kiriman / Remittance', 'send', 0xFF3B82F6),
  _inc('cat_hadiah_masuk', 'Hadiah & Pemberian', 'card_giftcard', 0xFFEC4899),
  _inc('cat_warisan', 'Warisan', 'real_estate_agent', 0xFF7C3AED),
  _inc('cat_bantuan', 'Bantuan Sosial / Subsidi', 'volunteer_activism', 0xFF059669),

  // Pengembalian
  _inc('cat_refund', 'Refund & Cashback', 'replay', 0xFF0EA5E9),
  _inc('cat_klaim_asuransi', 'Klaim Asuransi', 'health_and_safety', 0xFF22C55E),
  _inc('cat_piutang', 'Pelunasan Piutang', 'request_quote', 0xFF0D9488),

  // Lainnya
  _inc('cat_lainnya_inc', 'Lainnya', 'more_horiz', 0xFF64748B),
];

CategoriesTableCompanion _exp(String id, String name, String icon, int color) =>
    CategoriesTableCompanion.insert(
      id: id,
      name: name,
      type: 'expense',
      icon: icon,
      color: _calmColor(color),
      isDefault: const Value(true),
    );

CategoriesTableCompanion _inc(String id, String name, String icon, int color) =>
    CategoriesTableCompanion.insert(
      id: id,
      name: name,
      type: 'income',
      icon: icon,
      color: _calmColor(color),
      isDefault: const Value(true),
    );

int _calmColor(int color) {
  if (color == 0xFF64748B || color == 0xFF475569 ||
      color == 0xFF78716C) {
    return 0xFF78827B;
  }
  if (color == 0xFF92400E || color == 0xFFA16207 ||
      color == 0xFF854D0E) {
    return 0xFFA47D52;
  }
  if (color == 0xFF059669 || color == 0xFF047857 || color == 0xFF10B981 ||
      color == 0xFF0D9488 || color == 0xFF14B8A6 || color == 0xFF16A34A ||
      color == 0xFF15803D || color == 0xFF22C55E || color == 0xFF65A30D) {
    return 0xFF73977D;
  }
  if (color == 0xFFF59E0B || color == 0xFFEAB308 || color == 0xFFF97316 ||
      color == 0xFFFB923C || color == 0xFFD97706 || color == 0xFFA16207 ||
      color == 0xFF854D0E) {
    return 0xFFA47D52;
  }
  if (color == 0xFF3B82F6 || color == 0xFF0EA5E9 || color == 0xFF0284C7 ||
      color == 0xFF0891B2 || color == 0xFF1D4ED8 || color == 0xFF2563EB ||
      color == 0xFF4338CA || color == 0xFF4F46E5) {
    return 0xFF637F91;
  }
  if (color == 0xFF6366F1 || color == 0xFF8B5CF6 || color == 0xFF7C3AED ||
      color == 0xFFA855F7) {
    return 0xFF887594;
  }
  if (color == 0xFF06B6D4 || color == 0xFF38BDF8) {
    return 0xFF5E8584;
  }
  if (color == 0xFFEC4899 || color == 0xFFF472B6 || color == 0xFFDB2777 ||
      color == 0xFFE11D48) {
    return 0xFFA87578;
  }
  if (color == 0xFF84CC16) return 0xFF718A63;
  if (color == 0xFFDC2626 || color == 0xFFEF4444 || color == 0xFFB91C1C) {
    return 0xFFA45F56;
  }
  return color;
}
