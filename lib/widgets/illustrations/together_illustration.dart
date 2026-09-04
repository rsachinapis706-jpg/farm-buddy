import 'package:flutter/material.dart';

import 'package:farm_buddy/core/theme/app_colors.dart';
import 'package:farm_buddy/widgets/illustrations/illustration_utils.dart';

/// Onboarding 3 — "Move Together".
/// Two farmers loading a shared mini truck. The truck is drawn with a lit
/// front face and a shaded flank so it reads as a solid object.
class TogetherIllustration extends StatelessWidget {
  const TogetherIllustration({super.key, this.size = 240});

  final double size;

  @override
  Widget build(BuildContext context) {
    return ExcludeSemantics(
      child: SizedBox(
        width: size,
        height: size,
        child: CustomPaint(painter: _TogetherPainter(), isComplex: true),
      ),
    );
  }
}

class _TogetherPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final IllustrationCanvas c = IllustrationCanvas.begin(canvas, size, 200);

    // ------------------------------------------------------- backdrop
    canvas.drawCircle(
      const Offset(100, 96),
      86,
      Paint()..color = AppColors.primarySofter,
    );

    // Rolling field behind, so the trip clearly starts at a farm.
    canvas.drawPath(
      Path()
        ..moveTo(14, 118)
        ..quadraticBezierTo(58, 92, 104, 114)
        ..quadraticBezierTo(146, 132, 186, 112)
        ..lineTo(186, 150)
        ..lineTo(14, 150)
        ..close(),
      Paint()..color = AppColors.mapField,
    );

    // ------------------------------------------------------------ road
    canvas.drawPath(
      Path()
        ..moveTo(10, 152)
        ..lineTo(190, 152)
        ..lineTo(190, 172)
        ..lineTo(10, 172)
        ..close(),
      Paint()..color = AppColors.surfaceAlt,
    );
    for (int i = 0; i < 5; i++) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(20.0 + i * 38, 161, 18, 3),
          const Radius.circular(2),
        ),
        Paint()..color = AppColors.borderStrong,
      );
    }

    // ----------------------------------------------------------- truck
    c.softShadow(const Offset(118, 150), 108, 12);

    // Cargo box — front (lit) plus a darker top plane.
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(70, 88, 66, 46),
        const Radius.circular(5),
      ),
      Paint()..color = kCloth,
    );
    canvas.drawPath(
      Path()
        ..moveTo(70, 88)
        ..lineTo(78, 80)
        ..lineTo(144, 80)
        ..lineTo(136, 88)
        ..close(),
      Paint()..color = const Color(0xFFE4DDCB),
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(70, 116, 66, 18),
        const Radius.circular(4),
      ),
      Paint()..color = AppColors.primarySoft,
    );

    // Cabin.
    canvas.drawPath(
      Path()
        ..moveTo(136, 100)
        ..lineTo(160, 100)
        ..quadraticBezierTo(168, 100, 170, 110)
        ..lineTo(172, 134)
        ..lineTo(136, 134)
        ..close(),
      Paint()..color = AppColors.primary,
    );
    // Shaded nose.
    canvas.drawPath(
      Path()
        ..moveTo(160, 100)
        ..quadraticBezierTo(168, 100, 170, 110)
        ..lineTo(172, 134)
        ..lineTo(158, 134)
        ..close(),
      Paint()..color = AppColors.primaryDark,
    );
    // Windscreen.
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(141, 104, 20, 14),
        const Radius.circular(3),
      ),
      Paint()..color = AppColors.skySoft,
    );
    canvas.drawPath(
      Path()
        ..moveTo(141, 118)
        ..lineTo(155, 104)
        ..lineTo(161, 104)
        ..lineTo(147, 118)
        ..close(),
      Paint()..color = Colors.white.withValues(alpha: 0.55),
    );

    // Wheels with hubs.
    for (final double x in <double>[92, 158]) {
      canvas.drawCircle(Offset(x, 138), 12, Paint()..color = const Color(0xFF3A3A3A));
      canvas.drawCircle(Offset(x, 138), 5, Paint()..color = AppColors.surfaceAlt);
    }

    // ---------------------------------------------------------- farmers
    _farmer(canvas, c, const Offset(38, 96), AppColors.earth, kSkin);
    _farmer(canvas, c, const Offset(58, 100), AppColors.sky, kSkinShade);

    // A crate being carried between them.
    c.crate(const Offset(38, 116), 26, 16, color: const Color(0xFFCFA872));
    c.fruit(const Offset(45, 114), 5.5, const Color(0xFFD9452F));
    c.fruit(const Offset(56, 114), 5, const Color(0xFFE4573C));

    c.end();
  }

  void _farmer(
    Canvas canvas,
    IllustrationCanvas c,
    Offset feet,
    Color cloth,
    Color skin,
  ) {
    c.softShadow(Offset(feet.dx + 6, feet.dy + 56), 24, 6);

    // Legs.
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(feet.dx, feet.dy + 30, 6, 26),
        const Radius.circular(3),
      ),
      Paint()..color = const Color(0xFF6E6152),
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(feet.dx + 9, feet.dy + 30, 6, 26),
        const Radius.circular(3),
      ),
      Paint()..color = const Color(0xFF5C5145),
    );

    // Body.
    canvas.drawPath(
      Path()
        ..moveTo(feet.dx - 4, feet.dy + 34)
        ..lineTo(feet.dx - 1, feet.dy + 4)
        ..quadraticBezierTo(feet.dx + 7, feet.dy - 2, feet.dx + 16, feet.dy + 4)
        ..lineTo(feet.dx + 19, feet.dy + 34)
        ..close(),
      Paint()..color = cloth,
    );
    canvas.drawPath(
      Path()
        ..moveTo(feet.dx + 7, feet.dy + 1)
        ..lineTo(feet.dx + 16, feet.dy + 4)
        ..lineTo(feet.dx + 19, feet.dy + 34)
        ..lineTo(feet.dx + 7, feet.dy + 34)
        ..close(),
      Paint()..color = Colors.black.withValues(alpha: 0.10),
    );

    // Head.
    canvas.drawCircle(Offset(feet.dx + 7, feet.dy - 8), 10, Paint()..color = skin);
    canvas.drawPath(
      Path()
        ..moveTo(feet.dx - 4, feet.dy - 11)
        ..quadraticBezierTo(feet.dx + 7, feet.dy - 26, feet.dx + 18, feet.dy - 11)
        ..quadraticBezierTo(feet.dx + 7, feet.dy - 16, feet.dx - 4, feet.dy - 11)
        ..close(),
      Paint()..color = AppColors.harvest,
    );
    canvas.drawCircle(
      Offset(feet.dx + 4, feet.dy - 7),
      1.4,
      Paint()..color = kInk,
    );
    canvas.drawCircle(
      Offset(feet.dx + 11, feet.dy - 7),
      1.4,
      Paint()..color = kInk,
    );

    // Arm out towards the crate.
    canvas.drawLine(
      Offset(feet.dx + 16, feet.dy + 12),
      Offset(feet.dx + 26, feet.dy + 20),
      Paint()
        ..color = skin
        ..strokeWidth = 5.5
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(covariant _TogetherPainter oldDelegate) => false;
}
