import 'package:dompetku/data/db/app_database.dart';
import 'package:dompetku/data/providers/finance_providers.dart';
import 'package:dompetku/data/repositories/finance_repository.dart';
import 'package:dompetku/features/home/home_screen.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';

void main() {
  setUpAll(() async {
    await initializeDateFormatting('id_ID', null);
  });
  testWidgets('HomeScreen renders all Stitch design components properly', (
    tester,
  ) async {
    final db = AppDatabase(NativeDatabase.memory());
    final repo = DriftFinanceRepository(db);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          databaseProvider.overrideWithValue(db),
          financeRepositoryProvider.overrideWithValue(repo),
        ],
        child: const MaterialApp(home: HomeScreen()),
      ),
    );

    // Initial pump & settle async providers
    await tester.pumpAndSettle();

    // Verify Header
    expect(find.text('SakuKu'), findsOneWidget);
    expect(find.text('Halo!'), findsOneWidget);
    expect(find.text('Kelola keuanganmu hari ini'), findsOneWidget);

    // Verify Saldo Card
    expect(find.text('Total Saldo Dompet'), findsOneWidget);
    expect(find.text('Pemasukan'), findsNWidgets(2));
    expect(find.text('Pengeluaran'), findsNWidgets(2));

    // Verify Daily Summary Card
    expect(find.text('Hari Ini'), findsOneWidget);

    // Verify Anggaran Card
    expect(find.text('Anggaran Bulan Ini'), findsOneWidget);

    // Empty database must not render fabricated transaction entries.
    expect(find.text('Transaksi Terakhir'), findsNothing);
    expect(find.text('Supermarket Grand Lucky'), findsNothing);

    // Test Saldo Visibility Toggle
    final eyeButton = find.byIcon(Icons.visibility_outlined);
    if (eyeButton.evaluate().isEmpty) {
      await tester.drag(find.byType(CustomScrollView), const Offset(0, -400));
      await tester.pumpAndSettle();
    }
    final visibleEyeButton = find.byIcon(Icons.visibility_outlined);
    expect(visibleEyeButton, findsOneWidget);
    await tester.tap(visibleEyeButton);
    await tester.pumpAndSettle();

    expect(find.text('••••••••••••'), findsOneWidget);
    expect(find.byIcon(Icons.visibility_off_outlined), findsOneWidget);

    await tester.tap(find.text('Total Saldo Dompet'));
    await tester.pumpAndSettle();
    expect(find.text('Kelola Dompet'), findsOneWidget);
    expect(find.text('Daftar Dompet (0)'), findsOneWidget);

    addTearDown(() async {
      await db.close();
    });
  });
}
