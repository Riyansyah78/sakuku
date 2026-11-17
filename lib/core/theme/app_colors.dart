import 'package:flutter/material.dart';

class AppColors {
  const AppColors._();

  // Soft sage and stone surfaces for light and dark modes.
  static const Color backgroundLight = Color(0xFFF5F7F4);
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color surfaceVariantLight = Color(0xFFEDF1EC);
  static const Color borderLight = Color(0xFFDCE3DC);
  static const Color textPrimaryLight = Color(0xFF202923);
  static const Color textSecondaryLight = Color(0xFF536057);
  static const Color textTertiaryLight = Color(0xFF748078);

  static const Color backgroundDark = Color(0xFF151A17);
  static const Color surfaceDark = Color(0xFF1D241F);
  static const Color surfaceVariantDark = Color(0xFF252E28);
  static const Color borderDark = Color(0xFF354039);
  static const Color textPrimaryDark = Color(0xFFE8EDE8);
  static const Color textSecondaryDark = Color(0xFFADB8AF);
  static const Color textTertiaryDark = Color(0xFF87938A);

  // Muted sage actions and finance colors.
  static const Color primary = Color(0xFF587362);
  static const Color brandPrimary = Color(0xFF587362);
  static const Color brandPrimaryDark = Color(0xFF465B4D);
  static const Color budgetNearLimit = Color(0xFF9A7847);
  static const Color onPrimary = Color(0xFFFFFFFF);
  static const Color fab = Color(0xFF587362);
  static const Color primaryBright = Color(0xFFAFC3B3);
  static const Color primaryContainerLight = Color(0xFFE1EAE2);
  static const Color primaryContainerDark = Color(0xFF304238);
  static const Color onPrimaryContainerLight = Color(0xFF334A3B);
  static const Color onPrimaryContainerDark = Color(0xFFD0DED2);
  static const Color balanceCardLight = Color(0xFF5C7162);
  static const Color balanceCardDark = Color(0xFF394A3F);
  static const List<int> calmPalette = [
    0xFF73977D,
    0xFF637F91,
    0xFF887594,
    0xFF5E8584,
    0xFFA87578,
    0xFFA47D52,
    0xFF718A63,
    0xFF78827B,
  ];

  // Finance and alert colors use restrained green, clay, and ochre.
  static const Color incomeText = Color(0xFF4D765B);
  static const Color incomeTextLight = Color(0xFF4D765B);
  static const Color incomeTextDark = Color(0xFFA8C6AE);
  static const Color incomeFill = Color(0xFF73977D);
  static const Color incomeBg = Color(0xFFE4EEE6);
  static const Color expenseText = Color(0xFFA45F56);
  static const Color expenseTextLight = Color(0xFFA45F56);
  static const Color expenseTextDark = Color(0xFFD9A098);
  static const Color expenseFill = Color(0xFFC18379);
  static const Color expenseBg = Color(0xFFF3E7E4);
  static const Color warningFillLight = Color(0xFFAA8955);
  static const Color warningFillDark = Color(0xFFC5AA78);
  static const Color warningTextLight = Color(0xFF80643A);
  static const Color warningTextDark = Color(0xFFD5BD91);
  static const Color coin = Color(0xFFAA925F);

  // Category Colors
  static const Color categoryMakan = Color(0xFFA47D52);
  static const Color categoryTransport = Color(0xFF637F91);
  static const Color categoryBelanja = Color(0xFF887594);
  static const Color categoryTagihan = Color(0xFF5E8584);
  static const Color categoryHiburan = Color(0xFFA87578);
  static const Color categoryKesehatan = Color(0xFF718A63);
  static const Color categoryPendidikan = Color(0xFF6D7890);
  static const Color categoryLainnyaExpense = Color(0xFF78827B);
  static const Color categoryIncome = Color(0xFF73977D);

  static const LinearGradient heroGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [balanceCardLight, brandPrimaryDark],
  );
}

@immutable
class FinanceColorsExtension extends ThemeExtension<FinanceColorsExtension> {
  final Color incomeText;
  final Color expenseText;
  final Color expenseFill;
  final Color warningFill;
  final Color warningText;
  final Color border;
  final Color surfaceVariant;
  final Color textSecondary;
  final Color textTertiary;
  final Color fab;
  final LinearGradient heroGradient;

  const FinanceColorsExtension({
    required this.incomeText,
    required this.expenseText,
    required this.expenseFill,
    required this.warningFill,
    required this.warningText,
    required this.border,
    required this.surfaceVariant,
    required this.textSecondary,
    required this.textTertiary,
    required this.fab,
    required this.heroGradient,
  });

  static const light = FinanceColorsExtension(
    incomeText: AppColors.incomeTextLight,
    expenseText: AppColors.expenseTextLight,
    expenseFill: AppColors.expenseFill,
    warningFill: AppColors.warningFillLight,
    warningText: AppColors.warningTextLight,
    border: AppColors.borderLight,
    surfaceVariant: AppColors.surfaceVariantLight,
    textSecondary: AppColors.textSecondaryLight,
    textTertiary: AppColors.textTertiaryLight,
    fab: AppColors.fab,
    heroGradient: AppColors.heroGradient,
  );

  static const dark = FinanceColorsExtension(
    incomeText: AppColors.incomeTextDark,
    expenseText: AppColors.expenseTextDark,
    expenseFill: AppColors.expenseFill,
    warningFill: AppColors.warningFillDark,
    warningText: AppColors.warningTextDark,
    border: AppColors.borderDark,
    surfaceVariant: AppColors.surfaceVariantDark,
    textSecondary: AppColors.textSecondaryDark,
    textTertiary: AppColors.textTertiaryDark,
    fab: AppColors.fab,
    heroGradient: AppColors.heroGradient,
  );

  @override
  FinanceColorsExtension copyWith({
    Color? incomeText,
    Color? expenseText,
    Color? expenseFill,
    Color? warningFill,
    Color? warningText,
    Color? border,
    Color? surfaceVariant,
    Color? textSecondary,
    Color? textTertiary,
    Color? fab,
    LinearGradient? heroGradient,
  }) {
    return FinanceColorsExtension(
      incomeText: incomeText ?? this.incomeText,
      expenseText: expenseText ?? this.expenseText,
      expenseFill: expenseFill ?? this.expenseFill,
      warningFill: warningFill ?? this.warningFill,
      warningText: warningText ?? this.warningText,
      border: border ?? this.border,
      surfaceVariant: surfaceVariant ?? this.surfaceVariant,
      textSecondary: textSecondary ?? this.textSecondary,
      textTertiary: textTertiary ?? this.textTertiary,
      fab: fab ?? this.fab,
      heroGradient: heroGradient ?? this.heroGradient,
    );
  }

  @override
  FinanceColorsExtension lerp(
    ThemeExtension<FinanceColorsExtension>? other,
    double t,
  ) {
    if (other is! FinanceColorsExtension) return this;
    return FinanceColorsExtension(
      incomeText: Color.lerp(incomeText, other.incomeText, t)!,
      expenseText: Color.lerp(expenseText, other.expenseText, t)!,
      expenseFill: Color.lerp(expenseFill, other.expenseFill, t)!,
      warningFill: Color.lerp(warningFill, other.warningFill, t)!,
      warningText: Color.lerp(warningText, other.warningText, t)!,
      border: Color.lerp(border, other.border, t)!,
      surfaceVariant: Color.lerp(surfaceVariant, other.surfaceVariant, t)!,
      textSecondary: Color.lerp(textSecondary, other.textSecondary, t)!,
      textTertiary: Color.lerp(textTertiary, other.textTertiary, t)!,
      fab: Color.lerp(fab, other.fab, t)!,
      heroGradient: LinearGradient.lerp(heroGradient, other.heroGradient, t)!,
    );
  }
}
