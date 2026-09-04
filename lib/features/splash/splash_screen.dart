import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:farm_buddy/core/constants/app_config.dart';
import 'package:farm_buddy/core/l10n/app_strings.dart';
import 'package:farm_buddy/core/router/app_router.dart';
import 'package:farm_buddy/core/theme/app_colors.dart';
import 'package:farm_buddy/core/theme/app_spacing.dart';
import 'package:farm_buddy/core/theme/app_typography.dart';
import 'package:farm_buddy/providers/app_providers.dart';
import 'package:farm_buddy/widgets/brand/farm_buddy_logo.dart';
import 'package:farm_buddy/widgets/illustrations/field_scene.dart';

/// First impression. The mark grows in, the tagline settles, the fields hold
/// the bottom of the screen. Under two seconds, then out of the way.
class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  )..forward();

  late final Animation<double> _markScale = CurvedAnimation(
    parent: _controller,
    curve: const Interval(0, 0.7, curve: Curves.easeOutBack),
  );

  late final Animation<double> _textFade = CurvedAnimation(
    parent: _controller,
    curve: const Interval(0.35, 1, curve: Curves.easeOut),
  );

  @override
  void initState() {
    super.initState();
    _goNext();
  }

  Future<void> _goNext() async {
    await Future<void>.delayed(AppConfig.splashHold);
    if (!mounted) return;
    context.go(AppRoutes.onboarding);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final AppStrings s = ref.watch(stringsProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: <Widget>[
          // The land, always underneath everything.
          const Align(
            alignment: Alignment.bottomCenter,
            child: FieldScene(height: 220),
          ),

          SafeArea(
            child: Column(
              children: <Widget>[
                const Spacer(flex: 3),
                ScaleTransition(
                  scale: _markScale,
                  child: const FarmBuddyLogo(size: 108),
                ),
                const SizedBox(height: AppSpacing.xl),
                FadeTransition(
                  opacity: _textFade,
                  child: Column(
                    children: <Widget>[
                      const FarmBuddyWordmark(fontSize: 30),
                      const SizedBox(height: AppSpacing.sm),
                      Padding(
                        padding: AppSpacing.screen,
                        child: Text(
                          s('splash.tagline'),
                          style: AppText.body.copyWith(
                            color: AppColors.textSecondary,
                            fontSize: 15,
                          ),
                          textAlign: TextAlign.center,
                          maxLines: 2,
                        ),
                      ),
                    ],
                  ),
                ),
                const Spacer(flex: 4),
                FadeTransition(
                  opacity: _textFade,
                  child: const SizedBox(
                    width: 34,
                    height: 34,
                    child: CircularProgressIndicator(strokeWidth: 2.6),
                  ),
                ),
                const SizedBox(height: AppSpacing.huge),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
