import 'package:flutter/material.dart';

import 'package:farm_buddy/core/theme/app_colors.dart';
import 'package:farm_buddy/core/theme/app_spacing.dart';
import 'package:farm_buddy/core/theme/app_typography.dart';
import 'package:farm_buddy/core/utils/formatters.dart';
import 'package:farm_buddy/models/enums.dart';
import 'package:farm_buddy/models/transport.dart';
import 'package:farm_buddy/widgets/buttons/primary_button.dart';
import 'package:farm_buddy/widgets/common/emoji_text.dart';
import 'package:farm_buddy/widgets/common/status_badge.dart';

/// A vehicle you can book.
///
/// The capacity meter is the important bit: a farmer can see at a glance
/// whether their load fits, without doing arithmetic on two numbers.
class TransportCard extends StatelessWidget {
  const TransportCard({
    super.key,
    required this.option,
    required this.onRequest,
    this.quantityKg = 0,
    this.vehicleLabel,
    this.requestLabel,
    this.capacityLabel,
    this.availableLabel,
    this.unavailableLabel,
    this.etaLabel,
    this.tooSmallLabel,
    this.isSelected = false,
    this.onTap,
  });

  final TransportOption option;
  final VoidCallback onRequest;
  final double quantityKg;
  final String? vehicleLabel;
  final String? requestLabel;
  final String? capacityLabel;
  final String? availableLabel;
  final String? unavailableLabel;
  final String? etaLabel;
  final String? tooSmallLabel;
  final bool isSelected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final bool fits = quantityKg <= 0 || option.fits(quantityKg);
    final bool bookable = option.isAvailable && fits;
    final double load = option.loadFactor(quantityKg);

    return Opacity(
      opacity: option.isAvailable ? 1 : 0.62,
      child: Container(
        margin: const EdgeInsets.only(bottom: AppSpacing.sm),
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: AppRadius.rLg,
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.border,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: AppShadows.card,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Container(
                  width: 50,
                  height: 50,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: option.isShared
                        ? AppColors.harvestSoft
                        : AppColors.primarySoft,
                    borderRadius: AppRadius.rMd,
                  ),
                  child: EmojiText(option.type.emoji, size: 24),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Text(
                        vehicleLabel == null
                            ? option.providerName
                            : '${vehicleLabel!} · ${option.providerName}',
                        style: AppText.titleLg,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: <Widget>[
                          const Icon(
                            Icons.person_outline_rounded,
                            size: 13,
                            color: AppColors.textMuted,
                          ),
                          const SizedBox(width: 3),
                          Flexible(
                            child: Text(
                              option.driverName,
                              style: AppText.caption,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: AppSpacing.xs),
                          const Icon(
                            Icons.star_rounded,
                            size: 13,
                            color: AppColors.harvest,
                          ),
                          const SizedBox(width: 2),
                          Text(
                            option.rating.toStringAsFixed(1),
                            style: AppText.caption,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: AppSpacing.xs),
                Text(
                  Fmt.rupees(option.price),
                  style: AppText.priceSm.copyWith(color: AppColors.primaryDark),
                ),
              ],
            ),

            const SizedBox(height: AppSpacing.sm),

            // ------------------------------------------ capacity meter
            Row(
              children: <Widget>[
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Text(
                        '${capacityLabel ?? 'Capacity'}: ${Fmt.kilos(option.capacityKg)}',
                        style: AppText.caption,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 5),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: quantityKg <= 0 ? 0.0 : load,
                          minHeight: 7,
                          backgroundColor: AppColors.surfaceAlt,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            fits ? AppColors.primary : AppColors.danger,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                StatusBadge(
                  label: option.isAvailable
                      ? (availableLabel ?? 'Available')
                      : (unavailableLabel ?? 'Not available'),
                  tone: option.isAvailable ? BadgeTone.success : BadgeTone.neutral,
                  icon: option.isAvailable
                      ? Icons.check_circle_outline_rounded
                      : Icons.do_not_disturb_on_outlined,
                  dense: true,
                ),
              ],
            ),

            const SizedBox(height: AppSpacing.sm),

            Row(
              children: <Widget>[
                const Icon(
                  Icons.schedule_rounded,
                  size: 14,
                  color: AppColors.textMuted,
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    etaLabel ?? Fmt.minutes(option.etaMinutes),
                    style: AppText.caption,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (!fits)
                  Flexible(
                    child: Text(
                      tooSmallLabel ?? 'Too small for your load',
                      style: AppText.caption.copyWith(color: AppColors.danger),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
              ],
            ),

            const SizedBox(height: AppSpacing.md),
            PrimaryButton(
              label: requestLabel ?? 'Request Transport',
              icon: Icons.local_shipping_rounded,
              onPressed: bookable ? onRequest : null,
              size: FbButtonSize.medium,
            ),
          ],
        ),
      ),
    );
  }
}
