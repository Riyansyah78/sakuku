import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_radius.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/utils/date.dart';
import '../../core/utils/money.dart';
import '../../data/models/budget_model.dart';
import '../../data/models/transaction_model.dart';
import '../../data/providers/finance_providers.dart';
import '../../data/repositories/finance_repository.dart';
import '../accounts/accounts_screen.dart';
import '../budget/budget_screen.dart';
import '../transactions/add_transaction_screen.dart';
import '../transactions/transactions_screen.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dashboardAsync = ref.watch(homeDashboardProvider);
    final selectedMonth = ref.watch(selectedMonthProvider);
    final isHidden = ref.watch(isBalanceHiddenProvider);

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: SafeArea(
        bottom: false,
        child: dashboardAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text('Error: $e')),
          data: (data) => CustomScrollView(
            slivers: [
              SliverAppBar(
                pinned: true,
                backgroundColor: Theme.of(context).colorScheme.surface
                    .withValues(alpha: 0.85),
                surfaceTintColor: Colors.transparent,
                elevation: 0,
                scrolledUnderElevation: 1,
                expandedHeight: 64,
                flexibleSpace: FlexibleSpaceBar(
                  background: _AppHeader(
                    selectedMonth: selectedMonth,
                    ref: ref,
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.gutter,
                    vertical: AppSpacing.lg,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _GreetingRow(selectedMonth: selectedMonth, ref: ref),
                      const SizedBox(height: AppSpacing.lg),
                      _BalanceCard(data: data, isHidden: isHidden, ref: ref),
                      const SizedBox(height: AppSpacing.lg),
                      _DailySummaryCard(data: data, isHidden: isHidden),
                      const SizedBox(height: AppSpacing.lg),
                      _BudgetCard(data: data, selectedMonth: selectedMonth),
                      const SizedBox(height: AppSpacing.lg),
                      _RecentTransactions(data: data),
                      const SizedBox(height: 120), // nav bar clearance
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AppHeader extends StatelessWidget {
  final DateTime selectedMonth;
  final WidgetRef ref;

  const _AppHeader({required this.selectedMonth, required this.ref});

  void _showNotificationsSheet(BuildContext context) {
    final dashboard = ref.read(homeDashboardProvider).value;
    final budgets = dashboard?.budgetBreakdown ?? [];
    final alerts = budgets.where((b) => b.isWarning || b.isExceeded).toList();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Theme.of(ctx).colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Theme.of(ctx).colorScheme.outlineVariant,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Icon(
                  alerts.isEmpty
                      ? Icons.notifications_none_rounded
                      : Icons.notifications_active_rounded,
                  color: alerts.isEmpty
                      ? Theme.of(ctx).colorScheme.primary
                      : Theme.of(ctx).colorScheme.error,
                ),
                const SizedBox(width: 8),
                Text(
                  'Notifikasi & Peringatan',
                  style: Theme.of(ctx).textTheme.titleLarge
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (alerts.isEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(ctx).colorScheme.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    Icon(
                      Icons.check_circle_outline_rounded,
                      size: 40,
                      color: Theme.of(ctx).colorScheme.primary,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Semua Anggaran Aman',
                      style: Theme.of(ctx).textTheme.titleMedium
                          ?.copyWith(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Tidak ada kategori anggaran yang melebihi atau mendekati batas.',
                      textAlign: TextAlign.center,
                      style: Theme.of(ctx).textTheme.bodySmall?.copyWith(
                        color: Theme.of(ctx).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              )
            else
              ConstrainedBox(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(ctx).size.height * 0.45,
                ),
                child: ListView.separated(
                  shrinkWrap: true,
                  itemCount: alerts.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 8),
                  itemBuilder: (ctx, i) {
                    final item = alerts[i];
                    final isOver = item.isExceeded;
                    final color = isOver
                        ? Theme.of(ctx).colorScheme.error
                        : AppColors.warningFillLight;
                    return Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.08),
                        border: Border.all(color: color.withValues(alpha: 0.3)),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            isOver
                                ? Icons.error_outline_rounded
                                : Icons.warning_amber_rounded,
                            color: color,
                            size: 28,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  isOver
                                      ? 'Anggaran ${item.categoryName} Terlampaui!'
                                      : 'Anggaran ${item.categoryName} Mendekati Batas',
                                  style: Theme.of(ctx).textTheme.bodyMedium
                                      ?.copyWith(
                                        fontWeight: FontWeight.bold,
                                        color: color,
                                      ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'Terpakai ${MoneyUtils.format(item.spentAmount)} / ${MoneyUtils.format(item.limitAmount)} (${(item.percentage * 100).toStringAsFixed(0)}%)',
                                  style: Theme.of(ctx).textTheme.bodySmall,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Tutup'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final dashboard = ref.watch(homeDashboardProvider).value;
    final alertCount =
        dashboard?.budgetBreakdown
            .where((b) => b.isWarning || b.isExceeded)
            .length ??
        0;

    return Padding(
      padding: EdgeInsets.only(
        left: AppSpacing.gutter,
        right: AppSpacing.gutter,
        top: MediaQuery.of(context).padding.top,
      ),
      child: Row(
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'SakuKu',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.5,
                ),
              ),
              Text(
                'Home',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
          const Spacer(),
          IconButton(
            icon: alertCount > 0
                ? Badge.count(
                    count: alertCount,
                    child: const Icon(Icons.notifications_outlined),
                  )
                : const Icon(Icons.notifications_outlined),
            onPressed: () => _showNotificationsSheet(context),
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ],
      ),
    );
  }
}

class _GreetingRow extends StatelessWidget {
  final DateTime selectedMonth;
  final WidgetRef ref;

  const _GreetingRow({required this.selectedMonth, required this.ref});

  @override
  Widget build(BuildContext context) {
    final userName = ref.watch(userNameProvider).value ?? '';
    final greeting = userName.trim().isNotEmpty ? 'Halo, $userName' : 'Halo!';
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    greeting,
                    style: Theme.of(context).textTheme.headlineMedium
                        ?.copyWith(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(width: 6),
                  const Icon(
                    Icons.waving_hand_rounded,
                    size: 22,
                    color: AppColors.coin,
                  ),
                ],
              ),
              Text(
                'Kelola keuanganmu hari ini',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
        _MonthPicker(selectedMonth: selectedMonth, ref: ref),
      ],
    );
  }
}

class _MonthPicker extends StatelessWidget {
  final DateTime selectedMonth;
  final WidgetRef ref;

  const _MonthPicker({required this.selectedMonth, required this.ref});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        // Simple month picker: show date picker at month level
        final picked = await showDatePicker(
          context: context,
          initialDate: selectedMonth,
          firstDate: DateTime(2020),
          lastDate: DateTime(2100),
          helpText: 'Pilih Bulan',
        );
        if (picked != null) {
          ref.read(selectedMonthProvider.notifier).setMonth(picked);
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerHigh,
          borderRadius: AppRadius.pillRadius,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.calendar_today_rounded,
              size: 14,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(width: 4),
            Text(
              DateUtilsId.formatMonthYear(selectedMonth),
              style: Theme.of(context).textTheme.labelMedium,
            ),
            const SizedBox(width: 2),
            Icon(
              Icons.keyboard_arrow_down,
              size: 16,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ],
        ),
      ),
    );
  }
}

class _BalanceCard extends StatelessWidget {
  final HomeDashboardData data;
  final bool isHidden;
  final WidgetRef ref;

  const _BalanceCard({
    required this.data,
    required this.isHidden,
    required this.ref,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const AccountsScreen()),
      ),
      borderRadius: AppRadius.heroCardRadius,
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).brightness == Brightness.dark
              ? AppColors.balanceCardDark
              : AppColors.balanceCardLight,
          borderRadius: AppRadius.heroCardRadius,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Decorative blobs
            Positioned(
              right: -30,
              top: -30,
              child: Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.1),
                ),
              ),
            ),
            Positioned(
              left: -20,
              bottom: -20,
              child: Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.07),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        'Total Saldo Dompet',
                        style: Theme.of(context).textTheme.labelMedium
                            ?.copyWith(
                              color: Colors.white.withValues(alpha: 0.8),
                            ),
                      ),
                      const Spacer(),
                      GestureDetector(
                        onTap: () =>
                            ref.read(isBalanceHiddenProvider.notifier).toggle(),
                        child: Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white.withValues(alpha: 0.15),
                          ),
                          child: Icon(
                            isHidden
                                ? Icons.visibility_off_outlined
                                : Icons.visibility_outlined,
                            color: Colors.white,
                            size: 18,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    isHidden
                        ? '••••••••••••'
                        : MoneyUtils.format(data.totalBalance),
                    style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -1,
                      fontSize: 28,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Row(
                    children: [
                      Expanded(
                        child: _BalanceStat(
                          label: 'Pemasukan',
                          amount: isHidden
                              ? '••••••'
                              : MoneyUtils.formatSigned(data.totalIncome),
                          icon: Icons.arrow_upward_rounded,
                          iconBgColor: AppColors.incomeFill.withValues(
                            alpha: 0.3,
                          ),
                          iconColor: AppColors.incomeFill,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: _BalanceStat(
                          label: 'Pengeluaran',
                          amount: isHidden
                              ? '••••••'
                              : '-${MoneyUtils.format(data.totalExpense)}',
                          icon: Icons.arrow_downward_rounded,
                          iconBgColor: AppColors.expenseFill.withValues(
                            alpha: 0.3,
                          ),
                          iconColor: const Color(0xFFFFCDD2),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BalanceStat extends StatelessWidget {
  final String label;
  final String amount;
  final IconData icon;
  final Color iconBgColor;
  final Color iconColor;

  const _BalanceStat({
    required this.label,
    required this.amount,
    required this.icon,
    required this.iconBgColor,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.12),
        borderRadius: AppRadius.standardCardRadius,
      ),
      child: Row(
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: iconBgColor,
            ),
            child: Icon(icon, color: iconColor, size: 14),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  amount,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DailySummaryCard extends StatelessWidget {
  final HomeDashboardData data;
  final bool isHidden;

  const _DailySummaryCard({required this.data, required this.isHidden});

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final dateFormatted = DateUtilsId.formatMedium(now);
    final netToday = data.todayIncome - data.todayExpense;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerLowest,
        borderRadius: AppRadius.standardCardRadius,
        border: Border.all(
          color: Theme.of(context).colorScheme.outlineVariant,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: Hari Ini + Tanggal
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primaryContainer
                      .withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.calendar_today_rounded,
                  size: 16,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'Hari Ini',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  letterSpacing: -0.2,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                '($dateFormatted)',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
              const Spacer(),
              if (!isHidden)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color:
                        (netToday >= 0
                                ? AppColors.incomeFill
                                : AppColors.expenseFill)
                            .withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    netToday >= 0
                        ? '+${MoneyUtils.format(netToday)}'
                        : '-${MoneyUtils.format(netToday.abs())}',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: netToday >= 0
                          ? AppColors.incomeFill
                          : AppColors.expenseFill,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          // 2 stats row
          Row(
            children: [
              // Pemasukan Hari Ini
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm,
                    vertical: AppSpacing.sm,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.incomeFill.withValues(alpha: 0.06),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppColors.incomeFill.withValues(alpha: 0.18),
                      width: 1,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.arrow_upward_rounded,
                            size: 14,
                            color: AppColors.incomeFill,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Pemasukan',
                            style: Theme.of(context).textTheme.labelSmall
                                ?.copyWith(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onSurfaceVariant,
                                ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        isHidden
                            ? '••••••'
                            : MoneyUtils.format(data.todayIncome),
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          color: AppColors.incomeFill,
                          fontWeight: FontWeight.w700,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              // Pengeluaran Hari Ini
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm,
                    vertical: AppSpacing.sm,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.expenseFill.withValues(alpha: 0.06),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppColors.expenseFill.withValues(alpha: 0.18),
                      width: 1,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.arrow_downward_rounded,
                            size: 14,
                            color: AppColors.expenseFill,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Pengeluaran',
                            style: Theme.of(context).textTheme.labelSmall
                                ?.copyWith(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onSurfaceVariant,
                                ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        isHidden
                            ? '••••••'
                            : MoneyUtils.format(data.todayExpense),
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          color: AppColors.expenseFill,
                          fontWeight: FontWeight.w700,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _BudgetCard extends StatelessWidget {
  final HomeDashboardData data;
  final DateTime selectedMonth;

  const _BudgetCard({required this.data, required this.selectedMonth});

  @override
  Widget build(BuildContext context) {
    final pct = data.totalBudgetLimit > 0
        ? (data.totalBudgetSpent / data.totalBudgetLimit).clamp(0.0, 1.0)
        : 0.0;
    final pctDisplay = (pct * 100).toStringAsFixed(0);

    final barColor = pct >= 1.0
        ? Theme.of(context).colorScheme.error
        : pct >= 0.8
        ? Colors.orange
        : Theme.of(context).colorScheme.primaryContainer;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerLowest,
        borderRadius: AppRadius.standardCardRadius,
        border: Border.all(
          color: Theme.of(context).colorScheme.outlineVariant,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainer,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.pie_chart_outline,
                  size: 18,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Anggaran Bulan Ini',
                      style: Theme.of(context).textTheme.labelLarge
                          ?.copyWith(fontWeight: FontWeight.w600),
                    ),
                    Text(
                      DateUtilsId.formatMonthYear(selectedMonth),
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const BudgetScreen()),
                  );
                },
                child: Text(
                  'Lihat Detail',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.primary,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),

          // Amount + percentage
          Row(
            children: [
              Expanded(
                child: RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: MoneyUtils.format(data.totalBudgetSpent),
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.w600),
                      ),
                      TextSpan(
                        text: ' / ${MoneyUtils.format(data.totalBudgetLimit)}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Text(
                '$pctDisplay% terpakai',
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: barColor == Colors.orange
                      ? Colors.orange
                      : barColor == Theme.of(context).colorScheme.error
                      ? Theme.of(context).colorScheme.error
                      : Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Progress bar
          ClipRRect(
            borderRadius: AppRadius.pillRadius,
            child: LinearProgressIndicator(
              value: pct,
              minHeight: 10,
              backgroundColor: Theme.of(context).colorScheme.surfaceContainer,
              valueColor: AlwaysStoppedAnimation<Color>(barColor),
            ),
          ),

          // Category chips
          if (data.budgetBreakdown.isNotEmpty) ...[
            const SizedBox(height: 10),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: data.budgetBreakdown.map((b) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: _BudgetChip(budget: b),
                  );
                }).toList(),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _BudgetChip extends StatelessWidget {
  final CategoryBudgetProgressModel budget;

  const _BudgetChip({required this.budget});

  @override
  Widget build(BuildContext context) {
    final pctDisplay = (budget.percentage * 100).toStringAsFixed(0);
    final dotColor = Color(budget.categoryColor);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerLow,
        borderRadius: AppRadius.pillRadius,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(shape: BoxShape.circle, color: dotColor),
          ),
          const SizedBox(width: 6),
          Text(
            '${budget.categoryName}: $pctDisplay%',
            style: Theme.of(context).textTheme.labelSmall,
          ),
        ],
      ),
    );
  }
}

class _RecentTransactions extends StatelessWidget {
  final HomeDashboardData data;

  const _RecentTransactions({required this.data});

  @override
  Widget build(BuildContext context) {
    if (data.recentTransactions.isEmpty) {
      return const SizedBox.shrink();
    }

    // Group by day label
    final Map<String, List<TransactionDetailModel>> grouped = {};
    for (final tx in data.recentTransactions) {
      final key = DateUtilsId.formatDayHeader(tx.transaction.occurredAt);
      (grouped[key] ??= []).add(tx);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Transaksi Terakhir',
              style: Theme.of(context).textTheme.titleMedium
                  ?.copyWith(fontWeight: FontWeight.w700),
            ),
            const Spacer(),
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const TransactionsScreen()),
                );
              },
              child: Text(
                'Semua',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.primary,
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
        ...grouped.entries.map(
          (entry) => Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 4, bottom: 6),
                child: Text(
                  entry.key,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainerLowest,
                  borderRadius: AppRadius.standardCardRadius,
                  border: Border.all(
                    color: Theme.of(context).colorScheme.outlineVariant,
                    width: 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.03),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  children: entry.value.asMap().entries.map((e) {
                    final isLast = e.key == entry.value.length - 1;
                    return Column(
                      children: [
                        _TransactionRow(tx: e.value),
                        if (!isLast)
                          Divider(
                            height: 1,
                            indent: 56,
                            color: Theme.of(context).colorScheme.outlineVariant,
                          ),
                      ],
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: AppSpacing.md),
            ],
          ),
        ),
      ],
    );
  }
}

class _TransactionRow extends StatelessWidget {
  final TransactionDetailModel tx;

  const _TransactionRow({required this.tx});

  @override
  Widget build(BuildContext context) {
    final isIncome = tx.transaction.type == TransactionType.income;
    final isTransfer = tx.transaction.type == TransactionType.transfer;
    final isAdjustment = tx.transaction.type == TransactionType.adjustment;

    final amountColor = isAdjustment
        ? (tx.transaction.amount >= 0
              ? AppColors.incomeText
              : AppColors.expenseText)
        : isIncome
        ? AppColors.incomeText
        : isTransfer
        ? Theme.of(context).colorScheme.primary
        : AppColors.expenseText;

    final iconBg = isIncome
        ? AppColors.incomeBg
        : isTransfer
        ? Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.15)
        : AppColors.expenseBg;

    final iconColor = amountColor;

    final amountStr = isAdjustment
        ? MoneyUtils.formatSigned(tx.transaction.amount)
        : isIncome
        ? '+${MoneyUtils.format(tx.transaction.amount)}'
        : isTransfer
        ? MoneyUtils.format(tx.transaction.amount)
        : '-${MoneyUtils.format(tx.transaction.amount)}';

    final subtitle = isAdjustment
        ? 'Penyesuaian Saldo'
        : tx.categoryName ??
              (isTransfer
                  ? 'Transfer'
                  : (isIncome ? 'Pemasukan' : 'Pengeluaran'));
    final timeStr = DateUtilsId.formatTime(tx.transaction.occurredAt);

    final iconData = _resolveIcon(tx);

    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => AddTransactionScreen(initialDetail: tx),
          ),
        );
      },
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: iconBg,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(iconData, color: iconColor, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    tx.transaction.note ?? subtitle,
                    style: Theme.of(context).textTheme.labelLarge
                        ?.copyWith(fontWeight: FontWeight.w500),
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    '$subtitle • $timeStr',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            Text(
              amountStr,
              style: Theme.of(context).textTheme.labelLarge
                  ?.copyWith(color: amountColor, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }

  IconData _resolveIcon(TransactionDetailModel tx) {
    if (tx.transaction.type == TransactionType.income) {
      return Icons.payments_rounded;
    }
    if (tx.transaction.type == TransactionType.transfer) {
      return Icons.swap_horiz_rounded;
    }
    if (tx.transaction.type == TransactionType.adjustment) {
      return Icons.tune_rounded;
    }
    // Map category icon name to Material icon
    final icon = tx.categoryIcon ?? '';
    return switch (icon) {
      'restaurant' => Icons.restaurant_rounded,
      'directions_bus' => Icons.directions_bus_rounded,
      'shopping_bag' || 'shopping_cart' => Icons.shopping_bag_rounded,
      'receipt_long' => Icons.receipt_long_rounded,
      'sports_esports' => Icons.sports_esports_rounded,
      'health_and_safety' => Icons.health_and_safety_rounded,
      'school' => Icons.school_rounded,
      'local_cafe' => Icons.local_cafe_rounded,
      _ => Icons.attach_money_rounded,
    };
  }
}
