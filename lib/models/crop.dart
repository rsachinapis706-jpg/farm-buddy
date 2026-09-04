/// A crop the farmer can grow and sell.
class Crop {
  const Crop({
    required this.id,
    required this.name,
    required this.emoji,
    required this.seasonHint,
    required this.indicativePricePerKg,
  });

  final String id;

  /// English name. The UI shows `s('crop.$id')` where a translation exists and
  /// falls back to this.
  final String name;
  final String emoji;

  /// Short plain-language season note, e.g. "Best sold Jan–Mar".
  final String seasonHint;

  final double indicativePricePerKg;

  String get nameKey => 'crop.$id';

  @override
  bool operator ==(Object other) =>
      identical(this, other) || (other is Crop && other.id == id);

  @override
  int get hashCode => id.hashCode;
}

/// What the farmer is selling right now: crop + quantity + photo + location.
/// This single object is the seed of the entire journey.
class CropListing {
  const CropListing({
    required this.id,
    required this.crop,
    required this.quantityKg,
    this.photoPath,
    required this.locationName,
    required this.createdAt,
  });

  final String id;
  final Crop crop;
  final double quantityKg;

  /// File path of the photo taken or picked. Null until the farmer adds one.
  final String? photoPath;

  final String locationName;
  final DateTime createdAt;

  bool get hasPhoto => photoPath != null && photoPath!.isNotEmpty;

  /// The four inputs the product promises. Used to drive the progress ring
  /// on the Add Crop screen.
  int get completedSteps {
    int steps = 1; // crop is always chosen to create a listing
    if (quantityKg > 0) steps++;
    if (hasPhoto) steps++;
    if (locationName.isNotEmpty) steps++;
    return steps;
  }

  static const int totalSteps = 4;

  bool get isReady => quantityKg > 0 && locationName.isNotEmpty;

  CropListing copyWith({
    Crop? crop,
    double? quantityKg,
    String? photoPath,
    String? locationName,
  }) {
    return CropListing(
      id: id,
      crop: crop ?? this.crop,
      quantityKg: quantityKg ?? this.quantityKg,
      photoPath: photoPath ?? this.photoPath,
      locationName: locationName ?? this.locationName,
      createdAt: createdAt,
    );
  }
}
