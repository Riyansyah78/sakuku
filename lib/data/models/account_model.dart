enum AccountType { cash, bank, ewallet }

class AccountModel {
  final String id;
  final String name;
  final AccountType type;
  final int initialBalance;
  final String icon;
  final int color;
  final bool archived;
  final DateTime createdAt;

  const AccountModel({
    required this.id,
    required this.name,
    required this.type,
    required this.initialBalance,
    required this.icon,
    required this.color,
    this.archived = false,
    required this.createdAt,
  });

  AccountModel copyWith({
    String? id,
    String? name,
    AccountType? type,
    int? initialBalance,
    String? icon,
    int? color,
    bool? archived,
    DateTime? createdAt,
  }) {
    return AccountModel(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      initialBalance: initialBalance ?? this.initialBalance,
      icon: icon ?? this.icon,
      color: color ?? this.color,
      archived: archived ?? this.archived,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

class AccountWithBalanceModel {
  final AccountModel account;
  final int currentBalance;

  const AccountWithBalanceModel({
    required this.account,
    required this.currentBalance,
  });
}
