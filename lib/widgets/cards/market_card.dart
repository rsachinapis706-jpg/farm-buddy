import 'package:flutter/material.dart';

import 'package:farm_buddy/core/theme/app_colors.dart';
import 'package:farm_buddy/core/theme/app_spacing.dart';
import 'package:farm_buddy/core/theme/app_typography.dart';
import 'package:farm_buddy/core/utils/formatters.dart';
import 'package:farm_buddy/models/enums.dart';
import 'package:farm_buddy/models/market.dart';
import 'package:farm_buddy/widgets/common/status_badge.dart';

/// A place to sell, ranked.
///
/// Rank 1 gets the full treatment — gold medal, BEST VALUE badge, the money
/// spelled out and its own filled button. Ranks 2 and 3 collapse to a compact
/// row. That difference is the whole point: the app has an opinion, and the
/// visual weight says so before a single word is read.
class MarketCard extends StatelessWidget {
  const MarketCard({
    super.key,
    required this.market,
    required this.quantityKg,
    required this.onTap,
    this.rank,
    this.isBest = false,
    this.rankLabel,
    this.demandLabel,
    this.badgeLabel,
    this.expectedValueLabel,
    this.actionLabel,
    this.needsLabel,
    this.typeLabel,
  });

  final Market market;
  final double quantityKg;
  final VoidCallback onTap;
  final int? rank;
  final bool isBest;

  /// "Best Match" / "Nearby Buyer" / "Also worth checking"
  final String? rankLabel;
  final String? demandLabel;

  /// "BEST VALUE"
  final String? badgeLabel;
  final String? expectedValueLabel;
  final String? actionLabel;
  final String? needsLabel;
  final String? typeLabel;

  /// Rank is drawn, not written with a medal emoji. Emoji medals render
  /// differently on every platform (and not at all in some web font stacks),
  /// and a number is legible at 16px where a tiny gold disc is not. Colour
  /// carries the podium, the digit carries the meaning.
  static Color _medalColor(int? rank) => switch (rank) {
        1 => AppColors.gold,
        2 => AppColors.silver,
        3 => AppColors.bronze,
        _ => AppColors.textMuted,
      };

  static Color _medalSoft(int? rank) => switch (rank) {
        1 => AppColors.goldSoft,
        2 => AppColors.silverSoft,
        3 => AppColors.bronzeSoft,
        _ => AppColors.neutralSoft,
      };

  BadgeTone get _demandTone => switch (market.demand) {
        DemandLevel.high => BadgeTone.success,
        DemandLevel.medium => BadgeTone.warning,
        DemandLevel.low => BadgeTone.neutral,
      };

  @override
  Widget build(BuildContext context) {
    return isBest ? _buildHero(context) : _buildCompact(context);
  }

  // ------------------------------------------------------------- rank 1
  Widget _buildHero(BuildContext context) {
    final int shownRank = rank ?? 1;

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadius.rXl,
        border: Border.all(color: AppColors.primary, width: 2),
        boxShadow: AppShadows.raised,
      ),
      clipBehavior: Clip.antiAlias,
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          onTap: onTap,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              // ---------------------------------------------- rank strip
              Container(
                width: double.infinity,
                color: AppColors.primarySoft,
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.xs,
                ),
                child: Row(
                  children: <Widget>[
                    _RankBadge(rank: shownRank, size: 22),
                    const SizedBox(width: AppSpacing.xs),
                    Expanded(
                      child: Text(
                        rankLabel ?? 'Best Match',
                        style: AppText.label
                            .copyWith(color: AppColors.primaryDark),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (badgeLabel != null)
                      StatusBadge(
                        label: badgeLabel!,
                        tone: BadgeTone.gold,
                        icon: Icons.workspace_premium_rounded,
                        dense: true,
                      ),
                  ],
                ),
              ),

              Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    // -------------------------------------------- name
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Container(
                          width: 42,
                          height: 42,
                          decoration: BoxDecoration(
                            color: market.type.color.withValues(alpha: 0.10),
                            borderRadius: AppRadius.rMd,
                          ),
                          child: Icon(
                            market.type.icon,
                            size: 21,
                            color: market.type.color,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text(
                                market.name,
                                style: AppText.titleLg,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 2),
                              Text(
                                typeLabel == null
                                    ? market.area
                                    : '${typeLabel!} · ${market.area}',
                                style: AppText.caption,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: AppSpacing.md),

                    // -------------------------------------- price + facts
                    Wrap(
                      spacing: AppSpacing.md,
                      runSpacing: AppSpacing.xs,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: <Widget>[
                        Text(
                          Fmt.pricePerKg(market.pricePerKg),
                          style: AppText.priceLg
                              .copyWith(color: AppColors.primaryDark),
                        ),
                        _Fact(
                          icon: Icons.near_me_rounded,
                          text: Fmt.km(market.distanceKm),
                        ),
                        StatusBadge(
                          label: demandLabel ?? market.demand.name,
                          tone: _demandTone,
                          icon: market.demand.icon,
                          dense: true,
                        ),
                      ],
                    ),

                    const SizedBox(height: AppSpacing.sm),
                    if (needsLabel != null)
                      Row(
                        children: <Widget>[
                          const Icon(
                            Icons.inventory_2_outlined,
                            size: 15,
                            color: AppColors.textMuted,
                          ),
                          const SizedBox(width: 5),
                          Expanded(
                            child: Text(
                              needsLabel!,
                              style: AppText.caption,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),

                    const SizedBox(height: AppSpacing.md),

                    // ------------------------------------ expected value
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.md,
                        vertical: AppSpacing.sm,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primarySofter,
                        borderRadius: AppRadius.rMd,
                        border: Border.all(color: AppColors.primarySoft),
                      ),
                      child: Row(
                        children: <Widget>[
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                Text(
                                  expectedValueLabel ?? 'Expected value',
                                  style: AppText.caption,
                                  maxLines: 2,
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  Fmt.rupees(market.expectedValue(quantityKg)),
                                  style: AppText.priceMd
                                      .copyWith(color: AppColors.primaryDark),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: AppSpacing.xs),
                          Text(
                            Fmt.kilos(quantityKg),
                            style: AppText.bodySmStrong
                                .copyWith(color: AppColors.textSecondary),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: AppSpacing.md),
                    SizedBox(
                      width: double.infinity,
                      height: AppSpacing.ctaHeight,
                      child: FilledButton(
                        onPressed: onTap,
                        child: Text(
                          actionLabel ?? 'View Details',
                          style: AppText.button.copyWith(color: Colors.white),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ----------------------------------------------------------- rank 2/3+
  Widget _buildCompact(BuildContext context) {
    final int shownRank = rank ?? 0;

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadius.rLg,
        border: Border.all(color: AppColors.border),
        boxShadow: AppShadows.card,
      ),
      clipBehavior: Clip.antiAlias,
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.sm),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Container(
                  width: 42,
                  height: 42,
                  alignment: Alignment.center,
                  decoration: const BoxDecoration(
                    color: AppColors.surfaceAlt,
                    borderRadius: AppRadius.rMd,
                  ),
                  child: _RankBadge(rank: shownRank, size: 26),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      if (rankLabel != null)
                        Text(
                          rankLabel!,
                          style: AppText.caption.copyWith(
                            color: AppColors.textMuted,
                            fontWeight: FontWeight.w700,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      Text(
                        market.name,
                        style: AppText.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Wrap(
                        spacing: AppSpacing.xs,
                        runSpacing: 4,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: <Widget>[
                          Text(
                            Fmt.pricePerKg(market.pricePerKg),
                            style: AppText.priceSm
                                .copyWith(color: AppColors.primaryDark),
                          ),
                          _Fact(
                            icon: Icons.near_me_rounded,
                            text: Fmt.km(market.distanceKm),
                          ),
                          StatusBadge(
                            label: demandLabel ?? market.demand.name,
                            tone: _demandTone,
                            icon: market.demand.icon,
                            dense: true,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.chevron_right_rounded,
                  color: AppColors.textMuted,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// The podium position, drawn: a coloured disc with the rank inside it.
class _RankBadge extends StatelessWidget {
  const _RankBadge({required this.rank, required this.size});

  final int rank;
  final double size;

  @override
  Widget build(BuildContext context) {
    final Color colour = MarketCard._medalColor(rank);

    return Semantics(
      label: 'Rank $rank',
      child: Container(
        width: size,
        height: size,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: MarketCard._medalSoft(rank),
          shape: BoxShape.circle,
          border: Border.all(color: colour, width: 1.5),
        ),
        child: Text(
          rank > 0 ? '$rank' : '·',
          style: AppText.label.copyWith(
            fontSize: size * 0.5,
            fontWeight: FontWeight.w800,
            color: colour,
            height: 1,
          ),
        ),
      ),
    );
  }
}

class _Fact extends StatelessWidget {
  const _Fact({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Icon(icon, size: 14, color: AppColors.textMuted),
        const SizedBox(width: 3),
        Text(text, style: AppText.bodySmStrong.copyWith(fontSize: 13)),
      ],
    );
  }
}
