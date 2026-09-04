import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:farm_buddy/core/l10n/app_strings.dart';
import 'package:farm_buddy/core/router/app_router.dart';
import 'package:farm_buddy/core/theme/app_colors.dart';
import 'package:farm_buddy/core/theme/app_spacing.dart';
import 'package:farm_buddy/core/theme/app_typography.dart';
import 'package:farm_buddy/core/utils/responsive.dart';
import 'package:farm_buddy/models/enums.dart';
import 'package:farm_buddy/models/market_insight.dart';
import 'package:farm_buddy/models/user_profile.dart';
import 'package:farm_buddy/providers/app_providers.dart';
import 'package:farm_buddy/providers/market_providers.dart';
import 'package:farm_buddy/widgets/brand/farm_buddy_logo.dart';
import 'package:farm_buddy/widgets/cards/action_tile.dart';
import 'package:farm_buddy/widgets/cards/hero_action_card.dart';
import 'package:farm_buddy/widgets/cards/insight_card.dart';
import 'package:farm_buddy/widgets/common/language_sheet.dart';
import 'package:farm_buddy/widgets/common/offline_banner.dart';
import 'package:farm_buddy/widgets/common/section_header.dart';
import 'package:farm_buddy/widgets/states/error_state.dart';
import 'package:farm_buddy/widgets/states/skeleton_box.dart';

/// The answer to "what should I do today?".
///
/// One loud action, four shortcuts, one number. Nothing else competes.
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppStrings s = ref.watch(stringsProvider);
    final FarmerProfile profile = ref.watch(profileProvider);
    final String location = ref.watch(locationProvider);
    final String greetingKey = ref.watch(greetingKeyProvider);
    final AsyncValue<MarketInsight> insight = ref.watch(todayInsightProvider);

    final String firstName = profile.name.split(' ').first;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: RefreshIndicator(
          color: AppColors.primary,
          onRefresh: () async {
            ref.read(lastSyncedProvider.notifier).state = DateTime.now();
            ref.invalidate(todayInsightProvider);
            await ref.read(todayInsightProvider.future);
          },
          child: ListView(
            padding: const EdgeInsets.only(
              bottom: AppSpacing.bottomNavClearance,
            ),
            children: <Widget>[
              // ------------------------------------------------- header
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.lg,
                  AppSpacing.xs,
                  AppSpacing.sm,
                  AppSpacing.md,
                ),
                child: Row(
                  children: <Widget>[
                    const FarmBuddyLogo(size: 40),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          Text(
                            s.withArgs(
                              greetingKey,
                              <String, String>{'name': firstName},
                            ),
                            style: AppText.h3,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                          Row(
                            children: <Widget>[
                              const Icon(
                                Icons.place_rounded,
                                size: 14,
                                color: AppColors.primary,
                              ),
                              const SizedBox(width: 3),
                              Flexible(
                                child: Text(
                                  location,
                                  style: AppText.caption,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () => showLanguageSheet(context),
                      icon: const Icon(Icons.translate_rounded),
                      color: AppColors.textSecondary,
                      tooltip: s('profile.language'),
                      constraints: const BoxConstraints(
                        minWidth: AppSpacing.touchTarget,
                        minHeight: AppSpacing.touchTarget,
                      ),
                    ),
                  ],
                ),
              ),

              const ResponsiveCenter(
                child: OfflineBanner(),
              ),

              // ---------------------------------------------- hero card
              ResponsiveCenter(
                child: HeroActionCard(
                  title: s('home.hero.title'),
                  subtitle: s('home.hero.subtitle'),
                  buttonLabel: s('home.hero.cta'),
                  footnote: s('home.hero.footnote'),
                  onPressed: () => context.push(AppRoutes.addCrop),
                ),
              ),

              const SizedBox(height: AppSpacing.md),

              // ------------------------------------------- how it works
              ResponsiveCenter(
                child: _JourneyStrip(
                  title: s('home.journey.title'),
                  steps: <String>[
                    s('home.journey.1'),
                    s('home.journey.2'),
                    s('home.journey.3'),
                    s('home.journey.4'),
                  ],
                ),
              ),

              const SizedBox(height: AppSpacing.xl),

              // ------------------------------------------ quick actions
              ResponsiveCenter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    SectionHeader(title: s('home.actions.title')),
                    IntrinsicHeight(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: <Widget>[
                          Expanded(
                            child: ActionTile(
                              emoji: '🌱',
                              title: s('home.action.crop.title'),
                              subtitle: s('home.action.crop.subtitle'),
                              onTap: () => context.push(AppRoutes.cropHealth),
                            ),
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          Expanded(
                            child: ActionTile(
                              emoji: '📍',
                              title: s('home.action.market.title'),
                              subtitle: s('home.action.market.subtitle'),
                              accent: AppColors.earth,
                              onTap: () => context.go(AppRoutes.markets),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    IntrinsicHeight(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: <Widget>[
                          Expanded(
                            child: ActionTile(
                              emoji: '👨‍🌾',
                              title: s('home.action.farmers.title'),
                              subtitle: s('home.action.farmers.subtitle'),
                              accent: AppColors.sky,
                              onTap: () => context.go(AppRoutes.farmers),
                            ),
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          Expanded(
                            child: ActionTile(
                              emoji: '🚚',
                              title: s('home.action.transport.title'),
                              subtitle: s('home.action.transport.subtitle'),
                              accent: AppColors.harvest,
                              onTap: () => context.go(AppRoutes.transport),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: AppSpacing.xl),

              // ----------------------------------------------- insight
              ResponsiveCenter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    SectionHeader(title: s('home.insight.title')),
                    insight.when(
                      loading: () => const SkeletonCard(lines: 2),
                      error: (Object error, StackTrace stack) => ErrorState(
                        title: s('state.errorTitle'),
                        message: s('state.errorBody'),
                        retryLabel: s('common.retry'),
                        onRetry: () => ref.invalidate(todayInsightProvider),
                      ),
                      data: (MarketInsight value) => InsightCard(
                        insight: value,
                        cropDisplayName:
                            s('crop.${value.cropName.toLowerCase()}'),
                        demandLabel: s(value.demand.labelKey),
                        vsYesterdayLabel: s('home.insight.vsYesterday'),
                        actionLabel: s('home.insight.cta'),
                        onViewDetails: () => context.push(
                          '${AppRoutes.marketDetails}/${value.marketId}',
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
}

/// Add crop -> photo -> check -> sell. Four dots, one line, no mystery.
class _JourneyStrip extends StatelessWidget {
  const _JourneyStrip({required this.title, required this.steps});

  final String title;
  final List<String> steps;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.md,
      ),
      decoration: BoxDecoration(
        color: AppColors.surfaceAlt,
        borderRadius: AppRadius.rLg,
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            title,
            style: AppText.bodySmStrong.copyWith(color: AppColors.textSecondary),
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              for (int i = 0; i < steps.length; i++) ...<Widget>[
                Expanded(
                  child: Column(
                    children: <Widget>[
                      Container(
                        width: 26,
                        height: 26,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: AppColors.primary,
                            width: 1.5,
                          ),
                        ),
                        child: Text(
                          '${i + 1}',
                          style: AppText.caption.copyWith(
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                            color: AppColors.primaryDark,
                          ),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xxs),
                      Text(
                        steps[i],
                        style: AppText.caption.copyWith(fontSize: 10.5),
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                if (i != steps.length - 1)
                  Container(
                    width: 14,
                    height: 1.5,
                    margin: const EdgeInsets.only(top: 12.5),
                    color: AppColors.borderStrong,
                  ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}
