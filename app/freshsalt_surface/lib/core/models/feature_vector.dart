class FeatureVector {
  FeatureVector({
    required this.sessionId,
    required this.features,
    this.differenceImagePath,
    this.metadata = const {},
    required this.extractedAt,
  });

  final String sessionId;
  final Map<String, double> features;
  final String? differenceImagePath;
  final Map<String, dynamic> metadata;
  final DateTime extractedAt;

  bool get isValid {
    return features.values.every((value) => !value.isNaN && !value.isInfinite);
  }

  List<double> toOrderedArray(List<String> featureOrder) {
    return featureOrder.map((name) => features[name] ?? 0.0).toList();
  }

  factory FeatureVector.fromJson(Map<String, dynamic> json) {
    return FeatureVector(
      sessionId: json['session_id'] as String? ?? '',
      features: Map<String, double>.from(
        (json['features'] as Map? ?? const {}).map(
          (key, value) => MapEntry(key as String, (value as num).toDouble()),
        ),
      ),
      differenceImagePath: json['difference_image_path'] as String?,
      metadata: Map<String, dynamic>.from(
        json['metadata'] as Map? ?? const {},
      ),
      extractedAt: DateTime.parse(
        json['extracted_at'] as String? ?? DateTime.now().toIso8601String(),
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'session_id': sessionId,
      'features': features,
      'difference_image_path': differenceImagePath,
      'metadata': metadata,
      'extracted_at': extractedAt.toIso8601String(),
    };
  }
}
