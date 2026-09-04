import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'package:farm_buddy/core/theme/app_colors.dart';
import 'package:farm_buddy/widgets/illustrations/illustration_utils.dart';

/// Onboarding 1 — "Know Your Crop".
/// A farmer holding a magnifier over a tomato plant. Layered flat shapes with
/// one light source (upper left) so the scene reads as gently dimensional
/// rather than sticker-flat.
class CropInspectIllustration extends StatelessWidget {
  const CropInspectIllustration({super.key, this.size = 240});

  final double size;

  @override
  Widget build(BuildContext context) {
    return ExcludeSemantics(
      child: SizedBox(
        width: size,
        height: size,
        child: CustomPaint(painter: _CropInspectPainter(), isComplex: true),
      ),
    );
  }
}

class _CropInspectPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final IllustrationCanvas c = IllustrationCanvas.begin(canvas, size, 200);

    // ------------------------------------------------------- backdrop
    canvas.drawCircle(
      const Offset(100, 96),
      86,
      Paint()..color = AppColors.primarySofter,
    );
    canvas.drawCircle(
      const Offset(100, 96),
      86,
      Paint()
        ..color = AppColors.primarySoft
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );

    // Sun disc, low and warm.
    canvas.drawCircle(
      const Offset(150, 48),
      16,
      Paint()..color = AppColors.harvestSoft,
    );
    canvas.drawCircle(
      const Offset(150, 48),
      10,
      Paint()..color = AppColors.harvest.withValues(alpha: 0.85),
    );

    // ---------------------------------------------------------- ground
    final Path ground = Path()
      ..moveTo(18, 150)
      ..quadraticBezierTo(100, 132, 182, 150)
      ..lineTo(182, 178)
      ..lineTo(18, 178)
      ..close();
    canvas.drawPath(ground, Paint()..color = AppColors.mapField);
    canvas.drawPath(
      Path()
        ..moveTo(18, 150)
        ..quadraticBezierTo(100, 132, 182, 150),
      Paint()
        ..color = AppColors.primaryLight.withValues(alpha: 0.45)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5,
    );

    // Furrow hints.
    for (int i = 0; i < 3; i++) {
      final double y = 158.0 + i * 7;
      canvas.drawLine(
        Offset(30 + i * 6, y),
        Offset(170 - i * 6, y),
        Paint()
          ..color = AppColors.mapFieldAlt
          ..strokeWidth = 1.6
          ..strokeCap = StrokeCap.round,
      );
    }

    // ----------------------------------------------------- tomato plant
    c.softShadow(const Offset(126, 152), 30, 7);

    // Soil mound.
    canvas.drawPath(
      Path()
        ..moveTo(104, 152)
        ..quadraticBezierTo(126, 140, 148, 152)
        ..close(),
      Paint()..color = AppColors.soil.withValues(alpha: 0.75),
    );

    // Stem.
    canvas.drawPath(
      Path()
        ..moveTo(126, 150)
        ..cubicTo(124, 128, 128, 110, 126, 92),
      Paint()
        ..color = AppColors.primaryDark
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4
        ..strokeCap = StrokeCap.round,
    );

    // Leaves — three, each with a lit face and a shaded underside.
    c.leaf(const Offset(126, 128), 30, -0.55, AppColors.primary);
    c.leaf(const Offset(126, 112), 26, 0.62, AppColors.primaryLight);
    c.leaf(const Offset(126, 96), 22, -0.30, AppColors.primary);

    // Tomatoes.
    c.fruit(const Offset(115, 124), 9, const Color(0xFFD9452F));
    c.fruit(const Offset(139, 110), 7.5, const Color(0xFFE4573C));

    // --------------------------------------------------------- farmer
    c.softShadow(const Offset(64, 154), 26, 6);

    // Legs.
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(56, 120, 8, 32),
        const Radius.circular(4),
      ),
      Paint()..color = const Color(0xFF6E6152),
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(68, 120, 8, 32),
        const Radius.circular(4),
      ),
      Paint()..color = const Color(0xFF5C5145),
    );

    // Kurta body with a shaded right side.
    final Path body = Path()
      ..moveTo(50, 126)
      ..lineTo(54, 84)
      ..quadraticBezierTo(66, 76, 78, 84)
      ..lineTo(82, 126)
      ..close();
    canvas.drawPath(body, Paint()..color = AppColors.sky);
    canvas.drawPath(
      Path()
        ..moveTo(66, 80)
        ..lineTo(78, 84)
        ..lineTo(82, 126)
        ..lineTo(66, 126)
        ..close(),
      Paint()..color = AppColors.sky.withValues(alpha: 0.75),
    );

    // Head + simple turban.
    canvas.drawCircle(const Offset(66, 68), 13, Paint()..color = kSkin);
    canvas.drawPath(
      Path()
        ..moveTo(52, 64)
        ..quadraticBezierTo(66, 46, 80, 64)
        ..quadraticBezierTo(66, 58, 52, 64)
        ..close(),
      Paint()..color = AppColors.earth,
    );
    canvas.drawCircle(const Offset(62, 70), 1.7, Paint()..color = kInk);
    canvas.drawArc(
      const Rect.fromLTWH(60, 70, 10, 8),
      0.2,
      2.4,
      false,
      Paint()
        ..color = kInk
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.4
        ..strokeCap = StrokeCap.round,
    );

    // Arm reaching towards the plant, holding the magnifier.
    canvas.drawPath(
      Path()
        ..moveTo(76, 92)
        ..quadraticBezierTo(96, 92, 104, 104),
      Paint()
        ..color = kSkin
        ..style = PaintingStyle.stroke
        ..strokeWidth = 7
        ..strokeCap = StrokeCap.round,
    );

    // ------------------------------------------------------ magnifier
    const Offset lens = Offset(122, 116);
    // Handle first so the lens sits on top of it.
    canvas.save();
    canvas.translate(lens.dx, lens.dy);
    canvas.rotate(math.pi * 0.72);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(-3.5, 20, 7, 20),
        const Radius.circular(3.5),
      ),
      Paint()..color = AppColors.soil,
    );
    canvas.restore();

    canvas.drawCircle(
      lens,
      21,
      Paint()..color = Colors.white.withValues(alpha: 0.62),
    );
    canvas.drawCircle(
      lens,
      21,
      Paint()
        ..color = AppColors.primaryDark
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4.5,
    );
    // Glass glint.
    canvas.drawPath(
      Path()
        ..moveTo(112, 108)
        ..quadraticBezierTo(116, 102, 124, 102),
      Paint()
        ..color = Colors.white
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3
        ..strokeCap = StrokeCap.round,
    );

    c.end();
  }

  @override
  bool shouldRepaint(covariant _CropInspectPainter oldDelegate) => false;
}
