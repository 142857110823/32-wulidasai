import '../export/export_service.dart';
import '../models/model_bundle.dart';
import '../orchestrator/freshsalt_app_orchestrator.dart';
import '../repositories/click_validation_repository.dart';
import '../repositories/session_repository.dart';
import '../services/click_validation_service.dart';
import '../services/feature_extraction_service.dart';
import '../services/model_bundle_service.dart';
import '../services/prediction_service.dart';
import '../services/quality_control_service.dart';
import 'demo_capture_case.dart';

class AppScope {
  AppScope({
    required this.modelBundleService,
    required this.qualityControlService,
    required this.featureExtractionService,
    required this.predictionService,
    required this.clickValidationRepository,
    required this.clickValidationService,
    required this.sessionRepository,
    required this.exportService,
    required this.orchestrator,
    required this.isDemoMode,
    required String hardwareProfileLabel,
    required this.demoCaptureCases,
    this.demoRoiPolygon,
  }) : _hardwareProfileLabel = hardwareProfileLabel;

  final ModelBundleService modelBundleService;
  final QualityControlService qualityControlService;
  final FeatureExtractionService featureExtractionService;
  final PredictionService predictionService;
  final InMemoryClickValidationRepository clickValidationRepository;
  final ClickValidationService clickValidationService;
  final InMemorySessionRepository sessionRepository;
  final ExportService exportService;
  final FreshSaltAppOrchestrator orchestrator;
  final bool isDemoMode;
  String _hardwareProfileLabel;
  final List<DemoCaptureCase> demoCaptureCases;
  final Map<String, dynamic>? demoRoiPolygon;

  String get hardwareProfileLabel => _hardwareProfileLabel;

  factory AppScope.empty() {
    final modelBundleService = ModelBundleService();
    final qualityControlService = QualityControlService();
    final featureExtractionService = FeatureExtractionService();
    final predictionService = PredictionService();
    final clickValidationRepository = InMemoryClickValidationRepository();
    final clickValidationService = ClickValidationService(
      repository: clickValidationRepository,
    );
    final sessionRepository = InMemorySessionRepository();
    final exportService = ExportService();
    final orchestrator = FreshSaltAppOrchestrator(
      modelBundleService: modelBundleService,
      qualityControlService: qualityControlService,
      featureExtractionService: featureExtractionService,
      predictionService: predictionService,
      clickValidationService: clickValidationService,
      sessionRepository: sessionRepository,
      exportService: exportService,
    );

    return AppScope(
      modelBundleService: modelBundleService,
      qualityControlService: qualityControlService,
      featureExtractionService: featureExtractionService,
      predictionService: predictionService,
      clickValidationRepository: clickValidationRepository,
      clickValidationService: clickValidationService,
      sessionRepository: sessionRepository,
      exportService: exportService,
      orchestrator: orchestrator,
      isDemoMode: false,
      hardwareProfileLabel: '未配置',
      demoCaptureCases: const <DemoCaptureCase>[],
    );
  }

  static Future<AppScope> demo({
    required ModelBundle bundle,
    required String hardwareProfileId,
    required List<DemoCaptureCase> captureCases,
    required Map<String, dynamic> roiPolygon,
  }) async {
    final scope = AppScope.empty();
    await scope.modelBundleService.loadModelBundle(bundle);
    await scope.modelBundleService.activateModelBundle(bundle.modelId);
    scope.orchestrator.setHardwareProfile(hardwareProfileId);
    scope.orchestrator.setSourceMode('simulated');

    return AppScope(
      modelBundleService: scope.modelBundleService,
      qualityControlService: scope.qualityControlService,
      featureExtractionService: scope.featureExtractionService,
      predictionService: scope.predictionService,
      clickValidationRepository: scope.clickValidationRepository,
      clickValidationService: scope.clickValidationService,
      sessionRepository: scope.sessionRepository,
      exportService: scope.exportService,
      orchestrator: scope.orchestrator,
      isDemoMode: true,
      hardwareProfileLabel: hardwareProfileId,
      demoCaptureCases: List<DemoCaptureCase>.unmodifiable(captureCases),
      demoRoiPolygon: Map<String, dynamic>.unmodifiable(roiPolygon),
    );
  }

  void applyHardwareProfile(String hardwareProfileId) {
    _hardwareProfileLabel = hardwareProfileId;
    orchestrator.setHardwareProfile(hardwareProfileId);
  }
}
