import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:geocoding/geocoding.dart' as geo;
import 'package:geolocator/geolocator.dart';

import 'package:farm_buddy/models/farm_location.dart';

/// Device location, with every failure turned into a state the UI can explain.
///
/// Nothing here throws at the caller. A farmer who denies permission, has GPS
/// switched off, or is standing somewhere with no signal still gets a usable
/// app — they just get [FarmLocation.fallback] and a screen that says so.
class LocationService {
  const LocationService();

  Future<LocationAccess> checkAccess() async {
    try {
      if (!await Geolocator.isLocationServiceEnabled()) {
        return LocationAccess.serviceOff;
      }
      final LocationPermission p = await Geolocator.checkPermission();
      return _map(p);
    } catch (_) {
      // Desktop/unsupported platforms throw rather than returning a status.
      return LocationAccess.unsupported;
    }
  }

  /// Asks the OS. Safe to call repeatedly — once permanently denied, the OS
  /// stops showing the dialog and we report [LocationAccess.deniedForever]
  /// so the UI can offer the settings shortcut instead of asking again.
  Future<LocationAccess> request() async {
    try {
      if (!await Geolocator.isLocationServiceEnabled()) {
        return LocationAccess.serviceOff;
      }
      LocationPermission p = await Geolocator.checkPermission();
      if (p == LocationPermission.denied) {
        p = await Geolocator.requestPermission();
      }
      return _map(p);
    } catch (_) {
      return LocationAccess.unsupported;
    }
  }

  /// A position plus a human-readable place name.
  ///
  /// Returns null only when the position itself could not be read; a missing
  /// place *name* is not a failure — the coordinates are still useful, so the
  /// label falls back to the coordinates themselves.
  Future<FarmLocation?> current({Duration? timeout}) async {
    try {
      final LocationAccess access = await request();
      if (access != LocationAccess.granted) return null;

      final Position pos = await Geolocator.getCurrentPosition(
        locationSettings: LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: timeout ?? const Duration(seconds: 15),
        ),
      );

      return FarmLocation(
        latitude: pos.latitude,
        longitude: pos.longitude,
        label: await describe(pos.latitude, pos.longitude),
        source: LocationSource.device,
        capturedAt: DateTime.now(),
        accuracyMetres: pos.accuracy,
      );
    } catch (_) {
      return null;
    }
  }

  /// Reverse-geocodes to something a farmer would recognise, e.g.
  /// "Sulur, Coimbatore". Falls back to coordinates rather than failing.
  Future<String> describe(double lat, double lng) async {
    // The geocoding plugin has no web implementation; calling it there throws
    // MissingPluginException, so don't.
    if (kIsWeb) return _coords(lat, lng);

    try {
      // geocoding 5.x moved this from a top-level function onto an instance.
      final List<geo.Placemark> marks =
          await geo.Geocoding().placemarkFromCoordinates(lat, lng);
      if (marks.isEmpty) return _coords(lat, lng);

      final geo.Placemark m = marks.first;
      final List<String> parts = <String>[
        if ((m.subLocality ?? '').isNotEmpty) m.subLocality!,
        if ((m.locality ?? '').isNotEmpty) m.locality!,
        if ((m.administrativeArea ?? '').isNotEmpty) m.administrativeArea!,
      ];
      // Drop duplicates like "Sulur, Sulur, Tamil Nadu".
      final List<String> unique = <String>[];
      for (final String p in parts) {
        if (!unique.contains(p)) unique.add(p);
      }
      return unique.isEmpty ? _coords(lat, lng) : unique.take(2).join(', ');
    } catch (_) {
      return _coords(lat, lng);
    }
  }

  /// Opens the OS location settings — the only way out of "denied forever".
  Future<void> openSettings() async {
    try {
      await Geolocator.openAppSettings();
    } catch (_) {
      // Nothing sensible to do if the OS refuses; the UI already told the
      // farmer what to change.
    }
  }

  static String _coords(double lat, double lng) =>
      '${lat.toStringAsFixed(4)}, ${lng.toStringAsFixed(4)}';

  static LocationAccess _map(LocationPermission p) => switch (p) {
        LocationPermission.always ||
        LocationPermission.whileInUse =>
          LocationAccess.granted,
        LocationPermission.denied => LocationAccess.denied,
        LocationPermission.deniedForever => LocationAccess.deniedForever,
        LocationPermission.unableToDetermine => LocationAccess.unknown,
      };
}
