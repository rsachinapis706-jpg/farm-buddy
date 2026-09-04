import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:farm_buddy/core/constants/app_config.dart';
import 'package:farm_buddy/core/l10n/app_strings.dart';
import 'package:farm_buddy/models/enums.dart';
import 'package:farm_buddy/models/user_profile.dart';
import 'package:farm_buddy/services/mock_data.dart';

/// Language the whole app renders in. Changing this rebuilds every screen.
final languageProvider = StateProvider<AppLanguage>((ref) => AppLanguage.english);

/// The string table for the current language. Screens do:
/// `final s = ref.watch(stringsProvider);`
final stringsProvider =
    Provider<AppStrings>((ref) => AppStrings(ref.watch(languageProvider)));

/// Connectivity. Flipping this in Profile lets a judge see the offline
/// behaviour on stage without turning off the phone's data.
final isOnlineProvider = StateProvider<bool>((ref) => true);

/// When the cached copy was last refreshed. Drives "Last updated 10 min ago".
final lastSyncedProvider = StateProvider<DateTime>(
  (ref) => DateTime.now().subtract(const Duration(minutes: 10)),
);

/// Where the farmer is. Shown in the header, used to sort markets.
final locationProvider =
    StateProvider<String>((ref) => AppConfig.defaultLocationShort);

final profileProvider = Provider<FarmerProfile>((ref) => MockData.profile);

/// Data freshness derived from connectivity — the single source of truth for
/// every FreshnessChip in the app.
final freshnessProvider = Provider<DataFreshness>(
  (ref) => ref.watch(isOnlineProvider) ? DataFreshness.live : DataFreshness.cached,
);

/// Greeting key that matches the time of day.
final greetingKeyProvider = Provider<String>((ref) {
  final int hour = DateTime.now().hour;
  if (hour < 12) return 'home.greeting.morning';
  if (hour < 17) return 'home.greeting.afternoon';
  return 'home.greeting.evening';
});
