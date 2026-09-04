import 'package:flutter/material.dart';

import 'package:farm_buddy/core/theme/app_colors.dart';
import 'package:farm_buddy/core/theme/app_spacing.dart';
import 'package:farm_buddy/core/theme/app_typography.dart';
import 'package:farm_buddy/core/utils/formatters.dart';
import 'package:farm_buddy/models/farmer.dart';
import 'package:farm_buddy/widgets/buttons/primary_button.dart';
import 'package:farm_buddy/widgets/buttons/secondary_button.dart';
import 'package:farm_buddy/widgets/common/emoji_text.dart';
import 'package:farm_buddy/widgets/common/status_badge.dart';

/// A neighbour you could sell with.
///
/// Avatars are generated from the farmer's initials and a seed colour — no
/// photo upload, no face on a screen, no privacy question to answer.
class FarmerCard extends StatelessWidget {
  const FarmerCard({
    super.key,
    required this.farmer,
    required this.onConnect,
    required this.onViewProfile,
    this.connectLabel,
    this.connectedLabel,
    this.profileLabel,
    this.growingLabel,
    this.awayLabel,
    this.tagLabels = const <String>[],
  });

  final NearbyFarmer farmer;
  final VoidCallback onConnect;
  final VoidCallback onViewProfile;
  final String? connectLabel;
  final String? connectedLabel;
  final String? profileLabel;
  final String? growingLabel;
  final String? awayLabel;

  /// Already-localised tag labels.
  final List<String> tagLabels;

  static const List<Color> _avatarColors = <Color>[
    AppColors.primary,
    AppColors.earth,
    AppColors.sky,
    AppColors.soil,
    Color(0xFF7A5AA8),
    Color(0xFF2E8B8B),
  ];

  Color get _avatarColor =>
      _avatarColors[farmer.avatarSeed % _avatarColors.length];

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              // ------------------------------------------------ avatar
              Container(
                width: 52,
                height: 52,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: _avatarColor.withValues(alpha: 0.12),
                  borderRadius: AppRadius.rMd,
                  border: Border.all(color: _avatarColor.withValues(alpha: 0.25)),
                ),
                child: Text(
                  farmer.initials,
                  style: AppText.titleLg.copyWith(color: _avatarColor),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        Expanded(
                          child: Text(
                            farmer.name,
                            style: AppText.titleLg,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const Icon(
                          Icons.star_rounded,
                          size: 15,
                          color: AppColors.harvest,
                        ),
                        const SizedBox(width: 2),
                        Text(
                          farmer.rating.toStringAsFixed(1),
                          style: AppText.bodySmStrong.copyWith(fontSize: 13),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: <Widget>[
                        const Icon(
                          Icons.place_outlined,
                          size: 14,
                          color: AppColors.textMuted,
                        ),
                        const SizedBox(width: 3),
                        Flexible(
                          child: Text(
                            '${farmer.village} · ${Fmt.km(farmer.distanceKm)} ${awayLabel ?? 'away'}',
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
            ],
          ),

          const SizedBox(height: AppSpacing.sm),

          // ------------------------------------------------- growing
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.sm,
              vertical: AppSpacing.xs,
            ),
            decoration: const BoxDecoration(
              color: AppColors.surfaceAlt,
              borderRadius: AppRadius.rSm,
            ),
            child: Row(
              children: <Widget>[
                EmojiText(farmer.cropEmoji, size: 16),
                const SizedBox(width: AppSpacing.xs),
                Expanded(
                  child: Text(
                    '${growingLabel ?? 'Growing'}: ${farmer.cropName} — ${Fmt.kilos(farmer.quantityKg)}',
                    style: AppText.bodySmStrong.copyWith(fontSize: 13.5),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),

          if (tagLabels.isNotEmpty) ...<Widget>[
            const SizedBox(height: AppSpacing.sm),
            Wrap(
              spacing: AppSpacing.xxs,
              runSpacing: AppSpacing.xxs,
              children: <Widget>[
                for (final String tag in tagLabels)
                  StatusBadge(
                    label: tag,
                    tone: BadgeTone.highlight,
                    icon: Icons.local_offer_outlined,
                    dense: true,
                  ),
              ],
            ),
          ],

          const SizedBox(height: AppSpacing.md),

          Row(
            children: <Widget>[
              Expanded(
                child: farmer.isConnected
                    ? SecondaryButton(
                        label: connectedLabel ?? 'Connected',
                        icon: Icons.check_circle_rounded,
                        onPressed: null,
                        size: FbButtonSize.medium,
                        foreground: AppColors.success,
                      )
                    : PrimaryButton(
                        label: connectLabel ?? 'Connect',
                        icon: Icons.person_add_alt_1_rounded,
                        onPressed: onConnect,
                        size: FbButtonSize.medium,
                      ),
              ),
              const SizedBox(width: AppSpacing.xs),
              Expanded(
                child: SecondaryButton(
                  label: profileLabel ?? 'View Profile',
                  onPressed: onViewProfile,
                  size: FbButtonSize.medium,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
