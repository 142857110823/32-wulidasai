import 'package:flutter_test/flutter_test.dart';
import 'package:freshsalt_surface/core/export/export_service.dart';
import 'package:freshsalt_surface/core/models/capture_workflow_controller.dart';
import 'package:freshsalt_surface/core/models/capture_workflow_state.dart';
import 'package:freshsalt_surface/core/models/feature_vector.dart';
import 'package:freshsalt_surface/core/models/model_bundle.dart';
import 'package:freshsalt_surface/core/models/prediction_result.dart';
import 'package:freshsalt_surface/core/repositories/session_repository.dart';
import 'package:freshsalt_surface/core/services/feature_extraction_service.dart';
import 'package:freshsalt_surface/core/services/model_bundle_service.dart';
import 'package:freshsalt_surface/core/services/prediction_service.dart';
import 'package:freshsalt_surface/core/services/quality_control_service.dart';

import 'support/demo_fixtures.dart';

void main() {
  group('模型包服务', () {
    late ModelBundleService service;

    setUp(() {
      service = ModelBundleService();
    });

    test('可以加载模型包', () async {
      final bundle = ModelBundle.fromJson(demoModelBundleJson);
      final errors = await service.loadModelBundle(bundle);
      expect(errors, isEmpty);
    });

    test('可以激活模型包', () async {
      final bundle = ModelBundle.fromJson(demoModelBundleJson);
      await service.loadModelBundle(bundle);
      final errors = await service.activateModelBundle(bundle.modelId);
      expect(errors, isEmpty);
      expect(service.activeModel, isNotNull);
      expect(service.activeModel!.modelId, equals(bundle.modelId));
    });

    test('可校验硬件兼容性', () {
      final bundle = ModelBundle.fromJson(demoModelBundleJson);
      expect(
        service.validateHardwareCompatibility(demoHardwareProfileId, bundle),
        isTrue,
      );
      expect(
        service.validateHardwareCompatibility('darkbox_v2', bundle),
        isFalse,
      );
    });

    test('可校验结果范围', () {
      final bundle = ModelBundle.fromJson(demoModelBundleJson);
      expect(service.isResultInValidRange(0.35, bundle), isTrue);
      expect(service.isResultInValidRange(1.0, bundle), isFalse);
      expect(service.isResultInValidRange(-0.1, bundle), isFalse);
    });
  });

  group('质控服务', () {
    late QualityControlService service;

    setUp(() {
      service = QualityControlService();
    });

    test('中负载模拟图像通过质控', () async {
      final result = await service.performQualityControl(
        imageMetadata: demoImageMetadataMedium,
      );
      expect(result.isPassed, isTrue);
      expect(result.checks['exposure'], isTrue);
      expect(result.checks['sharpness'], isTrue);
      expect(result.checks['gray_card_rsd'], isTrue);
      expect(result.checks['roi_integrity'], isTrue);
    });

    test('过曝图像触发质控失败', () async {
      final result = await service.performQualityControl(
        imageMetadata: demoImageMetadataOverexposed,
      );
      expect(result.isPassed, isFalse);
      expect(result.checks['exposure'], isFalse);
      expect(result.failureReasons, isNotEmpty);
    });

    test('模糊图像触发清晰度失败', () async {
      final result = await service.performQualityControl(
        imageMetadata: demoImageMetadataBlurry,
      );
      expect(result.isPassed, isFalse);
      expect(result.checks['sharpness'], isFalse);
    });

    test('ROI 越界触发 ROI 失败', () async {
      final result = await service.performQualityControl(
        imageMetadata: demoImageMetadataRoiOutOfBounds,
      );
      expect(result.isPassed, isFalse);
      expect(result.checks['roi_integrity'], isFalse);
    });
  });

  group('特征提取服务', () {
    late FeatureExtractionService service;

    setUp(() {
      service = FeatureExtractionService();
    });

    test('能提取完整十维特征', () async {
      final featureVector = await service.extractFeatures(
        sessionId: 'session_001',
        imageMetadata: demoImageMetadataMedium,
      );

      expect(featureVector.isValid, isTrue);
      expect(featureVector.features.length, equals(10));
      expect(featureVector.features['dL'], isNotNull);
      expect(featureVector.features['whiteness_index'], isNotNull);
    });

    test('支持特征归一化', () {
      final normalized = service.normalizeFeatures(
        [1.0, 2.0, 3.0],
        [0.5, 1.5, 2.5],
        [0.5, 0.5, 0.5],
      );
      expect(normalized.length, equals(3));
      expect(normalized[0], closeTo(1.0, 1e-6));
    });

    test('支持灰卡颜色校正比例计算', () {
      final scales = service.performColorCorrection(
        grayCardRgb: [128, 128, 128],
        targetGrayRgb: [200, 200, 200],
      );

      expect(scales['r_scale'], isNotNull);
      expect(scales['r_scale']!, greaterThan(1.0));
    });
  });

  group('预测服务', () {
    late PredictionService service;

    setUp(() {
      service = PredictionService();
    });

    test('可输出预测结果', () async {
      final bundle = ModelBundle.fromJson(demoModelBundleJson);
      final featureVector = FeatureVector(
        sessionId: 'session_001',
        features: {
          'dL': -2.5,
          'da': 1.2,
          'db': 0.8,
          'dS': -0.5,
          'whiteness_index': 0.08,
          'specular_ratio': 0.05,
          'glcm_contrast': 0.12,
          'glcm_energy': 0.85,
          'dL2': 6.25,
          'specular_ratio2': 0.0025,
        },
        extractedAt: DateTime.now(),
      );

      final result = await service.predict(
        sessionId: 'session_001',
        sampleId: 'sample_001',
        featureVector: featureVector,
        modelBundle: bundle,
        hardwareProfileId: demoHardwareProfileId,
        sourceMode: 'simulated',
      );

      expect(result.resultStatus, isNotEmpty);
      expect(result.confidenceLevel, isNotEmpty);
      expect(
        result.predictedValue,
        inInclusiveRange(
          bundle.validRange[0] - 1.0,
          bundle.validRange[1] + 1.0,
        ),
      );
    });

    test('高负载输入会产生警告', () async {
      final bundle = ModelBundle.fromJson(demoModelBundleJson);
      final featureVector = FeatureVector(
        sessionId: 'session_002',
        features: {
          'dL': -15.2,
          'da': 6.8,
          'db': 4.5,
          'dS': -3.5,
          'whiteness_index': 0.45,
          'specular_ratio': 0.32,
          'glcm_contrast': 0.48,
          'glcm_energy': 0.68,
          'dL2': 231.04,
          'specular_ratio2': 0.1024,
        },
        extractedAt: DateTime.now(),
      );

      final result = await service.predict(
        sessionId: 'session_002',
        sampleId: 'sample_002',
        featureVector: featureVector,
        modelBundle: bundle,
        hardwareProfileId: demoHardwareProfileId,
        sourceMode: 'simulated',
      );

      expect(result.warnings, isNotEmpty);
    });
  });

  group('会话仓储', () {
    late InMemorySessionRepository repository;
    late PredictionResult mockResult;
    late FeatureVector mockFeatures;

    setUp(() {
      repository = InMemorySessionRepository();
      mockResult = PredictionResult(
        sessionId: 'session_001',
        sampleId: 'sample_001',
        modelId: 'model_001',
        predictedValue: 0.35,
        unit: 'mg/cm2 NaCl eq.',
        sourceMode: 'simulated',
        resultStatus: 'valid',
        confidenceLevel: 'high',
        validRangeMin: 0.0,
        validRangeMax: 0.75,
        featureVector: const {'dL': -8.5},
        hardwareProfileId: demoHardwareProfileId,
        warnings: const [],
        createdAt: DateTime.now(),
      );
      mockFeatures = FeatureVector(
        sessionId: 'session_001',
        features: const {'dL': -8.5},
        extractedAt: DateTime.now(),
      );
    });

    test('可保存并读取会话', () async {
      await repository.saveSession(
        sessionId: 'session_001',
        sampleId: 'sample_001',
        result: mockResult,
        featureVector: mockFeatures,
        baselineImagePath: '/path/to/baseline.jpg',
        saltedImagePath: '/path/to/salted.jpg',
        roiPolygon: const {'area': 4.0},
      );

      final retrieved = await repository.getSession('session_001');
      expect(retrieved, isNotNull);
      expect(retrieved!['sample_id'], equals('sample_001'));
    });

    test('可按 simulated 过滤会话', () async {
      await repository.saveSession(
        sessionId: 'session_001',
        sampleId: 'sample_001',
        result: mockResult,
        featureVector: mockFeatures,
        baselineImagePath: '/path/to/baseline.jpg',
        saltedImagePath: '/path/to/salted.jpg',
        roiPolygon: const {'area': 4.0},
      );

      final simulated = await repository.getAllSessions(isSimulated: true);
      expect(simulated.length, equals(1));
      expect(simulated[0]['is_simulated'], isTrue);
    });
  });

  group('CSV 导出服务', () {
    late ExportService service;
    late PredictionResult mockResult;

    setUp(() {
      service = ExportService();
      mockResult = PredictionResult(
        sessionId: 'session_001',
        sampleId: 'sample_001',
        modelId: 'model_001',
        predictedValue: 0.35,
        unit: 'mg/cm2 NaCl eq.',
        sourceMode: 'simulated',
        resultStatus: 'valid',
        confidenceLevel: 'high',
        validRangeMin: 0.0,
        validRangeMax: 0.75,
        featureVector: const {
          'dL': -8.5,
          'da': 3.5,
          'db': 2.1,
          'dS': -1.8,
          'whiteness_index': 0.24,
          'specular_ratio': 0.18,
          'glcm_contrast': 0.28,
          'glcm_energy': 0.78,
          'dL2': 72.25,
          'specular_ratio2': 0.0324,
        },
        hardwareProfileId: demoHardwareProfileId,
        warnings: const [],
        createdAt: DateTime.now(),
      );
    });

    test('可生成单行 CSV', () {
      final row = service.generateCsvRow(
        sessionId: 'session_001',
        sampleId: 'sample_001',
        result: mockResult,
        roiAreaCm2: 4.0,
        baselineImagePath: '/path/to/baseline.jpg',
        saltedImagePath: '/path/to/salted.jpg',
      );

      expect(row, isNotEmpty);
      expect(row.contains('session_001'), isTrue);
      expect(row.contains('0.3500'), isTrue);
    });

    test('可生成报告预览', () {
      final preview = service.generateReportPreview(
        sampleId: 'sample_001',
        result: mockResult,
        roiAreaCm2: 4.0,
        baselineImagePath: '/path/to/baseline.jpg',
        saltedImagePath: '/path/to/salted.jpg',
      );

      expect(preview.contains('FreshSalt Surface'), isTrue);
      expect(preview.contains('0.3500'), isTrue);
      expect(preview.contains(demoHardwareProfileId), isTrue);
    });
  });

  group('采集工作流状态', () {
    test('默认处于第 1 阶段并锁定后续步骤', () {
      const state = CaptureWorkflowState();

      expect(state.currentStage, equals(1));
      expect(state.nextStageLabel, equals('开始质控'));
      expect(state.canOpenQualityDetail, isFalse);
      expect(state.lockedStages, contains('I0 基线图'));
      expect(state.lockedStages, contains('保存'));
    });

    test('质控通过后进入第 2 阶段并解锁 I0', () {
      const state = CaptureWorkflowState(
        qualityControlPassed: true,
      );

      expect(state.currentStage, equals(2));
      expect(state.canUseBaseline, isTrue);
      expect(state.canOpenQualityDetail, isTrue);
      expect(state.nextStageLabel, equals('使用模拟 I0'));
    });

    test('结果生成但未保存时处于第 5 阶段', () {
      const state = CaptureWorkflowState(
        qualityControlPassed: true,
        baselineReady: true,
        saltedReady: true,
        roiConfirmed: true,
        predictionReady: true,
      );

      expect(state.currentStage, equals(5));
      expect(state.canOpenPredictionDetail, isTrue);
      expect(state.canSave, isTrue);
      expect(state.nextStageLabel, equals('保存并查看结果'));
    });

    test('保存后进入第 6 阶段', () {
      const state = CaptureWorkflowState(
        qualityControlPassed: true,
        baselineReady: true,
        saltedReady: true,
        roiConfirmed: true,
        predictionReady: true,
        saved: true,
      );

      expect(state.currentStage, equals(6));
      expect(state.nextStageLabel, equals('保存并查看结果'));
    });
  });

  group('采集工作流控制器', () {
    test('切换案例会重置已完成进度', () {
      final controller = CaptureWorkflowController(
        selectedCase: demoCaptureCases.first,
      );
      controller.useBaselineImage('/mock/baseline.png');
      controller.useSaltedImage('/mock/salted.png');
      controller.confirmRoi();

      controller.selectCase(demoCaptureCases.last);

      expect(controller.selectedCase?.id, equals(demoCaptureCases.last.id));
      expect(controller.baselineImagePath, isNull);
      expect(controller.saltedImagePath, isNull);
      expect(controller.roiConfirmed, isFalse);
      expect(controller.workflowState.currentStage, equals(1));
    });

    test('应用预测结果后进入可保存状态', () {
      final controller = CaptureWorkflowController(
        selectedCase: demoCaptureCases.first,
      );
      final prediction = PredictionResult(
        sessionId: 'session_demo',
        sampleId: 'sample_demo',
        modelId: 'freshsalt_rgb_cucumber_darkbox_v1',
        predictedValue: 0.35,
        unit: 'mg/cm2 NaCl eq.',
        sourceMode: 'simulated',
        resultStatus: 'valid',
        confidenceLevel: 'high',
        validRangeMin: 0.0,
        validRangeMax: 0.75,
        featureVector: const {'dL': -8.5},
        hardwareProfileId: demoHardwareProfileId,
        warnings: const [],
        createdAt: DateTime.now(),
      );
      final features = FeatureVector(
        sessionId: 'session_demo',
        features: const {'dL': -8.5},
        extractedAt: DateTime.now(),
      );

      controller.applyPrediction(
        sessionId: 'session_demo',
        featureVector: features,
        predictionResult: prediction,
        pendingSavePayload: const {'session_id': 'session_demo'},
      );

      expect(controller.predictionResult, isNotNull);
      expect(controller.featureVector, isNotNull);
      expect(controller.workflowState.canSave, isTrue);
      expect(controller.workflowState.currentStage, equals(5));
    });
  });
}
