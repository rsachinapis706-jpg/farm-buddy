import 'package:flutter/material.dart';

import 'package:farm_buddy/core/theme/app_colors.dart';
import 'package:farm_buddy/widgets/illustrations/illustration_utils.dart';

/// Onboarding 2 — "Find the Right Market".
/// A market stall with a striped canopy, crates of produce and a price tag.
class MarketIllustration extends StatelessWidget {
  const MarketIllustration({super.key, this.size = 240});

  final double size;

  @override
  Widget build(BuildContext context) {
    return ExcludeSemantics(
      child: SizedBox(
        width: size,
        height: size,
        child: CustomPaint(painter: _MarketPainter(), isComplex: true),
      ),
    );
  }
}

class _MarketPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final IllustrationCanvas c = IllustrationCanvas.begin(canvas, size, 200);

    // ------------------------------------------------------- backdrop
    canvas.drawCircle(
      const Offset(100, 96),
      86,
      Paint()..color = AppColors.harvestSoft.withValues(alpha: 0.75),
    );

    // Distant stalls, faded — depth by atmosphere, not by blur.
    for (final double x in <double>[36, 158]) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(x - 16, 74, 32, 44),
          const Radius.circular(4),
        ),
        Paint()..color = AppColors.harvest.withValues(alpha: 0.18),
      );
    }

    // ---------------------------------------------------------- ground
    canvas.drawPath(
      Path()
        ..moveTo(14, 150)
        ..quadraticBezierTo(100, 138, 186, 150)
        ..lineTo(186, 180)
        ..lineTo(14, 180)
        ..close(),
      Paint()..color = AppColors.surfaceAlt,
    );

    // ------------------------------------------------------ stall posts
    for (final double x in <double>[48, 148]) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(x - 3, 62, 6, 84),
          const Radius.circular(3),
        ),
        Paint()..color = AppColors.soil,
      );
    }

    // ---------------------------------------------------------- canopy
    // Scalloped edge, striped — the shape everyone recognises as a market.
    final Path canopy = Path()
      ..moveTo(34, 62)
      ..lineTo(100, 34)
      ..lineTo(166, 62)
      ..lineTo(166, 72);
    for (int i = 0; i < 8; i++) {
      final double x = 166 - i * 16.5;
      canopy.arcToPoint(
        Offset(x - 16.5, 72),
        radius: const Radius.circular(9),
        clockwise: false,
      );
    }
    canopy
      ..lineTo(34, 62)
      ..close();
    canvas.drawPath(canopy, Paint()..color = kCloth);

    // Stripes, clipped to the canopy.
    canvas.save();
    canvas.clipPath(canopy);
    for (int i = 0; i < 7; i++) {
      canvas.drawPath(
        Path()
          ..moveTo(100 + (i - 3.5) * 9, 34)
          ..lineTo(100 + (i - 3.5) * 19, 76)
          ..lineTo(100 + (i - 3.5) * 19 + 9, 76)
          ..lineTo(100 + (i - 3.5) * 9 + 5, 34)
          ..close(),
        Paint()..color = AppColors.earth.withValues(alpha: 0.85),
      );
    }
    canvas.restore();

    // Canopy underside shadow gives the roof thickness.
    canvas.drawPath(
      Path()
        ..moveTo(34, 62)
        ..lineTo(166, 62)
        ..lineTo(166, 68)
        ..lineTo(34, 68)
        ..close(),
      Paint()..color = AppColors.textPrimary.withValues(alpha: 0.10),
    );

    // --------------------------------------------------------- counter
    c.softShadow(const Offset(100, 148), 110, 12);
    canvas.drawPath(
      Path()
        ..moveTo(44, 118)
        ..lineTo(156, 118)
        ..lineTo(164, 110)
        ..lineTo(52, 110)
        ..close(),
      Paint()..color = const Color(0xFFD9B282),
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(44, 118, 112, 28),
        const Radius.circular(3),
      ),
      Paint()..color = const Color(0xFFB98A57),
    );

    // ---------------------------------------------------------- crates
    c.crate(const Offset(52, 92), 30, 20);
    c.crate(const Offset(92, 92), 30, 20, color: const Color(0xFFCFA872));
    c.crate(const Offset(120, 122), 28, 20);

    // Produce heaped in the crates.
    c.fruit(const Offset(60, 90), 7, const Color(0xFFD9452F));
    c.fruit(const Offset(72, 88), 7.5, const Color(0xFFE4573C));
    c.fruit(const Offset(83, 91), 6.5, const Color(0xFFD9452F));

    c.fruit(const Offset(100, 89), 7, AppColors.harvest);
    c.fruit(const Offset(112, 88), 7.5, const Color(0xFFEBB457));
    c.fruit(const Offset(122, 91), 6.5, AppColors.harvest);

    for (int i = 0; i < 3; i++) {
      c.leaf(Offset(126.0 + i * 8, 120), 12, -0.5, AppColors.primaryLight);
    }

    // ------------------------------------------------------- price tag
    // The single most important object in the scene: what you get paid.
    canvas.drawLine(
      const Offset(150, 68),
      const Offset(150, 82),
      Paint()
        ..color = AppColors.soil
        ..strokeWidth = 1.6,
    );
    final RRect tag = RRect.fromRectAndRadius(
      const Rect.fromLTWH(126, 82, 48, 30),
      const Radius.circular(8),
    );
    canvas.drawRRect(
      tag.shift(const Offset(0, 2)),
      Paint()..color = AppColors.textPrimary.withValues(alpha: 0.12),
    );
    canvas.drawRRect(tag, Paint()..color = AppColors.surface);
    canvas.drawRRect(
      tag,
      Paint()
        ..color = AppColors.primary
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5,
    );
    c.text(
      '₹32',
      const Offset(150, 93),
      fontSize: 15,
      color: AppColors.primaryDark,
      weight: FontWeight.w800,
    );
    c.text(
      'per kg',
      const Offset(150, 105),
      fontSize: 8,
      color: AppColors.textSecondary,
      weight: FontWeight.w600,
    );

    c.end();
  }

  @override
  bool shouldRepaint(covariant _MarketPainter oldDelegate) => false;
}
