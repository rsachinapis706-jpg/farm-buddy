import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'package:farm_buddy/core/theme/app_colors.dart';

/// Shared ink colours for the illustration set. One warm skin tone, one soft
/// ink — used across every scene so the cast looks like the same people.
const Color kSkin = Color(0xFFD9A06B);
const Color kSkinShade = Color(0xFFC08A56);
const Color kInk = Color(0xFF3A2E22);
const Color kCloth = Color(0xFFF4EFE3);

/// Sets up a fixed design-space canvas (default 200x200) and scales it to fit
/// whatever box the widget was given, so every illustration can be authored
/// with plain readable coordinates.
class IllustrationCanvas {
  IllustrationCanvas._(this._canvas);

  final Canvas _canvas;

  static IllustrationCanvas begin(Canvas canvas, Size size, double designSize) {
    canvas.save();
    final double scale = math.min(size.width, size.height) / designSize;
    final double dx = (size.width - designSize * scale) / 2;
    final double dy = (size.height - designSize * scale) / 2;
    canvas.translate(dx, dy);
    canvas.scale(scale);
    return IllustrationCanvas._(canvas);
  }

  /// Variant for wide scenes authored in a `designW x designH` box.
  static IllustrationCanvas beginBox(
    Canvas canvas,
    Size size,
    double designW,
    double designH,
  ) {
    canvas.save();
    final double scale = math.min(size.width / designW, size.height / designH);
    final double dx = (size.width - designW * scale) / 2;
    final double dy = (size.height - designH * scale) / 2;
    canvas.translate(dx, dy);
    canvas.scale(scale);
    return IllustrationCanvas._(canvas);
  }

  void end() => _canvas.restore();

  /// The single grounding shadow every object gets, so the scene sits on a
  /// surface instead of floating.
  void softShadow(Offset center, double width, double height) {
    _canvas.drawOval(
      Rect.fromCenter(center: center, width: width, height: height),
      Paint()
        ..color = AppColors.textPrimary.withValues(alpha: 0.10)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3),
    );
  }

  /// A leaf blade with a lit face, a shaded half and a midrib.
  void leaf(Offset base, double length, double angle, Color color) {
    _canvas.save();
    _canvas.translate(base.dx, base.dy);
    _canvas.rotate(angle);

    final Path blade = Path()
      ..moveTo(0, 0)
      ..quadraticBezierTo(length * 0.45, -length * 0.42, length, 0)
      ..quadraticBezierTo(length * 0.45, length * 0.42, 0, 0)
      ..close();
    _canvas.drawPath(blade, Paint()..color = color);

    // Shaded lower half.
    _canvas.drawPath(
      Path()
        ..moveTo(0, 0)
        ..quadraticBezierTo(length * 0.45, length * 0.42, length, 0)
        ..lineTo(0, 0)
        ..close(),
      Paint()..color = AppColors.primaryDeep.withValues(alpha: 0.14),
    );

    // Midrib.
    _canvas.drawLine(
      Offset.zero,
      Offset(length, 0),
      Paint()
        ..color = Colors.white.withValues(alpha: 0.35)
        ..strokeWidth = 1.4
        ..strokeCap = StrokeCap.round,
    );
    _canvas.restore();
  }

  /// A round fruit with a highlight and a small stem.
  void fruit(Offset center, double radius, Color color) {
    _canvas.drawCircle(center, radius, Paint()..color = color);
    _canvas.drawCircle(
      Offset(center.dx - radius * 0.32, center.dy - radius * 0.32),
      radius * 0.30,
      Paint()..color = Colors.white.withValues(alpha: 0.45),
    );
    _canvas.drawCircle(
      Offset(center.dx + radius * 0.35, center.dy + radius * 0.30),
      radius * 0.55,
      Paint()..color = Colors.black.withValues(alpha: 0.06),
    );
    _canvas.drawLine(
      Offset(center.dx, center.dy - radius),
      Offset(center.dx, center.dy - radius - 3),
      Paint()
        ..color = AppColors.primaryDark
        ..strokeWidth = 2
        ..strokeCap = StrokeCap.round,
    );
  }

  /// A wooden crate seen slightly from the side — front face plus a darker
  /// right face gives the whole illustration set its 2.5D feel.
  void crate(Offset topLeft, double w, double h, {Color? color}) {
    final Color base = color ?? const Color(0xFFC79A63);
    final double depth = w * 0.18;

    // Right (shaded) face.
    _canvas.drawPath(
      Path()
        ..moveTo(topLeft.dx + w, topLeft.dy)
        ..lineTo(topLeft.dx + w + depth, topLeft.dy - depth * 0.6)
        ..lineTo(topLeft.dx + w + depth, topLeft.dy + h - depth * 0.6)
        ..lineTo(topLeft.dx + w, topLeft.dy + h)
        ..close(),
      Paint()..color = _darken(base, 0.18),
    );
    // Top face.
    _canvas.drawPath(
      Path()
        ..moveTo(topLeft.dx, topLeft.dy)
        ..lineTo(topLeft.dx + depth, topLeft.dy - depth * 0.6)
        ..lineTo(topLeft.dx + w + depth, topLeft.dy - depth * 0.6)
        ..lineTo(topLeft.dx + w, topLeft.dy)
        ..close(),
      Paint()..color = _lighten(base, 0.12),
    );
    // Front face.
    _canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(topLeft.dx, topLeft.dy, w, h),
        const Radius.circular(2),
      ),
      Paint()..color = base,
    );
    // Slats.
    for (int i = 1; i < 3; i++) {
      final double y = topLeft.dy + h * i / 3;
      _canvas.drawLine(
        Offset(topLeft.dx + 2, y),
        Offset(topLeft.dx + w - 2, y),
        Paint()
          ..color = _darken(base, 0.12)
          ..strokeWidth = 1.2,
      );
    }
  }

  /// Draws text into the scene (price tags, the ₹ glyph).
  void text(
    String value,
    Offset center, {
    double fontSize = 12,
    Color color = AppColors.textPrimary,
    FontWeight weight = FontWeight.w700,
  }) {
    final TextPainter painter = TextPainter(
      text: TextSpan(
        text: value,
        style: TextStyle(fontSize: fontSize, color: color, fontWeight: weight),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    painter.paint(
      _canvas,
      Offset(center.dx - painter.width / 2, center.dy - painter.height / 2),
    );
  }

  Canvas get raw => _canvas;

  static Color _darken(Color c, double amount) {
    final HSLColor hsl = HSLColor.fromColor(c);
    return hsl
        .withLightness((hsl.lightness - amount).clamp(0.0, 1.0).toDouble())
        .toColor();
  }

  static Color _lighten(Color c, double amount) {
    final HSLColor hsl = HSLColor.fromColor(c);
    return hsl
        .withLightness((hsl.lightness + amount).clamp(0.0, 1.0).toDouble())
        .toColor();
  }
}
