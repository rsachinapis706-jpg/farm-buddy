/// Another farmer growing near you.
class NearbyFarmer {
  const NearbyFarmer({
    required this.id,
    required this.name,
    required this.village,
    required this.distanceKm,
    required this.cropName,
    required this.cropEmoji,
    required this.quantityKg,
    required this.avatarSeed,
    required this.latitude,
    required this.longitude,
    required this.tagKeys,
    this.isConnected = false,
    required this.rating,
  });

  final String id;
  final String name;
  final String village;
  final double distanceKm;

  final String cropName;
  final String cropEmoji;
  final double quantityKg;

  /// Drives the generated avatar colour + initials block. No photos, no
  /// uploads, no privacy problem.
  final int avatarSeed;

  /// Approximate village coordinates, so the live map can place them.
  final double latitude;
  final double longitude;

  /// Localisation keys: 'tag.sameCrop', 'tag.seeds', 'tag.rotation', ...
  final List<String> tagKeys;

  final bool isConnected;
  final double rating;

  String get initials {
    final List<String> parts = name
        .trim()
        .split(RegExp(r'\s+'))
        .where((String p) => p.isNotEmpty)
        .toList();
    if (parts.isEmpty) return '?';
    String head(String value) =>
        value.isEmpty ? '' : value.substring(0, 1).toUpperCase();
    if (parts.length == 1) return head(parts.first);
    return '${head(parts.first)}${head(parts.last)}';
  }

  NearbyFarmer copyWith({bool? isConnected}) {
    return NearbyFarmer(
      id: id,
      name: name,
      village: village,
      distanceKm: distanceKm,
      cropName: cropName,
      cropEmoji: cropEmoji,
      quantityKg: quantityKg,
      avatarSeed: avatarSeed,
      latitude: latitude,
      longitude: longitude,
      tagKeys: tagKeys,
      isConnected: isConnected ?? this.isConnected,
      rating: rating,
    );
  }
}

/// "You and 3 nearby farmers have 1,850 kg of tomatoes."
class GroupSaleOpportunity {
  const GroupSaleOpportunity({
    required this.cropName,
    required this.cropEmoji,
    required this.farmerCount,
    required this.totalQuantityKg,
    required this.betterPricePerKg,
    required this.soloPricePerKg,
    required this.members,
  });

  final String cropName;
  final String cropEmoji;

  /// Number of *other* farmers in the pool.
  final int farmerCount;

  final double totalQuantityKg;
  final double betterPricePerKg;
  final double soloPricePerKg;
  final List<NearbyFarmer> members;

  double get pricePerKgGain => betterPricePerKg - soloPricePerKg;

  /// What the whole group earns extra by selling together.
  double get extraEarning => pricePerKgGain * totalQuantityKg;

  /// What *you* earn extra on your own quantity.
  double extraEarningFor(double yourQuantityKg) =>
      pricePerKgGain * yourQuantityKg;
}
