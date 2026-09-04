import 'package:flutter/material.dart';

import 'package:farm_buddy/core/theme/app_colors.dart';
import 'package:farm_buddy/core/theme/app_spacing.dart';
import 'package:farm_buddy/core/theme/app_typography.dart';

/// The one thing the app wants you to do: **Sell My Crop**.
///
/// Deep green, physically raised off the cream page, with a leaf watermark
/// painted behind the text for depth. There is exactly one of these per
/// screen and never two on the same screen.
class HeroActionCard extends StatelessWidget {
  const HeroActionCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.buttonLabel,
    required this.onPressed,
    this.footnote,
    this.icon = Icons.storefront_rounded,
  });

  final String title;
  final String subtitle;
  final String buttonLabel;
  final VoidCallback onPressed;
  final String? footnote;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: AppColors.heroGreen,
        borderRadius: AppRadius.rXl,
        boxShadow: AppShadows.hero,
      ),
      child: ClipRRect(
        borderRadius: AppRadius.rXl,
        child: Stack(
          children: <Widget>[
            // Depth: a big soft leaf watermark bleeding off the corner.
            Positioned(
              right: -34,
              top: -26,
              child: ExcludeSemantics(
                child: SizedBox(
                  width: 190,
                  height: 190,
                  child: CustomPaint(painter: _WatermarkPainter()),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.16),
                          borderRadius: AppRadius.rMd,
                        ),
                        child: Icon(icon, color: Colors.white, size: 22),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: Text(
                          title,
                          style: AppText.h2.copyWith(color: Colors.white),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    subtitle,
                    style: AppText.bodySm.copyWith(
                      color: Colors.white.withValues(alpha: 0.88),
                      fontSize: 15,
                    ),
                    maxLines: 3,
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  SizedBox(
                    width: double.infinity,
                    height: AppSpacing.ctaHeight,
                    child: FilledButton(
                      onPressed: onPressed,
                      style: FilledButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: AppColors.primaryDark,
                        elevation: 0,
                        shape: const RoundedRectangleBorder(
                          borderRadius: AppRadius.rLg,
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Flexible(
                            child: Text(
                              buttonLabel,
                              style: AppText.button
                                  .copyWith(color: AppColors.primaryDark),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.center,
                            ),
                          ),
                          const SizedBox(width: AppSpacing.xs),
                          const Icon(Icons.arrow_forward_rounded, size: 20),
                        ],
                      ),
                    ),
                  ),
                  if (footnote != null) ...<Widget>[
                    const SizedBox(height: AppSpacing.sm),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Icon(
                          Icons.schedule_rounded,
                          size: 13,
                          color: Colors.white.withValues(alpha: 0.7),
                        ),
                        const SizedBox(width: 4),
                        Flexible(
                          child: Text(
                            footnote!,
                            style: AppText.caption.copyWith(
                              color: Colors.white.withValues(alpha: 0.7),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _WatermarkPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()..color = Colors.white.withValues(alpha: 0.07);
    canvas.drawCircle(Offset(size.width * 0.6, size.height * 0.4), 92, paint);

    canvas.save();
    canvas.translate(size.width * 0.42, size.height * 0.30);
    canvas.rotate(0.6);
    canvas.drawPath(
      Path()
        ..moveTo(0, 0)
        ..quadraticBezierTo(58, -56, 124, -8)
        ..quadraticBezierTo(58, 46, 0, 0)
        ..close(),
      Paint()..color = Colors.white.withValues(alpha: 0.10),
    );
    canvas.drawLine(
      Offset.zero,
      const Offset(120, -8),
      Paint()
        ..color = Colors.white.withValues(alpha: 0.14)
        ..strokeWidth = 2.5
        ..strokeCap = StrokeCap.round,
    );
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _WatermarkPainter oldDelegate) => false;
}
