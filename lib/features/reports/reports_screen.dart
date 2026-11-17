import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../core/theme/app_colors.dart';
import '../../core/utils/date.dart';
import '../../core/utils/icon_utils.dart';
import '../../core/utils/money.dart';
import '../../data/models/report_model.dart';
import '../../data/providers/finance_providers.dart';

class ReportsScreen extends ConsumerWidget {
  const ReportsScreen({super.key});

  void _previousPeriod(WidgetRef ref, String period, DateTime current) {
    DateTime nextDate;
    if (period == 'weekly') {
      nextDate = current.subtract(const Duration(days: 7));
    } else if (period == 'yearly') {
      nextDate = DateTime(current.year - 1, current.month, current.day);
    } else {
      nextDate = DateTime(current.year, current.month - 1, current.day);
    }
    ref.read(reportsDateProvider.notifier).setDate(nextDate);
  }

  void _nextPeriod(WidgetRef ref, String period, DateTime current) {
    DateTime nextDate;
    if (period == 'weekly') {
      nextDate = current.add(const Duration(days: 7));
    } else if (period == 'yearly') {
      nextDate = DateTime(current.year + 1, current.month, current.day);
    } else {
      nextDate = DateTime(current.year, current.month + 1, current.day);
    }
    ref.read(reportsDateProvider.notifier).setDate(nextDate);
  }

  String _formatPeriodLabel(String period, DateTime date) {
    if (period == 'weekly') {
      final monday = date.subtract(Duration(days: date.weekday - 1));
      final sunday = monday.add(const Duration(days: 6));
      return '${DateFormat('d MMM', 'id_ID').format(monday)} - ${DateFormat('d MMM yyyy', 'id_ID').format(sunday)}';
    } else if (period == 'yearly') {
      return DateFormat('yyyy', 'id_ID').format(date);
    } else {
      return DateUtilsId.formatMonthYear(date);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final period = ref.watch(reportsPeriodProvider);
    final date = ref.watch(reportsDateProvider);
    final reportAsync = ref.watch(reportsDataProvider);

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: Text(
          'Laporan Keuangan',
          style: Theme.of(context).textTheme.titleLarge
              ?.copyWith(fontWeight: FontWeight.w700),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Period Toggle
            Container(
              height: 42,
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerLow,
                borderRadius: BorderRadius.circular(999),
              ),
              child: Row(
                children: [
                  _buildToggleTab(
                    context,
                    label: 'Mingguan',
                    active: period == 'weekly',
                    onTap: () => ref
                        .read(reportsPeriodProvider.notifier)
                        .setPeriod('weekly'),
                  ),
                  _buildToggleTab(
                    context,
                    label: 'Bulanan',
                    active: period == 'monthly',
                    onTap: () => ref
                        .read(reportsPeriodProvider.notifier)
                        .setPeriod('monthly'),
                  ),
                  _buildToggleTab(
                    context,
                    label: 'Tahunan',
                    active: period == 'yearly',
                    onTap: () => ref
                        .read(reportsPeriodProvider.notifier)
                        .setPeriod('yearly'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // Date Navigation
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerLowest,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(Icons.chevron_left_rounded),
                    onPressed: () => _previousPeriod(ref, period, date),
                  ),
                  Text(
                    _formatPeriodLabel(period, date),
                    style: Theme.of(context).textTheme.titleSmall
                        ?.copyWith(fontWeight: FontWeight.w600),
                  ),
                  IconButton(
                    icon: const Icon(Icons.chevron_right_rounded),
                    onPressed: () => _nextPeriod(ref, period, date),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            reportAsync.when(
              loading: () => const Padding(
                padding: EdgeInsets.symmetric(vertical: 40),
                child: Center(child: CircularProgressIndicator()),
              ),
              error: (e, _) => Center(child: Text('Gagal memuat laporan: $e')),
              data: (data) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Summary Card
                    _buildSummaryCard(context, data),
                    const SizedBox(height: 20),

                    // Insight banner if available
                    if (data.comparisonInsight != null) ...[
                      _buildInsightCard(context, data.comparisonInsight!),
                      const SizedBox(height: 20),
                    ],

                    // Bar Chart
                    _buildChartCard(context, data.chartPoints),
                    const SizedBox(height: 24),

                    // Category Spending Breakdown
                    Text(
                      'Pengeluaran per Kategori',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.2,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildCategoryBreakdown(context, data.categoryRankings),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildToggleTab(
    BuildContext context, {
    required String label,
    required bool active,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            color: active
                ? Theme.of(context).colorScheme.surfaceContainerLowest
                : Colors.transparent,
            borderRadius: BorderRadius.circular(999),
            boxShadow: active
                ? [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 4,
                      offset: const Offset(0, 1),
                    ),
                  ]
                : null,
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: active ? FontWeight.w600 : FontWeight.w500,
              color: active
                  ? Theme.of(context).colorScheme.primary
                  : Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryCard(BuildContext context, ReportDataModel data) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: AppColors.incomeText,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'Pemasukan',
                          style: TextStyle(
                            fontSize: 12,
                            color: Theme.of(context)
                                .colorScheme
                                .onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      MoneyUtils.format(data.totalIncome),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppColors.incomeText,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: AppColors.expenseText,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'Pengeluaran',
                          style: TextStyle(
                            fontSize: 12,
                            color: Theme.of(context)
                                .colorScheme
                                .onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      MoneyUtils.format(data.totalExpense),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppColors.expenseText,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Divider(height: 1),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Tabungan Bersih',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
              Text(
                data.netSavings >= 0
                    ? '+${MoneyUtils.format(data.netSavings)}'
                    : '-${MoneyUtils.format(data.netSavings.abs())}',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: data.netSavings >= 0
                      ? AppColors.incomeText
                      : AppColors.expenseText,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInsightCard(BuildContext context, String insight) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.brandPrimary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.brandPrimary.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        children: [
          Icon(Icons.insights_rounded, color: AppColors.brandPrimary, size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              insight,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: AppColors.brandPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChartCard(BuildContext context, List<BarChartDataPoint> points) {
    double maxY = 0;
    for (final p in points) {
      if (p.income > maxY) maxY = p.income.toDouble();
      if (p.expense > maxY) maxY = p.expense.toDouble();
    }
    if (maxY == 0) maxY = 100000;
    maxY = maxY * 1.2;

    return Container(
      padding: const EdgeInsets.fromLTRB(14, 16, 14, 12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Arus Kas',
                style: Theme.of(context).textTheme.titleSmall
                    ?.copyWith(fontWeight: FontWeight.w700),
              ),
              Row(
                children: [
                  _buildLegendIndicator(AppColors.incomeText, 'Masuk'),
                  const SizedBox(width: 12),
                  _buildLegendIndicator(AppColors.expenseText, 'Keluar'),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 180,
            child: BarChart(
              BarChartData(
                maxY: maxY,
                alignment: BarChartAlignment.spaceAround,
                barTouchData: BarTouchData(
                  touchTooltipData: BarTouchTooltipData(
                    getTooltipItem: (group, groupIndex, rod, rodIndex) {
                      final point = points[groupIndex];
                      final isIncome = rodIndex == 0;
                      final label = isIncome ? 'Masuk' : 'Keluar';
                      final val = isIncome ? point.income : point.expense;
                      return BarTooltipItem(
                        '$label: ${MoneyUtils.format(val)}',
                        const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      );
                    },
                  ),
                ),
                titlesData: FlTitlesData(
                  show: true,
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  leftTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        final idx = value.toInt();
                        if (idx >= 0 && idx < points.length) {
                          return Padding(
                            padding: const EdgeInsets.only(top: 6),
                            child: Text(
                              points[idx].label,
                              style: TextStyle(
                                fontSize: 10,
                                color: Theme.of(context).colorScheme.outline,
                              ),
                            ),
                          );
                        }
                        return const SizedBox.shrink();
                      },
                    ),
                  ),
                ),
                gridData: const FlGridData(show: false),
                borderData: FlBorderData(show: false),
                barGroups: points.asMap().entries.map((entry) {
                  final idx = entry.key;
                  final p = entry.value;
                  return BarChartGroupData(
                    x: idx,
                    barsSpace: 4,
                    barRods: [
                      BarChartRodData(
                        toY: p.income.toDouble(),
                        color: AppColors.incomeText,
                        width: 8,
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(4),
                        ),
                      ),
                      BarChartRodData(
                        toY: p.expense.toDouble(),
                        color: AppColors.expenseText,
                        width: 8,
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(4),
                        ),
                      ),
                    ],
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLegendIndicator(Color color, String text) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 4),
        Text(text, style: const TextStyle(fontSize: 11)),
      ],
    );
  }

  Widget _buildCategoryBreakdown(
    BuildContext context,
    List<CategorySpendingModel> rankings,
  ) {
    if (rankings.isEmpty) {
      return Container(
        padding: const EdgeInsets.symmetric(vertical: 32),
        alignment: Alignment.center,
        child: Text(
          'Tidak ada pengeluaran pada periode ini.',
          style: TextStyle(color: Theme.of(context).colorScheme.outline),
        ),
      );
    }

    return Column(
      children: rankings.map((cat) {
        final iconData = IconUtils.resolveIcon(cat.categoryIcon);
        final color = Color(cat.categoryColor);
        final pctStr = (cat.percentage * 100).toStringAsFixed(1);

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainerLowest,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: Theme.of(context).colorScheme.outlineVariant,
            ),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(iconData, size: 20, color: color),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          cat.categoryName,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          '$pctStr% dari total',
                          style: TextStyle(
                            fontSize: 12,
                            color: Theme.of(context)
                                .colorScheme
                                .onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    MoneyUtils.format(cat.totalAmount),
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              ClipRRect(
                borderRadius: BorderRadius.circular(999),
                child: LinearProgressIndicator(
                  value: cat.percentage.clamp(0.0, 1.0),
                  minHeight: 6,
                  backgroundColor: Theme.of(context)
                      .colorScheme
                      .surfaceContainerLow,
                  valueColor: AlwaysStoppedAnimation<Color>(color),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}
