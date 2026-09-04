import 'package:farm_buddy/models/enums.dart';

/// The single "here is today, in one glance" card on Home.
class MarketInsight {
  const MarketInsight({
    required this.cropName,
    required this.cropEmoji,
    required this.pricePerKg,
    required this.changePercent,
    required this.distanceKm,
    required this.demand,
    required this.marketId,
    required this.marketName,
    required this.priceHistory,
    required this.updatedAt,
  });

  final String cropName;
  final String cropEmoji;
  final double pricePerKg;

  /// Change against yesterday, e.g. 8 for "+8%".
  final double changePercent;

  final double distanceKm;
  final DemandLevel demand;

  /// So "View Market Details" knows where to go.
  final String marketId;
  final String marketName;

  /// Seven days, oldest first — powers the sparkline on the card.
  final List<double> priceHistory;

  final DateTime updatedAt;

  bool get isUp => changePercent >= 0;
}
