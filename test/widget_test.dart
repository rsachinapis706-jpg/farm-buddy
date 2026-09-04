import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:farm_buddy/core/theme/app_theme.dart';
import 'package:farm_buddy/models/market.dart';
import 'package:farm_buddy/services/mock_data.dart';
import 'package:farm_buddy/widgets/buttons/primary_button.dart';
import 'package:farm_buddy/widgets/cards/market_card.dart';
import 'package:farm_buddy/widgets/common/status_badge.dart';

Widget _host(Widget child) => MaterialApp(
      theme: AppTheme.light,
      home: Scaffold(
        body: SingleChildScrollView(
          child: Padding(padding: const EdgeInsets.all(16), child: child),
        ),
      ),
    );

void main() {
  testWidgets('PrimaryButton renders its label and fires onPressed',
      (WidgetTester tester) async {
    int taps = 0;
    await tester.pumpWidget(
      _host(
        PrimaryButton(
          label: 'Find Best Market',
          onPressed: () => taps++,
        ),
      ),
    );

    expect(find.text('Find Best Market'), findsOneWidget);
    await tester.tap(find.byType(PrimaryButton));
    await tester.pump();
    expect(taps, 1);
  });

  testWidgets('PrimaryButton is inert while loading',
      (WidgetTester tester) async {
    int taps = 0;
    await tester.pumpWidget(
      _host(
        PrimaryButton(
          label: 'Working',
          isLoading: true,
          onPressed: () => taps++,
        ),
      ),
    );

    await tester.tap(find.byType(PrimaryButton));
    await tester.pump();
    expect(taps, 0, reason: 'A loading button must not double-submit');
  });

  testWidgets('StatusBadge always shows an icon beside its label',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      _host(
        const StatusBadge(
          label: 'HIGH',
          tone: BadgeTone.success,
          icon: Icons.trending_up_rounded,
        ),
      ),
    );

    // Status must never be communicated by colour alone.
    expect(find.text('HIGH'), findsOneWidget);
    expect(find.byIcon(Icons.trending_up_rounded), findsOneWidget);
  });

  testWidgets('MarketCard hero shows price, distance and expected value',
      (WidgetTester tester) async {
    final Market market = MockData.marketById('uzhavar-singanallur');

    await tester.pumpWidget(
      _host(
        MarketCard(
          market: market,
          quantityKg: 500,
          rank: 1,
          isBest: true,
          rankLabel: 'Best Match',
          badgeLabel: 'BEST VALUE',
          demandLabel: 'HIGH',
          expectedValueLabel: 'Expected value',
          actionLabel: 'View Details',
          onTap: () {},
        ),
      ),
    );

    expect(find.text('Uzhavar Sandhai, Singanallur'), findsOneWidget);
    expect(find.text('₹32/kg'), findsOneWidget);
    expect(find.text('12 km'), findsOneWidget);
    expect(find.text('₹16,000'), findsOneWidget);
    expect(find.text('BEST VALUE'), findsOneWidget);
    expect(find.text('View Details'), findsOneWidget);
  });

  testWidgets('MarketCard compact variant stays a single tappable row',
      (WidgetTester tester) async {
    final Market market = MockData.marketById('srv-annur');
    int taps = 0;

    await tester.pumpWidget(
      _host(
        MarketCard(
          market: market,
          quantityKg: 500,
          rank: 2,
          rankLabel: 'Nearby Buyer',
          demandLabel: 'Medium',
          onTap: () => taps++,
        ),
      ),
    );

    expect(find.text('SRV Traders, Annur'), findsOneWidget);
    expect(find.text('₹30/kg'), findsOneWidget);
    await tester.tap(find.text('SRV Traders, Annur'));
    await tester.pump();
    expect(taps, 1);
  });

  testWidgets('layout survives a 1.4x system font scale',
      (WidgetTester tester) async {
    final Market market = MockData.marketById('uzhavar-singanallur');

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: MediaQuery(
          data: const MediaQueryData(textScaler: TextScaler.linear(1.4)),
          child: Scaffold(
            body: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: MarketCard(
                  market: market,
                  quantityKg: 500,
                  rank: 1,
                  isBest: true,
                  rankLabel: 'Best Match',
                  badgeLabel: 'BEST VALUE',
                  demandLabel: 'HIGH',
                  onTap: () {},
                ),
              ),
            ),
          ),
        ),
      ),
    );

    // No RenderFlex overflow exceptions were thrown while laying out.
    expect(tester.takeException(), isNull);
  });
}
