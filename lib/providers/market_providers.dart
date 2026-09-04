import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:farm_buddy/models/crop.dart';
import 'package:farm_buddy/models/enums.dart';
import 'package:farm_buddy/models/market.dart';
import 'package:farm_buddy/models/market_insight.dart';
import 'package:farm_buddy/providers/activity_providers.dart';
import 'package:farm_buddy/providers/crop_providers.dart';
import 'package:farm_buddy/services/market_service.dart';

final marketServiceProvider =
    Provider<MarketService>((ref) => const MarketService());

/// Markets ranked for whatever the farmer is currently selling.
final rankedMarketsProvider =
    FutureProvider.autoDispose<List<Market>>((ref) async {
  final MarketService service = ref.watch(marketServiceProvider);
  final Crop crop = ref.watch(activeCropProvider);
  final double quantity = ref.watch(activeQuantityProvider);
  return service.rankedMarketsFor(crop, quantity);
});

/// The ranked list, re-ordered by whatever the farmer picked in the sort
/// control. `bestValue` keeps the app's own ranking; the other two let a
/// sceptic check the recommendation against the raw numbers.
final sortedMarketsProvider =
    Provider.autoDispose<AsyncValue<List<Market>>>((ref) {
  final MarketSort sort = ref.watch(marketSortProvider);
  return ref.watch(rankedMarketsProvider).whenData((List<Market> list) {
    final List<Market> ordered = List<Market>.of(list);
    switch (sort) {
      case MarketSort.bestValue:
        break; // rankedMarketsProvider already ordered by score
      case MarketSort.price:
        ordered.sort((Market a, Market b) =>
            b.pricePerKg.compareTo(a.pricePerKg));
      case MarketSort.distance:
        ordered.sort((Market a, Market b) =>
            a.distanceKm.compareTo(b.distanceKm));
    }
    return ordered;
  });
});

final marketByIdProvider =
    FutureProvider.autoDispose.family<Market, String>((ref, String id) async {
  return ref.watch(marketServiceProvider).byId(id);
});

final todayInsightProvider = FutureProvider<MarketInsight>((ref) async {
  return ref.watch(marketServiceProvider).todayInsight();
});

/// The market the farmer chose to sell at. Transport reads this to know where
/// the produce is going.
final selectedMarketProvider = StateProvider<Market?>((ref) => null);

/// Markets the farmer saved for later, shown in Profile.
final savedMarketIdsProvider = StateProvider<Set<String>>((ref) => <String>{});
