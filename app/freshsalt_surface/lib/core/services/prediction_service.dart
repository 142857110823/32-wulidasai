import '../models/feature_vector.dart';
import '../models/model_bundle.dart';
import '../models/prediction_result.dart';

class PredictionService {
  Future<PredictionResult> predict({
    required String sessionId,
    required String sampleId,
    required FeatureVector featureVector,
    required ModelBundle modelBundle,
    required String hardwareProfileId,
    required String sourceMode,
  }) async {
    if (!featureVector.isValid) {
      return _createErrorResult(
        sessionId: sessionId,
        sampleId: sampleId,
        modelId: modelBundle.modelId,
        hardwareProfileId: hardwareProfileId,
        sourceMode: sourceMode,
        validRangeMin: modelBundle.validRange[0],
        validRangeMax: modelBundle.validRange[1],
        errorMessage: '特征向量无效',
      );
    }

    final orderedFeatures =
        featureVector.toOrderedArray(modelBundle.featureOrder);
    if (orderedFeatures.length != modelBundle.coefficients.length) {
      return _createErrorResult(
        sessionId: sessionId,
        sampleId: sampleId,
        modelId: modelBundle.modelId,
        hardwareProfileId: hardwareProfileId,
        sourceMode: sourceMode,
        validRangeMin: modelBundle.validRange[0],
        validRangeMax: modelBundle.validRange[1],
        errorMessage: '特征维度与模型系数不匹配',
      );
    }

    var prediction = modelBundle.intercept;
    for (var index = 0; index < orderedFeatures.length; index++) {
      prediction += modelBundle.coefficients[index] * orderedFeatures[index];
    }

    prediction = _applySimulatedCalibration(
      sourceMode: sourceMode,
      featureVector: featureVector,
      fallbackPrediction: prediction,
    );

    final warnings = <String>[...modelBundle.warnings];
    var resultStatus = 'valid';
    var confidenceLevel = 'high';
    final isInRange = prediction >= modelBundle.validRange[0] &&
        prediction <= modelBundle.validRange[1];
    final approachingLimit = prediction >= modelBundle.validRange[1] * 0.9 &&
        prediction <= modelBundle.validRange[1];

    if (!isInRange) {
      resultStatus = 'out_of_range';
      confidenceLevel = 'low';
      warnings.add('结果超出模型有效范围');
    } else if (approachingLimit) {
      resultStatus = 'warning';
      confidenceLevel = 'medium';
      warnings.add('结果接近模型有效范围上限');
    }

    if (sourceMode == 'simulated') {
      warnings.add('模拟数据，仅用于交互验证');
      if (confidenceLevel == 'high') {
        confidenceLevel = 'medium';
      }
    }

    return PredictionResult(
      sessionId: sessionId,
      sampleId: sampleId,
      modelId: modelBundle.modelId,
      predictedValue: prediction.clamp(
        modelBundle.validRange[0] - 1.0,
        modelBundle.validRange[1] + 1.0,
      ),
      unit: 'mg/cm2 NaCl eq.',
      sourceMode: sourceMode,
      resultStatus: resultStatus,
      confidenceLevel: confidenceLevel,
      validRangeMin: modelBundle.validRange[0],
      validRangeMax: modelBundle.validRange[1],
      featureVector: featureVector.features,
      hardwareProfileId: hardwareProfileId,
      warnings: warnings,
      createdAt: DateTime.now(),
    );
  }

  double _applySimulatedCalibration({
    required String sourceMode,
    required FeatureVector featureVector,
    required double fallbackPrediction,
  }) {
    if (sourceMode != 'simulated') {
      return fallbackPrediction;
    }

    final roiSource = featureVector.metadata['roi_source'] as String?;
    switch (roiSource) {
      case 'demo_case_low':
        return 0.05;
      case 'demo_case_medium':
        return 0.35;
      case 'demo_case_high':
        return 0.70;
      default:
        return fallbackPrediction;
    }
  }

  PredictionResult _createErrorResult({
    required String sessionId,
    required String sampleId,
    required String modelId,
    required String hardwareProfileId,
    required String sourceMode,
    required double validRangeMin,
    required double validRangeMax,
    required String errorMessage,
  }) {
    return PredictionResult(
      sessionId: sessionId,
      sampleId: sampleId,
      modelId: modelId,
      predictedValue: 0,
      unit: 'mg/cm2 NaCl eq.',
      sourceMode: sourceMode,
      resultStatus: 'error',
      confidenceLevel: 'low',
      validRangeMin: validRangeMin,
      validRangeMax: validRangeMax,
      featureVector: const {},
      hardwareProfileId: hardwareProfileId,
      warnings: <String>[errorMessage],
      createdAt: DateTime.now(),
    );
  }
}
