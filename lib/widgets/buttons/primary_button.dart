import 'package:flutter/material.dart';

import 'package:farm_buddy/core/theme/app_colors.dart';
import 'package:farm_buddy/core/theme/app_spacing.dart';
import 'package:farm_buddy/core/theme/app_typography.dart';

enum FbButtonSize { large, medium }

/// The app's one loud button.
///
/// 56dp tall, full width by default, one per screen wherever possible — so a
/// farmer never has to work out which button is *the* button.
class PrimaryButton extends StatelessWidget {
  const PrimaryButton({
    super.key,
    required this.label,
    this.onPressed,
    this.icon,
    this.isLoading = false,
    this.expanded = true,
    this.size = FbButtonSize.large,
    this.tone,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool isLoading;
  final bool expanded;
  final FbButtonSize size;

  /// Overrides the fill — used sparingly (e.g. the harvest-gold group-sale CTA).
  final Color? tone;

  @override
  Widget build(BuildContext context) {
    final double height =
        size == FbButtonSize.large ? AppSpacing.ctaHeight : AppSpacing.touchTarget;
    final bool disabled = onPressed == null || isLoading;

    final Widget child = Row(
      mainAxisSize: expanded ? MainAxisSize.max : MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        if (isLoading) ...<Widget>[
          const SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2.4,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
        ] else if (icon != null) ...<Widget>[
          Icon(icon, size: 20, color: Colors.white),
          const SizedBox(width: AppSpacing.xs),
        ],
        Flexible(
          child: Text(
            label,
            style: AppText.button.copyWith(
              color: Colors.white,
              fontSize: size == FbButtonSize.large ? 17 : 15,
            ),
            // Two lines, not one: Tamil and Hindi CTAs run considerably longer
            // than their English source, and a clipped call to action is the
            // worst thing on the screen to clip.
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );

    // No extra Semantics wrapper: FilledButton already exposes the correct
    // button role, label and enabled state, and wrapping it would make a
    // screen reader announce the label twice.
    return SizedBox(
      height: height,
      width: expanded ? double.infinity : null,
      child: FilledButton(
        onPressed: disabled ? null : onPressed,
        style: FilledButton.styleFrom(
          backgroundColor: tone ?? AppColors.primary,
          disabledBackgroundColor: AppColors.borderStrong,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          shape: const RoundedRectangleBorder(borderRadius: AppRadius.rLg),
          elevation: 0,
        ),
        child: child,
      ),
    );
  }
}
