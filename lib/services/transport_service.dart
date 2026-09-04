import 'package:farm_buddy/core/constants/app_config.dart';
import 'package:farm_buddy/models/transport.dart';
import 'package:farm_buddy/services/mock_data.dart';

class TransportService {
  const TransportService();

  Future<TransportRoute> route({
    String? destinationName,
    String? destinationSub,
    double? distanceKm,
  }) async {
    await Future<void>.delayed(AppConfig.shortLatency);
    if (destinationName == null) return MockData.transportRoute;

    final double km = distanceKm ?? MockData.transportRoute.distanceKm;
    return MockData.transportRoute.copyWith(
      destinationName: destinationName,
      destinationSub: destinationSub,
      distanceKm: km,
      // Roughly 3 minutes per km on district roads, plus loading time.
      durationMinutes: (km * 2.9).round() + 8,
      estimatedCost: (km * 180).roundToDouble(),
    );
  }

  /// Vehicles big enough first, then by price. Anything too small still shows
  /// (greyed out with a reason) so the farmer is never left wondering.
  Future<List<TransportOption>> options(double quantityKg) async {
    await Future<void>.delayed(AppConfig.fakeLatency);

    final List<TransportOption> list = List<TransportOption>.of(
      MockData.transportOptions,
    )..sort((TransportOption a, TransportOption b) {
        final bool aFits = a.fits(quantityKg);
        final bool bFits = b.fits(quantityKg);
        if (aFits != bFits) return aFits ? -1 : 1;
        if (a.isAvailable != b.isAvailable) return a.isAvailable ? -1 : 1;
        return a.price.compareTo(b.price);
      });
    return list;
  }

  Future<TransportOption> sharedOption() async {
    await Future<void>.delayed(AppConfig.shortLatency);
    return MockData.sharedTransport;
  }
}
