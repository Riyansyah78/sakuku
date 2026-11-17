import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../core/theme/app_colors.dart';
import '../../core/utils/date.dart';
import '../../core/utils/icon_utils.dart';
import '../../core/utils/money.dart';
import '../../data/models/transaction_model.dart';
import '../../data/providers/finance_providers.dart';
import 'add_transaction_screen.dart';

class TransactionsScreen extends ConsumerStatefulWidget {
  const TransactionsScreen({super.key});

  @override
  ConsumerState<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends ConsumerState<TransactionsScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _previousMonth() {
    final current = ref.read(transactionFilterProvider).month ?? DateTime.now();
    final prev = DateTime(current.year, current.month - 1, 1);
    ref.read(transactionFilterProvider.notifier).setMonth(prev);
  }

  void _nextMonth() {
    final current = ref.read(transactionFilterProvider).month ?? DateTime.now();
    final next = DateTime(current.year, current.month + 1, 1);
    ref.read(transactionFilterProvider.notifier).setMonth(next);
  }

  Map<String, List<TransactionDetailModel>> _groupByDate(
    List<TransactionDetailModel> list,
  ) {
    final Map<String, List<TransactionDetailModel>> groups = {};
    for (final item in list) {
      final dateKey = DateFormat('yyyy-MM-dd')
          .format(item.transaction.occurredAt);
      groups.putIfAbsent(dateKey, () => []).add(item);
    }
    return groups;
  }

  String _formatHeaderDate(DateTime dt) {
    if (DateUtilsId.isToday(dt)) return 'Hari Ini';
    if (DateUtilsId.isYesterday(dt)) return 'Kemarin';
    return DateUtilsId.formatMedium(dt);
  }

  @override
  Widget build(BuildContext context) {
    final filter = ref.watch(transactionFilterProvider);
    final txsAsync = ref.watch(filteredTransactionsProvider);
    final currentMonth = filter.month ?? DateTime.now();

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: Text(
          'Transaksi',
          style: Theme.of(context).textTheme.titleLarge
              ?.copyWith(fontWeight: FontWeight.w700),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_rounded),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AddTransactionScreen()),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Month Selector
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            color: Theme.of(context).colorScheme.surfaceContainerLowest,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: const Icon(Icons.chevron_left_rounded),
                  onPressed: _previousMonth,
                ),
                Text(
                  DateUtilsId.formatMonthYear(currentMonth),
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    letterSpacing: -0.2,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.chevron_right_rounded),
                  onPressed: _nextMonth,
                ),
              ],
            ),
          ),

          // Search Field
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Cari catatan, kategori, dompet...',
                hintStyle: TextStyle(
                  fontSize: 14,
                  color: Theme.of(context).colorScheme.outline,
                ),
                prefixIcon: const Icon(Icons.search_rounded, size: 20),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear_rounded, size: 18),
                        onPressed: () {
                          _searchController.clear();
                          ref
                              .read(transactionFilterProvider.notifier)
                              .setQuery('');
                        },
                      )
                    : null,
                filled: true,
                fillColor: Theme.of(context).colorScheme.surfaceContainerLow,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 8,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: Theme.of(context).colorScheme.outlineVariant,
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: Theme.of(context).colorScheme.outlineVariant,
                  ),
                ),
              ),
              onChanged: (val) {
                ref.read(transactionFilterProvider.notifier).setQuery(val);
              },
            ),
          ),

          // Filter Chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                _buildFilterChip(
                  label: 'Semua',
                  isSelected: filter.type == null,
                  onSelected: () => ref
                      .read(transactionFilterProvider.notifier)
                      .setType(null),
                ),
                const SizedBox(width: 8),
                _buildFilterChip(
                  label: 'Pengeluaran',
                  isSelected: filter.type == TransactionType.expense,
                  onSelected: () => ref
                      .read(transactionFilterProvider.notifier)
                      .setType(TransactionType.expense),
                ),
                const SizedBox(width: 8),
                _buildFilterChip(
                  label: 'Pemasukan',
                  isSelected: filter.type == TransactionType.income,
                  onSelected: () => ref
                      .read(transactionFilterProvider.notifier)
                      .setType(TransactionType.income),
                ),
                const SizedBox(width: 8),
                _buildFilterChip(
                  label: 'Transfer',
                  isSelected: filter.type == TransactionType.transfer,
                  onSelected: () => ref
                      .read(transactionFilterProvider.notifier)
                      .setType(TransactionType.transfer),
                ),
                const SizedBox(width: 8),
                _buildFilterChip(
                  label: 'Penyesuaian',
                  isSelected: filter.type == TransactionType.adjustment,
                  onSelected: () => ref
                      .read(transactionFilterProvider.notifier)
                      .setType(TransactionType.adjustment),
                ),
              ],
            ),
          ),

          const Divider(height: 1),

          // Transactions Grouped List
          Expanded(
            child: txsAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) =>
                  Center(child: Text('Gagal memuat transaksi: $e')),
              data: (transactions) {
                if (transactions.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.receipt_long_outlined,
                          size: 56,
                          color: Theme.of(context).colorScheme.outlineVariant,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Belum ada transaksi',
                          style: Theme.of(context).textTheme.titleSmall
                              ?.copyWith(
                                color: Theme.of(context)
                                    .colorScheme
                                    .onSurfaceVariant,
                              ),
                        ),
                        const SizedBox(height: 16),
                        FilledButton.tonalIcon(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const AddTransactionScreen(),
                              ),
                            );
                          },
                          icon: const Icon(Icons.add_rounded),
                          label: const Text('Catat Transaksi'),
                        ),
                      ],
                    ),
                  );
                }

                final grouped = _groupByDate(transactions);
                final dateKeys = grouped.keys.toList();

                return ListView.builder(
                  padding: const EdgeInsets.only(bottom: 100),
                  itemCount: dateKeys.length,
                  itemBuilder: (context, index) {
                    final dateKey = dateKeys[index];
                    final dayTxs = grouped[dateKey]!;
                    final firstTxDate = dayTxs.first.transaction.occurredAt;

                    // Daily total net
                    int dayNet = 0;
                    for (final t in dayTxs) {
                      if (t.transaction.type == TransactionType.income) {
                        dayNet += t.transaction.amount;
                      } else if (t.transaction.type ==
                          TransactionType.expense) {
                        dayNet -= t.transaction.amount;
                      } else if (t.transaction.type ==
                          TransactionType.adjustment) {
                        dayNet += t.transaction.amount;
                      }
                    }

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Date Header
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16, 16, 16, 6),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                _formatHeaderDate(firstTxDate),
                                style: Theme.of(context).textTheme.labelLarge
                                    ?.copyWith(
                                      fontWeight: FontWeight.w700,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSurfaceVariant,
                                    ),
                              ),
                              Text(
                                dayNet >= 0
                                    ? '+${MoneyUtils.format(dayNet)}'
                                    : '-${MoneyUtils.format(dayNet.abs())}',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: dayNet >= 0
                                      ? AppColors.incomeText
                                      : AppColors.expenseText,
                                ),
                              ),
                            ],
                          ),
                        ),

                        // List items
                        ...dayTxs.map((item) {
                          return _buildTransactionTile(context, item);
                        }),
                      ],
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip({
    required String label,
    required bool isSelected,
    required VoidCallback onSelected,
  }) {
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) => onSelected(),
      showCheckmark: false,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    );
  }

  Widget _buildTransactionTile(
    BuildContext context,
    TransactionDetailModel item,
  ) {
    final tx = item.transaction;
    final isIncome = tx.type == TransactionType.income;
    final isExpense = tx.type == TransactionType.expense;
    final isTransfer = tx.type == TransactionType.transfer;
    final isAdjustment = tx.type == TransactionType.adjustment;

    final title = isAdjustment
        ? 'Penyesuaian Saldo'
        : isTransfer
        ? 'Transfer ke ${item.toAccountName ?? "Dompet"}'
        : (item.categoryName ?? (isIncome ? 'Pemasukan' : 'Pengeluaran'));

    final subtitle = [
      DateUtilsId.formatTime(tx.occurredAt),
      item.accountName,
      if (tx.note != null && tx.note!.isNotEmpty) tx.note!,
    ].join(' • ');

    final iconData = isTransfer
        ? Icons.swap_horiz_rounded
        : (item.categoryIcon != null
              ? IconUtils.resolveIcon(item.categoryIcon!)
              : (isIncome
                    ? Icons.arrow_downward_rounded
                    : Icons.shopping_bag_outlined));

    final iconColor = isTransfer
        ? Theme.of(context).colorScheme.primary
        : (item.categoryColor != null
              ? Color(item.categoryColor!)
              : AppColors.brandPrimary);

    final amountColor = isAdjustment
        ? (tx.amount >= 0 ? AppColors.incomeText : AppColors.expenseText)
        : isIncome
        ? AppColors.incomeText
        : isExpense
        ? AppColors.expenseText
        : Theme.of(context).colorScheme.primary;

    final prefix = isIncome ? '+' : (isExpense ? '-' : '');
    final amountText = isAdjustment
        ? MoneyUtils.formatSigned(tx.amount)
        : '$prefix${MoneyUtils.format(tx.amount)}';

    return Dismissible(
      key: Key(tx.id),
      direction: DismissDirection.endToStart,
      background: Container(
        color: AppColors.expenseText,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: const Icon(Icons.delete_outline_rounded, color: Colors.white),
      ),
      confirmDismiss: (dir) async {
        return await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Hapus Transaksi?'),
            content: const Text(
              'Transaksi yang dihapus tidak dapat dikembalikan.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text('Batal'),
              ),
              FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.expenseText,
                ),
                onPressed: () => Navigator.pop(ctx, true),
                child: const Text('Hapus'),
              ),
            ],
          ),
        );
      },
      onDismissed: (_) async {
        final repo = ref.read(financeRepositoryProvider);
        await repo.deleteTransaction(tx.id);
        ref.invalidate(filteredTransactionsProvider);
        ref.invalidate(homeDashboardProvider);
        ref.invalidate(accountsWithBalanceProvider);
        ref.invalidate(reportsDataProvider);

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Transaksi dihapus'),
              action: SnackBarAction(
                label: 'Urungkan',
                onPressed: () async {
                  await repo.addTransaction(tx);
                  ref.invalidate(filteredTransactionsProvider);
                  ref.invalidate(homeDashboardProvider);
                  ref.invalidate(accountsWithBalanceProvider);
                  ref.invalidate(reportsDataProvider);
                },
              ),
            ),
          );
        }
      },
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => AddTransactionScreen(initialDetail: item),
            ),
          );
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: Theme.of(context).colorScheme.outlineVariant
                    .withValues(alpha: 0.3),
                width: 0.8,
              ),
            ),
          ),
          child: Row(
            children: [
              // Category / Transfer Icon
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(iconData, color: iconColor, size: 22),
              ),
              const SizedBox(width: 12),

              // Title and Note
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.bodyLarge
                          ?.copyWith(fontWeight: FontWeight.w600),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),

              // Amount
              Text(
                amountText,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: amountColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
