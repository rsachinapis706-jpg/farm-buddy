import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:farm_buddy/core/l10n/app_strings.dart';
import 'package:farm_buddy/core/theme/app_colors.dart';
import 'package:farm_buddy/core/theme/app_spacing.dart';
import 'package:farm_buddy/core/theme/app_typography.dart';
import 'package:farm_buddy/core/utils/formatters.dart';
import 'package:farm_buddy/models/farmer.dart';
import 'package:farm_buddy/providers/app_providers.dart';
import 'package:farm_buddy/providers/farmer_providers.dart';
import 'package:farm_buddy/widgets/buttons/primary_button.dart';
import 'package:farm_buddy/widgets/common/emoji_text.dart';
import 'package:farm_buddy/widgets/common/fb_sheet.dart';
import 'package:farm_buddy/widgets/common/status_badge.dart';

/// "View Profile" used to be a snackbar. This is what it should always have
/// been: enough to decide whether to reach out, and a way to do it.
Future<void> showFarmerProfile(BuildContext context, NearbyFarmer farmer) {
  return showFbSheet<void>(
    context: context,
    title: farmer.name,
    subtitle: '${farmer.village} · ${Fmt.km(farmer.distanceKm)}',
    child: _FarmerProfileBody(farmer: farmer),
  );
}

class _FarmerProfileBody extends ConsumerWidget {
  const _FarmerProfileBody({required this.farmer});

  final NearbyFarmer farmer;

  static const List<Color> _avatarColors = <Color>[
    AppColors.primary,
    AppColors.earth,
    AppColors.sky,
    AppColors.soil,
    Color(0xFF7A5AA8),
    Color(0xFF2E8B8B),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppStrings s = ref.watch(stringsProvider);
    final Set<String> connected = ref.watch(connectedFarmerIdsProvider);
    final bool isConnected = connected.contains(farmer.id);
    final Color accent = _avatarColors[farmer.avatarSeed % _avatarColors.length];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        // ------------------------------------------------------ identity
        Row(
          children: <Widget>[
            Container(
              width: 64,
              height: 64,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: accent.withValues(alpha: 0.12),
                borderRadius: AppRadius.rLg,
                border: Border.all(color: accent.withValues(alpha: 0.25)),
              ),
              child: Text(
                farmer.initials,
                style: AppText.h2.copyWith(color: accent),
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  StatusBadge(
                    label: '${farmer.rating.toStringAsFixed(1)} ${s('farmers.rating')}',
                    tone: BadgeTone.gold,
                    icon: Icons.star_rounded,
                    dense: true,
                  ),
                  const SizedBox(height: AppSpacing.xxs),
                  Text(
                    '${Fmt.km(farmer.distanceKm)} ${s('common.away')}',
                    style: AppText.bodySm,
                  ),
                ],
              ),
            ),
          ],
        ),

        const SizedBox(height: AppSpacing.md),

        // ------------------------------------------------------ growing
        Container(
          padding: const EdgeInsets.all(AppSpacing.sm),
          decoration: const BoxDecoration(
            color: AppColors.surfaceAlt,
            borderRadius: AppRadius.rMd,
          ),
          child: Row(
            children: <Widget>[
              EmojiText(farmer.cropEmoji, size: 22),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  '${s('farmers.growing')}: ${s('crop.${farmer.cropName.toLowerCase()}')} — ${Fmt.kilos(farmer.quantityKg)}',
                  style: AppText.bodyStrong,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),

        if (farmer.tagKeys.isNotEmpty) ...<Widget>[
          const SizedBox(height: AppSpacing.md),
          Text(s('farmer.shares'), style: AppText.bodySmStrong),
          const SizedBox(height: AppSpacing.xs),
          Wrap(
            spacing: AppSpacing.xxs,
            runSpacing: AppSpacing.xxs,
            children: <Widget>[
              for (final String key in farmer.tagKeys)
                StatusBadge(
                  label: s(key),
                  tone: BadgeTone.highlight,
                  icon: Icons.local_offer_outlined,
                  dense: true,
                ),
            ],
          ),
        ],

        const SizedBox(height: AppSpacing.lg),

        // ------------------------------------------------------ contact
        FbSheetRow(
          icon: Icons.call_outlined,
          label: s('farmer.call'),
          detail: '+91 9•••• ••${farmer.avatarSeed}${farmer.avatarSeed}0',
          onTap: () => _toast(context, '${s('farmer.call')} · ${farmer.name}'),
        ),
        FbSheetRow(
          icon: Icons.chat_bubble_outline_rounded,
          label: s('farmer.message'),
          tone: AppColors.sky,
          onTap: () => _toast(context, '${s('farmer.message')} · ${farmer.name}'),
        ),

        const SizedBox(height: AppSpacing.sm),
        PrimaryButton(
          label: isConnected ? s('farmers.connected') : s('farmers.connect'),
          icon: isConnected
              ? Icons.check_circle_rounded
              : Icons.person_add_alt_1_rounded,
          onPressed: isConnected
              ? null
              : () {
                  ref.read(connectedFarmerIdsProvider.notifier).state =
                      <String>{...connected, farmer.id};
                  Navigator.of(context).pop();
                  _toast(
                    context,
                    s.withArgs('farmers.connectedToast', <String, String>{
                      'name': farmer.name,
                    }),
                  );
                },
        ),
      ],
    );
  }

  void _toast(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
}
