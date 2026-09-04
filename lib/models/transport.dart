import 'package:farm_buddy/models/enums.dart';

/// Farm -> market. The one journey the farmer actually has to make.
class TransportRoute {
  const TransportRoute({
    required this.pickupName,
    required this.pickupSub,
    required this.destinationName,
    required this.destinationSub,
    required this.distanceKm,
    required this.durationMinutes,
    required this.estimatedCost,
  });

  final String pickupName;
  final String pickupSub;
  final String destinationName;
  final String destinationSub;
  final double distanceKm;
  final int durationMinutes;
  final double estimatedCost;

  TransportRoute copyWith({
    String? destinationName,
    String? destinationSub,
    double? distanceKm,
    int? durationMinutes,
    double? estimatedCost,
  }) {
    return TransportRoute(
      pickupName: pickupName,
      pickupSub: pickupSub,
      destinationName: destinationName ?? this.destinationName,
      destinationSub: destinationSub ?? this.destinationSub,
      distanceKm: distanceKm ?? this.distanceKm,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      estimatedCost: estimatedCost ?? this.estimatedCost,
    );
  }
}

/// A vehicle the farmer can book, or a shared trip they can join.
class TransportOption {
  const TransportOption({
    required this.id,
    required this.providerName,
    required this.driverName,
    required this.type,
    required this.capacityKg,
    required this.price,
    required this.etaMinutes,
    required this.isAvailable,
    required this.rating,
    this.isShared = false,
    this.savingAmount,
    this.sharingFarmerCount,
  });

  final String id;

  /// "Tata Ace" — the vehicle a farmer recognises by sight.
  final String providerName;
  final String driverName;
  final VehicleType type;
  final int capacityKg;
  final double price;
  final int etaMinutes;
  final bool isAvailable;
  final double rating;

  /// Shared trips split the cost between farmers going the same way.
  final bool isShared;
  final double? savingAmount;
  final int? sharingFarmerCount;

  bool fits(double quantityKg) => quantityKg <= capacityKg;

  /// How full the load would be — drives the small capacity meter.
  double loadFactor(double quantityKg) => capacityKg == 0
      ? 0.0
      : (quantityKg / capacityKg).clamp(0.0, 1.0).toDouble();
}
