import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:farm_buddy/core/theme/app_colors.dart';
import 'package:farm_buddy/features/auth/login_screen.dart';
import 'package:farm_buddy/features/crop/add_crop_screen.dart';
import 'package:farm_buddy/features/crop/crop_health_screen.dart';
import 'package:farm_buddy/features/farmers/group_sale_screen.dart';
import 'package:farm_buddy/features/farmers/nearby_farmers_screen.dart';
import 'package:farm_buddy/features/home/home_screen.dart';
import 'package:farm_buddy/features/market/best_market_screen.dart';
import 'package:farm_buddy/features/market/market_details_screen.dart';
import 'package:farm_buddy/features/onboarding/onboarding_screen.dart';
import 'package:farm_buddy/features/profile/location_settings_screen.dart';
import 'package:farm_buddy/features/profile/profile_screen.dart';
import 'package:farm_buddy/features/shell/main_shell.dart';
import 'package:farm_buddy/features/splash/splash_screen.dart';
import 'package:farm_buddy/features/transport/transport_screen.dart';
import 'package:farm_buddy/widgets/states/error_state.dart';

/// Every destination in the app, in one place.
abstract final class AppRoutes {
  static const String splash = '/';
  static const String onboarding = '/onboarding';
  static const String login = '/login';

  // Tabs (inside the shell).
  static const String home = '/home';
  static const String markets = '/markets';
  static const String farmers = '/farmers';
  static const String transport = '/transport';
  static const String profile = '/profile';

  // Full-screen pushes (no bottom nav).
  static const String addCrop = '/add-crop';
  static const String cropHealth = '/crop-health';
  static const String marketDetails = '/market-details';
  static const String groupSale = '/group-sale';
  static const String locationSettings = '/location-settings';
}

final GlobalKey<NavigatorState> _rootNavigatorKey =
    GlobalKey<NavigatorState>(debugLabel: 'root');

final goRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: AppRoutes.splash,
    debugLogDiagnostics: false,
    routes: <RouteBase>[
      GoRoute(
        path: AppRoutes.splash,
        builder: (BuildContext context, GoRouterState state) =>
            const SplashScreen(),
      ),
      GoRoute(
        path: AppRoutes.onboarding,
        builder: (BuildContext context, GoRouterState state) =>
            const OnboardingScreen(),
      ),
      GoRoute(
        path: AppRoutes.login,
        builder: (BuildContext context, GoRouterState state) =>
            const LoginScreen(),
      ),
      GoRoute(
        path: AppRoutes.addCrop,
        builder: (BuildContext context, GoRouterState state) =>
            const AddCropScreen(),
      ),
      GoRoute(
        path: AppRoutes.cropHealth,
        builder: (BuildContext context, GoRouterState state) =>
            const CropHealthScreen(),
      ),
      GoRoute(
        path: AppRoutes.groupSale,
        builder: (BuildContext context, GoRouterState state) =>
            const GroupSaleScreen(),
      ),
      GoRoute(
        path: AppRoutes.locationSettings,
        builder: (BuildContext context, GoRouterState state) =>
            const LocationSettingsScreen(),
      ),
      GoRoute(
        path: '${AppRoutes.marketDetails}/:id',
        builder: (BuildContext context, GoRouterState state) =>
            MarketDetailsScreen(
          marketId: state.pathParameters['id'] ?? '',
        ),
      ),

      // ------------------------------------------------ the five tabs
      StatefulShellRoute.indexedStack(
        builder: (
          BuildContext context,
          GoRouterState state,
          StatefulNavigationShell navigationShell,
        ) =>
            MainShell(navigationShell: navigationShell),
        branches: <StatefulShellBranch>[
          StatefulShellBranch(
            routes: <RouteBase>[
              GoRoute(
                path: AppRoutes.home,
                builder: (BuildContext context, GoRouterState state) =>
                    const HomeScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: <RouteBase>[
              GoRoute(
                path: AppRoutes.markets,
                builder: (BuildContext context, GoRouterState state) =>
                    const BestMarketScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: <RouteBase>[
              GoRoute(
                path: AppRoutes.farmers,
                builder: (BuildContext context, GoRouterState state) =>
                    const NearbyFarmersScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: <RouteBase>[
              GoRoute(
                path: AppRoutes.transport,
                builder: (BuildContext context, GoRouterState state) =>
                    const TransportScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: <RouteBase>[
              GoRoute(
                path: AppRoutes.profile,
                builder: (BuildContext context, GoRouterState state) =>
                    const ProfileScreen(),
              ),
            ],
          ),
        ],
      ),
    ],

    // A wrong link should never show a red screen to a farmer.
    errorBuilder: (BuildContext context, GoRouterState state) => Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: ErrorState(
          icon: Icons.explore_off_rounded,
          title: 'Page not found',
          message: 'That screen does not exist. Let us take you home.',
          retryLabel: 'Go to Home',
          onRetry: () => context.go(AppRoutes.home),
        ),
      ),
    ),
  );
});
