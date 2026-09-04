import 'package:flutter/material.dart';

import 'package:farm_buddy/core/theme/app_colors.dart';
import 'package:farm_buddy/core/theme/app_spacing.dart';
import 'package:farm_buddy/core/theme/app_typography.dart';
import 'package:farm_buddy/widgets/common/platform/photo_view.dart';
import 'package:farm_buddy/widgets/illustrations/illustration_utils.dart';

/// Shows the farmer's crop photo.
///
/// Three cases, all handled without an error ever reaching the screen:
///  * a real file from the camera or gallery,
///  * the built-in sample (`demo://sample`) used when a device has no camera,
///  * nothing yet.
///
/// Display is delegated to `platformPhoto`, which resolves to a file-based
/// image on Android/iOS and a blob URL on the web — so the same journey runs
/// on a phone and in a browser.
class CropPhoto extends StatelessWidget {
  const CropPhoto({
    super.key,
    required this.path,
    this.height = 200,
    this.radius = AppRadius.rLg,
    this.emptyLabel,
    this.sampleLabel,
  });

  /// Sentinel used when the camera is unavailable.
  static const String demoPath = 'demo://sample';

  final String? path;
  final double height;
  final BorderRadius radius;
  final String? emptyLabel;
  final String? sampleLabel;

  bool get _isDemo => path == null || path == demoPath || path!.startsWith('demo:');

  @override
  Widget build(BuildContext context) {
    Widget content;

    if (path == null) {
      content = _EmptyPhoto(label: emptyLabel);
    } else if (_isDemo) {
      content = _SamplePhoto(label: sampleLabel);
    } else {
      content = platformPhoto(
        path!,
        height: height,
        onError: () => _SamplePhoto(label: sampleLabel),
      );
    }

    return ClipRRect(
      borderRadius: radius,
      child: SizedBox(height: height, width: double.infinity, child: content),
    );
  }
}

class _EmptyPhoto extends StatelessWidget {
  const _EmptyPhoto({this.label});

  final String? label;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.surfaceAlt,
      alignment: Alignment.center,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          const Icon(
            Icons.photo_camera_outlined,
            size: 34,
            color: AppColors.textMuted,
          ),
          if (label != null) ...<Widget>[
            const SizedBox(height: AppSpacing.xs),
            Text(label!, style: AppText.caption),
          ],
        ],
      ),
    );
  }
}

/// A drawn stand-in for a crop photo, so the flow is demonstrable on an
/// emulator with no camera. Always labelled — never passed off as a real photo.
class _SamplePhoto extends StatelessWidget {
  const _SamplePhoto({this.label});

  final String? label;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: <Widget>[
        ExcludeSemantics(
          child: CustomPaint(painter: _SamplePhotoPainter()),
        ),
        Positioned(
          left: AppSpacing.xs,
          bottom: AppSpacing.xs,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: AppColors.surface.withValues(alpha: 0.9),
              borderRadius: AppRadius.rPill,
            ),
            child: Text(
              label ?? 'Sample photo',
              style: AppText.caption.copyWith(fontSize: 11),
            ),
          ),
        ),
      ],
    );
  }
}

class _SamplePhotoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final double w = size.width;
    final double h = size.height;

    // Soil-to-canopy wash.
    canvas.drawRect(
      Rect.fromLTWH(0, 0, w, h),
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: <Color>[Color(0xFF4E8F5F), Color(0xFF2C6340)],
        ).createShader(Rect.fromLTWH(0, 0, w, h)),
    );

    final IllustrationCanvas c = IllustrationCanvas.beginBox(canvas, size, w, h);

    // Overlapping leaves, largest at the bottom for depth of field.
    final List<(double, double, double, double)> leaves =
        <(double, double, double, double)>[
      (0.20, 0.72, 0.42, -0.5),
      (0.62, 0.78, 0.46, -2.5),
      (0.42, 0.52, 0.34, -1.0),
      (0.78, 0.44, 0.30, -2.2),
      (0.14, 0.36, 0.28, -0.4),
      (0.50, 0.24, 0.24, -1.8),
    ];
    for (int i = 0; i < leaves.length; i++) {
      final (double lx, double ly, double len, double angle) = leaves[i];
      c.leaf(
        Offset(lx * w, ly * h),
        len * w * 0.5,
        angle,
        i.isEven ? const Color(0xFF6FBB86) : const Color(0xFF56A46E),
      );
    }

    // Two tomatoes to make it unmistakably a crop.
    c.fruit(Offset(w * 0.34, h * 0.62), w * 0.055, const Color(0xFFD9452F));
    c.fruit(Offset(w * 0.58, h * 0.40), w * 0.045, const Color(0xFFE4573C));

    // Soft vignette so the label stays readable.
    canvas.drawRect(
      Rect.fromLTWH(0, h * 0.6, w, h * 0.4),
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: <Color>[
            Colors.black.withValues(alpha: 0),
            Colors.black.withValues(alpha: 0.18),
          ],
        ).createShader(Rect.fromLTWH(0, h * 0.6, w, h * 0.4)),
    );

    c.end();
  }

  @override
  bool shouldRepaint(covariant _SamplePhotoPainter oldDelegate) => false;
}
