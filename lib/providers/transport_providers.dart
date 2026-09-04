import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:farm_buddy/models/market.dart';
import 'package:farm_buddy/models/transport.dart';
import 'package:farm_buddy/providers/crop_providers.dart';
import 'package:farm_buddy/providers/market_providers.dart';
import 'package:farm_buddy/services/transport_service.dart';

final transportServiceProvider =
    Provider<TransportService>((ref) => const TransportService());

/// The trip from the farm to whichever market the farmer picked.
final transportRouteProvider =
    FutureProvider.autoDispose<TransportRoute>((ref) async {
  final TransportService service = ref.watch(transportServiceProvider);
  final Market? market = ref.watch(selectedMarketProvider);
  return service.route(
    destinationName: market?.name,
    destinationSub: market?.area,
    distanceKm: market?.distanceKm,
  );
});

final transportOptionsProvider =
    FutureProvider.autoDispose<List<TransportOption>>((ref) async {
  final TransportService service = ref.watch(transportServiceProvider);
  final double quantity = ref.watch(activeQuantityProvider);
  return service.options(quantity);
});

final sharedTransportProvider =
    FutureProvider.autoDispose<TransportOption>((ref) async {
  return ref.watch(transportServiceProvider).sharedOption();
});

/// Which vehicle the farmer has booked, if any.
final bookedTransportIdProvider = StateProvider<String?>((ref) => null);
