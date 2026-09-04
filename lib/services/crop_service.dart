import 'package:farm_buddy/core/constants/app_config.dart';
import 'package:farm_buddy/models/crop.dart';
import 'package:farm_buddy/models/crop_health.dart';
import 'package:farm_buddy/services/mock_data.dart';

/// Crop catalogue and the photo check.
///
/// In the demo build `analyze` returns a deterministic result so a judge sees
/// the same screen twice in a row. Swapping in a real on-device model means
/// replacing one method — the UI never learns anything about the model.
class CropService {
  const CropService();

  List<Crop> allCrops() => MockData.crops;

  Crop cropById(String id) => MockData.cropById(id);

  Future<CropHealthResult> analyze(CropListing listing) async {
    await Future<void>.delayed(const Duration(milliseconds: 1600));

    // Deterministic demo behaviour: a photo of an "even" listing id shows the
    // healthy path, otherwise the "possible disease" path — so both states are
    // reachable on stage without hunting for a diseased leaf.
    final bool healthy = listing.id.hashCode.isEven;

    return healthy
        ? MockData.healthyResult(imagePath: listing.photoPath)
        : MockData.diseasedResult(imagePath: listing.photoPath);
  }

  /// Used when a farmer taps "Check Crop" from Home without a listing yet.
  Future<CropHealthResult> analyzeSample() async {
    await Future<void>.delayed(AppConfig.fakeLatency);
    return MockData.healthyResult();
  }
}
