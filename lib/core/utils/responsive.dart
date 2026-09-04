import 'package:flutter/material.dart';

import 'package:farm_buddy/core/theme/app_spacing.dart';

/// Keeps content readable on tablets and foldables without ever letting a
/// phone layout go edge-to-edge-ugly. Every screen body wraps in this.
class ResponsiveCenter extends StatelessWidget {
  const ResponsiveCenter({
    super.key,
    required this.child,
    this.maxWidth = 560,
    this.padding = AppSpacing.screen,
  });

  final Widget child;
  final double maxWidth;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: Padding(padding: padding, child: child),
      ),
    );
  }
}

/// A sliver-friendly version for `CustomScrollView` bodies.
class ResponsiveSliverPadding extends StatelessWidget {
  const ResponsiveSliverPadding({
    super.key,
    required this.sliver,
    this.maxWidth = 560,
    this.padding = AppSpacing.screen,
  });

  final Widget sliver;
  final double maxWidth;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    final double width = MediaQuery.sizeOf(context).width;
    final double sideGutter =
        width > maxWidth ? (width - maxWidth) / 2 : padding.left;
    return SliverPadding(
      padding: EdgeInsets.only(
        left: sideGutter,
        right: sideGutter,
        top: padding.top,
        bottom: padding.bottom,
      ),
      sliver: sliver,
    );
  }
}

extension ContextSize on BuildContext {
  double get screenW => MediaQuery.sizeOf(this).width;
  double get screenH => MediaQuery.sizeOf(this).height;

  /// True on short devices (small phones, landscape) where hero art must shrink.
  bool get isCompactHeight => MediaQuery.sizeOf(this).height < 700;

  /// True on very narrow devices where 2-up grids should stack.
  bool get isNarrow => MediaQuery.sizeOf(this).width < 340;

  /// User has bumped the system font size — give layouts more room.
  bool get isLargeText => MediaQuery.textScalerOf(this).scale(16) > 19;
}
