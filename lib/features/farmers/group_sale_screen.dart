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
import 'package:farm_buddy/models/farmer.dart';
import 'package:farm_buddy/providers/app_providers.dart';
import 'package:farm_buddy/providers/crop_providers.dart';
import 'package:farm_buddy/providers/farmer_providers.dart';
import 'package:farm_buddy/widgets/buttons/primary_button.dart';
import 'package:farm_buddy/widgets/cards/stat_card.dart';
import 'package:farm_buddy/widgets/common/app_header.dart';
import 'package:farm_buddy/widgets/common/demo_data_chip.dart';
import 'package:farm_buddy/widgets/common/emoji_text.dart';
import 'package:farm_buddy/widgets/states/error_state.dart';
import 'package:farm_buddy/widgets/states/loading_state.dart';

/// Four farmers, one lot, a better price.
///
/// The screen exists to make one number obvious: what selling together is
/// worth compared with selling alone.
class GroupSaleScreen extends ConsumerWidget {
  const GroupSaleScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppStrings s = ref.watch(stringsProvider);
    final AsyncValue<GroupSaleOpportunity> opportunity =
        ref.watch(groupSaleProvider);
    final double myQuantity = ref.watch(activeQuantityProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppHeader(
        title: s('groupSale.title'),
        subtitle: s('groupSale.subtitle'),
        onBack: () =>
            context.canPop() ? context.pop() : context.go(AppRoutes.farmers),
        actions: const <Widget>[
          Padding(
            padding: EdgeInsets.only(right: AppSpacing.xs),
            child: Center(child: DemoDataChip()),
          ),
        ],
      ),
      body: SafeArea(
        top: false,
        child: opportunity.when(
          loading: () => Center(child: LoadingState(message: s('state.loading'))),
          error: (Object error, StackTrace stack) => Center(
            child: ErrorState(
              title: s('state.errorTitle'),
              message: s('state.errorBody'),
              retryLabel: s('common.retry'),
              onRetry: () => ref.invalidate(groupSaleProvider),
            ),
          ),
          data: (GroupSaleOpportunity data) => ListView(
            padding: const EdgeInsets.only(bottom: AppSpacing.xxl),
            children: <Widget>[
              ResponsiveCenter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    // -------------------------------------- headline
                    Container(
                      padding: const EdgeInsets.all(AppSpacing.lg),
                      decoration: const BoxDecoration(
                        gradient: AppColors.heroGreen,
                        borderRadius: AppRadius.rXl,
                        boxShadow: AppShadows.hero,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Row(
                            children: <Widget>[
                              EmojiText(data.cropEmoji, size: 26),
                              const SizedBox(width: AppSpacing.xs),
                              Expanded(
                                child: Text(
                                  s('groupSale.total'),
                                  style: AppText.bodySm.copyWith(
                                    color: Colors.white.withValues(alpha: 0.85),
                                  ),
                                  maxLines: 2,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: AppSpacing.xxs),
                          Text(
                            Fmt.kilos(data.totalQuantityKg),
                            style: AppText.display.copyWith(color: Colors.white),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: AppSpacing.md),
                          Row(
                            children: <Widget>[
                              Expanded(
                                child: _PriceBlock(
                                  label: s('groupSale.soloPrice'),
                                  value: Fmt.pricePerKg(data.soloPricePerKg),
                                  faded: true,
                                ),
                              ),
                              const Icon(
                                Icons.arrow_forward_rounded,
                                color: Colors.white,
                                size: 20,
                              ),
                              Expanded(
                                child: _PriceBlock(
                                  label: s('groupSale.betterPrice'),
                                  value: Fmt.pricePerKg(data.betterPricePerKg),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: AppSpacing.md),

                    Row(
                      children: <Widget>[
                        Expanded(
                          child: StatCard(
                            label: s('groupSale.extraEarning'),
                            value: Fmt.rupees(data.extraEarning),
                            icon: Icons.trending_up_rounded,
                            tone: AppColors.success,
                            compact: true,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.xs),
                        Expanded(
                          child: StatCard(
                            label: s('groupSale.yourExtra'),
                            value: Fmt.rupees(
                              data.extraEarningFor(myQuantity),
                            ),
                            icon: Icons.account_balance_wallet_outlined,
                            tone: AppColors.primary,
                            compact: true,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: AppSpacing.xl),

                    // --------------------------------------- members
                    Text(s('groupSale.members'), style: AppText.h3),
                    const SizedBox(height: AppSpacing.sm),
                    _MemberRow(
                      initials: s('common.you').substring(0, 1).toUpperCase(),
                      name: s('common.you'),
                      detail: Fmt.kilos(myQuantity),
                      isYou: true,
                    ),
                    for (final NearbyFarmer member in data.members)
                      _MemberRow(
                        initials: member.initials,
                        name: member.name,
                        detail:
                            '${member.village} · ${Fmt.kilos(member.quantityKg)}',
                      ),

                    const SizedBox(height: AppSpacing.xl),

                    // ------------------------------------ how it works
                    Text(s('groupSale.how'), style: AppText.h3),
                    const SizedBox(height: AppSpacing.sm),
                    Container(
                      padding: const EdgeInsets.all(AppSpacing.md),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: AppRadius.rLg,
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Column(
                        children: <Widget>[
                          for (int i = 1; i <= 3; i++)
                            Padding(
                              padding: EdgeInsets.only(
                                bottom: i == 3 ? 0 : AppSpacing.sm,
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Container(
                                    width: 24,
                                    height: 24,
                                    alignment: Alignment.center,
                                    decoration: const BoxDecoration(
                                      color: AppColors.primarySoft,
                                      shape: BoxShape.circle,
                                    ),
                                    child: Text(
                                      '$i',
                                      style: AppText.caption.copyWith(
                                        fontWeight: FontWeight.w800,
                                        color: AppColors.primaryDark,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: AppSpacing.sm),
                                  Expanded(
                                    child: Text(
                                      s('groupSale.step$i'),
                                      style: AppText.bodySm,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                    ),

                    const SizedBox(height: AppSpacing.xxl),
                    PrimaryButton(
                      label: s('groupSale.cta'),
                      icon: Icons.groups_rounded,
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(s('groupSale.created'))),
                        );
                        context.go(AppRoutes.transport);
                      },
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
}

class _PriceBlock extends StatelessWidget {
  const _PriceBlock({
    required this.label,
    required this.value,
    this.faded = false,
  });

  final String label;
  final String value;
  final bool faded;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Text(
          label,
          style: AppText.caption.copyWith(
            color: Colors.white.withValues(alpha: faded ? 0.55 : 0.85),
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        Text(
          value,
          style: AppText.priceSm.copyWith(
            color: Colors.white.withValues(alpha: faded ? 0.6 : 1),
            decoration: faded ? TextDecoration.lineThrough : null,
            decorationColor: Colors.white70,
            fontSize: faded ? 17 : 22,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}

class _MemberRow extends StatelessWidget {
  const _MemberRow({
    required this.initials,
    required this.name,
    required this.detail,
    this.isYou = false,
  });

  final String initials;
  final String name;
  final String detail;
  final bool isYou;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.xs),
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: isYou ? AppColors.primarySofter : AppColors.surface,
        borderRadius: AppRadius.rMd,
        border: Border.all(
          color: isYou ? AppColors.primary : AppColors.border,
        ),
      ),
      child: Row(
        children: <Widget>[
          Container(
            width: 40,
            height: 40,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: isYou ? AppColors.primary : AppColors.surfaceAlt,
              borderRadius: AppRadius.rSm,
            ),
            child: Text(
              initials,
              style: AppText.bodySmStrong.copyWith(
                color: isYou ? Colors.white : AppColors.textPrimary,
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text(
                  name,
                  style: AppText.bodyStrong,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  detail,
                  style: AppText.caption,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          if (isYou)
            const Icon(
              Icons.check_circle_rounded,
              color: AppColors.primary,
              size: 22,
            ),
        ],
      ),
    );
  }
}
