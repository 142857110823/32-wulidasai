import '../models/feature_vector.dart';

class FeatureExtractionService {
  Future<FeatureVector> extractFeatures({
    required String sessionId,
    required Map<String, dynamic> imageMetadata,
    String? differenceImagePath,
  }) async {
    final features = <String, double>{
      'dL': (imageMetadata['color_dL'] as num? ?? 0.0).toDouble(),
      'da': (imageMetadata['color_da'] as num? ?? 0.0).toDouble(),
      'db': (imageMetadata['color_db'] as num? ?? 0.0).toDouble(),
      'dS': (imageMetadata['color_dS'] as num? ?? 0.0).toDouble(),
      'whiteness_index':
          (imageMetadata['whiteness_index'] as num? ?? 0.0).toDouble(),
      'specular_ratio':
          (imageMetadata['specular_ratio'] as num? ?? 0.0).toDouble(),
      'glcm_contrast':
          (imageMetadata['glcm_contrast'] as num? ?? 0.0).toDouble(),
      'glcm_energy': (imageMetadata['glcm_energy'] as num? ?? 0.0).toDouble(),
      'dL2': (imageMetadata['dL2'] as num? ?? 0.0).toDouble(),
      'specular_ratio2':
          (imageMetadata['specular_ratio2'] as num? ?? 0.0).toDouble(),
    };

    _validateFeatureVector(features);

    return FeatureVector(
      sessionId: sessionId,
      features: features,
      differenceImagePath: differenceImagePath,
      metadata: {
        'extraction_method': 'simulated',
        'roi_source': imageMetadata['roi_source'],
      },
      extractedAt: DateTime.now(),
    );
  }

  void _validateFeatureVector(Map<String, double> features) {
    for (final entry in features.entries) {
      if (entry.value.isNaN || entry.value.isInfinite) {
        throw Exception('特征 ${entry.key} 非法: ${entry.value}');
      }
    }
  }

  Map<String, double> performColorCorrection({
    required List<int> grayCardRgb,
    required List<int> targetGrayRgb,
  }) {
    final rScale = targetGrayRgb[0] / (grayCardRgb[0] + 1);
    final gScale = targetGrayRgb[1] / (grayCardRgb[1] + 1);
    final bScale = targetGrayRgb[2] / (grayCardRgb[2] + 1);

    return {
      'r_scale': rScale,
      'g_scale': gScale,
      'b_scale': bScale,
    };
  }

  List<double> normalizeFeatures(
    List<double> features,
    List<double> means,
    List<double> stds,
  ) {
    if (features.length != means.length || features.length != stds.length) {
      throw Exception('特征、均值、标准差长度不一致');
    }

    return List<double>.generate(
      features.length,
      (index) => (features[index] - means[index]) / (stds[index] + 1e-8),
    );
  }
}
