import 'capture_workflow_controller.dart';
import 'capture_workflow_state.dart';
import 'feature_vector.dart';
import 'prediction_result.dart';
import 'quality_control_result.dart';

class CaptureStepBundle {
  const CaptureStepBundle({
    this.qualityControl,
    this.featureVector,
    this.predictionResult,
    this.baselineImagePath,
    this.saltedImagePath,
    this.roiPolygon,
    this.workflowState = const CaptureWorkflowState(),
    this.controller,
    this.runQualityControl,
    this.useBaselineImage,
    this.useSaltedImage,
    this.importBaselineImage,
    this.importSaltedImage,
    this.confirmRoi,
    this.updateRoiPolygon,
    this.runFeatureExtraction,
    this.runPredictionWorkflow,
    this.saveSession,
  });

  final QualityControlResult? qualityControl;
  final FeatureVector? featureVector;
  final PredictionResult? predictionResult;
  final String? baselineImagePath;
  final String? saltedImagePath;
  final Map<String, dynamic>? roiPolygon;
  final CaptureWorkflowState workflowState;
  final CaptureWorkflowController? controller;

  final Future<void> Function()? runQualityControl;
  final void Function()? useBaselineImage;
  final void Function()? useSaltedImage;
  final Future<void> Function()? importBaselineImage;
  final Future<void> Function()? importSaltedImage;
  final void Function()? confirmRoi;
  final void Function(Map<String, dynamic> roiPolygon)? updateRoiPolygon;
  final Future<void> Function()? runFeatureExtraction;
  final Future<void> Function()? runPredictionWorkflow;
  final Future<void> Function()? saveSession;
}
