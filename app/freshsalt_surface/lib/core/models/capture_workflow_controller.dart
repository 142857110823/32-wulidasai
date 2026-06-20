import '../demo/demo_capture_case.dart';
import 'capture_workflow_state.dart';
import 'feature_vector.dart';
import 'prediction_result.dart';
import 'quality_control_result.dart';

class CaptureWorkflowController {
  CaptureWorkflowController({
    DemoCaptureCase? selectedCase,
  }) : _selectedCase = selectedCase;

  DemoCaptureCase? _selectedCase;
  QualityControlResult? _qualityControlResult;
  FeatureVector? _featureVector;
  PredictionResult? _predictionResult;
  String? _sessionId;
  String? _baselineImagePath;
  String? _saltedImagePath;
  bool _roiConfirmed = false;
  bool _saved = false;
  Map<String, dynamic>? _pendingSavePayload;

  DemoCaptureCase? get selectedCase => _selectedCase;
  QualityControlResult? get qualityControlResult => _qualityControlResult;
  FeatureVector? get featureVector => _featureVector;
  PredictionResult? get predictionResult => _predictionResult;
  String? get sessionId => _sessionId;
  String? get baselineImagePath => _baselineImagePath;
  String? get saltedImagePath => _saltedImagePath;
  bool get roiConfirmed => _roiConfirmed;
  bool get saved => _saved;
  Map<String, dynamic>? get pendingSavePayload => _pendingSavePayload;

  CaptureWorkflowState get workflowState => CaptureWorkflowState(
        qualityControlPassed: _qualityControlResult?.isPassed ?? false,
        baselineReady: _baselineImagePath != null,
        saltedReady: _saltedImagePath != null,
        roiConfirmed: _roiConfirmed,
        predictionReady: _predictionResult != null,
        saved: _saved,
      );

  void selectCase(DemoCaptureCase item) {
    _selectedCase = item;
    resetProgress();
  }

  void resetProgress() {
    _qualityControlResult = null;
    _featureVector = null;
    _predictionResult = null;
    _sessionId = null;
    _baselineImagePath = null;
    _saltedImagePath = null;
    _roiConfirmed = false;
    _saved = false;
    _pendingSavePayload = null;
  }

  void applyQualityControl(QualityControlResult result) {
    _qualityControlResult = result;
    if (!result.isPassed) {
      _featureVector = null;
      _predictionResult = null;
      _saved = false;
      _pendingSavePayload = null;
      _baselineImagePath = null;
      _saltedImagePath = null;
      _roiConfirmed = false;
    }
  }

  void useBaselineImage(String? path) {
    _baselineImagePath = path;
  }

  void useSaltedImage(String? path) {
    _saltedImagePath = path;
  }

  void confirmRoi() {
    _roiConfirmed = true;
  }

  void clearPredictionOutputs() {
    _featureVector = null;
    _predictionResult = null;
    _saved = false;
    _pendingSavePayload = null;
  }

  void applyFeatureVector({
    required String sessionId,
    required FeatureVector featureVector,
  }) {
    _sessionId = sessionId;
    _featureVector = featureVector;
    _predictionResult = null;
    _saved = false;
    _pendingSavePayload = null;
  }

  void applyPrediction({
    required String sessionId,
    required FeatureVector featureVector,
    required PredictionResult predictionResult,
    required Map<String, dynamic> pendingSavePayload,
  }) {
    _sessionId = sessionId;
    _featureVector = featureVector;
    _predictionResult = predictionResult;
    _pendingSavePayload = pendingSavePayload;
    _saved = false;
  }

  void markSaved() {
    _saved = true;
  }
}
