import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:farm_buddy/models/activity.dart';
import 'package:farm_buddy/models/crop.dart';
import 'package:farm_buddy/models/enums.dart';
import 'package:farm_buddy/models/market.dart';
import 'package:farm_buddy/providers/activity_providers.dart';
import 'package:farm_buddy/providers/crop_providers.dart';
import 'package:farm_buddy/providers/market_providers.dart';
import 'package:farm_buddy/services/mock_data.dart';

/// Covers the parts a farmer can change at runtime — the controls that make
/// the ranking checkable rather than something to take on trust.
void main() {
  ProviderContainer makeContainer() {
    final ProviderContainer container = ProviderContainer();
    addTearDown(container.dispose);
    return container;
  }

  /// These providers are `autoDispose`, so a bare `read` tears them down again
  /// before the next line runs and the value comes back null. Holding a
  /// subscription for the length of the test is what a live screen does.
  Future<List<Market>> sortedWith(
    ProviderContainer container,
    MarketSort sort,
  ) async {
    container.read(marketSortProvider.notifier).state = sort;

    final ProviderSubscription<AsyncValue<List<Market>>> sub =
        container.listen<AsyncValue<List<Market>>>(
      sortedMarketsProvider,
      (AsyncValue<List<Market>>? previous, AsyncValue<List<Market>> next) {},
      fireImmediately: true,
    );
    addTearDown(sub.close);

    await container.read(rankedMarketsProvider.future);
    return container.read(sortedMarketsProvider).value!;
  }

  group('market sort', () {
    test('best value keeps the app ranking', () async {
      final ProviderContainer c = makeContainer();
      final List<Market> list = await sortedWith(c, MarketSort.bestValue);
      expect(list.first.id, 'uzhavar-singanallur');
    });

    test('nearest really orders by distance', () async {
      final ProviderContainer c = makeContainer();
      final List<Market> list = await sortedWith(c, MarketSort.distance);

      expect(list.first.id, 'srv-annur', reason: 'SRV Traders is 5 km away');
      for (int i = 0; i < list.length - 1; i++) {
        expect(list[i].distanceKm, lessThanOrEqualTo(list[i + 1].distanceKm));
      }
    });

    test('highest price really orders by price', () async {
      final ProviderContainer c = makeContainer();
      final List<Market> list = await sortedWith(c, MarketSort.price);

      for (int i = 0; i < list.length - 1; i++) {
        expect(list[i].pricePerKg, greaterThanOrEqualTo(list[i + 1].pricePerKg));
      }
    });

    test('sorting by distance gives a different answer to the recommendation',
        () async {
      // If these ever matched, the sort control would be decorative.
      final List<Market> byValue =
          await sortedWith(makeContainer(), MarketSort.bestValue);
      final List<Market> byDistance =
          await sortedWith(makeContainer(), MarketSort.distance);
      expect(byValue.first.id, isNot(byDistance.first.id));
    });
  });

  group('changing the listing re-ranks', () {
    test('quantity change flows through to the active quantity', () async {
      final ProviderContainer c = makeContainer();
      expect(c.read(activeQuantityProvider), 500);

      c.read(currentListingProvider.notifier).update(
            fallbackCrop: MockData.crops.first,
            quantityKg: 2000,
          );
      expect(c.read(activeQuantityProvider), 2000);
    });

    test('crop change flows through to the active crop', () async {
      final ProviderContainer c = makeContainer();
      final Crop banana = MockData.cropById('banana');

      c.read(currentListingProvider.notifier)
          .update(fallbackCrop: banana, crop: banana);
      expect(c.read(activeCropProvider).id, 'banana');
    });

    test('a big load stops fitting the smallest market', () {
      final Market fpo = MockData.marketById('kongu-fpo-sulur');
      expect(fpo.acceptsQuantity(500), isTrue);
      expect(fpo.acceptsQuantity(2000), isFalse);
    });
  });

  group('records', () {
    test('a confirmed sale is remembered with its take-home value', () {
      final ProviderContainer c = makeContainer();
      final Market market = MockData.marketById('uzhavar-singanallur');

      expect(c.read(salesProvider), isEmpty);

      c.read(salesProvider.notifier).add(
            SaleRecord(
              id: 's1',
              marketId: market.id,
              marketName: market.name,
              cropName: 'Tomato',
              cropEmoji: '🍅',
              quantityKg: 500,
              pricePerKg: market.pricePerKg,
              travelCost: market.travelCostEstimate,
              soldAt: DateTime(2026, 3, 1),
            ),
          );

      final List<SaleRecord> sales = c.read(salesProvider);
      expect(sales, hasLength(1));
      expect(sales.first.gross, 16000);
      expect(sales.first.net, 16000 - market.travelCostEstimate);
    });

    test('a booking is remembered', () {
      final ProviderContainer c = makeContainer();
      expect(c.read(bookingsProvider), isEmpty);

      c.read(bookingsProvider.notifier).add(
            BookingRecord(
              id: 'b1',
              vehicleName: 'Tata Ace',
              vehicleEmoji: '🚚',
              destinationName: 'Uzhavar Sandhai',
              price: 2200,
              quantityKg: 500,
              isShared: false,
              bookedAt: DateTime(2026, 3, 1),
            ),
          );

      expect(c.read(bookingsProvider).first.vehicleName, 'Tata Ace');
    });
  });
}
