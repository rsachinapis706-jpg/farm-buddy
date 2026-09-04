import 'package:flutter/material.dart';

import 'package:farm_buddy/core/theme/app_colors.dart';
import 'package:farm_buddy/core/theme/app_spacing.dart';
import 'package:farm_buddy/core/theme/app_typography.dart';
import 'package:farm_buddy/core/utils/formatters.dart';
import 'package:farm_buddy/models/enums.dart';
import 'package:farm_buddy/models/market_insight.dart';
import 'package:farm_buddy/widgets/common/demo_data_chip.dart';
import 'package:farm_buddy/widgets/common/emoji_text.dart';
import 'package:farm_buddy/widgets/common/freshness_chip.dart';
import 'package:farm_buddy/widgets/common/price_trend_chart.dart';
import 'package:farm_buddy/widgets/common/status_badge.dart';

/// "Today's Market Insight" — the one number a farmer opens the app for.
class InsightCard extends StatelessWidget {
  const InsightCard({
    super.key,
    required this.insight,
    required this.onViewDetails,
    this.actionLabel,
    this.demandLabel,
    this.vsYesterdayLabel,
    this.cropDisplayName,
  });

  final MarketInsight insight;
  final VoidCallback onViewDetails;
  final String? actionLabel;
  final String? demandLabel;
  final String? vsYesterdayLabel;
  final String? cropDisplayName;

  @override
  Widget build(BuildContext context) {
    final bool up = insight.isUp;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadius.rXl,
        border: Border.all(color: AppColors.border),
        boxShadow: AppShadows.card,
      ),
      clipBehavior: Clip.antiAlias,
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          onTap: onViewDetails,
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                // ------------------------------------------- crop + price
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Container(
                      width: 44,
                      height: 44,
                      alignment: Alignment.center,
                      decoration: const BoxDecoration(
                        color: AppColors.surfaceAlt,
                        borderRadius: AppRadius.rMd,
                      ),
                      child: EmojiText(insight.cropEmoji, size: 22),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          Text(
                            cropDisplayName ?? insight.cropName,
                            style: AppText.titleLg,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            insight.marketName,
                            style: AppText.caption,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: AppSpacing.xs),
                    const DemoDataChip(),
                  ],
                ),

                const SizedBox(height: AppSpacing.sm),

                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: <Widget>[
                    Text(
                      Fmt.pricePerKg(insight.pricePerKg),
                      style: AppText.priceLg
                          .copyWith(color: AppColors.primaryDark),
                    ),
                    const SizedBox(width: AppSpacing.xs),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: StatusBadge(
                        label:
                            '${Fmt.signedPercent(insight.changePercent)} ${vsYesterdayLabel ?? ''}'
                                .trim(),
                        tone: up ? BadgeTone.success : BadgeTone.danger,
                        icon: up
                            ? Icons.arrow_upward_rounded
                            : Icons.arrow_downward_rounded,
                        dense: true,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: AppSpacing.sm),

                // ------------------------------------------- sparkline
                PriceTrendChart(
                  values: insight.priceHistory,
                  height: 74,
                  showDayLabels: false,
                ),

                const SizedBox(height: AppSpacing.sm),

                Wrap(
                  spacing: AppSpacing.xs,
                  runSpacing: AppSpacing.xs,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: <Widget>[
                    StatusBadge(
                      label: demandLabel ?? insight.demand.name,
                      tone: switch (insight.demand) {
                        DemandLevel.high => BadgeTone.success,
                        DemandLevel.medium => BadgeTone.warning,
                        DemandLevel.low => BadgeTone.neutral,
                      },
                      icon: insight.demand.icon,
                      dense: true,
                    ),
                    StatusBadge(
                      label: Fmt.km(insight.distanceKm),
                      tone: BadgeTone.neutral,
                      icon: Icons.near_me_rounded,
                      dense: true,
                    ),
                  ],
                ),

                const SizedBox(height: AppSpacing.sm),
                const Divider(height: 1),
                const SizedBox(height: AppSpacing.xs),

                Row(
                  children: <Widget>[
                    Expanded(
                      child: FreshnessChip(updatedAt: insight.updatedAt),
                    ),
                    const SizedBox(width: AppSpacing.xs),
                    Flexible(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          Flexible(
                            child: Text(
                              actionLabel ?? 'View Market Details',
                              style: AppText.bodySmStrong
                                  .copyWith(color: AppColors.primary),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const Icon(
                            Icons.arrow_forward_rounded,
                            size: 16,
                            color: AppColors.primary,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
