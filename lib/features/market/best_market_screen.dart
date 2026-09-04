import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:farm_buddy/core/l10n/app_strings.dart';
import 'package:farm_buddy/core/router/app_router.dart';
import 'package:farm_buddy/core/theme/app_colors.dart';
import 'package:farm_buddy/core/theme/app_spacing.dart';
import 'package:farm_buddy/core/theme/app_typography.dart';
import 'package:farm_buddy/core/utils/formatters.dart';
import 'package:farm_buddy/core/utils/responsive.dart';
import 'package:farm_buddy/features/market/widgets/market_controls.dart';
import 'package:farm_buddy/models/crop.dart';
import 'package:farm_buddy/models/enums.dart';
import 'package:farm_buddy/models/market.dart';
import 'package:farm_buddy/providers/activity_providers.dart';
import 'package:farm_buddy/providers/app_providers.dart';
import 'package:farm_buddy/providers/crop_providers.dart';
import 'package:farm_buddy/providers/market_providers.dart';
import 'package:farm_buddy/widgets/cards/market_card.dart';
import 'package:farm_buddy/widgets/cards/why_card.dart';
import 'package:farm_buddy/widgets/common/app_header.dart';
import 'package:farm_buddy/widgets/common/demo_data_chip.dart';
import 'package:farm_buddy/widgets/common/freshness_chip.dart';
import 'package:farm_buddy/widgets/common/fb_map.dart';
import 'package:farm_buddy/widgets/common/offline_banner.dart';
import 'package:farm_buddy/widgets/states/empty_state.dart';
import 'package:farm_buddy/widgets/states/error_state.dart';
import 'package:farm_buddy/widgets/states/loading_state.dart';

/// Where to sell, ranked, with the reasoning shown — and adjustable.
///
/// The visual hierarchy *is* the recommendation: one card is bigger, greener
/// and carries the money. The controls above it exist so that hierarchy can be
/// challenged: change the crop, change the quantity, or re-order by raw price
/// or raw distance, and watch the answer move.
class BestMarketScreen extends ConsumerWidget {
  const BestMarketScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppStrings s = ref.watch(stringsProvider);
    final Crop crop = ref.watch(activeCropProvider);
    final double quantity = ref.watch(activeQuantityProvider);
    final String place = ref.watch(locationProvider);
    final AsyncValue<List<Market>> markets = ref.watch(sortedMarketsProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppHeader(
        title: s('market.title'),
        subtitle: s.withArgs('market.subtitle', <String, String>{
          'qty': Fmt.kilos(quantity),
          'crop': s(crop.nameKey),
          'place': place,
        }),
        showLogo: true,
      ),
      body: SafeArea(
        top: false,
        child: RefreshIndicator(
          color: AppColors.primary,
          onRefresh: () async {
            ref.read(lastSyncedProvider.notifier).state = DateTime.now();
            ref.invalidate(rankedMarketsProvider);
            await ref.read(rankedMarketsProvider.future);
          },
          child: ListView(
            padding: const EdgeInsets.only(
              bottom: AppSpacing.bottomNavClearance,
            ),
            children: <Widget>[
              const ResponsiveCenter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    OfflineBanner(),
                    MarketControls(),
                    SizedBox(height: AppSpacing.md),
                  ],
                ),
              ),
              markets.when(
                loading: () => Padding(
                  padding: const EdgeInsets.only(top: AppSpacing.xxl),
                  child: LoadingState(message: s('market.loading')),
                ),
                error: (Object error, StackTrace stack) => Padding(
                  padding: const EdgeInsets.only(top: AppSpacing.md),
                  child: ErrorState(
                    title: s('market.error.title'),
                    message: s('market.error.body'),
                    retryLabel: s('common.retry'),
                    onRetry: () => ref.invalidate(rankedMarketsProvider),
                  ),
                ),
                data: (List<Market> list) {
                  if (list.isEmpty) {
                    return Padding(
                      padding: const EdgeInsets.only(top: AppSpacing.md),
                      child: EmptyState(
                        icon: Icons.storefront_outlined,
                        title: s('market.empty.title'),
                        message: s('market.empty.body'),
                        actionLabel: s('market.empty.cta'),
                        onAction: () => context.push(AppRoutes.addCrop),
                      ),
                    );
                  }
                  return _MarketList(
                    strings: s,
                    markets: list,
                    quantityKg: quantity,
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MarketList extends ConsumerWidget {
  const _MarketList({
    required this.strings,
    required this.markets,
    required this.quantityKg,
  });

  final AppStrings strings;
  final List<Market> markets;
  final double quantityKg;

  String? _rankLabel(AppStrings s, int rank) => switch (rank) {
        1 => s('market.bestMatch'),
        2 => s('market.nearbyBuyer'),
        3 => s('market.thirdOption'),
        _ => null,
      };

  void _open(BuildContext context, WidgetRef ref, Market market) {
    ref.read(selectedMarketProvider.notifier).state = market;
    context.push('${AppRoutes.marketDetails}/${market.id}');
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppStrings s = strings;
    final MarketSort sort = ref.watch(marketSortProvider);
    final String? focusedId = ref.watch(focusedMarketIdProvider);

    // The hero treatment is the app's *recommendation*. When the farmer sorts
    // by raw price or raw distance they are no longer looking at a
    // recommendation, so nothing gets a medal — that would be a lie.
    final bool isRecommendation = sort == MarketSort.bestValue;
    final Market best = markets.first;

    final List<FbMapMarker> pins = <FbMapMarker>[
      for (int i = 0; i < markets.length && i < 4; i++)
        FbMapMarker(
          id: markets[i].id,
          latitude: markets[i].latitude,
          longitude: markets[i].longitude,
          x: markets[i].mapX,
          y: markets[i].mapY,
          label: markets[i].name.split(',').first,
          rank: i + 1,
          isPrimary: focusedId == null
              ? (isRecommendation && i == 0)
              : focusedId == markets[i].id,
        ),
    ];

    return ResponsiveCenter(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          FbMap(
            height: 190,
            markers: pins,
            showRoute: true,
            centerLabel: best.name,
            onMarkerTap: (int index) {
              if (index >= markets.length) return;
              ref.read(focusedMarketIdProvider.notifier).state =
                  markets[index].id;
              _open(context, ref, markets[index]);
            },
          ),

          const SizedBox(height: AppSpacing.xs),
          Row(
            children: <Widget>[
              Expanded(child: FreshnessChip(updatedAt: best.updatedAt)),
              const SizedBox(width: AppSpacing.xs),
              const DemoDataChip(),
            ],
          ),

          const SizedBox(height: AppSpacing.sm),
          Text(
            s.withArgs('market.showing', <String, String>{
              'n': '${markets.length}',
            }),
            style: AppText.caption,
          ),
          const SizedBox(height: AppSpacing.sm),

          if (isRecommendation) ...<Widget>[
            MarketCard(
              market: best,
              quantityKg: quantityKg,
              rank: 1,
              isBest: true,
              rankLabel: _rankLabel(s, 1),
              badgeLabel: s('market.bestValue'),
              demandLabel: s(best.demand.labelKey),
              typeLabel: s(best.type.labelKey),
              expectedValueLabel: s('market.expectedValue'),
              actionLabel: s('market.viewDetails'),
              needsLabel: s.withArgs('market.needs', <String, String>{
                'qty': Fmt.kilos(best.requiredQuantityKg),
              }),
              onTap: () => _open(context, ref, best),
            ),
            WhyCard(
              title: s('market.why.title'),
              reasons: <String>[
                for (final String key in best.reasonKeys) s(key),
                if (best.acceptsQuantity(quantityKg))
                  s('market.acceptsAll')
                else
                  s('market.partialQuantity'),
              ],
            ),
            const SizedBox(height: AppSpacing.xl),
            Text(s('market.moreOptions'), style: AppText.h3),
            const SizedBox(height: AppSpacing.sm),
          ],

          for (int i = isRecommendation ? 1 : 0; i < markets.length; i++)
            MarketCard(
              market: markets[i],
              quantityKg: quantityKg,
              rank: i + 1,
              rankLabel: isRecommendation ? _rankLabel(s, i + 1) : null,
              demandLabel: s(markets[i].demand.labelKey),
              onTap: () => _open(context, ref, markets[i]),
            ),
        ],
      ),
    );
  }
}
