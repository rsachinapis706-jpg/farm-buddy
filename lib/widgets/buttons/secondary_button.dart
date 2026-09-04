import 'package:flutter/material.dart';

import 'package:farm_buddy/core/theme/app_colors.dart';
import 'package:farm_buddy/core/theme/app_spacing.dart';
import 'package:farm_buddy/core/theme/app_typography.dart';
import 'package:farm_buddy/widgets/buttons/primary_button.dart' show FbButtonSize;

/// The quiet companion to [PrimaryButton]: same size and shape, outlined so it
/// never competes for attention.
class SecondaryButton extends StatelessWidget {
  const SecondaryButton({
    super.key,
    required this.label,
    this.onPressed,
    this.icon,
    this.expanded = true,
    this.size = FbButtonSize.large,
    this.foreground,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool expanded;
  final FbButtonSize size;
  final Color? foreground;

  @override
  Widget build(BuildContext context) {
    final double height =
        size == FbButtonSize.large ? AppSpacing.ctaHeight : AppSpacing.touchTarget;
    final Color fg = foreground ?? AppColors.textPrimary;

    return SizedBox(
      height: height,
      width: expanded ? double.infinity : null,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          backgroundColor: AppColors.surface,
          foregroundColor: fg,
          // A disabled SecondaryButton is often a *state* ("Connected"), not a
          // dead control, so it keeps its colour instead of greying out.
          disabledForegroundColor: fg,
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          side: const BorderSide(color: AppColors.borderStrong, width: 1.5),
          shape: const RoundedRectangleBorder(borderRadius: AppRadius.rLg),
        ),
        child: Row(
          mainAxisSize: expanded ? MainAxisSize.max : MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            if (icon != null) ...<Widget>[
              Icon(icon, size: 20, color: fg),
              const SizedBox(width: AppSpacing.xs),
            ],
            Flexible(
              child: Text(
                label,
                style: AppText.button.copyWith(
                  color: fg,
                  fontSize: size == FbButtonSize.large ? 17 : 15,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
