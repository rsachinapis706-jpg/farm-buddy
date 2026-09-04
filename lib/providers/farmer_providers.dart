import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:farm_buddy/models/farmer.dart';
import 'package:farm_buddy/services/farmer_service.dart';

final farmerServiceProvider =
    Provider<FarmerService>((ref) => const FarmerService());

/// One of: 'all', 'sameCrop', 'nearby', 'seeds', 'rotation', 'collective'.
final farmerFilterProvider = StateProvider<String>((ref) => 'all');

final nearbyFarmersProvider =
    FutureProvider.autoDispose<List<NearbyFarmer>>((ref) async {
  final FarmerService service = ref.watch(farmerServiceProvider);
  final String filter = ref.watch(farmerFilterProvider);
  return service.nearby(cropFilter: filter);
});

final groupSaleProvider = FutureProvider<GroupSaleOpportunity>((ref) async {
  return ref.watch(farmerServiceProvider).groupSale();
});

/// Farmers this user has sent a connect request to. Kept in memory for the
/// demo; a real build would persist this.
final connectedFarmerIdsProvider =
    StateProvider<Set<String>>((ref) => <String>{});
