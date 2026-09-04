import 'package:flutter/material.dart';

import 'package:farm_buddy/core/theme/app_colors.dart';
import 'package:farm_buddy/widgets/illustrations/illustration_utils.dart';

/// A wide band of farmland used along the bottom of Splash and Login.
/// Layered hills with converging furrows give the scene real depth without
/// a single gradient-heavy flourish.
class FieldScene extends StatelessWidget {
  const FieldScene({super.key, this.height = 180});

  final double height;

  @override
  Widget build(BuildContext context) {
    return ExcludeSemantics(
      child: SizedBox(
        height: height,
        width: double.infinity,
        child: CustomPaint(painter: _FieldPainter(), isComplex: true),
      ),
    );
  }
}

class _FieldPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // Authored in a 320x180 box and stretched horizontally so it always
    // reaches both edges of the phone.
    canvas.save();
    canvas.scale(size.width / 320, size.height / 180);
    final IllustrationCanvas c = IllustrationCanvas.beginBox(
      canvas,
      const Size(320, 180),
      320,
      180,
    );

    // --------------------------------------------------------- sun
    canvas.drawCircle(
      const Offset(248, 44),
      34,
      Paint()..color = AppColors.harvest.withValues(alpha: 0.14),
    );
    canvas.drawCircle(
      const Offset(248, 44),
      21,
      Paint()..color = AppColors.harvest.withValues(alpha: 0.30),
    );
    canvas.drawCircle(
      const Offset(248, 44),
      13,
      Paint()..color = AppColors.harvest,
    );

    // ------------------------------------------------------- birds
    for (final Offset o in <Offset>[
      const Offset(70, 40),
      const Offset(92, 30),
      const Offset(110, 44),
    ]) {
      canvas.drawPath(
        Path()
          ..moveTo(o.dx - 6, o.dy)
          ..quadraticBezierTo(o.dx - 3, o.dy - 4, o.dx, o.dy)
          ..quadraticBezierTo(o.dx + 3, o.dy - 4, o.dx + 6, o.dy),
        Paint()
          ..color = AppColors.textMuted.withValues(alpha: 0.55)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.6
          ..strokeCap = StrokeCap.round,
      );
    }

    // ------------------------------------------------- distant hills
    canvas.drawPath(
      Path()
        ..moveTo(-10, 92)
        ..quadraticBezierTo(60, 58, 130, 88)
        ..quadraticBezierTo(210, 118, 330, 78)
        ..lineTo(330, 190)
        ..lineTo(-10, 190)
        ..close(),
      Paint()..color = AppColors.primaryLight.withValues(alpha: 0.28),
    );

    // ------------------------------------------------------- mid field
    final Path mid = Path()
      ..moveTo(-10, 116)
      ..quadraticBezierTo(90, 92, 180, 112)
      ..quadraticBezierTo(260, 128, 330, 106)
      ..lineTo(330, 190)
      ..lineTo(-10, 190)
      ..close();
    canvas.drawPath(mid, Paint()..color = AppColors.mapField);

    // Furrows on the mid field, converging towards the horizon.
    canvas.save();
    canvas.clipPath(mid);
    for (int i = 0; i < 12; i++) {
      final double topX = 40.0 + i * 20;
      final double bottomX = -60.0 + i * 42;
      canvas.drawLine(
        Offset(topX, 112),
        Offset(bottomX, 190),
        Paint()
          ..color = AppColors.mapFieldAlt
          ..strokeWidth = 2,
      );
    }
    canvas.restore();

    // ----------------------------------------------------- near field
    final Path near = Path()
      ..moveTo(-10, 150)
      ..quadraticBezierTo(80, 132, 170, 148)
      ..quadraticBezierTo(250, 162, 330, 142)
      ..lineTo(330, 190)
      ..lineTo(-10, 190)
      ..close();
    canvas.drawPath(near, Paint()..color = AppColors.primaryLight.withValues(alpha: 0.55));

    canvas.save();
    canvas.clipPath(near);
    for (int i = 0; i < 9; i++) {
      canvas.drawLine(
        Offset(-20.0 + i * 44, 190),
        Offset(30.0 + i * 34, 146),
        Paint()
          ..color = AppColors.primary.withValues(alpha: 0.22)
          ..strokeWidth = 3,
      );
    }
    canvas.restore();

    // ---------------------------------------------------------- tree
    c.softShadow(const Offset(56, 150), 40, 8);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(53, 116, 7, 34),
        const Radius.circular(3),
      ),
      Paint()..color = AppColors.soil,
    );
    canvas.drawCircle(
      const Offset(56, 108),
      22,
      Paint()..color = AppColors.primary,
    );
    canvas.drawCircle(
      const Offset(46, 100),
      14,
      Paint()..color = AppColors.primaryLight,
    );
    canvas.drawCircle(
      const Offset(68, 104),
      13,
      Paint()..color = AppColors.primaryDark.withValues(alpha: 0.85),
    );

    // ------------------------------------------------------- crop rows
    for (int i = 0; i < 7; i++) {
      final double x = 130.0 + i * 24;
      final double y = 156.0 + (i.isEven ? 0 : 5);
      c.leaf(Offset(x, y), 11, -1.6, AppColors.primaryDark.withValues(alpha: 0.75));
      c.leaf(Offset(x, y), 10, -2.4, AppColors.primary);
      c.leaf(Offset(x, y), 10, -0.8, AppColors.primary);
    }

    c.end();
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _FieldPainter oldDelegate) => false;
}
