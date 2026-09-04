/// Display formatting for money, weight, distance and time.
///
/// Money uses the Indian grouping convention (1,86,400 — not 186,400) because
/// that is what a farmer reads on a mandi slip.
abstract final class Fmt {
  static const String rupee = '₹';

  /// Groups digits the Indian way: last three, then pairs.
  /// 500 -> "500", 16000 -> "16,000", 186400 -> "1,86,400".
  static String indianGroup(num value) {
    final bool negative = value < 0;
    final int whole = value.abs().round();
    final String digits = whole.toString();

    if (digits.length <= 3) return negative ? '-$digits' : digits;

    final String lastThree = digits.substring(digits.length - 3);
    String rest = digits.substring(0, digits.length - 3);

    final StringBuffer buffer = StringBuffer();
    while (rest.length > 2) {
      buffer.write(',${rest.substring(rest.length - 2)}');
      rest = rest.substring(0, rest.length - 2);
    }

    final List<String> pairs = <String>[];
    final String tail = buffer.toString();
    if (tail.isNotEmpty) {
      pairs.addAll(tail.split(',').where((String p) => p.isNotEmpty).toList().reversed);
    }

    final String grouped =
        <String>[rest, ...pairs, lastThree].where((String p) => p.isNotEmpty).join(',');
    return negative ? '-$grouped' : grouped;
  }

  /// 16000 -> "₹16,000"
  static String rupees(num value) => '$rupee${indianGroup(value)}';

  /// 16000 -> "₹16K", 186400 -> "₹1.9L"
  static String rupeesCompact(num value) {
    final double v = value.toDouble();
    if (v.abs() >= 10000000) {
      return '$rupee${_trim(v / 10000000)}Cr';
    }
    if (v.abs() >= 100000) {
      return '$rupee${_trim(v / 100000)}L';
    }
    if (v.abs() >= 1000) {
      return '$rupee${_trim(v / 1000)}K';
    }
    return rupees(v);
  }

  /// 32 -> "₹32/kg", 27.5 -> "₹27.5/kg"
  static String pricePerKg(num value) => '$rupee${_trim(value)}/kg';

  /// Bare price with no unit: 32 -> "₹32"
  static String price(num value) => '$rupee${_trim(value)}';

  /// 12 -> "12 km", 2.4 -> "2.4 km"
  static String km(num value) => '${_trim(value)} km';

  /// 500 -> "500 kg", 1850 -> "1,850 kg", 2000 -> "2 tonnes"
  static String quantity(num kg) {
    if (kg >= 1000 && kg % 1000 == 0) {
      final num tonnes = kg / 1000;
      return '${_trim(tonnes)} ${tonnes == 1 ? 'tonne' : 'tonnes'}';
    }
    return '${indianGroup(kg)} kg';
  }

  /// Always in kg, grouped. 1850 -> "1,850 kg"
  static String kilos(num kg) => '${indianGroup(kg)} kg';

  /// 8.2 -> "8.2%"
  static String percent(num value) => '${_trim(value)}%';

  /// -3 -> "-3%", 8 -> "+8%". The caller supplies the arrow icon so that
  /// direction is never communicated by colour alone.
  static String signedPercent(num value) {
    final String sign = value > 0 ? '+' : '';
    return '$sign${_trim(value)}%';
  }

  /// 95 -> "1 hr 35 min", 45 -> "45 min"
  static String minutes(int totalMinutes) {
    if (totalMinutes < 60) return '$totalMinutes min';
    final int hours = totalMinutes ~/ 60;
    final int mins = totalMinutes % 60;
    if (mins == 0) return '$hours hr';
    return '$hours hr $mins min';
  }

  /// Relative freshness used by [FreshnessChip]. Returns a translation key
  /// suffix plus a value so callers can localise; the plain-English version
  /// here is the fallback.
  static String relative(DateTime time, {DateTime? now}) {
    final DateTime reference = now ?? DateTime.now();
    final Duration diff = reference.difference(time);

    if (diff.inSeconds < 60) return 'just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes} min ago';
    if (diff.inHours < 24) return '${diff.inHours} hr ago';
    if (diff.inDays == 1) return 'yesterday';
    return '${diff.inDays} days ago';
  }

  /// Structured version of [relative] so screens can localise the unit.
  /// Returns e.g. `('time.minutesAgo', '10')`.
  static (String keySuffix, String value) relativeParts(
    DateTime time, {
    DateTime? now,
  }) {
    final DateTime reference = now ?? DateTime.now();
    final Duration diff = reference.difference(time);

    if (diff.inSeconds < 60) return ('time.justNow', '');
    if (diff.inMinutes < 60) return ('time.minutesAgo', '${diff.inMinutes}');
    if (diff.inHours < 24) return ('time.hoursAgo', '${diff.inHours}');
    if (diff.inDays == 1) return ('time.yesterday', '');
    return ('time.daysAgo', '${diff.inDays}');
  }

  /// Drops a trailing ".0" so 12.0 renders as "12" but 12.4 stays "12.4".
  static String _trim(num value) {
    final double v = value.toDouble();
    if (v == v.roundToDouble()) return indianGroup(v);
    final String oneDecimal = v.toStringAsFixed(1);
    final List<String> parts = oneDecimal.split('.');
    return '${indianGroup(double.parse(parts.first))}.${parts.last}';
  }
}
