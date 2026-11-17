import 'package:flutter/foundation.dart';
import 'package:home_widget/home_widget.dart';

import '../../data/models/transaction_model.dart';
import '../../data/repositories/finance_repository.dart';
import '../utils/date.dart';
import '../utils/money.dart';

class HomeWidgetService {
  static const String androidWidgetName = 'DompetKuWidgetProvider';
  static const String qualifiedAndroidWidgetName =
      'com.dompetku.dompetku.DompetKuWidgetProvider';

  /// Sync widget data from [HomeDashboardData]
  static Future<void> updateHomeWidget(HomeDashboardData data) async {
    try {
      final now = DateTime.now();
      final dateStr = DateUtilsId.formatMedium(now);

      await HomeWidget.saveWidgetData<String>('today_date', dateStr);
      await HomeWidget.saveWidgetData<String>(
        'today_income',
        MoneyUtils.format(data.todayIncome),
      );
      await HomeWidget.saveWidgetData<String>(
        'today_expense',
        MoneyUtils.format(data.todayExpense),
      );

      final hasTx = data.recentTransactions.isNotEmpty;
      await HomeWidget.saveWidgetData<bool>('has_tx', hasTx);

      // Save up to 4 transactions
      for (int i = 0; i < 4; i++) {
        final idx = i + 1; // tx1..tx4
        if (i < data.recentTransactions.length) {
          final tx = data.recentTransactions[i];
          final title = tx.transaction.type == TransactionType.transfer
              ? 'Transaksi'
              : tx.categoryName ?? tx.transaction.note ?? 'Transaksi';
          final date = DateUtilsId.formatMedium(tx.transaction.occurredAt);
          final isIncome =
              tx.transaction.type == TransactionType.income ||
              (tx.transaction.type == TransactionType.adjustment &&
                  tx.transaction.amount >= 0);
          final amount = tx.transaction.type == TransactionType.adjustment
              ? MoneyUtils.formatSigned(tx.transaction.amount)
              : '${isIncome ? '+' : '-'}${MoneyUtils.format(tx.transaction.amount)}';

          await HomeWidget.saveWidgetData<String>('tx${idx}_title', title);
          await HomeWidget.saveWidgetData<String>('tx${idx}_date', date);
          await HomeWidget.saveWidgetData<String>('tx${idx}_amount', amount);
          await HomeWidget.saveWidgetData<bool>('tx${idx}_is_income', isIncome);
        } else {
          await HomeWidget.saveWidgetData<String>('tx${idx}_title', null);
        }
      }

      await HomeWidget.updateWidget(
        name: androidWidgetName,
        qualifiedAndroidName: qualifiedAndroidWidgetName,
      );
    } catch (e) {
      debugPrint('Error updating home widget: $e');
    }
  }

  /// Convenience method to sync directly from repository
  static Future<void> updateFromRepository(FinanceRepository repo) async {
    try {
      final data = await repo.getHomeDashboardData(DateTime.now());
      await updateHomeWidget(data);
    } catch (e) {
      debugPrint('Error updating widget from repo: $e');
    }
  }
}
