import 'package:farm_buddy/core/constants/app_config.dart';
import 'package:farm_buddy/models/farmer.dart';
import 'package:farm_buddy/services/mock_data.dart';

class FarmerService {
  const FarmerService();

  /// [cropFilter] is one of the filter ids used by the chips on the
  /// Nearby Farmers screen: 'all', 'sameCrop', 'nearby', 'seeds',
  /// 'rotation', 'collective'.
  Future<List<NearbyFarmer>> nearby({String? cropFilter}) async {
    await Future<void>.delayed(AppConfig.fakeLatency);
    return filterSync(cropFilter);
  }

  List<NearbyFarmer> filterSync(String? filter) {
    const List<NearbyFarmer> all = MockData.nearbyFarmers;
    switch (filter) {
      case 'sameCrop':
        return all
            .where((NearbyFarmer f) => f.tagKeys.contains('tag.sameCrop'))
            .toList();
      case 'nearby':
        return all.where((NearbyFarmer f) => f.distanceKm <= 5).toList();
      case 'seeds':
        return all
            .where((NearbyFarmer f) => f.tagKeys.contains('tag.seeds'))
            .toList();
      case 'rotation':
        return all
            .where((NearbyFarmer f) => f.tagKeys.contains('tag.rotation'))
            .toList();
      case 'collective':
        return all
            .where((NearbyFarmer f) => f.tagKeys.contains('tag.collective'))
            .toList();
      case 'all':
      default:
        return all;
    }
  }

  Future<GroupSaleOpportunity> groupSale() async {
    await Future<void>.delayed(AppConfig.shortLatency);
    return MockData.groupSale;
  }
}
