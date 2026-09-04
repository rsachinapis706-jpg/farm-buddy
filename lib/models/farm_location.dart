import 'dart:math' as math;

/// Where the farmer is, as the app understands it.
///
/// Two ways this gets filled: the device GPS, or the farmer picking a place by
/// hand. Both are legitimate — a farmer with location turned off must still be
/// able to use every screen, so [source] is recorded rather than assumed.
enum LocationSource { device, manual, defaultGuess }

class FarmLocation {
  const FarmLocation({
    required this.latitude,
    required this.longitude,
    required this.label,
    required this.source,
    required this.capturedAt,
    this.accuracyMetres,
  });

  final double latitude;
  final double longitude;

  /// Human-readable, e.g. "Sulur, Coimbatore".
  final String label;

  final LocationSource source;
  final DateTime capturedAt;

  /// Null when the position did not come from a sensor.
  final double? accuracyMetres;

  bool get isFromDevice => source == LocationSource.device;

  /// Coimbatore district centre — what the app assumes before it is told
  /// anything better. Clearly marked as a guess so the UI can say so.
  static FarmLocation fallback() => FarmLocation(
        latitude: 11.0244,
        longitude: 77.1261,
        label: 'Sulur, Coimbatore',
        source: LocationSource.defaultGuess,
        capturedAt: DateTime.now(),
      );

  FarmLocation copyWith({String? label, LocationSource? source}) {
    return FarmLocation(
      latitude: latitude,
      longitude: longitude,
      label: label ?? this.label,
      source: source ?? this.source,
      capturedAt: capturedAt,
      accuracyMetres: accuracyMetres,
    );
  }

  /// Great-circle distance in km (haversine). Good enough to order markets by
  /// — the app never presents this as a driving distance, and says "12 km"
  /// meaning "roughly that far away".
  double distanceKmTo(double lat, double lng) {
    const double earthRadiusKm = 6371;
    double toRad(double degrees) => degrees * math.pi / 180;

    final double dLat = toRad(lat - latitude);
    final double dLng = toRad(lng - longitude);

    final double a = math.pow(math.sin(dLat / 2), 2) +
        math.cos(toRad(latitude)) *
            math.cos(toRad(lat)) *
            math.pow(math.sin(dLng / 2), 2);

    return 2 * earthRadiusKm * math.asin(math.min(1, math.sqrt(a)));
  }
}

/// What the app is allowed to do with location right now.
enum LocationAccess {
  /// Never asked.
  unknown,

  /// Asked and granted.
  granted,

  /// Asked and refused — recoverable, we can ask again.
  denied,

  /// Refused permanently; only the OS settings screen can undo it.
  deniedForever,

  /// Permission is fine but the device has location switched off.
  serviceOff,

  /// This platform cannot report a position at all.
  unsupported,
}
