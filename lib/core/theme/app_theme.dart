import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'app_radius.dart';
import 'app_typography.dart';

class AppTheme {
  const AppTheme._();

  static ThemeData get light {
    final colorScheme = ColorScheme(
      brightness: Brightness.light,
      primary: AppColors.primary,
      onPrimary: AppColors.onPrimary,
      primaryContainer: AppColors.primaryContainerLight,
      onPrimaryContainer: AppColors.onPrimaryContainerLight,
      secondary: AppColors.brandPrimary,
      onSecondary: Colors.white,
      error: AppColors.expenseTextLight,
      onError: Colors.white,
      onSurfaceVariant: AppColors.textSecondaryLight,
      surface: AppColors.surfaceLight,
      onSurface: AppColors.textPrimaryLight,
      surfaceContainerLowest: AppColors.surfaceLight,
      surfaceContainerLow: AppColors.surfaceVariantLight,
      surfaceContainer: AppColors.surfaceVariantLight,
      surfaceContainerHigh: const Color(0xFFE3E9E3),
      outline: AppColors.borderLight,
      outlineVariant: AppColors.borderLight,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: AppColors.backgroundLight,
      cardTheme: const CardThemeData(
        color: AppColors.surfaceLight,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.standardCardRadius,
          side: BorderSide(color: AppColors.borderLight, width: 1),
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.borderLight,
        thickness: 1,
        space: 1,
      ),
      textTheme: TextTheme(
        headlineLarge: AppTypography.titleLarge.copyWith(
          color: AppColors.textPrimaryLight,
        ),
        headlineMedium: AppTypography.titleMedium.copyWith(
          color: AppColors.textPrimaryLight,
        ),
        headlineSmall: AppTypography.titleSmall.copyWith(
          color: AppColors.textPrimaryLight,
        ),
        titleLarge: AppTypography.titleLarge.copyWith(
          color: AppColors.textPrimaryLight,
        ),
        titleMedium: AppTypography.titleMedium.copyWith(
          color: AppColors.textPrimaryLight,
        ),
        titleSmall: AppTypography.titleSmall.copyWith(
          color: AppColors.textPrimaryLight,
        ),
        bodyLarge: AppTypography.bodyStrong.copyWith(
          color: AppColors.textPrimaryLight,
        ),
        bodyMedium: AppTypography.body.copyWith(
          color: AppColors.textPrimaryLight,
        ),
        bodySmall: AppTypography.caption.copyWith(
          color: AppColors.textSecondaryLight,
        ),
        labelLarge: AppTypography.bodyStrong.copyWith(
          color: AppColors.textPrimaryLight,
        ),
        labelMedium: AppTypography.caption.copyWith(
          color: AppColors.textSecondaryLight,
        ),
        labelSmall: AppTypography.caption.copyWith(
          color: AppColors.textTertiaryLight,
        ),
      ),
      extensions: const [FinanceColorsExtension.light],
    );
  }

  static ThemeData get dark {
    final colorScheme = ColorScheme(
      brightness: Brightness.dark,
      primary: AppColors.primaryBright,
      onPrimary: AppColors.backgroundDark,
      primaryContainer: AppColors.primaryContainerDark,
      onPrimaryContainer: AppColors.onPrimaryContainerDark,
      secondary: AppColors.primaryBright,
      onSecondary: AppColors.textPrimaryDark,
      error: AppColors.expenseTextDark,
      onError: AppColors.textPrimaryDark,
      onSurfaceVariant: AppColors.textSecondaryDark,
      surface: AppColors.surfaceDark,
      onSurface: AppColors.textPrimaryDark,
      surfaceContainerLowest: AppColors.surfaceDark,
      surfaceContainerLow: AppColors.surfaceVariantDark,
      surfaceContainer: AppColors.surfaceVariantDark,
      surfaceContainerHigh: const Color(0xFF263349),
      outline: AppColors.borderDark,
      outlineVariant: AppColors.borderDark,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: AppColors.backgroundDark,
      cardTheme: const CardThemeData(
        color: AppColors.surfaceDark,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.standardCardRadius,
          side: BorderSide(color: AppColors.borderDark, width: 1),
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.borderDark,
        thickness: 1,
        space: 1,
      ),
      textTheme: TextTheme(
        headlineLarge: AppTypography.titleLarge.copyWith(
          color: AppColors.textPrimaryDark,
        ),
        headlineMedium: AppTypography.titleMedium.copyWith(
          color: AppColors.textPrimaryDark,
        ),
        headlineSmall: AppTypography.titleSmall.copyWith(
          color: AppColors.textPrimaryDark,
        ),
        titleLarge: AppTypography.titleLarge.copyWith(
          color: AppColors.textPrimaryDark,
        ),
        titleMedium: AppTypography.titleMedium.copyWith(
          color: AppColors.textPrimaryDark,
        ),
        titleSmall: AppTypography.titleSmall.copyWith(
          color: AppColors.textPrimaryDark,
        ),
        bodyLarge: AppTypography.bodyStrong.copyWith(
          color: AppColors.textPrimaryDark,
        ),
        bodyMedium: AppTypography.body.copyWith(
          color: AppColors.textPrimaryDark,
        ),
        bodySmall: AppTypography.caption.copyWith(
          color: AppColors.textSecondaryDark,
        ),
        labelLarge: AppTypography.bodyStrong.copyWith(
          color: AppColors.textPrimaryDark,
        ),
        labelMedium: AppTypography.caption.copyWith(
          color: AppColors.textSecondaryDark,
        ),
        labelSmall: AppTypography.caption.copyWith(
          color: AppColors.textTertiaryDark,
        ),
      ),
      extensions: const [FinanceColorsExtension.dark],
    );
  }
}

extension ThemeContextX on BuildContext {
  ThemeData get theme => Theme.of(this);
  ColorScheme get colorScheme => Theme.of(this).colorScheme;
  TextTheme get textTheme => Theme.of(this).textTheme;
  FinanceColorsExtension get financeColors =>
      Theme.of(this).extension<FinanceColorsExtension>() ??
      FinanceColorsExtension.light;
}
