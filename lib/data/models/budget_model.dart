class BudgetModel {
  final String id;
  final String categoryId;
  final String month; // YYYY-MM
  final int limitAmount;

  const BudgetModel({
    required this.id,
    required this.categoryId,
    required this.month,
    required this.limitAmount,
  });
}

class CategoryBudgetProgressModel {
  final String categoryId;
  final String categoryName;
  final String categoryIcon;
  final int categoryColor;
  final int spentAmount;
  final int limitAmount;
  final double percentage; // spent / limit

  const CategoryBudgetProgressModel({
    required this.categoryId,
    required this.categoryName,
    required this.categoryIcon,
    required this.categoryColor,
    required this.spentAmount,
    required this.limitAmount,
    required this.percentage,
  });

  bool get isWarning => percentage >= 0.8 && percentage < 1.0;
  bool get isExceeded => percentage >= 1.0;
}
