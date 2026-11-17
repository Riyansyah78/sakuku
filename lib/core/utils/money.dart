import 'package:intl/intl.dart';

class MoneyUtils {
  const MoneyUtils._();

  static final NumberFormat _formatter = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 0,
  );

  /// Format plain Rupiah: "Rp 1.250.000"
  static String format(int amount) {
    return _formatter.format(amount).replaceAll('\u00A0', ' ');
  }

  /// Format signed Rupiah: "+Rp 8.500.000" or "-Rp 3.250.000" or "Rp 0"
  static String formatSigned(int amount) {
    if (amount > 0) {
      return '+${format(amount)}';
    } else if (amount < 0) {
      return '-${format(amount.abs())}';
    }
    return format(0);
  }

  /// Format compact Rupiah: "Rp 1,2 jt", "Rp 450 rb"
  static String formatCompact(int amount) {
    final abs = amount.abs();
    final sign = amount < 0 ? '-' : '';

    if (abs >= 1000000000) {
      final val = abs / 1000000000.0;
      final str = val
          .toStringAsFixed(val.truncateToDouble() == val ? 0 : 1)
          .replaceAll('.', ',');
      return '${sign}Rp $str M';
    } else if (abs >= 1000000) {
      final val = abs / 1000000.0;
      final str = val
          .toStringAsFixed(val.truncateToDouble() == val ? 0 : 1)
          .replaceAll('.', ',');
      return '${sign}Rp $str jt';
    } else if (abs >= 1000) {
      final val = abs / 1000.0;
      final str = val
          .toStringAsFixed(val.truncateToDouble() == val ? 0 : 1)
          .replaceAll('.', ',');
      return '${sign}Rp $str rb';
    }
    return '${sign}Rp $abs';
  }
}
