import 'package:flutter/material.dart';

import 'package:farm_buddy/core/theme/app_colors.dart';
import 'package:farm_buddy/core/theme/app_spacing.dart';

/// A 48x48 circular icon target. Always carries a tooltip so screen readers
/// and long-press both announce what it does.
class FbIconButton extends StatelessWidget {
  const FbIconButton({
    super.key,
    required this.icon,
    required this.tooltip,
    this.onPressed,
    this.background,
    this.foreground,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback? onPressed;
  final Color? background;
  final Color? foreground;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color: background ?? AppColors.surface,
        shape: const CircleBorder(
          side: BorderSide(color: AppColors.border),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onPressed,
          child: SizedBox(
            width: AppSpacing.touchTarget,
            height: AppSpacing.touchTarget,
            child: Icon(
              icon,
              size: 21,
              color: foreground ?? AppColors.textPrimary,
            ),
          ),
        ),
      ),
    );
  }
}
