import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../db/app_database.dart';
import '../models/account_model.dart';
import '../models/budget_model.dart';
import '../models/category_model.dart';
import '../models/report_model.dart';
import '../models/transaction_model.dart';
import '../repositories/finance_repository.dart';
import '../../core/services/home_widget_service.dart';

final databaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  ref.onDispose(() => db.close());
  return db;
});

final financeRepositoryProvider = Provider<FinanceRepository>((ref) {
  final db = ref.watch(databaseProvider);
  return DriftFinanceRepository(db);
});

class SelectedMonthNotifier extends Notifier<DateTime> {
  @override
  DateTime build() {
    final now = DateTime.now();
    return DateTime(now.year, now.month, 1);
  }

  void setMonth(DateTime month) => state = DateTime(month.year, month.month, 1);
}

final selectedMonthProvider = NotifierProvider<SelectedMonthNotifier, DateTime>(
  SelectedMonthNotifier.new,
);

class IsBalanceHiddenNotifier extends Notifier<bool> {
  @override
  bool build() {
    _loadFromDb();
    return false;
  }

  Future<void> _loadFromDb() async {
    final repo = ref.read(financeRepositoryProvider);
    final val = await repo.getSetting('hide_balance');
    if (val != null) {
      state = val == 'true';
    }
  }

  void toggle() {
    state = !state;
    final repo = ref.read(financeRepositoryProvider);
    repo.setSetting('hide_balance', state.toString());
  }
}

final isBalanceHiddenProvider = NotifierProvider<IsBalanceHiddenNotifier, bool>(
  IsBalanceHiddenNotifier.new,
);

final homeDashboardProvider = FutureProvider.autoDispose<HomeDashboardData>((
  ref,
) async {
  final repo = ref.watch(financeRepositoryProvider);
  final month = ref.watch(selectedMonthProvider);
  await repo.removeSampleDataIfPresent();
  final data = await repo.getHomeDashboardData(month);
  // Keep home screen widget in sync
  HomeWidgetService.updateHomeWidget(data);
  return data;
});

// Accounts provider
final accountsWithBalanceProvider =
    FutureProvider.autoDispose<List<AccountWithBalanceModel>>((ref) async {
      final repo = ref.watch(financeRepositoryProvider);
      await repo.removeSampleDataIfPresent();
      return repo.getAccountsWithBalances();
    });

// Categories provider
final categoriesListProvider = FutureProvider.family
    .autoDispose<List<CategoryModel>, CategoryType?>((ref, type) async {
      final repo = ref.watch(financeRepositoryProvider);
      await repo.removeSampleDataIfPresent();
      return repo.getCategories(type: type);
    });

// Transactions Filter State
class TransactionFilterState {
  final DateTime? month;
  final TransactionType? type;
  final String query;

  const TransactionFilterState({this.month, this.type, this.query = ''});

  TransactionFilterState copyWith({
    DateTime? month,
    TransactionType? type,
    bool clearType = false,
    String? query,
  }) {
    return TransactionFilterState(
      month: month ?? this.month,
      type: clearType ? null : (type ?? this.type),
      query: query ?? this.query,
    );
  }
}

class TransactionFilterNotifier extends Notifier<TransactionFilterState> {
  @override
  TransactionFilterState build() {
    final now = DateTime.now();
    return TransactionFilterState(month: DateTime(now.year, now.month, 1));
  }

  void setMonth(DateTime month) => state = state.copyWith(month: month);
  void setType(TransactionType? type) =>
      state = state.copyWith(type: type, clearType: type == null);
  void setQuery(String query) => state = state.copyWith(query: query);
}

final transactionFilterProvider =
    NotifierProvider<TransactionFilterNotifier, TransactionFilterState>(
      TransactionFilterNotifier.new,
    );

final filteredTransactionsProvider =
    FutureProvider.autoDispose<List<TransactionDetailModel>>((ref) async {
      final repo = ref.watch(financeRepositoryProvider);
      final filter = ref.watch(transactionFilterProvider);
      await repo.removeSampleDataIfPresent();
      return repo.getFilteredTransactions(
        month: filter.month,
        type: filter.type,
        query: filter.query,
      );
    });

// Budgets provider
final budgetsListProvider = FutureProvider.family
    .autoDispose<List<CategoryBudgetProgressModel>, String>((ref, month) async {
      final repo = ref.watch(financeRepositoryProvider);
      await repo.removeSampleDataIfPresent();
      return repo.getBudgets(month);
    });

// Reports filter
class ReportsPeriodNotifier extends Notifier<String> {
  @override
  String build() => 'monthly'; // 'weekly', 'monthly', 'yearly'

  void setPeriod(String p) => state = p;
}

final reportsPeriodProvider = NotifierProvider<ReportsPeriodNotifier, String>(
  ReportsPeriodNotifier.new,
);

class ReportsDateNotifier extends Notifier<DateTime> {
  @override
  DateTime build() => DateTime.now();

  void setDate(DateTime d) => state = d;
}

final reportsDateProvider = NotifierProvider<ReportsDateNotifier, DateTime>(
  ReportsDateNotifier.new,
);

final reportsDataProvider = FutureProvider.autoDispose<ReportDataModel>((
  ref,
) async {
  final repo = ref.watch(financeRepositoryProvider);
  final period = ref.watch(reportsPeriodProvider);
  final date = ref.watch(reportsDateProvider);
  await repo.removeSampleDataIfPresent();
  return repo.getReportsData(period: period, date: date);
});

// Theme Mode
class ThemeModeNotifier extends Notifier<ThemeMode> {
  @override
  ThemeMode build() {
    _loadFromDb();
    return ThemeMode.system;
  }

  Future<void> _loadFromDb() async {
    final repo = ref.read(financeRepositoryProvider);
    final val = await repo.getSetting('theme_mode');
    if (val != null) {
      if (val == 'light') state = ThemeMode.light;
      if (val == 'dark') state = ThemeMode.dark;
      if (val == 'system') state = ThemeMode.system;
    }
  }

  void setThemeMode(ThemeMode mode) {
    state = mode;
    final repo = ref.read(financeRepositoryProvider);
    repo.setSetting('theme_mode', mode.name);
  }
}

final themeModeProvider = NotifierProvider<ThemeModeNotifier, ThemeMode>(
  ThemeModeNotifier.new,
);

// User Profile providers (stored in SettingsTable)
final userNameProvider = FutureProvider<String>((ref) async {
  final repo = ref.watch(financeRepositoryProvider);
  return await repo.getSetting('user_name') ?? '';
});
