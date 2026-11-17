import 'package:intl/intl.dart';

class DateUtilsId {
  const DateUtilsId._();

  static String formatMonthYear(DateTime date) {
    return DateFormat('MMMM yyyy', 'id_ID').format(date);
  }

  static String formatDayHeader(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final target = DateTime(date.year, date.month, date.day);
    final diff = today.difference(target).inDays;

    if (diff == 0) {
      return 'Hari Ini';
    } else if (diff == 1) {
      return 'Kemarin';
    } else if (date.year == now.year) {
      return DateFormat('d MMM', 'id_ID').format(date);
    } else {
      return DateFormat('d MMM yyyy', 'id_ID').format(date);
    }
  }

  static String formatTime(DateTime date) {
    return DateFormat('HH:mm').format(date);
  }

  static String formatFull(DateTime date) {
    return DateFormat('d MMMM yyyy', 'id_ID').format(date);
  }

  static bool isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }

  static bool isYesterday(DateTime date) {
    final y = DateTime.now().subtract(const Duration(days: 1));
    return date.year == y.year && date.month == y.month && date.day == y.day;
  }

  static String formatMedium(DateTime date) {
    return DateFormat('d MMM yyyy', 'id_ID').format(date);
  }
}
