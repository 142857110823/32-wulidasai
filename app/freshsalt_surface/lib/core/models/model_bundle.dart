class ModelBundle {
  ModelBundle({
    required this.modelId,
    required this.source,
    required this.sampleType,
    required this.target,
    required this.unit,
    required this.validRange,
    required this.featureOrder,
    required this.coefficients,
    required this.intercept,
    required this.warnings,
    this.metadata = const {},
  });

  final String modelId;
  final String source;
  final String sampleType;
  final String target;
  final String unit;
  final List<double> validRange;
  final List<String> featureOrder;
  final List<double> coefficients;
  final double intercept;
  final List<String> warnings;
  final Map<String, dynamic> metadata;

  List<String> validate() {
    final errors = <String>[];

    if (modelId.isEmpty) {
      errors.add('model_id 不能为空');
    }
    if (source.isEmpty) {
      errors.add('source 不能为空');
    }
    if (sampleType.isEmpty) {
      errors.add('sample_type 不能为空');
    }
    if (validRange.length != 2 || validRange[0] >= validRange[1]) {
      errors.add('valid_range_mg_cm2 必须是 [min, max] 且 min < max');
    }
    if (featureOrder.isEmpty) {
      errors.add('feature_order 不能为空');
    }
    if (coefficients.isEmpty) {
      errors.add('coefficients 不能为空');
    }
    if (featureOrder.length != coefficients.length) {
      errors.add('feature_order 与 coefficients 长度不一致');
    }

    return errors;
  }

  bool get isSimulated => source == 'simulated';

  factory ModelBundle.fromJson(Map<String, dynamic> json) {
    return ModelBundle(
      modelId: json['model_id'] as String? ?? '',
      source: json['source'] as String? ?? 'real',
      sampleType: json['sample_type'] as String? ?? '',
      target: json['target'] as String? ?? '',
      unit: json['unit'] as String? ?? 'mg/cm2 NaCl eq.',
      validRange: List<double>.from(
        ((json['valid_range_mg_cm2'] as List?) ?? const [0.0, 1.0]).map(
          (value) => (value as num).toDouble(),
        ),
      ),
      featureOrder:
          List<String>.from(json['feature_order'] as List? ?? const []),
      coefficients: List<double>.from(
        ((json['coefficients'] as List?) ?? const []).map(
          (value) => (value as num).toDouble(),
        ),
      ),
      intercept: (json['intercept'] as num? ?? 0.0).toDouble(),
      warnings: List<String>.from(json['warnings'] as List? ?? const []),
      metadata: Map<String, dynamic>.from(
        json['metadata'] as Map? ?? const {},
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'model_id': modelId,
      'source': source,
      'sample_type': sampleType,
      'target': target,
      'unit': unit,
      'valid_range_mg_cm2': validRange,
      'feature_order': featureOrder,
      'coefficients': coefficients,
      'intercept': intercept,
      'warnings': warnings,
      'metadata': metadata,
    };
  }
}
