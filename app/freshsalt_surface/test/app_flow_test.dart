import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:freshsalt_surface/app.dart';
import 'package:freshsalt_surface/core/demo/demo_app_scope_provider.dart';
import 'package:freshsalt_surface/core/models/capture_step_bundle.dart';
import 'package:freshsalt_surface/core/models/capture_workflow_controller.dart';
import 'package:freshsalt_surface/core/models/feature_vector.dart';
import 'package:freshsalt_surface/core/models/prediction_result.dart';
import 'package:freshsalt_surface/features/capture/capture_page.dart';
import 'package:freshsalt_surface/features/capture/image_stage_page.dart';
import 'package:freshsalt_surface/features/feature_preview/feature_preview_page.dart';
import 'package:freshsalt_surface/features/prediction/prediction_page.dart';
import 'package:freshsalt_surface/features/quality_control/quality_control_page.dart';
import 'package:freshsalt_surface/features/result/result_page.dart';
import 'package:freshsalt_surface/features/roi/roi_page.dart';
import 'package:freshsalt_surface/routing/app_router.dart';

import 'support/demo_fixtures.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('默认启动保持平台首页为首屏', (tester) async {
    tester.view.physicalSize = const Size(1600, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const FreshSaltApp());
    await tester.pumpAndSettle();

    expect(find.text('首页工作台'), findsOneWidget);
    expect(find.text('模式选择与边界确认'), findsNothing);
  });

  testWidgets('采集页按主链顺序通过阶段页走到保存阶段', (tester) async {
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

    expect(find.text('采集工作台'), findsWidgets);
    expect(find.text('进入当前阶段页面'), findsOneWidget);

    await tester.tap(find.text('进入当前阶段页面'));
    await tester.pumpAndSettle();
    expect(find.text('成像质控'), findsWidgets);

    await tester.tap(find.text('开始质控'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('下一步：I0 基线图').last);
    await tester.pumpAndSettle();
    expect(find.text('I0 基线图'), findsWidgets);

    await tester.tap(find.text('使用模拟 I0'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('下一步：I1 待测图'));
    await tester.pumpAndSettle();
    expect(find.text('I1 待测图'), findsWidgets);

    await tester.tap(find.text('使用模拟 I1'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('下一步：ROI 摘要'));
    await tester.pumpAndSettle();
    expect(find.text('ROI 与灰卡'), findsWidgets);

    await tester.tap(find.text('确认 ROI'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('下一步：特征预览'));
    await tester.pumpAndSettle();
    expect(find.text('特征预览'), findsWidgets);

    await tester.tap(find.text('提取特征'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('下一步：结果计算'));
    await tester.pumpAndSettle();
    expect(find.text('结果计算'), findsWidgets);

    await tester.tap(find.text('开始演示预测'));
    await tester.pumpAndSettle();

    expect(find.text('保存到历史'), findsOneWidget);
    expect(find.text('查看结果详情'), findsNothing);
  });

  testWidgets('采集页显示主链概览与兼容工作台定位，而不是主动作中枢', (tester) async {
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

    expect(find.text('采集工作台'), findsWidgets);
    expect(find.text('采集主链'), findsOneWidget);
    expect(find.text('图像入口'), findsOneWidget);
    expect(find.text('当前阶段'), findsOneWidget);
  });

  testWidgets('质控页可直接执行并解锁 I0', (tester) async {
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

    await tester.tap(find.text('开始质控'));
    await tester.pumpAndSettle();

    expect(find.text('质控通过'), findsOneWidget);
    expect(find.text('下一步：I0 基线图'), findsOneWidget);
  });

  testWidgets('I0 阶段页在完成当前阶段前不允许前进', (tester) async {
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
    var advanced = false;

    await tester.pumpWidget(
      MaterialApp(
        home: ImageStagePage(
          title: 'I0 基线图',
          description: '查看当前基线图阶段状态与模拟图像路径。',
          imagePath: null,
          isReady: false,
          nextLabel: '下一步：I1 待测图',
          nextAction: () => advanced = true,
          bundle: CaptureStepBundle(
            controller: controller,
            workflowState: controller.workflowState,
            useBaselineImage: () {
              controller.useBaselineImage('/mock/from_stage_i0.png');
            },
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('下一步：I1 待测图'), warnIfMissed: false);
    await tester.pumpAndSettle();
    expect(advanced, isFalse);

    await tester.tap(find.text('使用模拟 I0'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('下一步：I1 待测图'));
    await tester.pumpAndSettle();
    expect(advanced, isTrue);
  });

  testWidgets('ROI 页确认后进入特征阶段', (tester) async {
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

    await tester.tap(find.text('确认 ROI'));
    await tester.pumpAndSettle();

    expect(find.textContaining('当前 ROI 已确认'), findsOneWidget);
    expect(find.text('下一步：特征预览'), findsOneWidget);
  });

  testWidgets('特征页和预测页各自承担本阶段主动作', (tester) async {
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

    await tester.tap(find.text('提取特征'));
    await tester.pumpAndSettle();
    expect(find.text('下一步：结果计算'), findsOneWidget);

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

    await tester.tap(find.text('开始演示预测'));
    await tester.pumpAndSettle();
    expect(find.text('保存到历史'), findsOneWidget);
  });

  testWidgets('结果详情页根据 sessionId 打开指定记录', (tester) async {
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
    warnings: predictedValue >= 0.7 ? const ['接近有效范围上限'] : const [],
    createdAt: DateTime.parse('2026-06-14T12:00:00Z'),
  );
}
