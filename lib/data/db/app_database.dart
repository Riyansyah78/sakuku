import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

import 'default_categories.dart';

part 'app_database.g.dart';

class AccountsTable extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get type => text()(); // cash, bank, ewallet
  IntColumn get initialBalance => integer()();
  TextColumn get icon => text()();
  IntColumn get color => integer()();
  BoolColumn get archived => boolean().withDefault(const Constant(false))();
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

class CategoriesTable extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get type => text()(); // expense, income
  TextColumn get icon => text()();
  IntColumn get color => integer()();
  BoolColumn get isDefault => boolean().withDefault(const Constant(false))();
  BoolColumn get archived => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};
}

class TransactionsTable extends Table {
  TextColumn get id => text()();
  TextColumn get type => text()(); // expense, income, transfer
  IntColumn get amount => integer()();
  TextColumn get categoryId => text().nullable()();
  TextColumn get accountId => text()();
  TextColumn get toAccountId => text().nullable()();
  DateTimeColumn get occurredAt => dateTime()();
  TextColumn get note => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

class BudgetsTable extends Table {
  TextColumn get id => text()();
  TextColumn get categoryId => text()();
  TextColumn get month => text()(); // YYYY-MM
  IntColumn get limitAmount => integer()();

  @override
  Set<Column> get primaryKey => {id};
}

class SettingsTable extends Table {
  TextColumn get key => text()();
  TextColumn get value => text()();

  @override
  Set<Column> get primaryKey => {key};
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'dompetku.sqlite'));
    return NativeDatabase.createInBackground(file);
  });
}

@DriftDatabase(
  tables: [
    AccountsTable,
    CategoriesTable,
    TransactionsTable,
    BudgetsTable,
    SettingsTable,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? e]) : super(e ?? _openConnection());

  @override
  int get schemaVersion => 3;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) async {
      await m.createAll();
      await _seedDefaultCategories();
      await _applyDefaultCategoryPalette();
    },
    onUpgrade: (m, from, to) async {
      if (from < 2) {
        await _seedDefaultCategories();
      }
      if (from < 3) {
        await _applyDefaultCategoryPalette();
      }
    },
  );

  Future<void> _seedDefaultCategories() async {
    for (final cat in defaultCategories) {
      await into(categoriesTable).insertOnConflictUpdate(cat);
    }
  }

  Future<void> _applyDefaultCategoryPalette() async {
    for (final category in defaultCategories) {
      await (update(categoriesTable)
            ..where((row) => row.id.equals(category.id.value)))
          .write(CategoriesTableCompanion(color: category.color));
    }
  }
}
