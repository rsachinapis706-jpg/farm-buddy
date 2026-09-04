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
import 'package:farm_buddy/features/farmers/widgets/farmer_profile_sheet.dart';
import 'package:farm_buddy/models/farmer.dart';
import 'package:farm_buddy/providers/app_providers.dart';
import 'package:farm_buddy/providers/farmer_providers.dart';
import 'package:farm_buddy/widgets/cards/farmer_card.dart';
import 'package:farm_buddy/widgets/common/app_header.dart';
import 'package:farm_buddy/widgets/common/demo_data_chip.dart';
import 'package:farm_buddy/widgets/common/emoji_text.dart';
import 'package:farm_buddy/widgets/common/map_preview.dart';
import 'package:farm_buddy/widgets/common/offline_banner.dart';
import 'package:farm_buddy/widgets/states/empty_state.dart';
import 'package:farm_buddy/widgets/states/error_state.dart';
import 'package:farm_buddy/widgets/states/loading_state.dart';

/// Farmers near you, and the reason to talk to them.
///
/// Volume is leverage: one farmer with 500 kg is a price taker, four farmers
/// with 1,850 kg are a supplier. The group-sale card sits above the list
/// because that is the insight, not the directory.
class NearbyFarmersScreen extends ConsumerWidget {
  const NearbyFarmersScreen({super.key});

  /// Filter ids; the label for each is `farmers.filter.<id>`.
  static const List<String> _filterIds = <String>[
    'all',
    'sameCrop',
    'nearby',
    'seeds',
    'rotation',
    'collective',
  ];

  /// Deterministic pin spots so the map is stable between rebuilds.
  static const List<Offset> _pinSpots = <Offset>[
    Offset(0.36, 0.34),
    Offset(0.62, 0.26),
    Offset(0.74, 0.56),
    Offset(0.30, 0.58),
    Offset(0.54, 0.70),
    Offset(0.84, 0.36),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppStrings s = ref.watch(stringsProvider);
    final String activeFilter = ref.watch(farmerFilterProvider);
    final Set<String> connected = ref.watch(connectedFarmerIdsProvider);
    final AsyncValue<List<NearbyFarmer>> farmers =
        ref.watch(nearbyFarmersProvider);
    final AsyncValue<GroupSaleOpportunity> groupSale =
        ref.watch(groupSaleProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppHeader(
        title: s('farmers.title'),
        subtitle: s('farmers.subtitle'),
        showLogo: true,
      ),
      body: SafeArea(
        top: false,
        child: RefreshIndicator(
          color: AppColors.primary,
          onRefresh: () async {
            ref.invalidate(nearbyFarmersProvider);
            await ref.read(nearbyFarmersProvider.future);
          },
          child: ListView(
            padding: const EdgeInsets.only(
              bottom: AppSpacing.bottomNavClearance,
            ),
            children: <Widget>[
              ResponsiveCenter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    const OfflineBanner(),

                    // ------------------------------------------- map
                    MapPreview(
                      height: 170,
                      showRoute: false,
                      markers: <MapMarker>[
                        for (int i = 0;
                            i < (farmers.value?.length ?? 0) &&
                                i < _pinSpots.length;
                            i++)
                          MapMarker(
                            x: _pinSpots[i].dx,
                            y: _pinSpots[i].dy,
                            label: farmers.value![i].name.split(' ').first,
                            emoji: farmers.value![i].cropEmoji,
                          ),
                      ],
                    ),

                    const SizedBox(height: AppSpacing.xs),
                    const Align(
                      alignment: Alignment.centerRight,
                      child: DemoDataChip(),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                  ],
                ),
              ),

              // -------------------------------------------- filters
              SizedBox(
                height: 48,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: AppSpacing.screen,
                  itemCount: _filterIds.length,
                  separatorBuilder: (BuildContext context, int index) =>
                      const SizedBox(width: AppSpacing.xs),
                  itemBuilder: (BuildContext context, int index) {
                    final String id = _filterIds[index];
                    return _FilterChip(
                      label: s('farmers.filter.$id'),
                      selected: id == activeFilter,
                      onTap: () =>
                          ref.read(farmerFilterProvider.notifier).state = id,
                    );
                  },
                ),
              ),

              const SizedBox(height: AppSpacing.md),

              // ----------------------------------------- group sale
              ResponsiveCenter(
                child: groupSale.maybeWhen(
                  data: (GroupSaleOpportunity data) => _GroupSaleBanner(
                    title: s('farmers.groupSale.title'),
                    body: s.withArgs(
                      'farmers.groupSale.body',
                      <String, String>{
                        'count': '${data.farmerCount}',
                        'qty': Fmt.kilos(data.totalQuantityKg),
                        'crop': s('crop.${data.cropName.toLowerCase()}'),
                      },
                    ),
                    cta: s('farmers.groupSale.cta'),
                    emoji: data.cropEmoji,
                    onTap: () => context.push(AppRoutes.groupSale),
                  ),
                  orElse: () => const SizedBox.shrink(),
                ),
              ),

              const SizedBox(height: AppSpacing.lg),

              // -------------------------------------------- the list
              ResponsiveCenter(
                child: farmers.when(
                  loading: () => LoadingState(message: s('state.loading')),
                  error: (Object error, StackTrace stack) => ErrorState(
                    title: s('state.errorTitle'),
                    message: s('state.errorBody'),
                    retryLabel: s('common.retry'),
                    onRetry: () => ref.invalidate(nearbyFarmersProvider),
                  ),
                  data: (List<NearbyFarmer> list) {
                    if (list.isEmpty) {
                      return EmptyState(
                        icon: Icons.groups_outlined,
                        title: s('farmers.empty.title'),
                        message: s('farmers.empty.body'),
                        actionLabel: s('farmers.filter.all'),
                        onAction: () => ref
                            .read(farmerFilterProvider.notifier)
                            .state = 'all',
                      );
                    }
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: <Widget>[
                        for (final NearbyFarmer farmer in list)
                          FarmerCard(
                            farmer: farmer.copyWith(
                              isConnected: connected.contains(farmer.id),
                            ),
                            connectLabel: s('farmers.connect'),
                            connectedLabel: s('farmers.connected'),
                            profileLabel: s('farmers.viewProfile'),
                            growingLabel: s('farmers.growing'),
                            awayLabel: s('common.away'),
                            tagLabels: <String>[
                              for (final String key in farmer.tagKeys) s(key),
                            ],
                            onConnect: () {
                              final Set<String> next = <String>{
                                ...connected,
                                farmer.id,
                              };
                              ref
                                  .read(connectedFarmerIdsProvider.notifier)
                                  .state = next;
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    s.withArgs(
                                      'farmers.connectedToast',
                                      <String, String>{'name': farmer.name},
                                    ),
                                  ),
                                ),
                              );
                            },
                            onViewProfile: () =>
                                showFarmerProfile(context, farmer),
                          ),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      selected: selected,
      button: true,
      child: Material(
        color: selected ? AppColors.primary : AppColors.surface,
        borderRadius: AppRadius.rPill,
        child: InkWell(
          onTap: onTap,
          borderRadius: AppRadius.rPill,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              borderRadius: AppRadius.rPill,
              border: Border.all(
                color: selected ? AppColors.primary : AppColors.border,
              ),
            ),
            child: Text(
              label,
              style: AppText.bodySmStrong.copyWith(
                color: selected ? Colors.white : AppColors.textSecondary,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
      ),
    );
  }
}

class _GroupSaleBanner extends StatelessWidget {
  const _GroupSaleBanner({
    required this.title,
    required this.body,
    required this.cta,
    required this.emoji,
    required this.onTap,
  });

  final String title;
  final String body;
  final String cta;
  final String emoji;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.harvestSoft,
      borderRadius: AppRadius.rLg,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadius.rLg,
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            borderRadius: AppRadius.rLg,
            border: Border.all(color: AppColors.harvest.withValues(alpha: 0.4)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                children: <Widget>[
                  Container(
                    width: 42,
                    height: 42,
                    alignment: Alignment.center,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: AppRadius.rMd,
                    ),
                    child: EmojiText(emoji, size: 21),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Text(
                      title,
                      style: AppText.titleLg,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(body, style: AppText.bodySm, maxLines: 3),
              const SizedBox(height: AppSpacing.sm),
              Row(
                children: <Widget>[
                  Flexible(
                    child: Text(
                      cta,
                      style: AppText.bodySmStrong
                          .copyWith(color: AppColors.primaryDark),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const Icon(
                    Icons.arrow_forward_rounded,
                    size: 17,
                    color: AppColors.primaryDark,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
