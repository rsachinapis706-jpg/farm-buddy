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
import 'package:farm_buddy/models/enums.dart';
import 'package:farm_buddy/models/transport.dart';
import 'package:farm_buddy/providers/activity_providers.dart';
import 'package:farm_buddy/providers/app_providers.dart';
import 'package:farm_buddy/providers/crop_providers.dart';
import 'package:farm_buddy/providers/transport_providers.dart';
import 'package:farm_buddy/widgets/buttons/primary_button.dart';
import 'package:farm_buddy/widgets/cards/stat_card.dart';
import 'package:farm_buddy/widgets/cards/transport_card.dart';
import 'package:farm_buddy/widgets/common/app_header.dart';
import 'package:farm_buddy/widgets/common/demo_data_chip.dart';
import 'package:farm_buddy/widgets/common/emoji_text.dart';
import 'package:farm_buddy/widgets/common/offline_banner.dart';
import 'package:farm_buddy/widgets/states/error_state.dart';
import 'package:farm_buddy/widgets/states/loading_state.dart';

/// Getting the produce there.
///
/// Transport is where a good price quietly disappears, so the trip, its cost
/// and the shared-truck alternative are all on one screen — before any
/// booking button.
class TransportScreen extends ConsumerWidget {
  const TransportScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppStrings s = ref.watch(stringsProvider);
    final double quantity = ref.watch(activeQuantityProvider);
    final AsyncValue<TransportRoute> route = ref.watch(transportRouteProvider);
    final AsyncValue<List<TransportOption>> options =
        ref.watch(transportOptionsProvider);
    final AsyncValue<TransportOption> shared =
        ref.watch(sharedTransportProvider);
    final String? bookedId = ref.watch(bookedTransportIdProvider);
    final String destination = route.value?.destinationName ?? '';

    void recordBooking(TransportOption option) {
      ref.read(bookedTransportIdProvider.notifier).state = option.id;
      ref.read(bookingsProvider.notifier).add(
            BookingRecord(
              id: 'booking-${DateTime.now().microsecondsSinceEpoch}',
              vehicleName: option.providerName,
              vehicleEmoji: option.type.emoji,
              destinationName: destination,
              price: option.price,
              quantityKg: quantity,
              isShared: option.isShared,
              bookedAt: DateTime.now(),
            ),
          );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppHeader(
        title: s('transport.title'),
        subtitle: s('transport.subtitle'),
        showLogo: true,
      ),
      body: SafeArea(
        top: false,
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

                  // ------------------------------------------- route
                  route.when(
                    loading: () => LoadingState(message: s('state.loading')),
                    error: (Object error, StackTrace stack) => ErrorState(
                      title: s('state.errorTitle'),
                      message: s('state.errorBody'),
                      retryLabel: s('common.retry'),
                      onRetry: () => ref.invalidate(transportRouteProvider),
                    ),
                    data: (TransportRoute data) => Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: <Widget>[
                        _RouteCard(
                          pickupLabel: s('transport.pickup'),
                          pickupName: s('transport.yourFarm'),
                          pickupSub: data.pickupSub,
                          destinationLabel: s('transport.destination'),
                          destinationName: data.destinationName,
                          destinationSub: data.destinationSub,
                        ),
                        const SizedBox(height: AppSpacing.md),
                        Row(
                          children: <Widget>[
                            Expanded(
                              child: StatCard(
                                label: s('transport.distance'),
                                value: Fmt.km(data.distanceKm),
                                icon: Icons.straighten_rounded,
                                compact: true,
                              ),
                            ),
                            const SizedBox(width: AppSpacing.xs),
                            Expanded(
                              child: StatCard(
                                label: s('transport.time'),
                                value: Fmt.minutes(data.durationMinutes),
                                icon: Icons.schedule_rounded,
                                compact: true,
                              ),
                            ),
                            const SizedBox(width: AppSpacing.xs),
                            Expanded(
                              child: StatCard(
                                label: s('transport.estCost'),
                                value: Fmt.rupees(data.estimatedCost),
                                icon: Icons.payments_outlined,
                                tone: AppColors.earth,
                                compact: true,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: AppSpacing.xl),

                  // ---------------------------------- shared transport
                  shared.maybeWhen(
                    data: (TransportOption data) => _SharedTransportCard(
                      title: s('transport.shared.title'),
                      body: s.withArgs(
                        'transport.shared.body',
                        <String, String>{
                          'count': '${data.sharingFarmerCount ?? 2}',
                        },
                      ),
                      savingLabel: s('transport.shared.saving'),
                      savingValue: Fmt.rupees(data.savingAmount ?? 0),
                      cta: s('transport.shared.cta'),
                      onJoin: () {
                        recordBooking(data);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(s('transport.joined'))),
                        );
                      },
                      joined: bookedId == data.id,
                    ),
                    orElse: () => const SizedBox.shrink(),
                  ),

                  const SizedBox(height: AppSpacing.xl),

                  // --------------------------------------- vehicles
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: Text(
                          s('transport.vehicles'),
                          style: AppText.h3,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const DemoDataChip(),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.sm),

                  options.when(
                    loading: () => LoadingState(message: s('state.loading')),
                    error: (Object error, StackTrace stack) => ErrorState(
                      title: s('state.errorTitle'),
                      message: s('state.errorBody'),
                      retryLabel: s('common.retry'),
                      onRetry: () => ref.invalidate(transportOptionsProvider),
                    ),
                    data: (List<TransportOption> list) => Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: <Widget>[
                        for (final TransportOption option in list)
                          TransportCard(
                            option: option,
                            quantityKg: quantity,
                            isSelected: bookedId == option.id,
                            vehicleLabel: s(option.type.labelKey),
                            capacityLabel: s('transport.capacity'),
                            availableLabel: s('transport.available'),
                            unavailableLabel: s('transport.unavailable'),
                            tooSmallLabel: s('transport.tooSmall'),
                            requestLabel: bookedId == option.id
                                ? s('common.done')
                                : s('transport.request'),
                            etaLabel: s.withArgs(
                              'transport.eta',
                              <String, String>{
                                'time': Fmt.minutes(option.etaMinutes),
                              },
                            ),
                            onRequest: () {
                              recordBooking(option);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(s('transport.requested')),
                                ),
                              );
                            },
                          ),
                      ],
                    ),
                  ),

                  const SizedBox(height: AppSpacing.md),
                  TextButton.icon(
                    onPressed: () => context.go(AppRoutes.markets),
                    icon: const Icon(Icons.storefront_rounded, size: 19),
                    label: Text(s('transport.chooseMarket')),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Pickup -> destination, drawn as a short vertical journey.
class _RouteCard extends StatelessWidget {
  const _RouteCard({
    required this.pickupLabel,
    required this.pickupName,
    required this.pickupSub,
    required this.destinationLabel,
    required this.destinationName,
    required this.destinationSub,
  });

  final String pickupLabel;
  final String pickupName;
  final String pickupSub;
  final String destinationLabel;
  final String destinationName;
  final String destinationSub;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadius.rLg,
        border: Border.all(color: AppColors.border),
        boxShadow: AppShadows.card,
      ),
      child: Column(
        children: <Widget>[
          _RouteStop(
            label: pickupLabel,
            name: pickupName,
            sub: pickupSub,
            color: AppColors.sky,
            icon: Icons.home_work_outlined,
          ),
          // The line between the two stops.
          Padding(
            padding: const EdgeInsets.only(left: 19),
            child: Row(
              children: <Widget>[
                Column(
                  children: List<Widget>.generate(
                    3,
                    (int i) => Container(
                      width: 2,
                      height: 5,
                      margin: const EdgeInsets.symmetric(vertical: 2),
                      color: AppColors.borderStrong,
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                const Icon(
                  Icons.arrow_downward_rounded,
                  size: 15,
                  color: AppColors.textMuted,
                ),
              ],
            ),
          ),
          _RouteStop(
            label: destinationLabel,
            name: destinationName,
            sub: destinationSub,
            color: AppColors.primary,
            icon: Icons.storefront_rounded,
          ),
        ],
      ),
    );
  }
}

class _RouteStop extends StatelessWidget {
  const _RouteStop({
    required this.label,
    required this.name,
    required this.sub,
    required this.color,
    required this.icon,
  });

  final String label;
  final String name;
  final String sub;
  final Color color;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.12),
            borderRadius: AppRadius.rMd,
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text(label, style: AppText.caption),
              Text(
                name,
                style: AppText.titleLg,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                sub,
                style: AppText.caption,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _SharedTransportCard extends StatelessWidget {
  const _SharedTransportCard({
    required this.title,
    required this.body,
    required this.savingLabel,
    required this.savingValue,
    required this.cta,
    required this.onJoin,
    required this.joined,
  });

  final String title;
  final String body;
  final String savingLabel;
  final String savingValue;
  final String cta;
  final VoidCallback onJoin;
  final bool joined;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.harvestSoft,
        borderRadius: AppRadius.rLg,
        border: Border.all(color: AppColors.harvest.withValues(alpha: 0.45)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Row(
            children: <Widget>[
              Container(
                width: 44,
                height: 44,
                alignment: Alignment.center,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: AppRadius.rMd,
                ),
                child: const EmojiText('🚛', size: 21),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Text(
                      title,
                      style: AppText.titleLg,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(body, style: AppText.caption, maxLines: 3),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.sm,
              vertical: AppSpacing.xs,
            ),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: AppRadius.rMd,
            ),
            child: Row(
              children: <Widget>[
                const Icon(
                  Icons.savings_outlined,
                  size: 18,
                  color: AppColors.success,
                ),
                const SizedBox(width: AppSpacing.xs),
                Expanded(
                  child: Text(
                    savingLabel,
                    style: AppText.bodySm,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Text(
                  savingValue,
                  style: AppText.priceSm.copyWith(color: AppColors.success),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          PrimaryButton(
            label: cta,
            icon: joined ? Icons.check_circle_rounded : Icons.group_add_rounded,
            tone: AppColors.harvest,
            onPressed: joined ? null : onJoin,
            size: FbButtonSize.medium,
          ),
        ],
      ),
    );
  }
}
