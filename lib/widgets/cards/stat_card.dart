import 'package:flutter/material.dart';

import 'package:farm_buddy/core/theme/app_colors.dart';
import 'package:farm_buddy/core/theme/app_spacing.dart';
import 'package:farm_buddy/core/theme/app_typography.dart';

/// A single number with its label. Used in rows of two or three.
class StatCard extends StatelessWidget {
  const StatCard({
    super.key,
    required this.label,
    required this.value,
    this.icon,
    this.tone,
    this.caption,
    this.compact = false,
  });

  final String label;
  final String value;
  final IconData? icon;
  final Color? tone;
  final String? caption;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final Color accent = tone ?? AppColors.primary;

    return Container(
      padding: EdgeInsets.all(compact ? AppSpacing.sm : AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadius.rMd,
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Row(
            children: <Widget>[
              if (icon != null) ...<Widget>[
                Icon(icon, size: 15, color: accent),
                const SizedBox(width: 5),
              ],
              Expanded(
                child: Text(
                  label,
                  style: AppText.caption,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xxs),
          Text(
            value,
            style: (compact ? AppText.priceSm : AppText.priceMd)
                .copyWith(color: AppColors.textPrimary),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          if (caption != null) ...<Widget>[
            const SizedBox(height: 2),
            Text(
              caption!,
              style: AppText.caption.copyWith(color: accent),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ],
      ),
    );
  }
}

/// A label/value row used inside detail cards — the "your money, step by step"
/// breakdown on Market Details is a stack of these.
class StatRow extends StatelessWidget {
  const StatRow({
    super.key,
    required this.label,
    required this.value,
    this.icon,
    this.valueColor,
    this.emphasise = false,
    this.negative = false,
  });

  final String label;
  final String value;
  final IconData? icon;
  final Color? valueColor;
  final bool emphasise;

  /// Renders the value as a deduction, with a minus sign and a muted tone.
  final bool negative;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          if (icon != null) ...<Widget>[
            Icon(icon, size: 18, color: AppColors.textMuted),
            const SizedBox(width: AppSpacing.xs),
          ],
          Expanded(
            child: Text(
              label,
              style: emphasise ? AppText.bodyStrong : AppText.bodySm,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: AppSpacing.xs),
          Text(
            negative ? '− $value' : value,
            style: (emphasise ? AppText.priceSm : AppText.bodySmStrong).copyWith(
              color: valueColor ??
                  (negative ? AppColors.textSecondary : AppColors.textPrimary),
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
