enum TransactionType { expense, income, transfer, adjustment }

class TransactionModel {
  final String id;
  final TransactionType type;
  final int amount; // in Rupiah, int only
  final String? categoryId;
  final String accountId;
  final String? toAccountId;
  final DateTime occurredAt;
  final String? note;
  final DateTime createdAt;
  final DateTime updatedAt;

  const TransactionModel({
    required this.id,
    required this.type,
    required this.amount,
    this.categoryId,
    required this.accountId,
    this.toAccountId,
    required this.occurredAt,
    this.note,
    required this.createdAt,
    required this.updatedAt,
  });
}

class TransactionDetailModel {
  final TransactionModel transaction;
  final String? categoryName;
  final String? categoryIcon;
  final int? categoryColor;
  final String accountName;
  final String? toAccountName;

  const TransactionDetailModel({
    required this.transaction,
    this.categoryName,
    this.categoryIcon,
    this.categoryColor,
    required this.accountName,
    this.toAccountName,
  });
}
