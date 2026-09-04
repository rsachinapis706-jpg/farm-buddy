import 'package:flutter_test/flutter_test.dart';

import 'package:farm_buddy/models/enums.dart';
import 'package:farm_buddy/models/market.dart';
import 'package:farm_buddy/services/market_service.dart';
import 'package:farm_buddy/services/mock_data.dart';

void main() {
  const MarketService service = MarketService();

  group('market ranking', () {
    test('ranks the best net-value market first for 500 kg', () {
      final List<Market> ranked = service.rankSync(500);

      // Uzhavar Sandhai wins: best price, high demand, close by, and it can
      // take the whole load.
      expect(ranked.first.id, 'uzhavar-singanallur');
      expect(ranked[1].id, 'srv-annur');
      expect(ranked[2].id, 'mettupalayam-regulated');
    });

    test('ranking is by take-home value, not headline price', () {
      final List<Market> ranked = service.rankSync(500);
      final Market first = ranked.first;
      final Market second = ranked[1];

      expect(
        first.netValue(500),
        greaterThan(second.netValue(500)),
        reason: 'A higher sticker price with a long trip must not win',
      );
    });

    test('a market that cannot take the whole load is penalised', () {
      // Kongu FPO wants only 600 kg.
      final Market fpo = MockData.marketById('kongu-fpo-sulur');
      expect(fpo.acceptsQuantity(500), isTrue);
      expect(fpo.acceptsQuantity(2000), isFalse);

      final double scoreWithinCapacity = fpo.score(500);
      expect(scoreWithinCapacity, greaterThan(0));
    });

    test('every market carries at least one plain-language reason', () {
      for (final Market market in MockData.markets) {
        expect(market.reasonKeys, isNotEmpty,
            reason: '${market.name} has no "why" to show the farmer');
      }
    });

    test('price change is computed against yesterday', () {
      final Market uzhavar = MockData.marketById('uzhavar-singanallur');
      expect(uzhavar.isPriceUp, isTrue);
      expect(uzhavar.priceChangePercent, greaterThan(0));

      final Market fpo = MockData.marketById('kongu-fpo-sulur');
      expect(fpo.isPriceUp, isFalse);
    });

    test('net value subtracts the trip', () {
      final Market uzhavar = MockData.marketById('uzhavar-singanallur');
      expect(uzhavar.expectedValue(500), 16000);
      expect(uzhavar.netValue(500), 16000 - uzhavar.travelCostEstimate);
    });
  });

  group('demo data integrity', () {
    test('every market has a full 7-day price history', () {
      for (final Market market in MockData.markets) {
        expect(market.priceHistory.length, 7, reason: market.name);
      }
    });

    test('map positions stay inside the drawn map box', () {
      for (final Market market in MockData.markets) {
        expect(market.mapX, inInclusiveRange(0.0, 1.0), reason: market.name);
        expect(market.mapY, inInclusiveRange(0.0, 1.0), reason: market.name);
      }
    });

    test('the group sale really does beat selling alone', () {
      expect(
        MockData.groupSale.betterPricePerKg,
        greaterThan(MockData.groupSale.soloPricePerKg),
      );
      expect(MockData.groupSale.extraEarning, greaterThan(0));
    });

    test('shared transport actually saves money', () {
      expect(MockData.sharedTransport.isShared, isTrue);
      expect(MockData.sharedTransport.savingAmount, greaterThan(0));
    });

    test('demand levels all render with an icon, not colour alone', () {
      for (final DemandLevel level in DemandLevel.values) {
        expect(level.labelKey.isNotEmpty, isTrue);
        expect(level.icon, isNotNull);
      }
    });
  });
}
