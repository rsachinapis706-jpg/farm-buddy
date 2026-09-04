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
import 'package:farm_buddy/models/activity.dart';
import 'package:farm_buddy/models/crop.dart';
import 'package:farm_buddy/models/enums.dart';
import 'package:farm_buddy/models/market.dart';
import 'package:farm_buddy/providers/activity_providers.dart';
import 'package:farm_buddy/providers/app_providers.dart';
import 'package:farm_buddy/providers/crop_providers.dart';
import 'package:farm_buddy/providers/market_providers.dart';
import 'package:farm_buddy/widgets/buttons/primary_button.dart';
import 'package:farm_buddy/widgets/buttons/secondary_button.dart';
import 'package:farm_buddy/widgets/cards/stat_card.dart';
import 'package:farm_buddy/widgets/cards/why_card.dart';
import 'package:farm_buddy/widgets/common/app_header.dart';
import 'package:farm_buddy/widgets/common/demo_data_chip.dart';
import 'package:farm_buddy/widgets/common/freshness_chip.dart';
import 'package:farm_buddy/widgets/common/map_preview.dart';
import 'package:farm_buddy/widgets/common/price_trend_chart.dart';
import 'package:farm_buddy/widgets/common/status_badge.dart';
import 'package:farm_buddy/widgets/states/error_state.dart';
import 'package:farm_buddy/widgets/states/loading_state.dart';

/// Everything about one market, ending in a decision.
///
/// The money breakdown is the heart of it: sale value, minus travel, equals
/// what actually reaches the farmer's pocket. Most price apps stop at the
/// first number.
class MarketDetailsScreen extends ConsumerWidget {
  const MarketDetailsScreen({super.key, required this.marketId});

  final String marketId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppStrings s = ref.watch(stringsProvider);
    final AsyncValue<Market> market = ref.watch(marketByIdProvider(marketId));
    final double quantity = ref.watch(activeQuantityProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppHeader(
        title: s('marketDetails.title'),
        onBack: () =>
            context.canPop() ? context.pop() : context.go(AppRoutes.markets),
        actions: const <Widget>[
          Padding(
            padding: EdgeInsets.only(right: AppSpacing.xs),
            child: Center(child: DemoDataChip()),
          ),
        ],
      ),
      body: SafeArea(
        top: false,
        child: market.when(
          loading: () => Center(child: LoadingState(message: s('state.loading'))),
          error: (Object error, StackTrace stack) => Center(
            child: ErrorState(
              title: s('state.errorTitle'),
              message: s('state.errorBody'),
              retryLabel: s('common.retry'),
              onRetry: () => ref.invalidate(marketByIdProvider(marketId)),
            ),
          ),
          data: (Market data) =>
              _Details(strings: s, market: data, quantityKg: quantity),
        ),
      ),
    );
  }
}

class _Details extends ConsumerWidget {
  const _Details({
    required this.strings,
    required this.market,
    required this.quantityKg,
  });

  final AppStrings strings;
  final Market market;
  final double quantityKg;

  Future<void> _confirmSell(BuildContext context, WidgetRef ref) async {
    final AppStrings s = strings;

    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: const RoundedRectangleBorder(borderRadius: AppRadius.rLg),
        title: Text(
          s.withArgs('marketDetails.confirmTitle', <String, String>{
            'market': market.name,
          }),
          style: AppText.h3,
        ),
        content: Text(
          s.withArgs('marketDetails.confirmBody', <String, String>{
            'qty': Fmt.kilos(quantityKg),
          }),
          style: AppText.bodySm,
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(s('common.cancel')),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(s('marketDetails.confirmCta')),
          ),
        ],
      ),
    );

    if (confirmed != true || !context.mounted) return;

    // Record it. Without this the button is a message that gets forgotten —
    // with it, Profile → My Sales can show what actually happened.
    final Crop crop = ref.read(activeCropProvider);
    ref.read(salesProvider.notifier).add(
          SaleRecord(
            id: 'sale-${DateTime.now().microsecondsSinceEpoch}',
            marketId: market.id,
            marketName: market.name,
            cropName: crop.name,
            cropEmoji: crop.emoji,
            quantityKg: quantityKg,
            pricePerKg: market.pricePerKg,
            travelCost: market.travelCostEstimate,
            soldAt: DateTime.now(),
          ),
        );

    ref.read(selectedMarketProvider.notifier).state = market;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(s('marketDetails.reserved'))),
    );
    context.go(AppRoutes.transport);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppStrings s = strings;

    final double gross = market.expectedValue(quantityKg);
    final double net = market.netValue(quantityKg);
    final bool saved =
        ref.watch(savedMarketIdsProvider).contains(market.id);

    return ListView(
      padding: const EdgeInsets.only(bottom: AppSpacing.xxl),
      children: <Widget>[
        ResponsiveCenter(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              // ------------------------------------------------ header
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: market.type.color.withValues(alpha: 0.10),
                      borderRadius: AppRadius.rMd,
                    ),
                    child: Icon(
                      market.type.icon,
                      color: market.type.color,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Text(
                          market.name,
                          style: AppText.h2,
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${s(market.type.labelKey)} · ${market.area}',
                          style: AppText.caption,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    tooltip: s('profile.savedMarkets'),
                    onPressed: () {
                      final Set<String> current =
                          ref.read(savedMarketIdsProvider);
                      final Set<String> next = <String>{...current};
                      if (saved) {
                        next.remove(market.id);
                      } else {
                        next.add(market.id);
                      }
                      ref.read(savedMarketIdsProvider.notifier).state = next;
                    },
                    icon: Icon(
                      saved ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
                      color: saved ? AppColors.primary : AppColors.textSecondary,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: AppSpacing.sm),
              Wrap(
                spacing: AppSpacing.xs,
                runSpacing: AppSpacing.xs,
                children: <Widget>[
                  StatusBadge(
                    label: '${s('marketDetails.open')} ${market.openHours}',
                    tone: BadgeTone.neutral,
                    icon: Icons.schedule_rounded,
                    dense: true,
                  ),
                  StatusBadge(
                    label: s(market.demand.labelKey),
                    tone: switch (market.demand) {
                      DemandLevel.high => BadgeTone.success,
                      DemandLevel.medium => BadgeTone.warning,
                      DemandLevel.low => BadgeTone.neutral,
                    },
                    icon: market.demand.icon,
                    dense: true,
                  ),
                ],
              ),

              const SizedBox(height: AppSpacing.md),
              MapPreview(
                height: 160,
                showRoute: true,
                centerLabel: market.name,
                markers: <MapMarker>[
                  MapMarker(
                    x: market.mapX,
                    y: market.mapY,
                    label: market.name.split(',').first,
                    isPrimary: true,
                  ),
                ],
              ),

              const SizedBox(height: AppSpacing.xl),

              // ------------------------------------------------- price
              Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: AppRadius.rLg,
                  border: Border.all(color: AppColors.border),
                  boxShadow: AppShadows.card,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: <Widget>[
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              Text(
                                s('marketDetails.currentPrice'),
                                style: AppText.caption,
                              ),
                              Text(
                                Fmt.pricePerKg(market.pricePerKg),
                                style: AppText.priceLg
                                    .copyWith(color: AppColors.primaryDark),
                              ),
                            ],
                          ),
                        ),
                        StatusBadge(
                          label: Fmt.signedPercent(market.priceChangePercent),
                          tone: market.isPriceUp
                              ? BadgeTone.success
                              : BadgeTone.danger,
                          icon: market.isPriceUp
                              ? Icons.arrow_upward_rounded
                              : Icons.arrow_downward_rounded,
                          dense: true,
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Text(s('marketDetails.trend'), style: AppText.bodySmStrong),
                    const SizedBox(height: AppSpacing.xs),
                    PriceTrendChart(values: market.priceHistory, height: 110),
                    const SizedBox(height: AppSpacing.xs),
                    FreshnessChip(updatedAt: market.updatedAt),
                  ],
                ),
              ),

              const SizedBox(height: AppSpacing.md),

              // -------------------------------------------- fast facts
              Row(
                children: <Widget>[
                  Expanded(
                    child: StatCard(
                      label: s('marketDetails.arrivals'),
                      value: Fmt.kilos(market.todaysArrivalsKg),
                      icon: Icons.inbox_rounded,
                      compact: true,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  Expanded(
                    child: StatCard(
                      label: s('marketDetails.required'),
                      value: Fmt.kilos(market.requiredQuantityKg),
                      icon: Icons.shopping_basket_outlined,
                      compact: true,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  Expanded(
                    child: StatCard(
                      label: s('marketDetails.distance'),
                      value: Fmt.km(market.distanceKm),
                      icon: Icons.near_me_rounded,
                      compact: true,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: AppSpacing.xl),

              // ---------------------------------------- money breakdown
              Text(s('marketDetails.breakdown'), style: AppText.h3),
              const SizedBox(height: AppSpacing.sm),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.xs,
                ),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: AppRadius.rLg,
                  border: Border.all(color: AppColors.border),
                ),
                child: Column(
                  children: <Widget>[
                    StatRow(
                      label: s('marketDetails.yourQuantity'),
                      value: Fmt.kilos(quantityKg),
                      icon: Icons.scale_outlined,
                    ),
                    const Divider(height: 1),
                    StatRow(
                      label:
                          '${s('marketDetails.gross')} (${Fmt.pricePerKg(market.pricePerKg)})',
                      value: Fmt.rupees(gross),
                      icon: Icons.sell_outlined,
                    ),
                    const Divider(height: 1),
                    StatRow(
                      label: s('marketDetails.travelCost'),
                      value: Fmt.rupees(market.travelCostEstimate),
                      icon: Icons.local_shipping_outlined,
                      negative: true,
                    ),
                    const Divider(height: 1),
                    StatRow(
                      label: s('marketDetails.netIncome'),
                      value: Fmt.rupees(net),
                      icon: Icons.account_balance_wallet_outlined,
                      emphasise: true,
                      valueColor: AppColors.primaryDark,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: AppSpacing.md),
              WhyCard(
                title: s('market.why.title'),
                reasons: <String>[
                  for (final String key in market.reasonKeys) s(key),
                  if (market.acceptsQuantity(quantityKg))
                    s('market.acceptsAll')
                  else
                    s('market.partialQuantity'),
                ],
              ),

              const SizedBox(height: AppSpacing.xxl),

              PrimaryButton(
                label: s('marketDetails.sellHere'),
                icon: Icons.check_circle_outline_rounded,
                onPressed: () => _confirmSell(context, ref),
              ),
              const SizedBox(height: AppSpacing.sm),
              SecondaryButton(
                label: s('marketDetails.navigate'),
                icon: Icons.directions_rounded,
                onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      '${s('marketDetails.navigate')} · ${market.name}',
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
