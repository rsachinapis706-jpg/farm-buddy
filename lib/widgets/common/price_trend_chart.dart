import 'package:flutter/material.dart';

import 'package:farm_buddy/core/theme/app_colors.dart';
import 'package:farm_buddy/core/theme/app_spacing.dart';
import 'package:farm_buddy/core/theme/app_typography.dart';
import 'package:farm_buddy/core/utils/formatters.dart';

/// Seven days of price, told as a shape.
///
/// No axes, no gridlines, no legend, no tooltips. A farmer needs one thing
/// from this: is the line going up or down, and what is it worth today. The
/// last point is called out in words next to the dot so the chart is still
/// readable if the line itself means nothing to you.
class PriceTrendChart extends StatelessWidget {
  const PriceTrendChart({
    super.key,
    required this.values,
    this.height = 120,
    this.labels,
    this.lineColor = AppColors.primary,
    this.showLastValueDot = true,
    this.showDayLabels = true,
  });

  final List<double> values;
  final double height;

  /// Seven short day letters. Defaults to M T W T F S S.
  final List<String>? labels;

  final Color lineColor;
  final bool showLastValueDot;
  final bool showDayLabels;

  static const List<String> _defaultLabels = <String>[
    'M', 'T', 'W', 'T', 'F', 'S', 'S',
  ];

  @override
  Widget build(BuildContext context) {
    if (values.length < 2) return SizedBox(height: height);

    final double first = values.first;
    final double last = values.last;
    final bool up = last >= first;
    final List<String> dayLabels = labels ?? _defaultLabels;

    return Semantics(
      label: up
          ? 'Price trend rising, now ${Fmt.pricePerKg(last)}'
          : 'Price trend falling, now ${Fmt.pricePerKg(last)}',
      child: ExcludeSemantics(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            SizedBox(
              height: height,
              width: double.infinity,
              child: CustomPaint(
                painter: _TrendPainter(
                  values: values,
                  color: up ? lineColor : AppColors.earth,
                  showDot: showLastValueDot,
                ),
              ),
            ),
            if (showDayLabels) ...<Widget>[
              const SizedBox(height: AppSpacing.xs),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  for (int i = 0; i < values.length; i++)
                    Text(
                      i < dayLabels.length ? dayLabels[i] : '',
                      style: AppText.caption.copyWith(
                        fontSize: 11,
                        fontWeight: i == values.length - 1
                            ? FontWeight.w800
                            : FontWeight.w500,
                        color: i == values.length - 1
                            ? AppColors.textPrimary
                            : AppColors.textMuted,
                      ),
                    ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _TrendPainter extends CustomPainter {
  _TrendPainter({
    required this.values,
    required this.color,
    required this.showDot,
  });

  final List<double> values;
  final Color color;
  final bool showDot;

  @override
  void paint(Canvas canvas, Size size) {
    // Leave room on the right for the value bubble.
    const double rightPad = 6;
    const double topPad = 14;
    const double bottomPad = 8;
    final double w = size.width - rightPad;
    final double h = size.height - topPad - bottomPad;

    double min = values.reduce((double a, double b) => a < b ? a : b);
    double max = values.reduce((double a, double b) => a > b ? a : b);
    if (max - min < 0.001) {
      // A perfectly flat week still deserves a line through the middle.
      min -= 1;
      max += 1;
    }
    // Breathing room so the line never touches the edges.
    final double range = max - min;
    min -= range * 0.18;
    max += range * 0.18;

    final List<Offset> points = <Offset>[
      for (int i = 0; i < values.length; i++)
        Offset(
          (i / (values.length - 1)) * w,
          topPad + h - ((values[i] - min) / (max - min)) * h,
        ),
    ];

    // ------------------------------------------------ baseline hint
    canvas.drawLine(
      Offset(0, size.height - bottomPad),
      Offset(w, size.height - bottomPad),
      Paint()
        ..color = AppColors.border
        ..strokeWidth = 1,
    );

    // ----------------------------------------------- smoothed curve
    final Path line = Path()..moveTo(points.first.dx, points.first.dy);
    for (int i = 0; i < points.length - 1; i++) {
      final Offset p0 = points[i];
      final Offset p1 = points[i + 1];
      final double midX = (p0.dx + p1.dx) / 2;
      line.cubicTo(midX, p0.dy, midX, p1.dy, p1.dx, p1.dy);
    }

    // Soft fill under the line.
    final Path fill = Path.from(line)
      ..lineTo(points.last.dx, size.height - bottomPad)
      ..lineTo(points.first.dx, size.height - bottomPad)
      ..close();
    canvas.drawPath(
      fill,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: <Color>[color.withValues(alpha: 0.22), color.withValues(alpha: 0.02)],
        ).createShader(Rect.fromLTWH(0, 0, size.width, size.height)),
    );

    canvas.drawPath(
      line,
      Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );

    // ------------------------------------------- today's value dot
    if (showDot) {
      final Offset last = points.last;
      canvas.drawCircle(last, 8, Paint()..color = color.withValues(alpha: 0.16));
      canvas.drawCircle(last, 5.5, Paint()..color = Colors.white);
      canvas.drawCircle(
        last,
        5.5,
        Paint()
          ..color = color
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3,
      );

      // The number, spelled out — the chart is never the only source of truth.
      final TextPainter tp = TextPainter(
        text: TextSpan(
          text: Fmt.pricePerKg(values.last),
          style: AppText.caption.copyWith(
            fontSize: 11.5,
            fontWeight: FontWeight.w800,
            color: color,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();

      double bx = last.dx - tp.width - 4;
      if (bx < 0) bx = 0;
      final double by = (last.dy - tp.height - 12).clamp(0.0, size.height).toDouble();

      final RRect bubble = RRect.fromRectAndRadius(
        Rect.fromLTWH(bx - 5, by - 3, tp.width + 10, tp.height + 6),
        const Radius.circular(6),
      );
      canvas.drawRRect(bubble, Paint()..color = Colors.white);
      canvas.drawRRect(
        bubble,
        Paint()
          ..color = color.withValues(alpha: 0.30)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1,
      );
      tp.paint(canvas, Offset(bx, by));
    }
  }

  @override
  bool shouldRepaint(covariant _TrendPainter oldDelegate) =>
      oldDelegate.values != values || oldDelegate.color != color;
}
