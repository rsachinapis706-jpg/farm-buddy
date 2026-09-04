import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:farm_buddy/core/l10n/app_strings.dart';
import 'package:farm_buddy/core/router/app_router.dart';
import 'package:farm_buddy/core/theme/app_colors.dart';
import 'package:farm_buddy/core/theme/app_spacing.dart';
import 'package:farm_buddy/core/theme/app_typography.dart';
import 'package:farm_buddy/core/utils/responsive.dart';
import 'package:farm_buddy/providers/app_providers.dart';
import 'package:farm_buddy/widgets/buttons/primary_button.dart';
import 'package:farm_buddy/widgets/illustrations/crop_inspect_illustration.dart';
import 'package:farm_buddy/widgets/illustrations/market_illustration.dart';
import 'package:farm_buddy/widgets/illustrations/together_illustration.dart';

/// Three screens, three promises. No account required to read them, and Skip
/// is always available in the top corner.
class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final PageController _controller = PageController();
  int _index = 0;

  static const int _pageCount = 3;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _next() {
    if (_index == _pageCount - 1) {
      context.go(AppRoutes.login);
      return;
    }
    _controller.nextPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  Widget _illustrationFor(int index, double size) {
    switch (index) {
      case 0:
        return CropInspectIllustration(size: size);
      case 1:
        return MarketIllustration(size: size);
      default:
        return TogetherIllustration(size: size);
    }
  }

  @override
  Widget build(BuildContext context) {
    final AppStrings s = ref.watch(stringsProvider);
    final double artSize = context.isCompactHeight ? 200.0 : 260.0;
    final bool isLast = _index == _pageCount - 1;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: <Widget>[
            // ------------------------------------------------------ skip
            Align(
              alignment: Alignment.centerRight,
              child: Padding(
                padding: const EdgeInsets.only(right: AppSpacing.xs),
                child: TextButton(
                  onPressed: () => context.go(AppRoutes.login),
                  style: TextButton.styleFrom(
                    minimumSize: const Size(64, AppSpacing.touchTarget),
                  ),
                  child: Text(
                    s('common.skip'),
                    style: AppText.bodyStrong
                        .copyWith(color: AppColors.textSecondary),
                  ),
                ),
              ),
            ),

            // ----------------------------------------------------- pages
            Expanded(
              child: PageView.builder(
                controller: _controller,
                itemCount: _pageCount,
                onPageChanged: (int value) => setState(() => _index = value),
                itemBuilder: (BuildContext context, int index) {
                  return ResponsiveCenter(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        _illustrationFor(index, artSize),
                        const SizedBox(height: AppSpacing.xxl),
                        Text(
                          s('onboard.${index + 1}.title'),
                          style: AppText.h1,
                          textAlign: TextAlign.center,
                          maxLines: 2,
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        Text(
                          s('onboard.${index + 1}.body'),
                          style: AppText.body,
                          textAlign: TextAlign.center,
                          maxLines: 4,
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),

            // ------------------------------------------------ dots + cta
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.lg,
                AppSpacing.md,
                AppSpacing.lg,
                AppSpacing.xl,
              ),
              child: Column(
                children: <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List<Widget>.generate(_pageCount, (int i) {
                      final bool active = i == _index;
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 250),
                        curve: Curves.easeOut,
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        height: 8,
                        width: active ? 26 : 8,
                        decoration: BoxDecoration(
                          color:
                              active ? AppColors.primary : AppColors.borderStrong,
                          borderRadius: AppRadius.rPill,
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 480),
                    child: PrimaryButton(
                      label: isLast ? s('onboard.cta') : s('common.next'),
                      icon: isLast ? Icons.arrow_forward_rounded : null,
                      onPressed: _next,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
