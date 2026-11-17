import 'package:dompetku/data/db/app_database.dart';
import 'package:dompetku/data/models/account_model.dart';
import 'package:dompetku/data/models/transaction_model.dart';
import 'package:dompetku/data/repositories/finance_repository.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late AppDatabase db;
  late DriftFinanceRepository repo;

  setUp(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    db = AppDatabase(NativeDatabase.memory());
    repo = DriftFinanceRepository(db);
  });

  tearDown(() async {
    await db.close();
  });

  group('DriftFinanceRepository tests', () {
    test('fresh database stays empty without sample data', () async {
      await repo.removeSampleDataIfPresent();

      expect(await repo.getAccounts(), isEmpty);
      // Default categories are seeded on creation, so categories is NOT empty
      expect(await repo.getCategories(), isNotEmpty);
      expect(await repo.getRecentTransactions(), isEmpty);
      expect(await repo.getBudgets(_month(DateTime.now())), isEmpty);

      final dashboard = await repo.getHomeDashboardData(DateTime.now());
      expect(dashboard.totalBalance, 0);
      expect(dashboard.totalIncome, 0);
      expect(dashboard.totalExpense, 0);
      expect(dashboard.todayIncome, 0);
      expect(dashboard.todayExpense, 0);
      expect(dashboard.totalBudgetLimit, 0);
    });

    test(
      'balance adjustments update balance and remain in transaction history',
      () async {
        final now = DateTime.now();
        await repo.addAccount(
          AccountModel(
            id: 'acc_test',
            name: 'Dompet Tes',
            type: AccountType.cash,
            initialBalance: 100,
            icon: 'payments',
            color: 0xFF10B981,
            createdAt: now,
          ),
        );
        await repo.addTransaction(
          TransactionModel(
            id: 'tx_test_income',
            type: TransactionType.income,
            amount: 20,
            accountId: 'acc_test',
            occurredAt: now,
            createdAt: now,
            updatedAt: now,
          ),
        );
        await repo.addTransaction(
          TransactionModel(
            id: 'tx_test_expense',
            type: TransactionType.expense,
            amount: 5,
            accountId: 'acc_test',
            occurredAt: now,
            createdAt: now,
            updatedAt: now,
          ),
        );

        await repo.adjustAccountBalance('acc_test', 200);
        expect(
          (await repo.getAccountsWithBalances()).single.currentBalance,
          200,
        );
        final history = await repo.getFilteredTransactions();
        final adjustment = history.singleWhere(
          (item) => item.transaction.type == TransactionType.adjustment,
        );
        expect(adjustment.transaction.amount, 85);

        await repo.adjustAccountBalance('acc_test', 200);
        expect((await repo.getFilteredTransactions()).length, 3);

        await repo.adjustAccountBalance('acc_test', 50);
        expect(
          (await repo.getAccountsWithBalances()).single.currentBalance,
          50,
        );
        final dashboard = await repo.getHomeDashboardData(now);
        expect(dashboard.totalBalance, 50);
      },
    );

    test('settings CRUD works correctly', () async {
      expect(await repo.getSetting('user_name'), isNull);

      await repo.setSetting('user_name', 'Budi');
      expect(await repo.getSetting('user_name'), 'Budi');

      await repo.setSetting('user_name', 'Rian Baru');
      expect(await repo.getSetting('user_name'), 'Rian Baru');

      await repo.setSetting('user_email', 'rian@test.com');
      expect(await repo.getSetting('user_email'), 'rian@test.com');

      // Theme & balance settings persistence
      await repo.setSetting('theme_mode', 'dark');
      expect(await repo.getSetting('theme_mode'), 'dark');

      await repo.setSetting('hide_balance', 'true');
      expect(await repo.getSetting('hide_balance'), 'true');
    });
  });
}

String _month(DateTime date) =>
    '${date.year}-${date.month.toString().padLeft(2, '0')}';
