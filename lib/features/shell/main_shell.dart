import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:farm_buddy/core/l10n/app_strings.dart';
import 'package:farm_buddy/core/theme/app_colors.dart';
import 'package:farm_buddy/providers/app_providers.dart';
import 'package:farm_buddy/widgets/common/bottom_navigation.dart';

/// Holds the five tabs. Each tab keeps its own navigation stack, so backing
/// out of a market detail returns you to Markets, not to Home.
class MainShell extends ConsumerWidget {
  const MainShell({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppStrings s = ref.watch(stringsProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      // The nav bar floats, so the page paints behind it.
      extendBody: true,
      body: navigationShell,
      bottomNavigationBar: FbBottomNavigation(
        currentIndex: navigationShell.currentIndex,
        onTap: (int index) => navigationShell.goBranch(
          index,
          // Tapping the tab you are already on returns to its root.
          initialLocation: index == navigationShell.currentIndex,
        ),
        labels: <String>[
          s('nav.home'),
          s('nav.markets'),
          s('nav.farmers'),
          s('nav.transport'),
          s('nav.profile'),
        ],
      ),
    );
  }
}
