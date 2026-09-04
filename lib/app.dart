import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:farm_buddy/core/constants/app_config.dart';
import 'package:farm_buddy/core/router/app_router.dart';
import 'package:farm_buddy/core/theme/app_theme.dart';

class FarmBuddyApp extends ConsumerWidget {
  const FarmBuddyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final GoRouter router = ref.watch(goRouterProvider);

    return MaterialApp.router(
      title: AppConfig.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      // Light only: the app is read outdoors, in daylight, and a single
      // well-tuned surface set keeps contrast predictable.
      themeMode: ThemeMode.light,
      routerConfig: router,
      builder: (BuildContext context, Widget? child) {
        // Respect the system font size, but keep the layout from breaking at
        // the extremes — accessibility without a broken screen.
        return MediaQuery.withClampedTextScaling(
          minScaleFactor: 0.9,
          maxScaleFactor: 1.4,
          child: child ?? const SizedBox.shrink(),
        );
      },
    );
  }
}
