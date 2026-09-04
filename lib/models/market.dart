import 'package:farm_buddy/models/enums.dart';

/// A place the farmer could sell to today.
class Market {
  const Market({
    required this.id,
    required this.name,
    required this.type,
    required this.area,
    required this.pricePerKg,
    required this.yesterdayPricePerKg,
    required this.distanceKm,
    required this.demand,
    required this.requiredQuantityKg,
    required this.todaysArrivalsKg,
    required this.travelCostEstimate,
    required this.openHours,
    required this.priceHistory,
    required this.reasonKeys,
    required this.mapX,
    required this.mapY,
    required this.latitude,
    required this.longitude,
    required this.updatedAt,
  });

  final String id;
  final String name;
  final MarketType type;

  /// "Singanallur, Coimbatore"
  final String area;

  final double pricePerKg;
  final double yesterdayPricePerKg;
  final double distanceKm;
  final DemandLevel demand;

  /// How much of this crop the market still wants today.
  final int requiredQuantityKg;

  /// How much has already arrived — high arrivals usually means softer prices.
  final int todaysArrivalsKg;

  final double travelCostEstimate;

  /// "6:00 AM – 1:00 PM"
  final String openHours;

  /// Seven values, oldest first. Drives [PriceTrendChart].
  final List<double> priceHistory;

  /// Localisation keys explaining *why* this market is recommended.
  final List<String> reasonKeys;

  /// Normalised 0..1 position on the drawn map. Used only by [MapPreview],
  /// which has no concept of real geography.
  final double mapX;
  final double mapY;

  /// Real coordinates, used by the live Google map and to compute distance
  /// from wherever the farmer actually is.
  final double latitude;
  final double longitude;

  final DateTime updatedAt;

  double get priceChangePercent {
    if (yesterdayPricePerKg == 0) return 0;
    return ((pricePerKg - yesterdayPricePerKg) / yesterdayPricePerKg) * 100;
  }

  bool get isPriceUp => pricePerKg >= yesterdayPricePerKg;

  double expectedValue(double quantityKg) => pricePerKg * quantityKg;

  double netValue(double quantityKg) =>
      expectedValue(quantityKg) - travelCostEstimate;

  bool acceptsQuantity(double quantityKg) => quantityKg <= requiredQuantityKg;

  /// Simple, explainable ranking score. Deliberately readable: price carries
  /// the most weight, then demand, then how far the farmer must travel.
  /// Nothing about this is a black box — the UI can show every term.
  double score(double quantityKg) {
    final double revenue = netValue(quantityKg);
    final double demandBoost = 1 + (demand.strength * 0.08);
    final double distancePenalty =
        1 - (distanceKm / 400).clamp(0.0, 0.25).toDouble();
    final double capacityPenalty = acceptsQuantity(quantityKg) ? 1.0 : 0.75;
    return revenue * demandBoost * distancePenalty * capacityPenalty;
  }
}
