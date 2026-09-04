import 'package:farm_buddy/core/constants/app_config.dart';
import 'package:farm_buddy/models/crop.dart';
import 'package:farm_buddy/models/market.dart';
import 'package:farm_buddy/models/market_insight.dart';
import 'package:farm_buddy/services/mock_data.dart';

/// Ranks places to sell.
///
/// The ranking is deliberately explainable: net value first, nudged by demand,
/// penalised by distance and by not being able to take the whole load. Every
/// term maps to a line the farmer sees in "Why this is recommended".
class MarketService {
  const MarketService();

  Future<List<Market>> rankedMarketsFor(Crop crop, double quantityKg) async {
    await Future<void>.delayed(AppConfig.fakeLatency);

    final List<Market> ranked = List<Market>.of(MockData.markets)
      ..sort((Market a, Market b) =>
          b.score(quantityKg).compareTo(a.score(quantityKg)));
    return ranked;
  }

  /// Same ranking, no delay — used by screens that already have the data
  /// cached and only need the order.
  List<Market> rankSync(double quantityKg) {
    return List<Market>.of(MockData.markets)
      ..sort((Market a, Market b) =>
          b.score(quantityKg).compareTo(a.score(quantityKg)));
  }

  Future<Market> byId(String id) async {
    await Future<void>.delayed(AppConfig.shortLatency);
    return MockData.marketById(id);
  }

  Future<MarketInsight> todayInsight() async {
    await Future<void>.delayed(AppConfig.shortLatency);
    return MockData.todayInsight;
  }
}
