import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:farm_buddy/core/constants/app_config.dart';
import 'package:farm_buddy/models/crop.dart';
import 'package:farm_buddy/models/crop_health.dart';
import 'package:farm_buddy/services/crop_service.dart';

final cropServiceProvider = Provider<CropService>((ref) => const CropService());

final allCropsProvider =
    Provider<List<Crop>>((ref) => ref.watch(cropServiceProvider).allCrops());

/// The listing being built on the Add Crop screen and carried through the
/// whole journey: crop -> quantity -> photo -> location -> analyse -> sell.
class CurrentListingNotifier extends StateNotifier<CropListing?> {
  CurrentListingNotifier() : super(null);

  void setCrop(Crop crop) {
    final CropListing? current = state;
    if (current == null) {
      state = CropListing(
        id: _newId(),
        crop: crop,
        quantityKg: 0,
        locationName: AppConfig.defaultLocationShort,
        createdAt: DateTime.now(),
      );
    } else {
      state = current.copyWith(crop: crop);
    }
  }

  void setQuantity(double quantityKg) {
    final CropListing? current = state;
    if (current == null) return;
    state = current.copyWith(quantityKg: quantityKg);
  }

  void setPhoto(String? path) {
    final CropListing? current = state;
    if (current == null) return;
    // copyWith cannot clear a value, so rebuild when removing the photo.
    if (path == null) {
      state = CropListing(
        id: current.id,
        crop: current.crop,
        quantityKg: current.quantityKg,
        locationName: current.locationName,
        createdAt: current.createdAt,
      );
      return;
    }
    state = current.copyWith(photoPath: path);
  }

  void setLocation(String location) {
    final CropListing? current = state;
    if (current == null) return;
    state = current.copyWith(locationName: location);
  }

  /// Seeds a demo listing so "Best Market" and "Transport" are meaningful even
  /// when a judge taps them straight from Home.
  void seedDemo(Crop crop, {double quantityKg = 500}) {
    state = CropListing(
      id: _newId(),
      crop: crop,
      quantityKg: quantityKg,
      locationName: AppConfig.defaultLocationShort,
      createdAt: DateTime.now(),
    );
  }

  /// Commits a fully-built listing from the Add Crop screen.
  void replace(CropListing listing) => state = listing;

  /// Changes crop and/or quantity from anywhere, creating a listing if the
  /// farmer has not made one yet. This is what lets the Best Market screen
  /// re-rank live without sending them back to Add Crop.
  void update({
    required Crop fallbackCrop,
    Crop? crop,
    double? quantityKg,
  }) {
    final CropListing? current = state;
    if (current == null) {
      state = CropListing(
        id: _newId(),
        crop: crop ?? fallbackCrop,
        quantityKg: quantityKg ?? 500,
        locationName: AppConfig.defaultLocationShort,
        createdAt: DateTime.now(),
      );
      return;
    }
    state = current.copyWith(crop: crop, quantityKg: quantityKg);
  }

  void clear() => state = null;

  static String _newId() => 'listing-${DateTime.now().microsecondsSinceEpoch}';
}

final currentListingProvider =
    StateNotifierProvider<CurrentListingNotifier, CropListing?>(
  (ref) => CurrentListingNotifier(),
);

/// Quantity to use across the app — falls back to the demo 500 kg so no screen
/// ever divides by zero or shows an empty money figure.
final activeQuantityProvider = Provider<double>((ref) {
  final CropListing? listing = ref.watch(currentListingProvider);
  final double qty = listing?.quantityKg ?? 0;
  return qty > 0 ? qty : 500;
});

final activeCropProvider = Provider<Crop>((ref) {
  final CropListing? listing = ref.watch(currentListingProvider);
  return listing?.crop ?? ref.watch(allCropsProvider).first;
});

/// Runs the photo check for the current listing.
final cropHealthProvider =
    FutureProvider.autoDispose<CropHealthResult>((ref) async {
  final CropService service = ref.watch(cropServiceProvider);
  final CropListing? listing = ref.watch(currentListingProvider);
  if (listing == null) return service.analyzeSample();
  return service.analyze(listing);
});
