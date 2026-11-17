import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../../core/theme/app_colors.dart';
import '../../data/providers/finance_providers.dart';
import '../accounts/accounts_screen.dart';
import '../categories/categories_screen.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  void _showThemeDialog(BuildContext context, WidgetRef ref) {
    final current = ref.read(themeModeProvider);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Pilih Tema'),
        content: RadioGroup<ThemeMode>(
          groupValue: current,
          onChanged: (val) {
            if (val != null) {
              ref.read(themeModeProvider.notifier).setThemeMode(val);
              Navigator.pop(ctx);
            }
          },
          child: const Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              RadioListTile<ThemeMode>(
                title: Text('Ikuti Sistem'),
                value: ThemeMode.system,
              ),
              RadioListTile<ThemeMode>(
                title: Text('Tema Terang'),
                value: ThemeMode.light,
              ),
              RadioListTile<ThemeMode>(
                title: Text('Tema Gelap'),
                value: ThemeMode.dark,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Edit Profile ───────────────────────────────────────────────────────

  void _showEditProfileSheet(
      BuildContext context, WidgetRef ref, String currentName) {
    final nameCtrl = TextEditingController(text: currentName);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          left: 20, right: 20, top: 20,
          bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(currentName.isEmpty ? 'Tambah Nama' : 'Edit Nama',
                    style: Theme.of(ctx).textTheme.titleMedium
                        ?.copyWith(fontWeight: FontWeight.w700)),
                IconButton(
                    icon: const Icon(Icons.close_rounded),
                    onPressed: () => Navigator.pop(ctx)),
              ],
            ),
            const SizedBox(height: 16),
            Text('Nama', style: Theme.of(ctx).textTheme.labelMedium),
            const SizedBox(height: 6),
            TextField(
              controller: nameCtrl,
              textCapitalization: TextCapitalization.words,
              decoration: InputDecoration(
                hintText: 'Masukkan nama kamu',
                filled: true,
                fillColor: Theme.of(ctx).colorScheme.surfaceContainerLow,
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 20),
            FilledButton(
              onPressed: () async {
                final name = nameCtrl.text.trim();
                final repo = ref.read(financeRepositoryProvider);
                await repo.setSetting('user_name', name);
                ref.invalidate(userNameProvider);
                if (ctx.mounted) Navigator.pop(ctx);
              },
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Simpan'),
            ),
          ],
        ),
      ),
    );
  }

  Future<String> _saveCsvFile(String csv) async {
    Directory targetDir;
    try {
      final downloads = await getDownloadsDirectory();
      if (downloads != null) {
        targetDir = Directory(p.join(downloads.path, 'dompetku_exports'));
      } else {
        final docs = await getApplicationDocumentsDirectory();
        targetDir = Directory(p.join(docs.path, 'dompetku_exports'));
      }
    } catch (_) {
      final docs = await getApplicationDocumentsDirectory();
      targetDir = Directory(p.join(docs.path, 'dompetku_exports'));
    }

    if (!await targetDir.exists()) {
      await targetDir.create(recursive: true);
    }

    final timestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
    final file = File(p.join(targetDir.path, 'transaksi_$timestamp.csv'));
    await file.writeAsString(csv);
    return file.path;
  }

  void _showExportCsvDialog(BuildContext context, WidgetRef ref) async {
    final now = DateTime.now();
    final start = DateTime(now.year, 1, 1);
    final repo = ref.read(financeRepositoryProvider);
    final csv = await repo.exportTransactionsCsv(start, now);

    if (context.mounted) {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Ekspor Transaksi (CSV)'),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Data CSV transaksi tahun berjalan:'),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Theme.of(ctx).colorScheme.surfaceContainerLow,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: SelectableText(
                    csv,
                    style: const TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 11,
                    ),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Tutup'),
            ),
            OutlinedButton.icon(
              icon: const Icon(Icons.copy_rounded, size: 16),
              label: const Text('Salin'),
              onPressed: () {
                Clipboard.setData(ClipboardData(text: csv));
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('CSV berhasil disalin ke clipboard'),
                  ),
                );
              },
            ),
            FilledButton.icon(
              icon: const Icon(Icons.download_rounded, size: 16),
              label: const Text('Simpan File'),
              onPressed: () async {
                Navigator.pop(ctx);
                try {
                  final savedPath = await _saveCsvFile(csv);
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Tersimpan di: $savedPath'),
                        duration: const Duration(seconds: 4),
                      ),
                    );
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Gagal menyimpan file: $e')),
                    );
                  }
                }
              },
            ),
          ],
        ),
      );
    }
  }

  // ── Backup ─────────────────────────────────────────────────────────────

  Future<void> _createBackup(BuildContext context, WidgetRef ref) async {
    try {
      final repo = ref.read(financeRepositoryProvider);
      final dbPath = await repo.getDbPath();
      final dbFile = File(dbPath);
      if (!await dbFile.exists()) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Database tidak ditemukan')),
          );
        }
        return;
      }
      final backupDir = await _getBackupDir();
      final stamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
      final backupPath = p.join(backupDir.path, 'dompetku_backup_$stamp.db');
      await dbFile.copy(backupPath);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Backup berhasil disimpan!\n$backupPath'),
            duration: const Duration(seconds: 4),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal backup: $e')),
        );
      }
    }
  }

  // ── Restore ────────────────────────────────────────────────────────────

  Future<void> _showRestoreDialog(BuildContext context, WidgetRef ref) async {
    try {
      final backupDir = await _getBackupDir();
      if (!await backupDir.exists()) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Belum ada file backup')),
          );
        }
        return;
      }
      final files = backupDir
          .listSync()
          .whereType<File>()
          .where((f) => f.path.endsWith('.db'))
          .toList()
        ..sort((a, b) => b.path.compareTo(a.path));
      if (files.isEmpty) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Belum ada file backup')),
          );
        }
        return;
      }
      if (!context.mounted) return;
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Pilih Backup'),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: files.length,
              itemBuilder: (_, i) {
                final name = p.basename(files[i].path);
                final stat = files[i].statSync();
                final sizeKb = (stat.size / 1024).toStringAsFixed(0);
                return ListTile(
                  leading: const Icon(Icons.storage_rounded),
                  title: Text(name, style: const TextStyle(fontSize: 13)),
                  subtitle: Text('$sizeKb KB'),
                  onTap: () {
                    Navigator.pop(ctx);
                    _confirmRestore(context, ref, files[i]);
                  },
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Batal'),
            ),
          ],
        ),
      );
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal membaca backup: $e')),
        );
      }
    }
  }

  void _confirmRestore(BuildContext context, WidgetRef ref, File backupFile) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Pulihkan Data?'),
        content: Text(
          'Semua data saat ini akan diganti dengan data dari backup "${p.basename(backupFile.path)}". Tindakan ini tidak dapat dibatalkan.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await _doRestore(context, ref, backupFile);
            },
            child: const Text('Pulihkan'),
          ),
        ],
      ),
    );
  }

  Future<void> _doRestore(
      BuildContext context, WidgetRef ref, File backupFile) async {
    try {
      final repo = ref.read(financeRepositoryProvider);
      final dbPath = await repo.getDbPath();
      final db = ref.read(databaseProvider);
      await db.close();
      await backupFile.copy(dbPath);
      ref.invalidate(databaseProvider);
      ref.invalidate(financeRepositoryProvider);
      ref.invalidate(homeDashboardProvider);
      ref.invalidate(filteredTransactionsProvider);
      ref.invalidate(accountsWithBalanceProvider);
      ref.invalidate(reportsDataProvider);
      ref.invalidate(userNameProvider);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Data berhasil dipulihkan dari backup')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal pulihkan: $e')),
        );
      }
    }
  }

  Future<Directory> _getBackupDir() async {
    final docs = await getApplicationDocumentsDirectory();
    final dir = Directory(p.join(docs.path, 'dompetku_backups'));
    if (!await dir.exists()) await dir.create(recursive: true);
    return dir;
  }

  void _showResetConfirmation(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Reset Semua Data?'),
        content: const Text(
          'Seluruh transaksi, dompet, dan anggaran akan dihapus dan dikembalikan ke setelan awal. Tindakan ini tidak dapat dibatalkan.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.expenseText,
            ),
            onPressed: () async {
              final repo = ref.read(financeRepositoryProvider);
              await repo.resetAllData();
              ref.invalidate(homeDashboardProvider);
              ref.invalidate(filteredTransactionsProvider);
              ref.invalidate(accountsWithBalanceProvider);
              ref.invalidate(reportsDataProvider);

              if (ctx.mounted) {
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Semua data berhasil di-reset')),
                );
              }
            },
            child: const Text('Hapus & Reset'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    final themeLabel = themeMode == ThemeMode.light
        ? 'Terang'
        : (themeMode == ThemeMode.dark ? 'Gelap' : 'Ikuti Sistem');

    final userName = ref.watch(userNameProvider).value ?? '';

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: Text(
          'Profil & Pengaturan',
          style: Theme.of(context).textTheme.titleLarge
              ?.copyWith(fontWeight: FontWeight.w700),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // User Header - tappable to edit
            GestureDetector(
              onTap: () => _showEditProfileSheet(context, ref, userName),
              child: Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainerLowest,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: Theme.of(context).colorScheme.outlineVariant,
                  ),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 28,
                      backgroundColor:
                          Theme.of(context).colorScheme.primaryContainer,
                      child: userName.isNotEmpty
                          ? Text(
                              userName[0].toUpperCase(),
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w700,
                                color: Theme.of(context)
                                    .colorScheme
                                    .onPrimaryContainer,
                              ),
                            )
                          : Icon(
                              Icons.person_outline_rounded,
                              size: 28,
                              color: Theme.of(context)
                                  .colorScheme
                                  .onPrimaryContainer,
                            ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            userName.isNotEmpty ? userName : 'Tambahkan Nama',
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(
                                  fontWeight: FontWeight.w700,
                                  color: userName.isNotEmpty
                                      ? null
                                      : Theme.of(context)
                                          .colorScheme
                                          .onSurfaceVariant,
                                ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            userName.isNotEmpty
                                ? 'Ketuk untuk mengubah nama'
                                : 'Ketuk untuk mengatur profil',
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall
                                ?.copyWith(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .outline,
                                ),
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      Icons.edit_outlined,
                      size: 20,
                      color: Theme.of(context).colorScheme.outline,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Preference Section
            Text(
              'Preferensi',
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                fontWeight: FontWeight.w700,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 8),
            _buildSettingTile(
              context,
              icon: Icons.palette_outlined,
              title: 'Tema Tampilan',
              trailingText: themeLabel,
              onTap: () => _showThemeDialog(context, ref),
            ),
            const SizedBox(height: 20),

            // Data Management Section
            Text(
              'Manajemen Data',
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                fontWeight: FontWeight.w700,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 8),
            _buildSettingTile(
              context,
              icon: Icons.account_balance_wallet_outlined,
              title: 'Kelola Dompet & Akun',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const AccountsScreen()),
                );
              },
            ),
            _buildSettingTile(
              context,
              icon: Icons.category_outlined,
              title: 'Kelola Kategori',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const CategoriesScreen()),
                );
              },
            ),
            _buildSettingTile(
              context,
              icon: Icons.file_download_outlined,
              title: 'Ekspor Data (CSV)',
              onTap: () => _showExportCsvDialog(context, ref),
            ),
            const SizedBox(height: 20),

            // Backup & Restore Section
            Text(
              'Cadangan & Pemulihan',
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                fontWeight: FontWeight.w700,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 8),
            _buildSettingTile(
              context,
              icon: Icons.backup_outlined,
              title: 'Buat Cadangan (Backup)',
              onTap: () => _createBackup(context, ref),
            ),
            _buildSettingTile(
              context,
              icon: Icons.restore_rounded,
              title: 'Pulihkan Cadangan (Restore)',
              onTap: () => _showRestoreDialog(context, ref),
            ),
            const SizedBox(height: 20),

            // Danger Zone
            Text(
              'Zona Berbahaya',
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                fontWeight: FontWeight.w700,
                color: AppColors.expenseText,
              ),
            ),
            const SizedBox(height: 8),
            _buildSettingTile(
              context,
              icon: Icons.delete_forever_outlined,
              title: 'Reset Semua Data',
              titleColor: AppColors.expenseText,
              iconColor: AppColors.expenseText,
              onTap: () => _showResetConfirmation(context, ref),
            ),
            const SizedBox(height: 24),

            // About Section
            Center(
              child: Column(
                children: [
                  Text(
                    'SakuKu v1.0.0',
                    style: TextStyle(
                      fontSize: 12,
                      color: Theme.of(context).colorScheme.outline,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Kelola keuangan harian lebih tenang',
                    style: TextStyle(
                      fontSize: 11,
                      color: Theme.of(context).colorScheme.outlineVariant,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    String? trailingText,
    Color? titleColor,
    Color? iconColor,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
      ),
      child: ListTile(
        onTap: onTap,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        leading: Icon(
          icon,
          color: iconColor ?? Theme.of(context).colorScheme.primary,
          size: 22,
        ),
        title: Text(
          title,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: titleColor ?? Theme.of(context).colorScheme.onSurface,
          ),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (trailingText != null) ...[
              Text(
                trailingText,
                style: TextStyle(
                  fontSize: 13,
                  color: Theme.of(context).colorScheme.outline,
                ),
              ),
              const SizedBox(width: 6),
            ],
            Icon(
              Icons.chevron_right_rounded,
              color: Theme.of(context).colorScheme.outline,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}
