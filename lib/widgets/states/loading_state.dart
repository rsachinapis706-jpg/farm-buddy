import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'package:farm_buddy/core/theme/app_colors.dart';
import 'package:farm_buddy/core/theme/app_spacing.dart';
import 'package:farm_buddy/core/theme/app_typography.dart';

/// A calm waiting state: three leaves turning slowly around a seed.
/// No percentage, no spinner-of-doom — just "we are working on it".
class LoadingState extends StatelessWidget {
  const LoadingState({super.key, this.message, this.height = 220});

  final String? message;
  final double height;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      width: double.infinity,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          const LeafSpinner(size: 56),
          if (message != null) ...<Widget>[
            const SizedBox(height: AppSpacing.md),
            Padding(
              padding: AppSpacing.screen,
              child: Text(
                message!,
                style: AppText.bodySm,
                textAlign: TextAlign.center,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// The brand's loading mark. Also used inline inside cards.
class LeafSpinner extends StatefulWidget {
  const LeafSpinner({super.key, this.size = 40});

  final double size;

  @override
  State<LeafSpinner> createState() => _LeafSpinnerState();
}

class _LeafSpinnerState extends State<LeafSpinner>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1400),
  )..repeat();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ExcludeSemantics(
      child: SizedBox(
        width: widget.size,
        height: widget.size,
        child: AnimatedBuilder(
          animation: _controller,
          builder: (BuildContext context, Widget? child) {
            return CustomPaint(
              painter: _LeafSpinnerPainter(_controller.value),
            );
          },
        ),
      ),
    );
  }
}

class _LeafSpinnerPainter extends CustomPainter {
  _LeafSpinnerPainter(this.t);

  final double t;

  @override
  void paint(Canvas canvas, Size size) {
    final Offset center = Offset(size.width / 2, size.height / 2);
    final double r = size.width / 2;

    canvas.drawCircle(
      center,
      r * 0.22,
      Paint()..color = AppColors.harvest,
    );

    for (int i = 0; i < 3; i++) {
      final double angle = (t * 2 * math.pi) + (i * 2 * math.pi / 3);
      // Each leaf breathes slightly out of phase for a living, organic feel.
      final double pulse =
          0.82 + 0.18 * math.sin((t * 2 * math.pi) + i * 1.2);

      canvas.save();
      canvas.translate(center.dx, center.dy);
      canvas.rotate(angle);
      final double len = r * 0.86 * pulse;
      canvas.drawPath(
        Path()
          ..moveTo(r * 0.24, 0)
          ..quadraticBezierTo(len * 0.6, -len * 0.34, len, 0)
          ..quadraticBezierTo(len * 0.6, len * 0.34, r * 0.24, 0)
          ..close(),
        Paint()
          ..color = <Color>[
            AppColors.primary,
            AppColors.primaryLight,
            AppColors.primaryDark,
          ][i],
      );
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant _LeafSpinnerPainter oldDelegate) =>
      oldDelegate.t != t;
}
