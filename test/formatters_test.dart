import 'package:flutter_test/flutter_test.dart';

import 'package:farm_buddy/core/utils/formatters.dart';

void main() {
  group('Indian digit grouping', () {
    test('groups the last three digits, then pairs', () {
      expect(Fmt.indianGroup(500), '500');
      expect(Fmt.indianGroup(1850), '1,850');
      expect(Fmt.indianGroup(16000), '16,000');
      expect(Fmt.indianGroup(186400), '1,86,400');
      expect(Fmt.indianGroup(1234567), '12,34,567');
      expect(Fmt.indianGroup(12345678), '1,23,45,678');
    });

    test('handles negatives', () {
      expect(Fmt.indianGroup(-16000), '-16,000');
    });
  });

  group('money', () {
    test('rupees uses the ₹ glyph and Indian grouping', () {
      expect(Fmt.rupees(16000), '₹16,000');
      expect(Fmt.rupees(186400), '₹1,86,400');
    });

    test('compact money uses K / L / Cr', () {
      expect(Fmt.rupeesCompact(16000), '₹16K');
      expect(Fmt.rupeesCompact(186400), '₹1.9L');
    });

    test('price per kg drops a trailing .0 but keeps real decimals', () {
      expect(Fmt.pricePerKg(32), '₹32/kg');
      expect(Fmt.pricePerKg(27.5), '₹27.5/kg');
    });
  });

  group('units', () {
    test('distance', () {
      expect(Fmt.km(12), '12 km');
      expect(Fmt.km(2.4), '2.4 km');
    });

    test('quantity switches to tonnes only on exact thousands', () {
      expect(Fmt.quantity(500), '500 kg');
      expect(Fmt.quantity(1850), '1,850 kg');
      expect(Fmt.quantity(1000), '1 tonne');
      expect(Fmt.quantity(2000), '2 tonnes');
    });

    test('kilos always stays in kg', () {
      expect(Fmt.kilos(2000), '2,000 kg');
      expect(Fmt.kilos(1850), '1,850 kg');
    });

    test('signed percent keeps the sign for the caller to pair with an icon', () {
      expect(Fmt.signedPercent(8), '+8%');
      expect(Fmt.signedPercent(-3), '-3%');
    });

    test('durations read like a person would say them', () {
      expect(Fmt.minutes(45), '45 min');
      expect(Fmt.minutes(60), '1 hr');
      expect(Fmt.minutes(95), '1 hr 35 min');
    });
  });

  group('freshness', () {
    test('relative time buckets', () {
      final DateTime now = DateTime(2026, 3, 1, 12, 0);
      expect(Fmt.relative(now.subtract(const Duration(seconds: 5)), now: now),
          'just now');
      expect(Fmt.relative(now.subtract(const Duration(minutes: 10)), now: now),
          '10 min ago');
      expect(Fmt.relative(now.subtract(const Duration(hours: 3)), now: now),
          '3 hr ago');
      expect(Fmt.relative(now.subtract(const Duration(days: 1)), now: now),
          'yesterday');
    });

    test('relativeParts returns a localisation key and a value', () {
      final DateTime now = DateTime(2026, 3, 1, 12, 0);
      final parts =
          Fmt.relativeParts(now.subtract(const Duration(minutes: 10)), now: now);
      expect(parts.$1, 'time.minutesAgo');
      expect(parts.$2, '10');
    });
  });
}
