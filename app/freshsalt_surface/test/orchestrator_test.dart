import 'package:flutter_test/flutter_test.dart';
import 'package:freshsalt_surface/core/export/export_service.dart';
import 'package:freshsalt_surface/core/models/click_validation_case.dart';
import 'package:freshsalt_surface/core/models/model_bundle.dart';
import 'package:freshsalt_surface/core/orchestrator/freshsalt_app_orchestrator.dart';
import 'package:freshsalt_surface/core/repositories/click_validation_repository.dart';
import 'package:freshsalt_surface/core/repositories/session_repository.dart';
import 'package:freshsalt_surface/core/services/click_validation_service.dart';
import 'package:freshsalt_surface/core/services/feature_extraction_service.dart';
import 'package:freshsalt_surface/core/services/model_bundle_service.dart';
import 'package:freshsalt_surface/core/services/prediction_service.dart';
import 'package:freshsalt_surface/core/services/quality_control_service.dart';

import 'support/demo_fixtures.dart';

void main() {
  group('FreshSaltAppOrchestrator', () {
    late FreshSaltAppOrchestrator orchestrator;
    late ModelBundleService modelBundleService;
    late InMemorySessionRepository sessionRepository;

    setUp(() {
      modelBundleService = ModelBundleService();
      sessionRepository = InMemorySessionRepository();
      orchestrator = FreshSaltAppOrchestrator(
        modelBundleService: modelBundleService,
        qualityControlService: QualityControlService(),
        featureExtractionService: FeatureExtractionService(),
        predictionService: PredictionService(),
        clickValidationService: ClickValidationService(
          repository: InMemoryClickValidationRepository(),
        ),
        sessionRepository: sessionRepository,
        exportService: ExportService(),
      );
    });

    test('完整采集链路可执行但不自动保存结果', () async {
      final bundle = ModelBundle.fromJson(demoModelBundleJson);
      await modelBundleService.loadModelBundle(bundle);
      await modelBundleService.activateModelBundle(bundle.modelId);

      orchestrator.setHardwareProfile(demoHardwareProfileId);
      orchestrator.setSourceMode('simulated');

      final result = await orchestrator.executeFullCaptureWorkflow(
        sessionId: 'session_001',
        sampleId: 'sample_001',
        imageMetadata: demoImageMetadataMedium,
        baselineImagePath: '/mock/baseline.jpg',
        saltedImagePath: '/mock/salted.jpg',
        roiPolygon: demoRoiPolygon,
      );

      expect(result['status'], equals('success'));
      expect(result['results'], isNotNull);
      expect(
        (result['results'] as Map<String, dynamic>)['session_saved'],
        isFalse,
      );
      expect(sessionRepository.getSessionCount(), equals(0));
    });

    test('质控失败时阻断链路', () async {
      final bundle = ModelBundle.fromJson(demoModelBundleJson);
      await modelBundleService.loadModelBundle(bundle);
      await modelBundleService.activateModelBundle(bundle.modelId);

      orchestrator.setHardwareProfile(demoHardwareProfileId);
      orchestrator.setSourceMode('simulated');

      final result = await orchestrator.executeFullCaptureWorkflow(
        sessionId: 'session_002',
        sampleId: 'sample_002',
        imageMetadata: demoImageMetadataOverexposed,
        baselineImagePath: '/mock/baseline.jpg',
        saltedImagePath: '/mock/salted.jpg',
        roiPolygon: demoRoiPolygon,
      );

      expect(result['status'], equals('qc_failed'));
      expect(result['failure_reasons'], isNotEmpty);
    });

    test('未启用模型时返回错误', () async {
      orchestrator.setHardwareProfile(demoHardwareProfileId);
      orchestrator.setSourceMode('simulated');

      final result = await orchestrator.executeFullCaptureWorkflow(
        sessionId: 'session_003',
        sampleId: 'sample_003',
        imageMetadata: demoImageMetadataMedium,
        baselineImagePath: '/mock/baseline.jpg',
        saltedImagePath: '/mock/salted.jpg',
        roiPolygon: demoRoiPolygon,
      );

      expect(result['status'], equals('error'));
      expect((result['error'] as String), contains('模型包'));
    });
  });

  group('点击验证台编排', () {
    late FreshSaltAppOrchestrator orchestrator;
    late ModelBundleService modelBundleService;

    setUp(() async {
      modelBundleService = ModelBundleService();
      orchestrator = FreshSaltAppOrchestrator(
        modelBundleService: modelBundleService,
        qualityControlService: QualityControlService(),
        featureExtractionService: FeatureExtractionService(),
        predictionService: PredictionService(),
        clickValidationService: ClickValidationService(
          repository: InMemoryClickValidationRepository(),
        ),
        sessionRepository: InMemorySessionRepository(),
        exportService: ExportService(),
      );

      final bundle = ModelBundle.fromJson(demoModelBundleJson);
      await modelBundleService.loadModelBundle(bundle);
      await modelBundleService.activateModelBundle(bundle.modelId);
      orchestrator.setHardwareProfile(demoHardwareProfileId);
      orchestrator.setSourceMode('simulated');
    });

    test('可执行接近 M01-M15 的完整点击验证链路', () async {
      final testCases = [
        ClickValidationCase(
          caseId: 'M01_HOME',
          module: 'home_router',
          action: '点击开始采集预测',
          mockInput: const {'source_mode': 'simulated'},
          expectedOutput: const {
            'status': 'success',
            'route': '/quality-control',
          },
        ),
        ClickValidationCase(
          caseId: 'M02_MODEL',
          module: 'model_bundle',
          action: '启用模拟模型',
          mockInput: const {'model_id': 'freshsalt_rgb_cucumber_darkbox_v1'},
          expectedOutput: const {
            'status': 'success',
            'active_model_id': 'freshsalt_rgb_cucumber_darkbox_v1',
          },
        ),
        ClickValidationCase(
          caseId: 'M03_QC_PASS',
          module: 'quality_control',
          action: '执行质控通过案例',
          mockInput: {'image_metadata': demoImageMetadataMedium},
          expectedOutput: const {'qc_status': 'passed', 'all_checks': true},
        ),
        ClickValidationCase(
          caseId: 'M04_QC_FAIL',
          module: 'quality_control',
          action: '执行过曝失败案例',
          mockInput: {'image_metadata': demoImageMetadataOverexposed},
          expectedOutput: const {
            'qc_status': 'failed',
            'failed_checks': 'exposure',
          },
        ),
        ClickValidationCase(
          caseId: 'M05_CAPTURE_I0',
          module: 'capture_i0',
          action: '使用模拟 I0',
          mockInput: const {'baseline_image_path': '/mock/baseline_medium.png'},
          expectedOutput: const {'status': 'success', 'baseline_loaded': true},
        ),
        ClickValidationCase(
          caseId: 'M06_CAPTURE_I1',
          module: 'capture_i1',
          action: '使用模拟 I1',
          mockInput: const {'salted_image_path': '/mock/salted_medium.png'},
          expectedOutput: const {'status': 'success', 'salted_loaded': true},
        ),
        ClickValidationCase(
          caseId: 'M07_ROI',
          module: 'roi',
          action: '确认 ROI',
          mockInput: const {'roi_area_cm2': 4.0, 'roi_within_bounds': true},
          expectedOutput: const {'status': 'success', 'roi_valid': true},
        ),
        ClickValidationCase(
          caseId: 'M08_FEATURE',
          module: 'feature_extraction',
          action: '提取模拟特征',
          mockInput: {
            'session_id': 'validation_feature_session',
            'image_metadata': demoImageMetadataMedium,
          },
          expectedOutput: const {'status': 'success', 'feature_count': 10},
        ),
        ClickValidationCase(
          caseId: 'M09_PREDICT',
          module: 'prediction',
          action: '计算模拟结果',
          mockInput: {
            'session_id': 'validation_prediction_session',
            'sample_id': 'validation_sample_medium',
            'image_metadata': demoImageMetadataMedium,
          },
          expectedOutput: const {'status': 'success', 'predicted_value': 0.35},
        ),
        ClickValidationCase(
          caseId: 'M10_RESULT',
          module: 'result_view',
          action: '打开结果详情图表',
          mockInput: const {'result_status': 'valid'},
          expectedOutput: const {'status': 'success', 'charts_ready': true},
        ),
        ClickValidationCase(
          caseId: 'M11_SAVE',
          module: 'save_history',
          action: '保存到历史',
          mockInput: {
            'session_id': 'validation_saved_session',
            'sample_id': 'validation_saved_sample',
            'baseline_image_path': '/mock/baseline_medium.png',
            'salted_image_path': '/mock/salted_medium.png',
            'roi_polygon': demoRoiPolygon,
            'image_metadata': demoImageMetadataMedium,
          },
          expectedOutput: const {'status': 'success', 'session_saved': true},
        ),
        ClickValidationCase(
          caseId: 'M12_HISTORY',
          module: 'history_view',
          action: '查看历史记录',
          mockInput: const {'is_simulated': true},
          expectedOutput: const {'status': 'success', 'simulated_badge': true},
        ),
        ClickValidationCase(
          caseId: 'M13_ANALYSIS',
          module: 'analysis_view',
          action: '查看分析总览',
          mockInput: const {'record_count': 1},
          expectedOutput: const {'status': 'success', 'analysis_ready': true},
        ),
        ClickValidationCase(
          caseId: 'M14_EXPORT',
          module: 'export_csv',
          action: '校验 CSV 字段',
          mockInput: const {'session_id': 'validation_saved_session'},
          expectedOutput: const {
            'status': 'success',
            'csv_fields_complete': true,
          },
        ),
        ClickValidationCase(
          caseId: 'M15_FULL_CHAIN',
          module: 'full_chain',
          action: '一键跑完整点击链',
          mockInput: const {'chain': 'm01_m14'},
          expectedOutput: const {
            'status': 'success',
            'chain_complete': true,
            'steps_passed': 13,
            'history_saved': true,
            'export_ready': true,
          },
        ),
      ];

      final result = await orchestrator.executeFullClickValidation(testCases);

      expect(result['total'], equals(15));
      expect(result['passed'], equals(15));
      expect(result['failed'], equals(0));
      expect(result['logs'], isList);
    });

    test('M15_FULL_CHAIN 返回的 steps_passed 与实际执行步数一致', () async {
      final result = await orchestrator.executeFullClickValidation([
        ClickValidationCase(
          caseId: 'M15_FULL_CHAIN',
          module: 'full_chain',
          action: '一键跑完整点击链',
          mockInput: const {'chain': 'm01_m14'},
          expectedOutput: const {
            'status': 'success',
            'chain_complete': true,
            'steps_passed': 13,
            'history_saved': true,
            'export_ready': true,
          },
        ),
      ]);

      expect(result['passed'], equals(1));
      final logs = List<Map<String, dynamic>>.from(
        result['logs'] as List? ?? const <Map<String, dynamic>>[],
      );
      expect(logs, isNotEmpty);
      expect(logs.single['actual_output']['steps_passed'], equals(13));
    });
  });
}
