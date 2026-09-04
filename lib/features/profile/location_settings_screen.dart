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
import 'package:farm_buddy/models/farm_location.dart';
import 'package:farm_buddy/providers/app_providers.dart';
import 'package:farm_buddy/providers/location_providers.dart';
import 'package:farm_buddy/widgets/buttons/primary_button.dart';
import 'package:farm_buddy/widgets/buttons/secondary_button.dart';
import 'package:farm_buddy/widgets/common/app_header.dart';
import 'package:farm_buddy/widgets/common/fb_map.dart';
import 'package:farm_buddy/widgets/common/status_badge.dart';

/// Everything about location in one place: what the app knows, how it learned
/// it, and how to change it.
///
/// The farmer is never forced to share a position. Denying permission is a
/// supported path, not an error — they can pick a place by hand and every
/// screen keeps working.
class LocationSettingsScreen extends ConsumerStatefulWidget {
  const LocationSettingsScreen({super.key});

  @override
  ConsumerState<LocationSettingsScreen> createState() =>
      _LocationSettingsScreenState();
}

class _LocationSettingsScreenState
    extends ConsumerState<LocationSettingsScreen> {
  bool _busy = false;

  /// Places a Coimbatore-district farmer would plausibly pick.
  static const List<({String label, double lat, double lng})> _places =
      <({String label, double lat, double lng})>[
    (label: 'Sulur, Coimbatore', lat: 11.0244, lng: 77.1261),
    (label: 'Annur, Coimbatore', lat: 11.2333, lng: 77.1000),
    (label: 'Mettupalayam, Coimbatore', lat: 11.2990, lng: 76.9370),
    (label: 'Pollachi, Coimbatore', lat: 10.6589, lng: 77.0089),
    (label: 'Kinathukadavu, Coimbatore', lat: 10.7600, lng: 77.0100),
  ];

  Future<void> _detect(AppStrings s) async {
    setState(() => _busy = true);
    final bool ok = await ref.read(farmLocationProvider.notifier).detect();
    if (!mounted) return;
    setState(() => _busy = false);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(s(ok ? 'loc.updated' : 'loc.failed'))),
    );
  }

  @override
  Widget build(BuildContext context) {
    final AppStrings s = ref.watch(stringsProvider);
    final FarmLocation here = ref.watch(farmLocationProvider);
    final LocationAccess access =
        ref.watch(farmLocationProvider.notifier).access;
    final bool liveMap = ref.watch(liveMapProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppHeader(
        title: s('loc.title'),
        subtitle: s('loc.subtitle'),
        onBack: () =>
            context.canPop() ? context.pop() : context.go(AppRoutes.profile),
      ),
      body: SafeArea(
        top: false,
        child: ListView(
          padding: const EdgeInsets.only(bottom: AppSpacing.xxl),
          children: <Widget>[
            ResponsiveCenter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  // -------------------------------------------- the map
                  FbMap(
                    height: 180,
                    centerLabel: here.label,
                    markers: <FbMapMarker>[
                      FbMapMarker(
                        id: 'you',
                        latitude: here.latitude,
                        longitude: here.longitude,
                        x: 0.5,
                        y: 0.5,
                        label: here.label,
                        isPrimary: true,
                      ),
                    ],
                  ),

                  const SizedBox(height: AppSpacing.md),

                  // ------------------------------------ what we know
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
                        Text(s('loc.current'), style: AppText.caption),
                        const SizedBox(height: 2),
                        Text(
                          here.label,
                          style: AppText.h3,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        Wrap(
                          spacing: AppSpacing.xs,
                          runSpacing: AppSpacing.xs,
                          children: <Widget>[
                            StatusBadge(
                              label: s(switch (here.source) {
                                LocationSource.device => 'loc.source.device',
                                LocationSource.manual => 'loc.source.manual',
                                LocationSource.defaultGuess =>
                                  'loc.source.guess',
                              }),
                              tone: here.isFromDevice
                                  ? BadgeTone.success
                                  : BadgeTone.neutral,
                              icon: here.isFromDevice
                                  ? Icons.my_location_rounded
                                  : Icons.place_outlined,
                              dense: true,
                            ),
                            if (here.accuracyMetres != null)
                              StatusBadge(
                                label: s.withArgs(
                                  'loc.accuracy',
                                  <String, String>{
                                    'n': here.accuracyMetres!.round().toString(),
                                  },
                                ),
                                tone: BadgeTone.info,
                                icon: Icons.adjust_rounded,
                                dense: true,
                              ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          '${here.latitude.toStringAsFixed(4)}, ${here.longitude.toStringAsFixed(4)}  ·  ${Fmt.relative(here.capturedAt)}',
                          style: AppText.caption,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: AppSpacing.md),
                  PrimaryButton(
                    label: _busy ? s('loc.detecting') : s('loc.use'),
                    icon: Icons.my_location_rounded,
                    isLoading: _busy,
                    onPressed: () => _detect(s),
                  ),

                  // ------------------------------------- permission state
                  if (access != LocationAccess.granted &&
                      access != LocationAccess.unknown) ...<Widget>[
                    const SizedBox(height: AppSpacing.md),
                    _PermissionNotice(
                      access: access,
                      strings: s,
                      onOpenSettings: () =>
                          ref.read(locationServiceProvider).openSettings(),
                    ),
                  ],

                  const SizedBox(height: AppSpacing.lg),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      const Icon(
                        Icons.lock_outline_rounded,
                        size: 15,
                        color: AppColors.textMuted,
                      ),
                      const SizedBox(width: AppSpacing.xs),
                      Expanded(
                        child: Text(s('loc.why'), style: AppText.caption),
                      ),
                    ],
                  ),

                  const SizedBox(height: AppSpacing.xl),

                  // --------------------------------------- live map switch
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: AppRadius.rLg,
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Row(
                      children: <Widget>[
                        const Icon(
                          Icons.map_outlined,
                          size: 21,
                          color: AppColors.textSecondary,
                        ),
                        const SizedBox(width: AppSpacing.md),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              Text(s('loc.liveMap'), style: AppText.bodyStrong),
                              Text(
                                s('loc.liveMapBody'),
                                style: AppText.caption,
                                maxLines: 3,
                              ),
                            ],
                          ),
                        ),
                        Switch(
                          value: liveMap,
                          onChanged: (bool v) =>
                              ref.read(liveMapProvider.notifier).state = v,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: AppSpacing.xl),

                  // ------------------------------------------ pick a place
                  Text(s('loc.pick'), style: AppText.h3),
                  const SizedBox(height: AppSpacing.sm),
                  for (final ({String label, double lat, double lng}) p
                      in _places)
                    _PlaceRow(
                      label: p.label,
                      selected: here.label == p.label,
                      onTap: () {
                        ref
                            .read(farmLocationProvider.notifier)
                            .setManual(p.lat, p.lng, p.label);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(s('loc.updated'))),
                        );
                      },
                    ),

                  const SizedBox(height: AppSpacing.md),
                  SecondaryButton(
                    label: s('loc.reset'),
                    icon: Icons.restart_alt_rounded,
                    onPressed: () =>
                        ref.read(farmLocationProvider.notifier).reset(),
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

class _PermissionNotice extends StatelessWidget {
  const _PermissionNotice({
    required this.access,
    required this.strings,
    required this.onOpenSettings,
  });

  final LocationAccess access;
  final AppStrings strings;
  final VoidCallback onOpenSettings;

  @override
  Widget build(BuildContext context) {
    final AppStrings s = strings;
    final String key = switch (access) {
      LocationAccess.denied => 'loc.permission.denied',
      LocationAccess.deniedForever => 'loc.permission.forever',
      LocationAccess.serviceOff => 'loc.permission.off',
      LocationAccess.unsupported => 'loc.permission.unsupported',
      _ => 'loc.permission.denied',
    };
    final bool canOpenSettings = access == LocationAccess.deniedForever ||
        access == LocationAccess.serviceOff;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.warningSoft,
        borderRadius: AppRadius.rLg,
        border: Border.all(color: AppColors.warning.withValues(alpha: 0.35)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              const Icon(
                Icons.info_outline_rounded,
                size: 20,
                color: AppColors.warning,
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  s('loc.permission.title'),
                  style: AppText.bodySmStrong,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(s(key), style: AppText.bodySm),
          if (canOpenSettings) ...<Widget>[
            const SizedBox(height: AppSpacing.sm),
            SecondaryButton(
              label: s('loc.openSettings'),
              icon: Icons.settings_outlined,
              size: FbButtonSize.medium,
              onPressed: onOpenSettings,
            ),
          ],
        ],
      ),
    );
  }
}

class _PlaceRow extends StatelessWidget {
  const _PlaceRow({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.xs),
      child: Material(
        color: selected ? AppColors.primarySofter : AppColors.surface,
        borderRadius: AppRadius.rMd,
        child: InkWell(
          onTap: onTap,
          borderRadius: AppRadius.rMd,
          child: Container(
            constraints: const BoxConstraints(minHeight: 56),
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.sm,
            ),
            decoration: BoxDecoration(
              borderRadius: AppRadius.rMd,
              border: Border.all(
                color: selected ? AppColors.primary : AppColors.border,
                width: selected ? 2 : 1,
              ),
            ),
            child: Row(
              children: <Widget>[
                Icon(
                  Icons.place_outlined,
                  size: 20,
                  color: selected ? AppColors.primary : AppColors.textMuted,
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(
                    label,
                    style: AppText.bodyStrong,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (selected)
                  const Icon(
                    Icons.check_circle_rounded,
                    color: AppColors.primary,
                    size: 22,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
