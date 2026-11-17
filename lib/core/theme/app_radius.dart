import 'package:flutter/material.dart';

class AppRadius {
  const AppRadius._();

  static const double heroCard = 24.0;
  static const double standardCard = 16.0;
  static const double categoryChip = 16.0;
  static const double button = 14.0;
  static const double textField = 12.0;
  static const double pill = 999.0;
  static const double bottomSheet = 28.0;
  static const double dialog = 24.0;

  static const BorderRadius heroCardRadius = BorderRadius.all(
    Radius.circular(heroCard),
  );
  static const BorderRadius standardCardRadius = BorderRadius.all(
    Radius.circular(standardCard),
  );
  static const BorderRadius categoryChipRadius = BorderRadius.all(
    Radius.circular(categoryChip),
  );
  static const BorderRadius buttonRadius = BorderRadius.all(
    Radius.circular(button),
  );
  static const BorderRadius textFieldRadius = BorderRadius.all(
    Radius.circular(textField),
  );
  static const BorderRadius pillRadius = BorderRadius.all(
    Radius.circular(pill),
  );
  static const BorderRadius bottomSheetRadius = BorderRadius.vertical(
    top: Radius.circular(bottomSheet),
  );
  static const BorderRadius dialogRadius = BorderRadius.all(
    Radius.circular(dialog),
  );
}
