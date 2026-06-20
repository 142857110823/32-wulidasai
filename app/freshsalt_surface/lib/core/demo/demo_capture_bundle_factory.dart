import '../models/capture_step_bundle.dart';
import '../models/capture_workflow_controller.dart';
import 'demo_app_scope.dart';

CaptureStepBundle buildDemoCaptureBundle(
  AppScope scope, {
  String? initialCaseId,
}) {
  final initialCase = _resolveInitialCase(scope, initialCaseId);
  final controller = CaptureWorkflowController(selectedCase: initialCase);

  Future<void> runQualityControl() async {
    if (initialCase == null) {
      return;
    }
    final qc = await scope.qualityControlService.performQualityControl(
      imageMetadata: initialCase.imageMetadata,
    );
    controller.applyQualityControl(qc);
  }

  Future<void> runPredictionWorkflow() async {
    final activeModel = scope.modelBundleService.activeModel;
    if (initialCase == null || activeModel == null) {
      return;
    }

    final sessionId = controller.sessionId ??
        'demo_prediction_${DateTime.now().millisecondsSinceEpoch}';
    final featureVector = await scope.featureExtractionService.extractFeatures(
      sessionId: sessionId,
      imageMetadata: initialCase.imageMetadata,
      differenceImagePath: '/mock/demo_prediction_diff.png',
    );
    final prediction = await scope.predictionService.predict(
      sessionId: sessionId,
      sampleId: initialCase.sampleId,
      featureVector: featureVector,
      modelBundle: activeModel,
      hardwareProfileId: scope.hardwareProfileLabel,
      sourceMode: 'simulated',
    );

    controller.applyPrediction(
      sessionId: sessionId,
      featureVector: featureVector,
      predictionResult: prediction,
      pendingSavePayload: {
        'session_id': sessionId,
        'sample_id': initialCase.sampleId,
        'baseline_image_path':
            controller.baselineImagePath ?? initialCase.baselineImagePath,
        'salted_image_path':
            controller.saltedImagePath ?? initialCase.saltedImagePath,
        'roi_polygon': scope.demoRoiPolygon ?? const <String, dynamic>{},
      },
    );
  }

  Future<void> runFeatureExtraction() async {
    if (initialCase == null) {
      return;
    }

    final sessionId =
        controller.sessionId ?? 'demo_feature_${DateTime.now().millisecondsSinceEpoch}';
    final featureVector = await scope.featureExtractionService.extractFeatures(
      sessionId: sessionId,
      imageMetadata: initialCase.imageMetadata,
      differenceImagePath: '/mock/demo_feature_diff.png',
    );
    controller.applyFeatureVector(
      sessionId: sessionId,
      featureVector: featureVector,
    );
  }

  Future<void> saveSession() async {
    final prediction = controller.predictionResult;
    final featureVector = controller.featureVector;
    final payload = controller.pendingSavePayload;
    if (prediction == null || featureVector == null || payload == null) {
      return;
    }

    await scope.sessionRepository.saveSession(
      sessionId: payload['session_id'] as String,
      sampleId: payload['sample_id'] as String,
      result: prediction,
      featureVector: featureVector,
      baselineImagePath: payload['baseline_image_path'] as String,
      saltedImagePath: payload['salted_image_path'] as String,
      roiPolygon: Map<String, dynamic>.from(
        payload['roi_polygon'] as Map? ?? const <String, dynamic>{},
      ),
    );
    controller.markSaved();
  }

  return CaptureStepBundle(
    controller: controller,
    baselineImagePath: initialCase?.baselineImagePath,
    saltedImagePath: initialCase?.saltedImagePath,
    roiPolygon: scope.demoRoiPolygon,
    runQualityControl: runQualityControl,
    useBaselineImage: () => controller.useBaselineImage(
      initialCase?.baselineImagePath,
    ),
    useSaltedImage: () => controller.useSaltedImage(
      initialCase?.saltedImagePath,
    ),
    confirmRoi: controller.confirmRoi,
    runFeatureExtraction: runFeatureExtraction,
    runPredictionWorkflow: runPredictionWorkflow,
    saveSession: saveSession,
  );
}

dynamic _resolveInitialCase(AppScope scope, String? initialCaseId) {
  if (scope.demoCaptureCases.isEmpty) {
    return null;
  }
  if (initialCaseId != null) {
    for (final item in scope.demoCaptureCases) {
      if (item.id == initialCaseId) {
        return item;
      }
    }
  }
  return scope.demoCaptureCases.length > 1
      ? scope.demoCaptureCases[1]
      : scope.demoCaptureCases.first;
}
