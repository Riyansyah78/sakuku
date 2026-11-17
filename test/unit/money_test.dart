import 'package:dompetku/core/utils/money.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('MoneyUtils tests', () {
    test('format formats integer Rupiah properly', () {
      expect(MoneyUtils.format(18450000), 'Rp 18.450.000');
      expect(MoneyUtils.format(0), 'Rp 0');
      expect(MoneyUtils.format(500), 'Rp 500');
    });

    test('formatSigned formats income and expense with correct signs', () {
      expect(MoneyUtils.formatSigned(8500000), '+Rp 8.500.000');
      expect(MoneyUtils.formatSigned(-3250000), '-Rp 3.250.000');
      expect(MoneyUtils.formatSigned(0), 'Rp 0');
    });

    test('formatCompact formats compact rupiah properly', () {
      expect(MoneyUtils.formatCompact(1200000), 'Rp 1,2 jt');
      expect(MoneyUtils.formatCompact(450000), 'Rp 450 rb');
      expect(MoneyUtils.formatCompact(1000000000), 'Rp 1 M');
      expect(MoneyUtils.formatCompact(-50000), '-Rp 50 rb');
    });
  });
}
