/// The farmer using the app.
class FarmerProfile {
  const FarmerProfile({
    required this.name,
    required this.village,
    required this.district,
    required this.phone,
    required this.crops,
    required this.totalListings,
    required this.totalTransactions,
    required this.totalEarnings,
    required this.memberSince,
    required this.rating,
  });

  final String name;
  final String village;
  final String district;

  /// Stored masked. The full number never appears on screen.
  final String phone;

  final List<String> crops;
  final int totalListings;
  final int totalTransactions;
  final double totalEarnings;
  final String memberSince;
  final double rating;

  String get location => '$village, $district';

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
}
