import 'package:drift/drift.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

import '../db/app_database.dart';
import '../models/account_model.dart';
import '../models/category_model.dart';
import '../models/transaction_model.dart';
import '../models/budget_model.dart';
import '../models/report_model.dart';

class HomeDashboardData {
  final int totalBalance;
  final int totalIncome;
  final int totalExpense;
  final int todayIncome;
  final int todayExpense;
  final int totalBudgetLimit;
  final int totalBudgetSpent;
  final List<CategoryBudgetProgressModel> budgetBreakdown;
  final List<TransactionDetailModel> recentTransactions;

  const HomeDashboardData({
    required this.totalBalance,
    required this.totalIncome,
    required this.totalExpense,
    this.todayIncome = 0,
    this.todayExpense = 0,
    required this.totalBudgetLimit,
    required this.totalBudgetSpent,
    required this.budgetBreakdown,
    required this.recentTransactions,
  });
}

abstract class FinanceRepository {
  Future<void> removeSampleDataIfPresent();
  Future<HomeDashboardData> getHomeDashboardData(DateTime month);
  Future<List<AccountModel>> getAccounts();
  Future<List<AccountWithBalanceModel>> getAccountsWithBalances();
  Future<void> addAccount(AccountModel account);
  Future<void> updateAccount(AccountModel account);
  Future<void> adjustAccountBalance(String accountId, int targetBalance);
  Future<void> archiveAccount(String id);
  Future<List<CategoryModel>> getCategories({CategoryType? type});
  Future<void> addCategory(CategoryModel category);
  Future<void> archiveCategory(String id);
  Future<List<TransactionDetailModel>> getRecentTransactions({int limit = 5});
  Future<List<TransactionDetailModel>> getFilteredTransactions({
    DateTime? month,
    TransactionType? type,
    String? query,
  });
  Future<void> addTransaction(TransactionModel transaction);
  Future<void> updateTransaction(TransactionModel transaction);
  Future<void> deleteTransaction(String id);
  Future<TransactionModel?> getTransactionById(String id);
  Future<List<CategoryBudgetProgressModel>> getBudgets(String month);
  Future<void> saveBudget(String categoryId, String month, int limitAmount);
  Future<void> deleteBudget(String id);
  Future<ReportDataModel> getReportsData({
    required String period,
    required DateTime date,
  });
  Future<String> exportTransactionsCsv(DateTime startDate, DateTime endDate);
  Future<void> resetAllData();

  // Settings (profile, preferences)
  Future<String?> getSetting(String key);
  Future<void> setSetting(String key, String value);

  // Backup / Restore
  Future<String> getDbPath();
}

class DriftFinanceRepository implements FinanceRepository {
  final AppDatabase db;
  Future<void>? _sampleDataCleanup;

  DriftFinanceRepository(this.db);

  @override
  Future<void> removeSampleDataIfPresent() =>
      _sampleDataCleanup ??= _removeSampleData();

  Future<void> _removeSampleData() async {
    await db.batch((batch) {
      batch.deleteWhere(
        db.transactionsTable,
        (row) => row.id.isIn(['tx_1', 'tx_2', 'tx_3', 'tx_4', 'tx_5']),
      );
      batch.deleteWhere(
        db.budgetsTable,
        (row) => row.id.isIn(['b_makan', 'b_belanja', 'b_transport']),
      );
      batch.deleteWhere(
        db.categoriesTable,
        (row) => row.id.isIn([
          'cat_makan',
          'cat_transport',
          'cat_belanja',
          'cat_tagihan',
          'cat_hiburan',
          'cat_kesehatan',
          'cat_pendidikan',
          'cat_lainnya_exp',
          'cat_gaji',
          'cat_bonus',
          'cat_freelance',
          'cat_hadiah',
          'cat_lainnya_inc',
        ]),
      );
      batch.deleteWhere(
        db.accountsTable,
        (row) => row.id.isIn(['acc_cash', 'acc_bank', 'acc_ewallet']),
      );
    });
  }

  /*
    final now = DateTime.now();
    await db.batch((batch) {
      batch.insertAll(db.accountsTable, [
        AccountsTableCompanion.insert(
          id: 'acc_cash',
          name: 'Tunai',
          type: 'cash',
          initialBalance: 1200000,
          icon: 'payments',
          color: 0xFF10B981,
          createdAt: now,
        ),
        AccountsTableCompanion.insert(
          id: 'acc_bank',
          name: 'Bank BCA',
          type: 'bank',
          initialBalance: 15000000,
          icon: 'account_balance',
          color: 0xFF3B82F6,
          createdAt: now,
        ),
        AccountsTableCompanion.insert(
          id: 'acc_ewallet',
          name: 'GoPay / OVO',
          type: 'ewallet',
          initialBalance: 2250000,
          icon: 'account_balance_wallet',
          color: 0xFFA855F7,
          createdAt: now,
        ),
      ]);

      // Seed default categories per PRD section 9
      batch.insertAll(db.categoriesTable, [
        // Expenses
        CategoriesTableCompanion.insert(
          id: 'cat_makan',
          name: 'Makanan',
          type: 'expense',
          icon: 'restaurant',
          color: 0xFFF59E0B,
          isDefault: const Value(true),
        ),
        CategoriesTableCompanion.insert(
          id: 'cat_transport',
          name: 'Transport',
          type: 'expense',
          icon: 'directions_bus',
          color: 0xFF3B82F6,
          isDefault: const Value(true),
        ),
        CategoriesTableCompanion.insert(
          id: 'cat_belanja',
          name: 'Belanja',
          type: 'expense',
          icon: 'shopping_bag',
          color: 0xFFA855F7,
          isDefault: const Value(true),
        ),
        CategoriesTableCompanion.insert(
          id: 'cat_tagihan',
          name: 'Tagihan',
          type: 'expense',
          icon: 'receipt_long',
          color: 0xFF06B6D4,
          isDefault: const Value(true),
        ),
        CategoriesTableCompanion.insert(
          id: 'cat_hiburan',
          name: 'Hiburan',
          type: 'expense',
          icon: 'sports_esports',
          color: 0xFFEC4899,
          isDefault: const Value(true),
        ),
        CategoriesTableCompanion.insert(
          id: 'cat_kesehatan',
          name: 'Kesehatan',
          type: 'expense',
          icon: 'health_and_safety',
          color: 0xFF84CC16,
          isDefault: const Value(true),
        ),
        CategoriesTableCompanion.insert(
          id: 'cat_pendidikan',
          name: 'Pendidikan',
          type: 'expense',
          icon: 'school',
          color: 0xFF6366F1,
          isDefault: const Value(true),
        ),
        CategoriesTableCompanion.insert(
          id: 'cat_lainnya_exp',
          name: 'Lainnya',
          type: 'expense',
          icon: 'more_horiz',
          color: 0xFF64748B,
          isDefault: const Value(true),
        ),

        // Income
        CategoriesTableCompanion.insert(
          id: 'cat_gaji',
          name: 'Gaji',
          type: 'income',
          icon: 'payments',
          color: 0xFF10B981,
          isDefault: const Value(true),
        ),
        CategoriesTableCompanion.insert(
          id: 'cat_bonus',
          name: 'Bonus',
          type: 'income',
          icon: 'redeem',
          color: 0xFF10B981,
          isDefault: const Value(true),
        ),
        CategoriesTableCompanion.insert(
          id: 'cat_freelance',
          name: 'Freelance',
          type: 'income',
          icon: 'work',
          color: 0xFF10B981,
          isDefault: const Value(true),
        ),
        CategoriesTableCompanion.insert(
          id: 'cat_hadiah',
          name: 'Hadiah',
          type: 'income',
          icon: 'card_giftcard',
          color: 0xFF10B981,
          isDefault: const Value(true),
        ),
        CategoriesTableCompanion.insert(
          id: 'cat_lainnya_inc',
          name: 'Lainnya',
          type: 'income',
          icon: 'more_horiz',
          color: 0xFF10B981,
          isDefault: const Value(true),
        ),
      ]);

      // Seed budgets for current month
      final monthStr = '${now.year}-${now.month.toString().padLeft(2, '0')}';
      batch.insertAll(db.budgetsTable, [
        BudgetsTableCompanion.insert(
          id: 'b_makan',
          categoryId: 'cat_makan',
          month: monthStr,
          limitAmount: 3000000,
        ),
        BudgetsTableCompanion.insert(
          id: 'b_belanja',
          categoryId: 'cat_belanja',
          month: monthStr,
          limitAmount: 1800000,
        ),
        BudgetsTableCompanion.insert(
          id: 'b_transport',
          categoryId: 'cat_transport',
          month: monthStr,
          limitAmount: 1200000,
        ),
      ]);

      // Ensure seed transactions fall within the current month
      final today = DateTime(now.year, now.month, now.day, 14, 20);
      final earlierToday = DateTime(now.year, now.month, now.day, 8, 30);
      final date3 = now.day > 1
          ? DateTime(now.year, now.month, now.day - 1, 18, 45)
          : DateTime(now.year, now.month, now.day, 7, 15);
      final date4 = now.day > 1
          ? DateTime(now.year, now.month, now.day - 1, 7, 15)
          : DateTime(now.year, now.month, now.day, 6, 30);

      batch.insertAll(db.transactionsTable, [
        TransactionsTableCompanion.insert(
          id: 'tx_1',
          type: 'expense',
          amount: 485000,
          categoryId: const Value('cat_belanja'),
          accountId: 'acc_bank',
          occurredAt: today,
          note: const Value('Supermarket Grand Lucky'),
          createdAt: now,
          updatedAt: now,
        ),
        TransactionsTableCompanion.insert(
          id: 'tx_2',
          type: 'income',
          amount: 8500000,
          categoryId: const Value('cat_gaji'),
          accountId: 'acc_bank',
          occurredAt: DateTime(now.year, now.month, now.day, 10, 5),
          note: const Value('Gaji PT Digital Media'),
          createdAt: now,
          updatedAt: now,
        ),
        TransactionsTableCompanion.insert(
          id: 'tx_3',
          type: 'expense',
          amount: 54000,
          categoryId: const Value('cat_makan'),
          accountId: 'acc_ewallet',
          occurredAt: earlierToday,
          note: const Value('Kopi Kenangan & Makan Siang'),
          createdAt: now,
          updatedAt: now,
        ),
        TransactionsTableCompanion.insert(
          id: 'tx_4',
          type: 'expense',
          amount: 420000,
          categoryId: const Value('cat_tagihan'),
          accountId: 'acc_bank',
          occurredAt: date3,
          note: const Value('Tagihan Listrik & WiFi'),
          createdAt: now,
          updatedAt: now,
        ),
        TransactionsTableCompanion.insert(
          id: 'tx_5',
          type: 'expense',
          amount: 14000,
          categoryId: const Value('cat_transport'),
          accountId: 'acc_ewallet',
          occurredAt: date4,
          note: const Value('QRIS MRT Jakarta'),
          createdAt: now,
          updatedAt: now,
        ),
      ]);
    });
  }

  */

  @override
  Future<HomeDashboardData> getHomeDashboardData(DateTime month) async {
    final startOfMonth = DateTime(month.year, month.month, 1);
    final nextMonth = month.month == 12
        ? DateTime(month.year + 1, 1, 1)
        : DateTime(month.year, month.month + 1, 1);

    // 1. Calculate accounts initial balance
    final accounts = await (db.select(
      db.accountsTable,
    )..where((tbl) => tbl.archived.equals(false))).get();
    int totalInitial = 0;
    for (final a in accounts) {
      totalInitial += a.initialBalance;
    }

    // 2. Fetch all transactions to calculate true balance per rule:
    // Saldo = initial + income - expense + transfer_in - transfer_out
    final allTransactions = await db.select(db.transactionsTable).get();
    int overallIncome = 0;
    int overallExpense = 0;
    int overallAdjustments = 0;

    int monthIncome = 0;
    int monthExpense = 0;

    final Map<String, int> categoryExpenseMap = {};

    final now = DateTime.now();
    final startOfToday = DateTime(now.year, now.month, now.day);
    final endOfToday = DateTime(now.year, now.month, now.day, 23, 59, 59, 999);

    int todayIncome = 0;
    int todayExpense = 0;

    for (final tx in allTransactions) {
      if (tx.type == 'income') {
        overallIncome += tx.amount;
      } else if (tx.type == 'expense') {
        overallExpense += tx.amount;
      } else if (tx.type == 'adjustment') {
        overallAdjustments += tx.amount;
      }

      // Check today boundary
      if (!tx.occurredAt.isBefore(startOfToday) &&
          !tx.occurredAt.isAfter(endOfToday)) {
        if (tx.type == 'income') {
          todayIncome += tx.amount;
        } else if (tx.type == 'expense') {
          todayExpense += tx.amount;
        }
      }

      // Check month boundary
      if (!tx.occurredAt.isBefore(startOfMonth) &&
          tx.occurredAt.isBefore(nextMonth)) {
        if (tx.type == 'income') {
          monthIncome += tx.amount;
        } else if (tx.type == 'expense') {
          monthExpense += tx.amount;
          if (tx.categoryId != null) {
            categoryExpenseMap[tx.categoryId!] =
                (categoryExpenseMap[tx.categoryId!] ?? 0) + tx.amount;
          }
        }
      }
    }

    final totalBalance =
        totalInitial + overallIncome - overallExpense + overallAdjustments;

    // 3. Budgets for this month
    final monthStr = '${month.year}-${month.month.toString().padLeft(2, '0')}';
    final budgets = await (db.select(
      db.budgetsTable,
    )..where((tbl) => tbl.month.equals(monthStr))).get();
    final categories = await db.select(db.categoriesTable).get();
    final catMap = {for (var c in categories) c.id: c};

    int totalBudgetLimit = 0;
    final List<CategoryBudgetProgressModel> budgetBreakdown = [];

    for (final b in budgets) {
      totalBudgetLimit += b.limitAmount;
      final spent = categoryExpenseMap[b.categoryId] ?? 0;
      final cat = catMap[b.categoryId];
      if (cat != null) {
        final pct = b.limitAmount > 0 ? (spent / b.limitAmount) : 0.0;
        budgetBreakdown.add(
          CategoryBudgetProgressModel(
            categoryId: b.categoryId,
            categoryName: cat.name,
            categoryIcon: cat.icon,
            categoryColor: cat.color,
            spentAmount: spent,
            limitAmount: b.limitAmount,
            percentage: pct,
          ),
        );
      }
    }

    // 4. Recent transactions
    final recent = await getRecentTransactions(limit: 5);

    return HomeDashboardData(
      totalBalance: totalBalance,
      totalIncome: monthIncome,
      totalExpense: monthExpense,
      todayIncome: todayIncome,
      todayExpense: todayExpense,
      totalBudgetLimit: totalBudgetLimit,
      totalBudgetSpent: monthExpense,
      budgetBreakdown: budgetBreakdown,
      recentTransactions: recent,
    );
  }

  @override
  Future<List<AccountModel>> getAccounts() async {
    final rows = await (db.select(
      db.accountsTable,
    )..where((tbl) => tbl.archived.equals(false))).get();
    return rows.map((r) {
      final type = AccountType.values.firstWhere(
        (e) => e.name == r.type,
        orElse: () => AccountType.cash,
      );
      return AccountModel(
        id: r.id,
        name: r.name,
        type: type,
        initialBalance: r.initialBalance,
        icon: r.icon,
        color: r.color,
        archived: r.archived,
        createdAt: r.createdAt,
      );
    }).toList();
  }

  @override
  Future<List<CategoryModel>> getCategories({CategoryType? type}) async {
    var query = db.select(db.categoriesTable)
      ..where((tbl) => tbl.archived.equals(false));
    if (type != null) {
      query = query..where((tbl) => tbl.type.equals(type.name));
    }
    final rows = await query.get();
    return rows
        .map(
          (r) => CategoryModel(
            id: r.id,
            name: r.name,
            type: r.type == 'income'
                ? CategoryType.income
                : CategoryType.expense,
            icon: r.icon,
            color: r.color,
            isDefault: r.isDefault,
            archived: r.archived,
          ),
        )
        .toList();
  }

  @override
  Future<List<TransactionDetailModel>> getRecentTransactions({
    int limit = 5,
  }) async {
    final query = db.select(db.transactionsTable)
      ..orderBy([(t) => OrderingTerm.desc(t.occurredAt)])
      ..limit(limit);

    final rows = await query.get();
    final categories = await db.select(db.categoriesTable).get();
    final accounts = await db.select(db.accountsTable).get();

    final catMap = {for (var c in categories) c.id: c};
    final accMap = {for (var a in accounts) a.id: a};

    return rows.map((r) {
      final cat = r.categoryId != null ? catMap[r.categoryId] : null;
      final acc = accMap[r.accountId];
      final toAcc = r.toAccountId != null ? accMap[r.toAccountId] : null;

      final type = TransactionType.values.firstWhere(
        (e) => e.name == r.type,
        orElse: () => TransactionType.expense,
      );

      final txModel = TransactionModel(
        id: r.id,
        type: type,
        amount: r.amount,
        categoryId: r.categoryId,
        accountId: r.accountId,
        toAccountId: r.toAccountId,
        occurredAt: r.occurredAt,
        note: r.note,
        createdAt: r.createdAt,
        updatedAt: r.updatedAt,
      );

      return TransactionDetailModel(
        transaction: txModel,
        categoryName: cat?.name,
        categoryIcon: cat?.icon,
        categoryColor: cat?.color,
        accountName: acc?.name ?? 'Akun',
        toAccountName: toAcc?.name,
      );
    }).toList();
  }

  @override
  Future<void> addTransaction(TransactionModel transaction) async {
    await db
        .into(db.transactionsTable)
        .insert(
          TransactionsTableCompanion.insert(
            id: transaction.id,
            type: transaction.type.name,
            amount: transaction.amount,
            categoryId: Value(transaction.categoryId),
            accountId: transaction.accountId,
            toAccountId: Value(transaction.toAccountId),
            occurredAt: transaction.occurredAt,
            note: Value(transaction.note),
            createdAt: transaction.createdAt,
            updatedAt: transaction.updatedAt,
          ),
        );
  }

  @override
  Future<void> deleteTransaction(String id) async {
    await (db.delete(db.transactionsTable)..where((t) => t.id.equals(id))).go();
  }

  @override
  Future<TransactionModel?> getTransactionById(String id) async {
    final r = await (db.select(
      db.transactionsTable,
    )..where((t) => t.id.equals(id))).getSingleOrNull();
    if (r == null) return null;
    return TransactionModel(
      id: r.id,
      type: TransactionType.values.firstWhere(
        (e) => e.name == r.type,
        orElse: () => TransactionType.expense,
      ),
      amount: r.amount,
      categoryId: r.categoryId,
      accountId: r.accountId,
      toAccountId: r.toAccountId,
      occurredAt: r.occurredAt,
      note: r.note,
      createdAt: r.createdAt,
      updatedAt: r.updatedAt,
    );
  }

  @override
  Future<void> updateTransaction(TransactionModel transaction) async {
    await (db.update(
      db.transactionsTable,
    )..where((t) => t.id.equals(transaction.id))).write(
      TransactionsTableCompanion(
        type: Value(transaction.type.name),
        amount: Value(transaction.amount),
        categoryId: Value(transaction.categoryId),
        accountId: Value(transaction.accountId),
        toAccountId: Value(transaction.toAccountId),
        occurredAt: Value(transaction.occurredAt),
        note: Value(transaction.note),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  @override
  Future<List<AccountWithBalanceModel>> getAccountsWithBalances() async {
    final accounts = await getAccounts();
    final allTxs = await db.select(db.transactionsTable).get();

    return accounts.map((acc) {
      int balance = acc.initialBalance;
      for (final tx in allTxs) {
        if (tx.accountId == acc.id) {
          if (tx.type == 'income' || tx.type == 'adjustment') {
            balance += tx.amount;
          } else if (tx.type == 'expense' || tx.type == 'transfer') {
            balance -= tx.amount;
          }
        }
        if (tx.toAccountId == acc.id && tx.type == 'transfer') {
          balance += tx.amount;
        }
      }
      return AccountWithBalanceModel(account: acc, currentBalance: balance);
    }).toList();
  }

  @override
  Future<void> addAccount(AccountModel account) async {
    await db
        .into(db.accountsTable)
        .insert(
          AccountsTableCompanion.insert(
            id: account.id,
            name: account.name,
            type: account.type.name,
            initialBalance: account.initialBalance,
            icon: account.icon,
            color: account.color,
            archived: Value(account.archived),
            createdAt: account.createdAt,
          ),
        );
  }

  @override
  Future<void> updateAccount(AccountModel account) async {
    await (db.update(
      db.accountsTable,
    )..where((t) => t.id.equals(account.id))).write(
      AccountsTableCompanion(
        name: Value(account.name),
        type: Value(account.type.name),
        initialBalance: Value(account.initialBalance),
        icon: Value(account.icon),
        color: Value(account.color),
      ),
    );
  }

  @override
  Future<void> adjustAccountBalance(String accountId, int targetBalance) async {
    await db.transaction(() async {
      final account = await (db.select(
        db.accountsTable,
      )..where((t) => t.id.equals(accountId))).getSingleOrNull();
      if (account == null) throw StateError('Dompet tidak ditemukan');

      final transactions =
          await (db.select(db.transactionsTable)..where(
                (t) =>
                    t.accountId.equals(accountId) |
                    t.toAccountId.equals(accountId),
              ))
              .get();
      var currentBalance = account.initialBalance;
      for (final tx in transactions) {
        if (tx.accountId == accountId) {
          if (tx.type == 'income' || tx.type == 'adjustment') {
            currentBalance += tx.amount;
          } else if (tx.type == 'expense' || tx.type == 'transfer') {
            currentBalance -= tx.amount;
          }
        }
        if (tx.toAccountId == accountId && tx.type == 'transfer') {
          currentBalance += tx.amount;
        }
      }

      final difference = targetBalance - currentBalance;
      if (difference == 0) return;

      final now = DateTime.now();
      await db
          .into(db.transactionsTable)
          .insert(
            TransactionsTableCompanion.insert(
              id: 'adjustment_${now.microsecondsSinceEpoch}',
              type: 'adjustment',
              amount: difference,
              accountId: accountId,
              occurredAt: now,
              note: const Value('Penyesuaian saldo'),
              createdAt: now,
              updatedAt: now,
            ),
          );
    });
  }

  @override
  Future<void> archiveAccount(String id) async {
    await (db.update(db.accountsTable)..where((t) => t.id.equals(id))).write(
      const AccountsTableCompanion(archived: Value(true)),
    );
  }

  @override
  Future<void> addCategory(CategoryModel category) async {
    await db
        .into(db.categoriesTable)
        .insert(
          CategoriesTableCompanion.insert(
            id: category.id,
            name: category.name,
            type: category.type.name,
            icon: category.icon,
            color: category.color,
            isDefault: Value(category.isDefault),
            archived: Value(category.archived),
          ),
        );
  }

  @override
  Future<void> archiveCategory(String id) async {
    await (db.update(db.categoriesTable)..where((t) => t.id.equals(id))).write(
      const CategoriesTableCompanion(archived: Value(true)),
    );
  }

  @override
  Future<List<TransactionDetailModel>> getFilteredTransactions({
    DateTime? month,
    TransactionType? type,
    String? query,
  }) async {
    var q = db.select(db.transactionsTable)
      ..orderBy([(t) => OrderingTerm.desc(t.occurredAt)]);

    if (month != null) {
      final start = DateTime(month.year, month.month, 1);
      final nextMonth = month.month == 12
          ? DateTime(month.year + 1, 1, 1)
          : DateTime(month.year, month.month + 1, 1);
      q = q
        ..where(
          (t) =>
              t.occurredAt.isBiggerOrEqualValue(start) &
              t.occurredAt.isSmallerThanValue(nextMonth),
        );
    }

    if (type != null) {
      q = q..where((t) => t.type.equals(type.name));
    }

    final rows = await q.get();
    final categories = await db.select(db.categoriesTable).get();
    final accounts = await db.select(db.accountsTable).get();

    final catMap = {for (var c in categories) c.id: c};
    final accMap = {for (var a in accounts) a.id: a};

    final allDetails = rows.map((r) {
      final cat = r.categoryId != null ? catMap[r.categoryId] : null;
      final acc = accMap[r.accountId];
      final toAcc = r.toAccountId != null ? accMap[r.toAccountId] : null;

      final txType = TransactionType.values.firstWhere(
        (e) => e.name == r.type,
        orElse: () => TransactionType.expense,
      );

      final txModel = TransactionModel(
        id: r.id,
        type: txType,
        amount: r.amount,
        categoryId: r.categoryId,
        accountId: r.accountId,
        toAccountId: r.toAccountId,
        occurredAt: r.occurredAt,
        note: r.note,
        createdAt: r.createdAt,
        updatedAt: r.updatedAt,
      );

      return TransactionDetailModel(
        transaction: txModel,
        categoryName: cat?.name,
        categoryIcon: cat?.icon,
        categoryColor: cat?.color,
        accountName: acc?.name ?? 'Akun',
        toAccountName: toAcc?.name,
      );
    }).toList();

    if (query != null && query.trim().isNotEmpty) {
      final lower = query.trim().toLowerCase();
      return allDetails.where((d) {
        final matchNote =
            d.transaction.note?.toLowerCase().contains(lower) ?? false;
        final matchCat = d.categoryName?.toLowerCase().contains(lower) ?? false;
        final matchAcc = d.accountName.toLowerCase().contains(lower);
        return matchNote || matchCat || matchAcc;
      }).toList();
    }

    return allDetails;
  }

  @override
  Future<List<CategoryBudgetProgressModel>> getBudgets(String month) async {
    final budgets = await (db.select(
      db.budgetsTable,
    )..where((tbl) => tbl.month.equals(month))).get();
    final categories = await db.select(db.categoriesTable).get();
    final catMap = {for (var c in categories) c.id: c};

    // Calculate spent for this month
    final parts = month.split('-');
    final year = int.parse(parts[0]);
    final m = int.parse(parts[1]);
    final start = DateTime(year, m, 1);
    final end = m == 12 ? DateTime(year + 1, 1, 1) : DateTime(year, m + 1, 1);

    final monthTxs =
        await (db.select(db.transactionsTable)..where(
              (t) =>
                  t.occurredAt.isBiggerOrEqualValue(start) &
                  t.occurredAt.isSmallerThanValue(end) &
                  t.type.equals('expense'),
            ))
            .get();

    final Map<String, int> expenseMap = {};
    for (final tx in monthTxs) {
      if (tx.categoryId != null) {
        expenseMap[tx.categoryId!] =
            (expenseMap[tx.categoryId!] ?? 0) + tx.amount;
      }
    }

    return budgets.map((b) {
      final cat = catMap[b.categoryId];
      final spent = expenseMap[b.categoryId] ?? 0;
      final pct = b.limitAmount > 0 ? (spent / b.limitAmount) : 0.0;
      return CategoryBudgetProgressModel(
        categoryId: b.categoryId,
        categoryName: cat?.name ?? 'Kategori',
        categoryIcon: cat?.icon ?? 'category',
        categoryColor: cat?.color ?? 0xFF10B981,
        spentAmount: spent,
        limitAmount: b.limitAmount,
        percentage: pct,
      );
    }).toList();
  }

  @override
  Future<void> saveBudget(
    String categoryId,
    String month,
    int limitAmount,
  ) async {
    final existing =
        await (db.select(db.budgetsTable)..where(
              (t) => t.categoryId.equals(categoryId) & t.month.equals(month),
            ))
            .getSingleOrNull();

    if (existing != null) {
      await (db.update(db.budgetsTable)..where((t) => t.id.equals(existing.id)))
          .write(BudgetsTableCompanion(limitAmount: Value(limitAmount)));
    } else {
      await db
          .into(db.budgetsTable)
          .insert(
            BudgetsTableCompanion.insert(
              id: 'b_${DateTime.now().millisecondsSinceEpoch}',
              categoryId: categoryId,
              month: month,
              limitAmount: limitAmount,
            ),
          );
    }
  }

  @override
  Future<void> deleteBudget(String id) async {
    await (db.delete(db.budgetsTable)..where((t) => t.id.equals(id))).go();
  }

  @override
  Future<ReportDataModel> getReportsData({
    required String period,
    required DateTime date,
  }) async {
    DateTime start;
    DateTime end;
    DateTime prevStart;
    DateTime prevEnd;

    if (period == 'weekly') {
      // Find Monday
      final weekday = date.weekday; // 1 = Monday, 7 = Sunday
      start = DateTime(
        date.year,
        date.month,
        date.day,
      ).subtract(Duration(days: weekday - 1));
      end = start.add(const Duration(days: 7));
      prevStart = start.subtract(const Duration(days: 7));
      prevEnd = start;
    } else if (period == 'yearly') {
      start = DateTime(date.year, 1, 1);
      end = DateTime(date.year + 1, 1, 1);
      prevStart = DateTime(date.year - 1, 1, 1);
      prevEnd = start;
    } else {
      // monthly
      start = DateTime(date.year, date.month, 1);
      end = date.month == 12
          ? DateTime(date.year + 1, 1, 1)
          : DateTime(date.year, date.month + 1, 1);
      prevStart = date.month == 1
          ? DateTime(date.year - 1, 12, 1)
          : DateTime(date.year, date.month - 1, 1);
      prevEnd = start;
    }

    final currentTxs =
        await (db.select(db.transactionsTable)..where(
              (t) =>
                  t.occurredAt.isBiggerOrEqualValue(start) &
                  t.occurredAt.isSmallerThanValue(end),
            ))
            .get();

    final prevTxs =
        await (db.select(db.transactionsTable)..where(
              (t) =>
                  t.occurredAt.isBiggerOrEqualValue(prevStart) &
                  t.occurredAt.isSmallerThanValue(prevEnd),
            ))
            .get();

    int totalIncome = 0;
    int totalExpense = 0;
    final Map<String, int> catExpenseMap = {};

    for (final tx in currentTxs) {
      if (tx.type == 'income') {
        totalIncome += tx.amount;
      } else if (tx.type == 'expense') {
        totalExpense += tx.amount;
        if (tx.categoryId != null) {
          catExpenseMap[tx.categoryId!] =
              (catExpenseMap[tx.categoryId!] ?? 0) + tx.amount;
        }
      }
    }

    int prevExpense = 0;
    for (final tx in prevTxs) {
      if (tx.type == 'expense') prevExpense += tx.amount;
    }

    // Chart points
    final List<BarChartDataPoint> chartPoints = [];
    if (period == 'weekly') {
      const dayNames = ['Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab', 'Min'];
      for (int i = 0; i < 7; i++) {
        final dayStart = start.add(Duration(days: i));
        final dayEnd = dayStart.add(const Duration(days: 1));
        int dayInc = 0;
        int dayExp = 0;
        for (final tx in currentTxs) {
          if (!tx.occurredAt.isBefore(dayStart) &&
              tx.occurredAt.isBefore(dayEnd)) {
            if (tx.type == 'income') dayInc += tx.amount;
            if (tx.type == 'expense') dayExp += tx.amount;
          }
        }
        chartPoints.add(
          BarChartDataPoint(
            label: dayNames[i],
            income: dayInc,
            expense: dayExp,
          ),
        );
      }
    } else if (period == 'yearly') {
      const monthNames = [
        'Jan',
        'Feb',
        'Mar',
        'Apr',
        'Mei',
        'Jun',
        'Jul',
        'Agu',
        'Sep',
        'Okt',
        'Nov',
        'Des',
      ];
      for (int i = 1; i <= 12; i++) {
        final mStart = DateTime(date.year, i, 1);
        final mEnd = i == 12
            ? DateTime(date.year + 1, 1, 1)
            : DateTime(date.year, i + 1, 1);
        int mInc = 0;
        int mExp = 0;
        for (final tx in currentTxs) {
          if (!tx.occurredAt.isBefore(mStart) && tx.occurredAt.isBefore(mEnd)) {
            if (tx.type == 'income') mInc += tx.amount;
            if (tx.type == 'expense') mExp += tx.amount;
          }
        }
        chartPoints.add(
          BarChartDataPoint(
            label: monthNames[i - 1],
            income: mInc,
            expense: mExp,
          ),
        );
      }
    } else {
      // Monthly: split into 4 weeks
      for (int w = 1; w <= 4; w++) {
        final wStart = start.add(Duration(days: (w - 1) * 7));
        final wEnd = w == 4 ? end : start.add(Duration(days: w * 7));
        int wInc = 0;
        int wExp = 0;
        for (final tx in currentTxs) {
          if (!tx.occurredAt.isBefore(wStart) && tx.occurredAt.isBefore(wEnd)) {
            if (tx.type == 'income') wInc += tx.amount;
            if (tx.type == 'expense') wExp += tx.amount;
          }
        }
        chartPoints.add(
          BarChartDataPoint(label: 'Mg $w', income: wInc, expense: wExp),
        );
      }
    }

    // Category rankings
    final categories = await db.select(db.categoriesTable).get();
    final catMap = {for (var c in categories) c.id: c};
    final List<CategorySpendingModel> rankings = [];
    catExpenseMap.forEach((catId, amount) {
      final cat = catMap[catId];
      final pct = totalExpense > 0 ? (amount / totalExpense) : 0.0;
      rankings.add(
        CategorySpendingModel(
          categoryId: catId,
          categoryName: cat?.name ?? 'Lainnya',
          categoryIcon: cat?.icon ?? 'category',
          categoryColor: cat?.color ?? 0xFF64748B,
          totalAmount: amount,
          percentage: pct,
        ),
      );
    });
    rankings.sort((a, b) => b.totalAmount.compareTo(a.totalAmount));

    // Insight
    String? insight;
    if (prevExpense > 0) {
      final diff = ((totalExpense - prevExpense) / prevExpense * 100).round();
      if (diff < 0) {
        insight =
            'Pengeluaran turun ${diff.abs()}% dibanding periode sebelumnya. Pertahankan!';
      } else if (diff > 0) {
        insight =
            'Pengeluaran naik $diff% dibanding periode sebelumnya. Perhatikan pos belanja!';
      } else {
        insight = 'Pengeluaran sama persis dengan periode sebelumnya.';
      }
    } else if (totalExpense > 0) {
      insight = 'Mulai mencatat pengeluaran. Kelola anggaranmu dengan bijak!';
    }

    return ReportDataModel(
      period: period,
      date: date,
      totalIncome: totalIncome,
      totalExpense: totalExpense,
      netSavings: totalIncome - totalExpense,
      chartPoints: chartPoints,
      categoryRankings: rankings,
      comparisonInsight: insight,
    );
  }

  @override
  Future<String> exportTransactionsCsv(
    DateTime startDate,
    DateTime endDate,
  ) async {
    final start = DateTime(startDate.year, startDate.month, startDate.day);
    final end = DateTime(endDate.year, endDate.month, endDate.day, 23, 59, 59);

    final txs =
        await (db.select(db.transactionsTable)
              ..where(
                (t) =>
                    t.occurredAt.isBiggerOrEqualValue(start) &
                    t.occurredAt.isSmallerOrEqualValue(end),
              )
              ..orderBy([(t) => OrderingTerm.desc(t.occurredAt)]))
            .get();

    final categories = await db.select(db.categoriesTable).get();
    final accounts = await db.select(db.accountsTable).get();
    final catMap = {for (var c in categories) c.id: c.name};
    final accMap = {for (var a in accounts) a.id: a.name};

    final buffer = StringBuffer();
    buffer.writeln('Tanggal,Tipe,Kategori,Dompet,Nominal,Catatan');

    for (final tx in txs) {
      final dateStr =
          '${tx.occurredAt.year}-${tx.occurredAt.month.toString().padLeft(2, '0')}-${tx.occurredAt.day.toString().padLeft(2, '0')}';
      final tipe = tx.type == 'income'
          ? 'Pemasukan'
          : (tx.type == 'expense' ? 'Pengeluaran' : 'Transfer');
      final cat = tx.categoryId != null ? (catMap[tx.categoryId] ?? '') : '';
      final acc = accMap[tx.accountId] ?? '';
      final note = (tx.note ?? '').replaceAll(',', ' ').replaceAll('\n', ' ');
      buffer.writeln('$dateStr,$tipe,$cat,$acc,${tx.amount},"$note"');
    }

    return buffer.toString();
  }

  @override
  Future<void> resetAllData() async {
    await db.delete(db.transactionsTable).go();
    await db.delete(db.budgetsTable).go();
    await db.delete(db.categoriesTable).go();
    await db.delete(db.accountsTable).go();
  }

  @override
  Future<String?> getSetting(String key) async {
    final row = await (db.select(
      db.settingsTable,
    )..where((t) => t.key.equals(key))).getSingleOrNull();
    return row?.value;
  }

  @override
  Future<void> setSetting(String key, String value) async {
    await db
        .into(db.settingsTable)
        .insertOnConflictUpdate(
          SettingsTableCompanion.insert(key: key, value: value),
        );
  }

  @override
  Future<String> getDbPath() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    return p.join(dbFolder.path, 'dompetku.sqlite');
  }
}
