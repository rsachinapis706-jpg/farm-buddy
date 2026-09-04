import 'package:flutter/material.dart';

import 'package:farm_buddy/models/enums.dart';

/// One thing the farmer can actually do today. Never a diagnosis, never a
/// chemical prescription — an action, in plain words.
class HealthAdvice {
  const HealthAdvice({
    required this.titleKey,
    required this.bodyKey,
    required this.icon,
  });

  final String titleKey;
  final String bodyKey;
  final IconData icon;
}

/// The result of the crop photo check, translated out of model-speak.
class CropHealthResult {
  const CropHealthResult({
    required this.cropName,
    required this.cropEmoji,
    required this.status,
    required this.confidence,
    required this.summaryKey,
    required this.advice,
    this.imagePath,
    required this.analyzedAt,
  });

  final String cropName;
  final String cropEmoji;
  final HealthStatus status;

  /// 0.0 – 1.0. Shown as "We are 92% sure", never as a raw score.
  final double confidence;

  final String summaryKey;
  final List<HealthAdvice> advice;
  final String? imagePath;
  final DateTime analyzedAt;

  int get confidencePercent => (confidence * 100).round();

  bool get hasImage => imagePath != null && imagePath!.isNotEmpty;

  /// When we are not sure enough, the UI leans harder on "ask an expert".
  bool get isLowConfidence => confidence < 0.75;
}
