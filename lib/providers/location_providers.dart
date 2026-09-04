import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:farm_buddy/models/farm_location.dart';
import 'package:farm_buddy/services/location_service.dart';

final locationServiceProvider =
    Provider<LocationService>((ref) => const LocationService());

/// Whether to draw the real Google map instead of the built-in drawn one.
///
/// Off by default, deliberately. The drawn map needs no key, no billing
/// account and no signal; the live map needs all three, and a demo should
/// never be one expired API key away from a blank screen. The farmer (or the
/// person demoing) turns it on when they want it.
final liveMapProvider = StateProvider<bool>((ref) => false);

/// The farmer's location. Starts as an honest guess and is replaced the moment
/// the device gives us something better.
class FarmLocationNotifier extends StateNotifier<FarmLocation> {
  FarmLocationNotifier(this._service) : super(FarmLocation.fallback());

  final LocationService _service;

  bool _busy = false;
  bool get isDetecting => _busy;

  LocationAccess access = LocationAccess.unknown;

  /// Returns true when a real device fix replaced the guess.
  Future<bool> detect() async {
    if (_busy) return false;
    _busy = true;
    // Re-emit so listeners can show a spinner.
    state = state;

    try {
      access = await _service.checkAccess();
      final FarmLocation? fix = await _service.current();
      if (fix != null) {
        state = fix;
        access = LocationAccess.granted;
        return true;
      }
      // Refresh the reason it failed so the UI can be specific.
      access = await _service.checkAccess();
      return false;
    } finally {
      _busy = false;
      state = state;
    }
  }

  /// Farmer picked a place by hand. Just as valid as a GPS fix.
  void setManual(double lat, double lng, String label) {
    state = FarmLocation(
      latitude: lat,
      longitude: lng,
      label: label,
      source: LocationSource.manual,
      capturedAt: DateTime.now(),
    );
  }

  void reset() => state = FarmLocation.fallback();
}

final farmLocationProvider =
    StateNotifierProvider<FarmLocationNotifier, FarmLocation>(
  (ref) => FarmLocationNotifier(ref.watch(locationServiceProvider)),
);

/// Short label for headers — the existing `locationProvider` string, now fed
/// by the real location instead of a hard-coded constant.
final locationLabelProvider = Provider<String>(
  (ref) => ref.watch(farmLocationProvider).label,
);
