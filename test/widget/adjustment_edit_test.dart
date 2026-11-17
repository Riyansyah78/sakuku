import 'package:dompetku/data/db/app_database.dart';
import 'package:dompetku/data/models/account_model.dart';
import 'package:dompetku/data/models/transaction_model.dart';
import 'package:dompetku/data/providers/finance_providers.dart';
import 'package:dompetku/data/repositories/finance_repository.dart';
import 'package:dompetku/features/transactions/add_transaction_screen.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';

void main() {
  setUpAll(() async => initializeDateFormatting('id_ID', null));

  testWidgets('balance adjustment can be edited to a negative amount', (
    tester,
  ) async {
    final db = AppDatabase(NativeDatabase.memory());
    final repo = DriftFinanceRepository(db);
    final now = DateTime.now();
    await repo.addAccount(
      AccountModel(
        id: 'acc_adjustment_test',
        name: 'Dompet Tes',
        type: AccountType.cash,
        initialBalance: 0,
        icon: 'payments',
        color: 0xFF587362,
        createdAt: now,
      ),
    );
    final transaction = TransactionModel(
      id: 'tx_adjustment_test',
      type: TransactionType.adjustment,
      amount: 100,
      accountId: 'acc_adjustment_test',
      occurredAt: now,
      note: 'Penyesuaian saldo',
      createdAt: now,
      updatedAt: now,
    );
    await repo.addTransaction(transaction);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          databaseProvider.overrideWithValue(db),
          financeRepositoryProvider.overrideWithValue(repo),
        ],
        child: MaterialApp(
          home: AddTransactionScreen(
            initialDetail: TransactionDetailModel(
              transaction: transaction,
              accountName: 'Dompet Tes',
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final saveButton = find.widgetWithText(
      FilledButton,
      'Simpan Perubahan',
    );
    expect(tester.widget<FilledButton>(saveButton).onPressed, isNotNull);
    await tester.tap(find.text('Kurangi Saldo'));
    await tester.pumpAndSettle();
    await tester.tap(saveButton);
    await tester.pumpAndSettle();

    expect((await repo.getTransactionById(transaction.id))?.amount, -100);
    addTearDown(() async => db.close());
  });
}
