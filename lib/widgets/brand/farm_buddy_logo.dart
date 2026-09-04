import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'package:farm_buddy/core/theme/app_colors.dart';
import 'package:farm_buddy/core/theme/app_spacing.dart';

/// The Farm Buddy mark.
///
/// One idea, one shape: a **leaf whose base tapers into a location pin**, with
/// a gold seed at its heart. Growth + place + the thing you plant, in a single
/// silhouette that still reads at 24px on a header or as a launcher icon.
///
/// Drawn with a [CustomPainter] so it is razor sharp at every density and adds
/// zero bytes of assets to the bundle.
class FarmBuddyLogo extends StatelessWidget {
  const FarmBuddyLogo({
    super.key,
    this.size = 96,
    this.showWordmark = false,
    this.onCream = false,
  });

  final double size;

  /// Renders the wordmark beneath the mark.
  final bool showWordmark;

  /// Places the mark on a rounded cream tile — the app-icon treatment.
  final bool onCream;

  @override
  Widget build(BuildContext context) {
    final Widget mark = SizedBox(
      width: size,
      height: size,
      child: CustomPaint(painter: _LogoPainter(), isComplex: true),
    );

    final Widget framed = onCream
        ? Container(
            width: size * 1.34,
            height: size * 1.34,
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(size * 0.30),
              boxShadow: AppShadows.raised,
              border: Border.all(color: AppColors.border),
            ),
            alignment: Alignment.center,
            child: mark,
          )
        : mark;

    if (!showWordmark) {
      return ExcludeSemantics(child: framed);
    }

    return Semantics(
      label: 'Farm Buddy',
      child: ExcludeSemantics(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            framed,
            SizedBox(height: size * 0.22),
            FarmBuddyWordmark(fontSize: size * 0.30),
          ],
        ),
      ),
    );
  }
}

/// "FARM BUDDY" set in the brand's letter-spacing, with the two words weighted
/// differently so the lockup has a centre of gravity.
class FarmBuddyWordmark extends StatelessWidget {
  const FarmBuddyWordmark({
    super.key,
    this.fontSize = 28,
    this.color = AppColors.textPrimary,
  });

  final double fontSize;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Text.rich(
      TextSpan(
        children: <InlineSpan>[
          TextSpan(
            text: 'FARM',
            style: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.w800,
              color: color,
              letterSpacing: fontSize * 0.10,
              height: 1.1,
            ),
          ),
          TextSpan(
            text: ' BUDDY',
            style: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.w400,
              color: color,
              letterSpacing: fontSize * 0.10,
              height: 1.1,
            ),
          ),
        ],
      ),
      textAlign: TextAlign.center,
    );
  }
}

class _LogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final double s = math.min(size.width, size.height);
    final double dx = (size.width - s) / 2;
    final double dy = (size.height - s) / 2;

    // Work in a 100x100 space, then scale.
    canvas.save();
    canvas.translate(dx, dy);
    canvas.scale(s / 100);

    // ---------------------------------------------------- ground shadow
    canvas.drawOval(
      const Rect.fromLTWH(28, 88, 44, 10),
      Paint()
        ..color = const Color(0x1A14301F)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4),
    );

    // ------------------------------------------------------- leaf / pin
    // Bottom tip at (50, 94) is the pin point; the body swells into a leaf.
    final Path leaf = Path()
      ..moveTo(50, 94)
      ..cubicTo(24, 70, 12, 54, 12, 40)
      ..cubicTo(12, 20, 29, 6, 50, 6)
      ..cubicTo(71, 6, 88, 20, 88, 40)
      ..cubicTo(88, 54, 76, 70, 50, 94)
      ..close();

    canvas.drawPath(
      leaf,
      Paint()
        ..shader = AppColors.leafSheen.createShader(
          const Rect.fromLTWH(12, 6, 76, 88),
        ),
    );

    // Lit face: a lighter wedge on the upper-left gives the mark volume
    // without a single extra colour.
    final Path highlight = Path()
      ..moveTo(50, 90)
      ..cubicTo(30, 68, 20, 54, 20, 40)
      ..cubicTo(20, 24, 33, 12, 50, 11)
      ..close();
    canvas.drawPath(
      highlight,
      Paint()..color = Colors.white.withValues(alpha: 0.13),
    );

    // Shaded right flank for depth.
    final Path shade = Path()
      ..moveTo(50, 94)
      ..cubicTo(74, 71, 86, 55, 86, 41)
      ..cubicTo(86, 28, 76, 16, 62, 10)
      ..cubicTo(74, 20, 78, 30, 78, 42)
      ..cubicTo(78, 56, 68, 72, 50, 94)
      ..close();
    canvas.drawPath(
      shade,
      Paint()..color = AppColors.primaryDeep.withValues(alpha: 0.16),
    );

    // ------------------------------------------------------------ midrib
    canvas.drawPath(
      Path()
        ..moveTo(50, 88)
        ..cubicTo(50, 66, 50, 44, 50, 22),
      Paint()
        ..color = Colors.white.withValues(alpha: 0.28)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.4
        ..strokeCap = StrokeCap.round,
    );

    // ------------------------------------------------- gold seed / centre
    canvas.drawCircle(
      const Offset(50, 40),
      13.5,
      Paint()..color = AppColors.background,
    );
    canvas.drawCircle(
      const Offset(50, 40),
      10.5,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: <Color>[Color(0xFFF0BE5E), AppColors.harvest],
        ).createShader(const Rect.fromLTWH(39.5, 29.5, 21, 21)),
    );
    // Tiny sprout inside the seed — the "buddy" doing the helping.
    canvas.drawPath(
      Path()
        ..moveTo(50, 45)
        ..lineTo(50, 37)
        ..moveTo(50, 39)
        ..cubicTo(46, 36, 45, 34, 45.5, 32.5)
        ..moveTo(50, 40.5)
        ..cubicTo(54, 37.5, 55, 35.5, 54.5, 34),
      Paint()
        ..color = AppColors.primaryDark
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.8
        ..strokeCap = StrokeCap.round,
    );

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _LogoPainter oldDelegate) => false;
}
