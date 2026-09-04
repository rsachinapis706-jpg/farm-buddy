/// Things the farmer has actually done in this session.
///
/// Without these, "Sell Here" and "Request Transport" are buttons that show a
/// message and forget. Recording them is what makes Profile → My Sales real,
/// and what lets a judge see that an action had a consequence.
class SaleRecord {
  const SaleRecord({
    required this.id,
    required this.marketId,
    required this.marketName,
    required this.cropName,
    required this.cropEmoji,
    required this.quantityKg,
    required this.pricePerKg,
    required this.travelCost,
    required this.soldAt,
  });

  final String id;
  final String marketId;
  final String marketName;
  final String cropName;
  final String cropEmoji;
  final double quantityKg;
  final double pricePerKg;
  final double travelCost;
  final DateTime soldAt;

  double get gross => pricePerKg * quantityKg;
  double get net => gross - travelCost;
}

class BookingRecord {
  const BookingRecord({
    required this.id,
    required this.vehicleName,
    required this.vehicleEmoji,
    required this.destinationName,
    required this.price,
    required this.quantityKg,
    required this.isShared,
    required this.bookedAt,
  });

  final String id;
  final String vehicleName;
  final String vehicleEmoji;
  final String destinationName;
  final double price;
  final double quantityKg;
  final bool isShared;
  final DateTime bookedAt;
}
