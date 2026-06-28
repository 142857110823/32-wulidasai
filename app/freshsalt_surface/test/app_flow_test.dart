import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:freshsalt_surface/app.dart';
import 'package:freshsalt_surface/core/services/ai_capture_assistant_service.dart';
import 'package:freshsalt_surface/core/demo/demo_app_scope_provider.dart';
import 'package:freshsalt_surface/core/models/capture_step_bundle.dart';
import 'package:freshsalt_surface/core/models/capture_workflow_controller.dart';
import 'package:freshsalt_surface/core/models/feature_vector.dart';
import 'package:freshsalt_surface/core/models/prediction_result.dart';
import 'package:freshsalt_surface/core/models/quality_control_result.dart';
import 'package:freshsalt_surface/features/capture/capture_page.dart';
import 'package:freshsalt_surface/features/feature_preview/feature_preview_page.dart';
import 'package:freshsalt_surface/features/prediction/prediction_page.dart';
import 'package:freshsalt_surface/features/quality_control/quality_control_page.dart';
import 'package:freshsalt_surface/features/result/result_page.dart';
import 'package:freshsalt_surface/features/roi/roi_page.dart';
import 'package:freshsalt_surface/routing/app_router.dart';

import 'support/demo_fixtures.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Finder buttonWithText(String text) => find.widgetWithText(FilledButton, text);

  List<String> visibleTexts(WidgetTester tester) {
    return find
        .byType(Text)
        .evaluate()
        .map((element) => (element.widget as Text).data)
        .whereType<String>()
        .toList();
  }

  testWidgets('default app boots into platform home', (tester) async {
    tester.view.physicalSize = const Size(1600, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const FreshSaltApp());
    await tester.pumpAndSettle();

    expect(find.byType(MaterialApp), findsOneWidget);
  });

  testWidgets('capture page can run through demo chain to save stage',
      (tester) async {
    tester.view.physicalSize = const Size(1600, 3200);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final scope = await buildDemoScope();

    await tester.pumpWidget(
      DemoAppScopeProvider(
        scope: scope,
        child: MaterialApp(
          onGenerateRoute: AppRouter.onGenerateRoute,
          home: CapturePage(scope: scope),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.widgetWithText(FilledButton, '进入成像质控'));
    await tester.pumpAndSettle();

    await tester.tap(buttonWithText('开始质控'));
    await tester.pumpAndSettle();
    await tester.tap(find.textContaining('I0').last);
    await tester.pumpAndSettle();

    await tester.tap(find.text('使用模拟 I0'));
    await tester.pumpAndSettle();
    expect(find.textContaining('I1'), findsWidgets);

    await tester.tap(find.text('使用模拟 I1'));
    await tester.pumpAndSettle();
    expect(find.textContaining('ROI'), findsWidgets);

    await tester.tap(find.textContaining('确认 ROI'));
    await tester.pumpAndSettle();
    await tester.tap(find.textContaining('特征').last);
    await tester.pumpAndSettle();

    await tester.tap(buttonWithText('提取特征'));
    await tester.pumpAndSettle();
    await tester.tap(find.textContaining('结果计算').last);
    await tester.pumpAndSettle();

    await tester.tap(buttonWithText('开始结果计算'));
    await tester.pumpAndSettle();

    expect(find.textContaining('保存'), findsWidgets);
  });

  testWidgets('quality control can unlock baseline stage', (tester) async {
    final scope = await buildDemoScope();
    final controller = CaptureWorkflowController(
      selectedCase: demoCaptureCases[1],
    );

    Future<void> runQualityControl() async {
      final qc = await scope.qualityControlService.performQualityControl(
        imageMetadata: demoImageMetadataMedium,
      );
      controller.applyQualityControl(qc);
    }

    await tester.pumpWidget(
      MaterialApp(
        home: QualityControlPage(
          bundle: CaptureStepBundle(
            controller: controller,
            workflowState: controller.workflowState,
            runQualityControl: runQualityControl,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(buttonWithText('开始质控'));
    await tester.pumpAndSettle();

    expect(find.textContaining('I0'), findsWidgets);
  });

  testWidgets('roi confirm unlocks feature preview stage', (tester) async {
    final controller = CaptureWorkflowController(
      selectedCase: demoCaptureCases.first,
    );
    controller.applyQualityControl(
      await buildDemoScope().then(
        (scope) => scope.qualityControlService.performQualityControl(
          imageMetadata: demoImageMetadataMedium,
        ),
      ),
    );
    controller.useBaselineImage('/mock/baseline.png');
    controller.useSaltedImage('/mock/salted.png');

    await tester.pumpWidget(
      MaterialApp(
        home: RoiPage(
          bundle: CaptureStepBundle(
            controller: controller,
            workflowState: controller.workflowState,
            roiPolygon: demoRoiPolygon,
            confirmRoi: controller.confirmRoi,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byType(FilledButton));
    await tester.pumpAndSettle();

    expect(find.textContaining('特征'), findsWidgets);
  });

  testWidgets('roi page supports manual drag and updates area summary',
      (tester) async {
    tester.view.physicalSize = const Size(1600, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final controller = CaptureWorkflowController(
      selectedCase: demoCaptureCases.first,
    );
    controller.applyQualityControl(
      await buildDemoScope().then(
        (scope) => scope.qualityControlService.performQualityControl(
          imageMetadata: demoImageMetadataMedium,
        ),
      ),
    );
    controller.useBaselineImage('/mock/baseline.png');
    controller.useSaltedImage('/mock/salted.png');

    await tester.pumpWidget(
      MaterialApp(
        home: RoiPage(
          bundle: CaptureStepBundle(
            controller: controller,
            workflowState: controller.workflowState,
            roiPolygon: demoRoiPolygon,
            confirmRoi: controller.confirmRoi,
            updateRoiPolygon: controller.updateRoiPolygon,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('面积'), findsOneWidget);
    expect(find.textContaining('4.00 cm2'), findsWidgets);

    final moveRegion = find.byKey(const ValueKey('roi-move-region'));
    await tester.drag(moveRegion, const Offset(36, 24));
    await tester.pumpAndSettle();

    final texts = visibleTexts(tester).join('\n');
    expect(texts, contains('待确认'));
    expect(texts, contains('中心'));
  });

  testWidgets('feature page and prediction page can progress independently',
      (tester) async {
    final controller = CaptureWorkflowController(
      selectedCase: demoCaptureCases.first,
    );
    controller.applyQualityControl(
      await buildDemoScope().then(
        (scope) => scope.qualityControlService.performQualityControl(
          imageMetadata: demoImageMetadataMedium,
        ),
      ),
    );
    controller.useBaselineImage('/mock/baseline.png');
    controller.useSaltedImage('/mock/salted.png');
    controller.confirmRoi();

    Future<void> runFeatureExtraction() async {
      final scope = await buildDemoScope();
      final featureVector = await scope.featureExtractionService.extractFeatures(
        sessionId: 'feature_stage_session',
        imageMetadata: demoImageMetadataMedium,
        differenceImagePath: '/mock/feature_stage_diff.png',
      );
      controller.applyFeatureVector(
        sessionId: 'feature_stage_session',
        featureVector: featureVector,
      );
    }

    await tester.pumpWidget(
      MaterialApp(
        home: FeaturePreviewPage(
          bundle: CaptureStepBundle(
            controller: controller,
            workflowState: controller.workflowState,
            runFeatureExtraction: runFeatureExtraction,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(buttonWithText('提取特征'));
    await tester.pumpAndSettle();

    Future<void> runPredictionWorkflow() async {
      controller.applyPrediction(
        sessionId: 'prediction_stage_session',
        featureVector: buildFeatureVector(),
        predictionResult: buildPredictionResult(
          sessionId: 'prediction_stage_session',
          sampleId: 'sample_prediction_stage',
          predictedValue: 0.35,
        ),
        pendingSavePayload: const {'session_id': 'prediction_stage_session'},
      );
    }

    await tester.pumpWidget(
      MaterialApp(
        home: PredictionPage(
          bundle: CaptureStepBundle(
            controller: controller,
            workflowState: controller.workflowState,
            runPredictionWorkflow: runPredictionWorkflow,
            saveSession: () async {
              controller.markSaved();
            },
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(buttonWithText('开始结果计算'));
    await tester.pumpAndSettle();
    expect(find.textContaining('保存'), findsWidgets);
  });

  testWidgets('feature page shows default preview before extraction',
      (tester) async {
    final controller = CaptureWorkflowController(
      selectedCase: demoCaptureCases.first,
    );
    controller.applyQualityControl(
      await buildDemoScope().then(
        (scope) => scope.qualityControlService.performQualityControl(
          imageMetadata: demoImageMetadataMedium,
        ),
      ),
    );
    controller.useBaselineImage('/mock/baseline.png');
    controller.useSaltedImage('/mock/salted.png');
    controller.confirmRoi();

    await tester.pumpWidget(
      MaterialApp(
        home: FeaturePreviewPage(
          bundle: CaptureStepBundle(
            controller: controller,
            workflowState: controller.workflowState,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final texts = visibleTexts(tester).join('\n');
    expect(texts, contains('特征预览'));
    expect(texts, contains('特征数量'));
    expect(texts, contains('4'));
    expect(texts, contains('difference_image_path: preview_pending'));
    expect(texts, contains('提取特征'));
  });

  testWidgets('prediction page shows default preview before calculation',
      (tester) async {
    final controller = CaptureWorkflowController(
      selectedCase: demoCaptureCases.first,
    );
    controller.applyQualityControl(
      await buildDemoScope().then(
        (scope) => scope.qualityControlService.performQualityControl(
          imageMetadata: demoImageMetadataMedium,
        ),
      ),
    );
    controller.useBaselineImage('/mock/baseline.png');
    controller.useSaltedImage('/mock/salted.png');
    controller.confirmRoi();

    await tester.pumpWidget(
      MaterialApp(
        home: PredictionPage(
          bundle: CaptureStepBundle(
            controller: controller,
            workflowState: controller.workflowState,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final texts = visibleTexts(tester).join('\n');
    expect(texts, contains('结果计算'));
    expect(texts, contains('0.350'));
    expect(texts, contains('开始结果计算'));
    expect(texts, contains('有效范围: 0.00 - 0.75 mg/cm2 NaCl eq.'));
  });

  testWidgets('result page can open a specific saved session', (tester) async {
    final scope = await buildDemoScope();
    final older = buildPredictionResult(
      sessionId: 'session_low',
      sampleId: 'sample_low',
      predictedValue: 0.05,
    );
    final newer = buildPredictionResult(
      sessionId: 'session_high',
      sampleId: 'sample_high',
      predictedValue: 0.70,
    );

    await scope.sessionRepository.saveSession(
      sessionId: older.sessionId,
      sampleId: older.sampleId,
      result: older,
      featureVector: buildFeatureVector(),
      baselineImagePath: '/mock/baseline_low.png',
      saltedImagePath: '/mock/salted_low.png',
      roiPolygon: demoRoiPolygon,
    );
    await scope.sessionRepository.saveSession(
      sessionId: newer.sessionId,
      sampleId: newer.sampleId,
      result: newer,
      featureVector: buildFeatureVector(),
      baselineImagePath: '/mock/baseline_high.png',
      saltedImagePath: '/mock/salted_high.png',
      roiPolygon: demoRoiPolygon,
    );

    await tester.pumpWidget(
      DemoAppScopeProvider(
        scope: scope,
        child: const MaterialApp(
          home: ResultPage(sessionId: 'session_low'),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('sample_low'), findsOneWidget);
    expect(find.text('sample_high'), findsNothing);
  });

  testWidgets('result page shows AI explanation card', (tester) async {
    final scope = await buildDemoScope();
    final result = buildPredictionResult(
      sessionId: 'session_ai',
      sampleId: 'sample_ai',
      predictedValue: 0.70,
    );

    await scope.sessionRepository.saveSession(
      sessionId: result.sessionId,
      sampleId: result.sampleId,
      result: result,
      featureVector: buildFeatureVector(),
      baselineImagePath: '/mock/baseline_ai.png',
      saltedImagePath: '/mock/salted_ai.png',
      roiPolygon: demoRoiPolygon,
    );

    await tester.pumpWidget(
      DemoAppScopeProvider(
        scope: scope,
        child: const MaterialApp(
          home: ResultPage(sessionId: 'session_ai'),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.drag(find.byType(ListView), const Offset(0, -700));
    await tester.pumpAndSettle();

    final texts = visibleTexts(tester).join('\n');
    expect(texts, contains('AI 解释卡'));
    expect(texts, contains('可信度'));
    expect(texts, contains('关键影响因子'));
    expect(texts, contains('本次结果为何偏高/偏低'));
    expect(texts, contains('是否建议重拍或补采'));
  });

  testWidgets('quality control page shows real pixel metrics', (tester) async {
    final controller = CaptureWorkflowController(
      selectedCase: demoCaptureCases.first,
    );
    controller.useBaselineImage(
      'workspace_baseline.png',
      isSimulated: false,
    );
    controller.applyQualityControl(
      QualityControlResult(
        status: 'passed',
        checks: const {
          'exposure': true,
          'sharpness': true,
          'gray_card_rsd': true,
          'roi_integrity': true,
        },
        metrics: const {
          'source_mode': 'real_image_pixels',
          'exposure_saturation_ratio': 0.0012,
          'laplacian_variance': 132.4,
          'gray_card_rsd': 0.0113,
        },
        failureReasons: const [],
        checkedAt: DateTime(2026, 6, 26),
      ),
    );

    await tester.pumpWidget(
      MaterialApp(
        home: QualityControlPage(
          bundle: CaptureStepBundle(
            controller: controller,
            workflowState: controller.workflowState,
            qualityControl: controller.qualityControlResult,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.drag(find.byType(ListView), const Offset(0, -900));
    await tester.pumpAndSettle();

    final texts = visibleTexts(tester);
    expect(texts.join('\n'), contains('real_image_pixels'));
    expect(texts.join('\n'), contains('saturation_ratio:'));
    expect(texts.join('\n'), contains('laplacian_variance:'));
    expect(texts.join('\n'), contains('gray_card_rsd:'));
  });

  testWidgets('feature page shows extraction metadata for real images',
      (tester) async {
    final controller = CaptureWorkflowController(
      selectedCase: demoCaptureCases.first,
    );
    controller.useBaselineImage(
      'workspace_baseline.png',
      isSimulated: false,
    );
    controller.useSaltedImage(
      'workspace_salted.png',
      isSimulated: false,
    );
    controller.confirmRoi();
    controller.applyFeatureVector(
      sessionId: 'real_feature_session',
      featureVector: FeatureVector(
        sessionId: 'real_feature_session',
        features: const {
          'dL': 0.12,
          'da': 0.04,
          'db': 0.09,
          'dS': 0.02,
          'whiteness_index': 0.52,
          'specular_ratio': 0.08,
          'glcm_contrast': 0.11,
          'glcm_energy': 0.84,
          'dL2': 0.0144,
          'specular_ratio2': 0.0064,
        },
        metadata: const {
          'extraction_method': 'real_image_pixels',
          'roi_source': 'center_crop',
        },
        extractedAt: DateTime(2026, 6, 26),
      ),
    );

    await tester.pumpWidget(
      MaterialApp(
        home: FeaturePreviewPage(
          bundle: CaptureStepBundle(
            controller: controller,
            workflowState: controller.workflowState,
            featureVector: controller.featureVector,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.drag(find.byType(ListView), const Offset(0, -900));
    await tester.pumpAndSettle();

    final texts = visibleTexts(tester);
    expect(texts.join('\n'), contains('real_image_pixels'));
    expect(texts.join('\n'), contains('提取方式'));
    expect(texts.join('\n'), contains('real_image_pixels'));
    expect(texts.join('\n'), contains('ROI 来源'));
    expect(texts.join('\n'), contains('center_crop'));
    expect(
      texts.join('\n'),
      contains('difference_image_path: not_generated'),
    );
  });

  test('AI capture assistant builds retake advice for failed real-image QC', () {
    const service = AiCaptureAssistantService();
    final advice = service.build(
      hasImportedRealImages: true,
      qualityControlResult: QualityControlResult(
        status: 'failed',
        checks: const {
          'exposure': false,
          'sharpness': true,
          'gray_card_rsd': false,
          'roi_integrity': true,
        },
        metrics: const {'source_mode': 'real_image_pixels'},
        failureReasons: const [],
        checkedAt: DateTime(2026, 6, 27),
      ),
      roiPolygon: demoRoiPolygon,
    );

    expect(advice, isNotNull);
    expect(advice!.qualityStatus, '建议重拍');
    expect(advice.roiSuggestion, contains('ROI'));
    expect(advice.reasons.join('\n'), contains('高光过强'));
    expect(advice.reasons.join('\n'), contains('灰卡'));
  });
}

FeatureVector buildFeatureVector() {
  return FeatureVector(
    sessionId: 'feature_session',
    features: const {
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
    extractedAt: DateTime.parse('2026-06-14T12:00:00Z'),
  );
}

PredictionResult buildPredictionResult({
  required String sessionId,
  required String sampleId,
  required double predictedValue,
}) {
  return PredictionResult(
    sessionId: sessionId,
    sampleId: sampleId,
    modelId: 'freshsalt_rgb_cucumber_darkbox_v1',
    predictedValue: predictedValue,
    unit: 'mg/cm2 NaCl eq.',
    sourceMode: 'simulated',
    resultStatus: 'valid',
    confidenceLevel: 'high',
    validRangeMin: 0.0,
    validRangeMax: 0.75,
    featureVector: const {
      'dL': -8.5,
      'da': 3.5,
    },
    hardwareProfileId: demoHardwareProfileId,
    warnings:
        predictedValue >= 0.7 ? const ['approaching upper bound'] : const [],
    createdAt: DateTime.parse('2026-06-14T12:00:00Z'),
  );
}
