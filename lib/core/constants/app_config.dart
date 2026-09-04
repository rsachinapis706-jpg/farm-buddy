/// Single place for app-wide constants and demo switches.
abstract final class AppConfig {
  static const String appName = 'FARM BUDDY';
  static const String tagline = 'The right decision. At the right time.';

  /// When true, every screen showing sample content renders a "Demo data"
  /// chip. Honest with judges, and it disappears the day a real API lands.
  static const bool isDemoMode = true;

  /// Simulated round-trip so loading states are visible in the demo.
  static const Duration fakeLatency = Duration(milliseconds: 900);
  static const Duration shortLatency = Duration(milliseconds: 500);

  static const String defaultLocation = 'Coimbatore, Tamil Nadu';
  static const String defaultLocationShort = 'Coimbatore';

  /// How long the splash holds before routing on.
  static const Duration splashHold = Duration(milliseconds: 1900);
}
