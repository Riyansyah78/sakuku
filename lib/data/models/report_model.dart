class CategorySpendingModel {
  final String categoryId;
  final String categoryName;
  final String categoryIcon;
  final int categoryColor;
  final int totalAmount;
  final double percentage; // 0.0 - 1.0

  const CategorySpendingModel({
    required this.categoryId,
    required this.categoryName,
    required this.categoryIcon,
    required this.categoryColor,
    required this.totalAmount,
    required this.percentage,
  });
}

class BarChartDataPoint {
  final String label; // e.g. "Mg 1", "Jan", "Sen"
  final int income;
  final int expense;

  const BarChartDataPoint({
    required this.label,
    required this.income,
    required this.expense,
  });
}

class ReportDataModel {
  final String period; // 'weekly', 'monthly', 'yearly'
  final DateTime date;
  final int totalIncome;
  final int totalExpense;
  final int netSavings;
  final List<BarChartDataPoint> chartPoints;
  final List<CategorySpendingModel> categoryRankings;
  final String? comparisonInsight;

  const ReportDataModel({
    required this.period,
    required this.date,
    required this.totalIncome,
    required this.totalExpense,
    required this.netSavings,
    required this.chartPoints,
    required this.categoryRankings,
    this.comparisonInsight,
  });
}
