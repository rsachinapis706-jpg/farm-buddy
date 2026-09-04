import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'package:farm_buddy/core/theme/app_colors.dart';
import 'package:farm_buddy/core/theme/app_spacing.dart';
import 'package:farm_buddy/core/theme/app_typography.dart';
import 'package:farm_buddy/widgets/common/emoji_text.dart';

/// One pin on the drawn map.
class MapMarker {
  const MapMarker({
    required this.x,
    required this.y,
    required this.label,
    this.isPrimary = false,
    this.rank,
    this.emoji,
  });

  /// Normalised 0..1 inside the map box.
  final double x;
  final double y;

  final String label;
  final bool isPrimary;
  final int? rank;
  final String? emoji;
}

/// A map without a map SDK.
///
/// Farm Buddy needs to answer "where is this, roughly, relative to me?" — not
/// "what is the house number?". A drawn map answers that instantly, works with
/// no connection, needs no API key or billing account, and never shows a grey
/// tile grid on a weak signal. The layout is representative, and the widget
/// says so.
class MapPreview extends StatelessWidget {
  const MapPreview({
    super.key,
    this.height = 200,
    this.markers = const <MapMarker>[],
    this.showYouAreHere = true,
    this.onTap,
    this.centerLabel,
    this.showRoute = false,
    this.onMarkerTap,
  });

  final double height;
  final List<MapMarker> markers;
  final bool showYouAreHere;
  final VoidCallback? onTap;
  final String? centerLabel;
  final bool showRoute;

  /// Called with the index of the tapped pin. A map you cannot touch is a
  /// picture; this makes the pins a way into each market.
  final void Function(int index)? onMarkerTap;

  /// Where "you" sit on every Farm Buddy map.
  static const Offset youAt = Offset(0.18, 0.78);

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: centerLabel == null
          ? 'Map preview'
          : 'Map preview showing $centerLabel',
      button: onTap != null,
      child: ClipRRect(
        borderRadius: AppRadius.rLg,
        child: SizedBox(
          height: height,
          width: double.infinity,
          child: LayoutBuilder(
            builder: (BuildContext context, BoxConstraints constraints) {
              final double w = constraints.maxWidth;
              final double h = constraints.maxHeight;

              return GestureDetector(
                onTap: onTap,
                child: Stack(
                  fit: StackFit.expand,
                  children: <Widget>[
                    CustomPaint(
                      painter: _MapPainter(
                        markers: markers,
                        showRoute: showRoute,
                        showYou: showYouAreHere,
                      ),
                    ),

                    // ------------------------------------------- pins
                    for (int i = 0; i < markers.length; i++)
                      Positioned(
                        left: (markers[i].x * w) - 60,
                        top: (markers[i].y * h) - 46,
                        width: 120,
                        child: Semantics(
                          button: onMarkerTap != null,
                          label: markers[i].label,
                          child: GestureDetector(
                            behavior: HitTestBehavior.opaque,
                            onTap: onMarkerTap == null
                                ? null
                                : () => onMarkerTap!(i),
                            child: _Pin(marker: markers[i]),
                          ),
                        ),
                      ),

                    if (showYouAreHere)
                      Positioned(
                        left: (youAt.dx * w) - 40,
                        top: (youAt.dy * h) - 12,
                        width: 80,
                        child: const _YouAreHere(),
                      ),

                    // ------------------------------- honesty + controls
                    Positioned(
                      left: AppSpacing.xs,
                      bottom: AppSpacing.xs,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.xs,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.surface.withValues(alpha: 0.88),
                          borderRadius: AppRadius.rPill,
                          border: Border.all(color: AppColors.border),
                        ),
                        child: Text(
                          'Map preview',
                          style: AppText.caption.copyWith(fontSize: 10),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _Pin extends StatelessWidget {
  const _Pin({required this.marker});

  final MapMarker marker;

  @override
  Widget build(BuildContext context) {
    final Color fill =
        marker.isPrimary ? AppColors.primary : AppColors.surface;
    final Color fg =
        marker.isPrimary ? Colors.white : AppColors.textPrimary;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
          decoration: BoxDecoration(
            color: fill,
            borderRadius: AppRadius.rPill,
            border: Border.all(
              color: marker.isPrimary ? AppColors.primaryDark : AppColors.border,
            ),
            boxShadow: AppShadows.card,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              if (marker.rank != null)
                Container(
                  width: 16,
                  height: 16,
                  alignment: Alignment.center,
                  margin: const EdgeInsets.only(right: 4),
                  decoration: BoxDecoration(
                    color: marker.isPrimary ? Colors.white : AppColors.primarySoft,
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    '${marker.rank}',
                    style: AppText.caption.copyWith(
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      color: AppColors.primaryDark,
                    ),
                  ),
                )
              else if (marker.emoji != null)
                Padding(
                  padding: const EdgeInsets.only(right: 3),
                  child: EmojiText(marker.emoji!, size: 11),
                ),
              Flexible(
                child: Text(
                  marker.label,
                  style: AppText.caption.copyWith(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w700,
                    color: fg,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
        // Pin stem + point.
        Container(
          width: 2,
          height: 8,
          color: marker.isPrimary ? AppColors.primaryDark : AppColors.borderStrong,
        ),
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: marker.isPrimary ? AppColors.primary : AppColors.surface,
            shape: BoxShape.circle,
            border: Border.all(
              color: marker.isPrimary ? AppColors.primaryDark : AppColors.borderStrong,
              width: 1.5,
            ),
          ),
        ),
      ],
    );
  }
}

class _YouAreHere extends StatelessWidget {
  const _YouAreHere();

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Container(
          width: 18,
          height: 18,
          decoration: BoxDecoration(
            color: AppColors.sky,
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 3),
            boxShadow: AppShadows.card,
          ),
        ),
        const SizedBox(height: 3),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(
            color: AppColors.surface.withValues(alpha: 0.92),
            borderRadius: AppRadius.rPill,
          ),
          child: Text(
            'You',
            style: AppText.caption.copyWith(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: AppColors.sky,
            ),
          ),
        ),
      ],
    );
  }
}

class _MapPainter extends CustomPainter {
  _MapPainter({
    required this.markers,
    required this.showRoute,
    required this.showYou,
  });

  final List<MapMarker> markers;
  final bool showRoute;
  final bool showYou;

  @override
  void paint(Canvas canvas, Size size) {
    final double w = size.width;
    final double h = size.height;

    // --------------------------------------------------------- land
    canvas.drawRect(
      Rect.fromLTWH(0, 0, w, h),
      Paint()..color = AppColors.mapLand,
    );

    // Field patches — irregular blocks so it reads as farmland, not a city.
    final List<Rect> fields = <Rect>[
      Rect.fromLTWH(w * 0.02, h * 0.06, w * 0.26, h * 0.24),
      Rect.fromLTWH(w * 0.34, h * 0.02, w * 0.20, h * 0.18),
      Rect.fromLTWH(w * 0.62, h * 0.10, w * 0.30, h * 0.22),
      Rect.fromLTWH(w * 0.06, h * 0.40, w * 0.22, h * 0.20),
      Rect.fromLTWH(w * 0.46, h * 0.44, w * 0.24, h * 0.22),
      Rect.fromLTWH(w * 0.72, h * 0.58, w * 0.24, h * 0.26),
      Rect.fromLTWH(w * 0.14, h * 0.72, w * 0.24, h * 0.22),
    ];
    for (int i = 0; i < fields.length; i++) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(fields[i], const Radius.circular(6)),
        Paint()
          ..color = i.isEven ? AppColors.mapField : AppColors.mapFieldAlt,
      );
      // Furrow texture.
      canvas.save();
      canvas.clipRRect(
        RRect.fromRectAndRadius(fields[i], const Radius.circular(6)),
      );
      final Rect f = fields[i];
      for (double x = f.left; x < f.right; x += 6) {
        canvas.drawLine(
          Offset(x, f.top),
          Offset(x - 6, f.bottom),
          Paint()
            ..color = AppColors.mapLand.withValues(alpha: 0.45)
            ..strokeWidth = 1.2,
        );
      }
      canvas.restore();
    }

    // -------------------------------------------------------- river
    final Path river = Path()
      ..moveTo(-4, h * 0.36)
      ..cubicTo(w * 0.28, h * 0.30, w * 0.34, h * 0.58, w * 0.62, h * 0.54)
      ..cubicTo(w * 0.84, h * 0.51, w * 0.90, h * 0.36, w + 4, h * 0.40);
    canvas.drawPath(
      river,
      Paint()
        ..color = AppColors.mapWater
        ..style = PaintingStyle.stroke
        ..strokeWidth = 9
        ..strokeCap = StrokeCap.round,
    );

    // -------------------------------------------------------- roads
    final Paint roadCasing = Paint()
      ..color = AppColors.mapRoadEdge
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    final Paint road = Paint()
      ..color = AppColors.mapRoad
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final List<Path> roads = <Path>[
      Path()
        ..moveTo(-4, h * 0.86)
        ..cubicTo(w * 0.30, h * 0.80, w * 0.42, h * 0.30, w + 4, h * 0.22),
      Path()
        ..moveTo(w * 0.10, -4)
        ..cubicTo(w * 0.22, h * 0.36, w * 0.52, h * 0.60, w * 0.86, h + 4),
      Path()
        ..moveTo(-4, h * 0.52)
        ..lineTo(w + 4, h * 0.68),
    ];
    for (int i = 0; i < roads.length; i++) {
      final double width = i == 0 ? 9.0 : (i == 1 ? 7.0 : 4.0);
      canvas.drawPath(roads[i], roadCasing..strokeWidth = width + 2.5);
      canvas.drawPath(roads[i], road..strokeWidth = width);
    }

    // ---------------------------------------------------- route line
    if (showRoute && showYou) {
      MapMarker? target;
      for (final MapMarker m in markers) {
        if (m.isPrimary) {
          target = m;
          break;
        }
      }
      target ??= markers.isNotEmpty ? markers.first : null;

      if (target != null) {
        final Offset from = Offset(
          MapPreview.youAt.dx * w,
          MapPreview.youAt.dy * h,
        );
        final Offset to = Offset(target.x * w, target.y * h);
        _dashedCurve(canvas, from, to);

        // Direction arrow at the midpoint.
        final Offset mid = Offset(
          (from.dx + to.dx) / 2,
          (from.dy + to.dy) / 2 - 14,
        );
        canvas.drawCircle(mid, 9, Paint()..color = AppColors.primary);
        final double angle = math.atan2(to.dy - from.dy, to.dx - from.dx);
        canvas.save();
        canvas.translate(mid.dx, mid.dy);
        canvas.rotate(angle);
        canvas.drawPath(
          Path()
            ..moveTo(-3, -3.5)
            ..lineTo(3.5, 0)
            ..lineTo(-3, 3.5)
            ..close(),
          Paint()..color = Colors.white,
        );
        canvas.restore();
      }
    }
  }

  void _dashedCurve(Canvas canvas, Offset from, Offset to) {
    final Path path = Path()
      ..moveTo(from.dx, from.dy)
      ..quadraticBezierTo(
        (from.dx + to.dx) / 2,
        math.min(from.dy, to.dy) - 26,
        to.dx,
        to.dy,
      );

    final Paint paint = Paint()
      ..color = AppColors.primary
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;

    for (final metric in path.computeMetrics()) {
      double distance = 0;
      while (distance < metric.length) {
        final double next = math.min(distance + 9, metric.length);
        canvas.drawPath(metric.extractPath(distance, next), paint);
        distance = next + 7;
      }
    }
  }

  @override
  bool shouldRepaint(covariant _MapPainter oldDelegate) =>
      oldDelegate.markers != markers ||
      oldDelegate.showRoute != showRoute ||
      oldDelegate.showYou != showYou;
}
