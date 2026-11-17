import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_colors.dart';
import '../../core/utils/icon_utils.dart';
import '../../core/utils/money.dart';
import '../../data/models/account_model.dart';
import '../../data/providers/finance_providers.dart';
import '../transactions/add_transaction_screen.dart';

class AccountsScreen extends ConsumerWidget {
  const AccountsScreen({super.key});

  void _showAddEditAccountDialog(
    BuildContext context,
    WidgetRef ref, [
    AccountModel? initial,
    int? currentBalance,
  ]) {
    final nameController = TextEditingController(text: initial?.name ?? '');
    final balanceController = TextEditingController(
      text: (currentBalance ?? initial?.initialBalance ?? 0).toString(),
    );
    AccountType selectedType = initial?.type ?? AccountType.bank;
    String selectedIcon = initial?.icon ?? 'account_balance';
    int selectedColor = initial?.color ?? AppColors.calmPalette.first;

    final availableIcons = [
      'account_balance',
      'payments',
      'account_balance_wallet',
      'credit_card',
      'savings',
    ];
    final availableColors = AppColors.calmPalette;

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setState) {
            return AlertDialog(
              title: Text(initial != null ? 'Ubah Dompet' : 'Tambah Dompet'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    TextField(
                      controller: nameController,
                      decoration: const InputDecoration(
                        labelText: 'Nama Dompet (cth: BCA, Dompet Utama)',
                      ),
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<AccountType>(
                      initialValue: selectedType,
                      decoration: const InputDecoration(
                        labelText: 'Tipe Dompet',
                      ),
                      items: const [
                        DropdownMenuItem(
                          value: AccountType.cash,
                          child: Text('Tunai (Cash)'),
                        ),
                        DropdownMenuItem(
                          value: AccountType.bank,
                          child: Text('Rekening Bank'),
                        ),
                        DropdownMenuItem(
                          value: AccountType.ewallet,
                          child: Text('E-Wallet'),
                        ),
                      ],
                      onChanged: (val) {
                        if (val != null) setState(() => selectedType = val);
                      },
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: balanceController,
                      keyboardType: const TextInputType.numberWithOptions(
                        signed: true,
                      ),
                      decoration: InputDecoration(
                        labelText: initial == null
                            ? 'Saldo Awal (Rp)'
                            : 'Saldo Saat Ini (Rp)',
                        prefixText: 'Rp ',
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Pilih Ikon',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: availableIcons.map((ic) {
                        final isSel = selectedIcon == ic;
                        return GestureDetector(
                          onTap: () => setState(() => selectedIcon = ic),
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: isSel
                                  ? Theme.of(ctx).colorScheme.primaryContainer
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: isSel
                                    ? Theme.of(ctx).colorScheme.primary
                                    : Colors.grey.shade300,
                              ),
                            ),
                            child: Icon(IconUtils.resolveIcon(ic), size: 22),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Pilih Warna',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: availableColors.map((col) {
                        final isSel = selectedColor == col;
                        return GestureDetector(
                          onTap: () => setState(() => selectedColor = col),
                          child: Container(
                            width: 28,
                            height: 28,
                            decoration: BoxDecoration(
                              color: Color(col),
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: isSel
                                    ? Colors.black
                                    : Colors.transparent,
                                width: 2,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('Batal'),
                ),
                FilledButton(
                  onPressed: () async {
                    final name = nameController.text.trim();
                    if (name.isEmpty) return;
                    final targetBalance = int.tryParse(
                      balanceController.text.replaceAll(RegExp(r'[^0-9-]'), ''),
                    );
                    if (targetBalance == null) return;
                    final repo = ref.read(financeRepositoryProvider);

                    if (initial != null) {
                      final updated = initial.copyWith(
                        name: name,
                        type: selectedType,
                        icon: selectedIcon,
                        color: selectedColor,
                      );
                      await repo.updateAccount(updated);
                      await repo.adjustAccountBalance(
                        initial.id,
                        targetBalance,
                      );
                    } else {
                      final newAcc = AccountModel(
                        id: 'acc_${DateTime.now().millisecondsSinceEpoch}',
                        name: name,
                        type: selectedType,
                        initialBalance: targetBalance,
                        icon: selectedIcon,
                        color: selectedColor,
                        createdAt: DateTime.now(),
                      );
                      await repo.addAccount(newAcc);
                    }

                    ref.invalidate(accountsWithBalanceProvider);
                    ref.invalidate(homeDashboardProvider);
                    if (ctx.mounted) Navigator.pop(ctx);
                  },
                  child: const Text('Simpan'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showArchiveConfirmation(
    BuildContext context,
    WidgetRef ref,
    AccountModel account,
  ) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Arsipkan Dompet?'),
        content: Text(
          'Dompet "${account.name}" akan disembunyikan dan tidak muncul di pilihan transaksi baru.',
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
              await repo.archiveAccount(account.id);
              ref.invalidate(accountsWithBalanceProvider);
              ref.invalidate(homeDashboardProvider);
              if (ctx.mounted) Navigator.pop(ctx);
            },
            child: const Text('Arsipkan'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final accountsAsync = ref.watch(accountsWithBalanceProvider);

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: Text(
          'Kelola Dompet',
          style: Theme.of(context).textTheme.titleLarge
              ?.copyWith(fontWeight: FontWeight.w700),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddEditAccountDialog(context, ref),
        icon: const Icon(Icons.add_rounded),
        label: const Text('Tambah Dompet'),
      ),
      body: accountsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (accounts) {
          int totalSaldo = 0;
          for (final a in accounts) {
            totalSaldo += a.currentBalance;
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Total Balance Card
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Theme.of(context).brightness == Brightness.dark
                        ? AppColors.balanceCardDark
                        : AppColors.balanceCardLight,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.08),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Total Saldo Seluruh Dompet',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        MoneyUtils.format(totalSaldo),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 26,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          FilledButton.tonal(
                            style: FilledButton.styleFrom(
                              backgroundColor: Colors.white.withValues(
                                alpha: 0.2,
                              ),
                              foregroundColor: Colors.white,
                            ),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const AddTransactionScreen(),
                                ),
                              );
                            },
                            child: const Row(
                              children: [
                                Icon(Icons.swap_horiz_rounded, size: 18),
                                SizedBox(width: 6),
                                Text('Transfer Saldo'),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                Text(
                  'Daftar Dompet (${accounts.length})',
                  style: Theme.of(context).textTheme.titleSmall
                      ?.copyWith(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 12),

                ...accounts.map((a) {
                  final acc = a.account;
                  final iconData = IconUtils.resolveIcon(acc.icon);
                  final color = Color(acc.color);

                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Theme.of(context)
                          .colorScheme
                          .surfaceContainerLowest,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: Theme.of(context).colorScheme.outlineVariant,
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: color.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(iconData, color: color, size: 22),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                acc.name,
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                acc.type.name.toUpperCase(),
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: Theme.of(context).colorScheme.outline,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              MoneyUtils.format(a.currentBalance),
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                InkWell(
                                  onTap: () => _showAddEditAccountDialog(
                                    context,
                                    ref,
                                    acc,
                                    a.currentBalance,
                                  ),
                                  child: Icon(
                                    Icons.edit_outlined,
                                    size: 18,
                                    color: Theme.of(context)
                                        .colorScheme
                                        .outline,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                InkWell(
                                  onTap: () => _showArchiveConfirmation(
                                    context,
                                    ref,
                                    acc,
                                  ),
                                  child: const Icon(
                                    Icons.archive_outlined,
                                    size: 18,
                                    color: AppColors.expenseText,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                }),
              ],
            ),
          );
        },
      ),
    );
  }
}
