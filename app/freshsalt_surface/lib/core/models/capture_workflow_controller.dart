import '../demo/demo_capture_case.dart';
import 'capture_workflow_state.dart';
import 'dart:typed_data';
import 'feature_vector.dart';
import 'prediction_result.dart';
import 'quality_control_result.dart';

class CaptureWorkflowController {
  CaptureWorkflowController({
    DemoCaptureCase? selectedCase,
    Map<String, dynamic>? initialRoiPolygon,
  })  : _selectedCase = selectedCase,
        _initialRoiPolygon = initialRoiPolygon == null
            ? null
            : Map<String, dynamic>.from(initialRoiPolygon),
        _roiPolygon = initialRoiPolygon == null
            ? null
            : Map<String, dynamic>.from(initialRoiPolygon);

  DemoCaptureCase? _selectedCase;
  final Map<String, dynamic>? _initialRoiPolygon;
  QualityControlResult? _qualityControlResult;
  FeatureVector? _featureVector;
  PredictionResult? _predictionResult;
  String? _sessionId;
  String? _baselineImagePath;
  String? _saltedImagePath;
  Uint8List? _baselineImageBytes;
  Uint8List? _saltedImageBytes;
  bool _baselineUsesSimulatedSource = true;
  bool _saltedUsesSimulatedSource = true;
  bool _roiConfirmed = false;
  Map<String, dynamic>? _roiPolygon;
  bool _saved = false;
  Map<String, dynamic>? _pendingSavePayload;

  DemoCaptureCase? get selectedCase => _selectedCase;
  QualityControlResult? get qualityControlResult => _qualityControlResult;
  FeatureVector? get featureVector => _featureVector;
  PredictionResult? get predictionResult => _predictionResult;
  String? get sessionId => _sessionId;
  String? get baselineImagePath => _baselineImagePath;
  String? get saltedImagePath => _saltedImagePath;
  Uint8List? get baselineImageBytes => _baselineImageBytes;
  Uint8List? get saltedImageBytes => _saltedImageBytes;
  bool get baselineUsesSimulatedSource => _baselineUsesSimulatedSource;
  bool get saltedUsesSimulatedSource => _saltedUsesSimulatedSource;
  Map<String, dynamic>? get roiPolygon => _roiPolygon;
  bool get hasImportedRealImages =>
      (_baselineImagePath != null && !_baselineUsesSimulatedSource) ||
      (_saltedImagePath != null && !_saltedUsesSimulatedSource);
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
    _baselineImageBytes = null;
    _saltedImageBytes = null;
    _baselineUsesSimulatedSource = true;
    _saltedUsesSimulatedSource = true;
    _roiConfirmed = false;
    _roiPolygon = _initialRoiPolygon == null
        ? null
        : Map<String, dynamic>.from(_initialRoiPolygon);
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
      _roiConfirmed = false;
    }
  }

  void useBaselineImage(
    String? path, {
    bool isSimulated = true,
    Uint8List? imageBytes,
  }) {
    _baselineImagePath = path;
    _baselineImageBytes = imageBytes;
    _baselineUsesSimulatedSource = isSimulated;
  }

  void useSaltedImage(
    String? path, {
    bool isSimulated = true,
    Uint8List? imageBytes,
  }) {
    _saltedImagePath = path;
    _saltedImageBytes = imageBytes;
    _saltedUsesSimulatedSource = isSimulated;
  }

  void confirmRoi() {
    _roiConfirmed = true;
  }

  void updateRoiPolygon(Map<String, dynamic> roiPolygon) {
    _roiPolygon = Map<String, dynamic>.from(roiPolygon);
    _roiConfirmed = false;
    _featureVector = null;
    _predictionResult = null;
    _saved = false;
    _pendingSavePayload = null;
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
