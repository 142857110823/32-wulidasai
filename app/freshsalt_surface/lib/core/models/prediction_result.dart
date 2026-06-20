class PredictionResult {
  PredictionResult({
    required this.sessionId,
    required this.sampleId,
    required this.modelId,
    required this.predictedValue,
    required this.unit,
    required this.sourceMode,
    required this.resultStatus,
    required this.confidenceLevel,
    required this.validRangeMin,
    required this.validRangeMax,
    required this.featureVector,
    required this.hardwareProfileId,
    required this.warnings,
    required this.createdAt,
  });

  final String sessionId;
  final String sampleId;
  final String modelId;
  final double predictedValue;
  final String unit;
  final String sourceMode;
  final String resultStatus;
  final String confidenceLevel;
  final double validRangeMin;
  final double validRangeMax;
  final Map<String, dynamic> featureVector;
  final String hardwareProfileId;
  final List<String> warnings;
  final DateTime createdAt;

  bool get isSimulated => sourceMode == 'simulated';

  bool get isOutOfRange {
    return predictedValue < validRangeMin || predictedValue > validRangeMax;
  }

  bool get approachingUpperLimit {
    final threshold = validRangeMax * 0.9;
    return predictedValue >= threshold && predictedValue <= validRangeMax;
  }

  factory PredictionResult.fromJson(Map<String, dynamic> json) {
    return PredictionResult(
      sessionId: json['session_id'] as String? ?? '',
      sampleId: json['sample_id'] as String? ?? '',
      modelId: json['model_id'] as String? ?? '',
      predictedValue: (json['predicted_mg_cm2'] as num? ?? 0.0).toDouble(),
      unit: json['unit'] as String? ?? 'mg/cm2 NaCl eq.',
      sourceMode: json['source_mode'] as String? ?? 'real',
      resultStatus: json['result_status'] as String? ?? 'valid',
      confidenceLevel: json['confidence_level'] as String? ?? 'high',
      validRangeMin: (json['valid_range_min'] as num? ?? 0.0).toDouble(),
      validRangeMax: (json['valid_range_max'] as num? ?? 1.0).toDouble(),
      featureVector: Map<String, dynamic>.from(
        json['feature_vector'] as Map? ?? const {},
      ),
      hardwareProfileId: json['hardware_profile_id'] as String? ?? '',
      warnings: List<String>.from(json['warnings'] as List? ?? const []),
      createdAt: DateTime.parse(
        json['created_at'] as String? ?? DateTime.now().toIso8601String(),
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'session_id': sessionId,
      'sample_id': sampleId,
      'model_id': modelId,
      'predicted_mg_cm2': predictedValue,
      'unit': unit,
      'source_mode': sourceMode,
      'result_status': resultStatus,
      'confidence_level': confidenceLevel,
      'valid_range_min': validRangeMin,
      'valid_range_max': validRangeMax,
      'feature_vector': featureVector,
      'hardware_profile_id': hardwareProfileId,
      'warnings': warnings,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
