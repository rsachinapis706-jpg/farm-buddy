import 'package:flutter/material.dart';

import 'package:farm_buddy/core/theme/app_colors.dart';
import 'package:farm_buddy/core/theme/app_spacing.dart';

/// The one surface every card in Farm Buddy is built on.
///
/// A hairline border plus a low soft shadow — the card lifts off the cream
/// background just enough to feel physical, never enough to feel like a
/// dashboard widget.
class FbCard extends StatelessWidget {
  const FbCard({
    super.key,
    required this.child,
    this.padding = AppSpacing.card,
    this.onTap,
    this.background = AppColors.surface,
    this.borderColor,
    this.radius = AppRadius.rLg,
    this.shadows,
    this.gradient,
    this.clipContent = false,
  });

  final Widget child;
  final EdgeInsets padding;
  final VoidCallback? onTap;
  final Color background;
  final Color? borderColor;
  final BorderRadius radius;
  final List<BoxShadow>? shadows;
  final Gradient? gradient;

  /// Set when the card paints artwork that must not spill past its corners.
  final bool clipContent;

  @override
  Widget build(BuildContext context) {
    final Widget content = Padding(padding: padding, child: child);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: gradient == null ? background : null,
        gradient: gradient,
        borderRadius: radius,
        border: Border.all(color: borderColor ?? AppColors.border),
        boxShadow: shadows ?? AppShadows.card,
      ),
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          onTap: onTap,
          borderRadius: radius,
          child: clipContent
              ? ClipRRect(borderRadius: radius, child: content)
              : content,
        ),
      ),
    );
  }
}
