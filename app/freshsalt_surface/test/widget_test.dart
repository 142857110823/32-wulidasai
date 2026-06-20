import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:freshsalt_surface/app.dart';
import 'package:freshsalt_surface/core/demo/demo_app_scope.dart';
import 'package:freshsalt_surface/core/demo/demo_app_scope_provider.dart';
import 'package:freshsalt_surface/core/models/feature_vector.dart';
import 'package:freshsalt_surface/core/models/prediction_result.dart';
import 'package:freshsalt_surface/features/home/mode_selection_page.dart';
import 'package:freshsalt_surface/features/result/result_page.dart';
import 'package:freshsalt_surface/routing/app_router.dart';

import 'support/demo_fixtures.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Finder sectionButton(String sectionTitle, String buttonText) {
    final sectionCard = find.ancestor(
      of: find.text(sectionTitle),
      matching: find.byType(Card),
    );
    final filled = find.descendant(
      of: sectionCard,
      matching: find.widgetWithText(FilledButton, buttonText).hitTestable(),
    );
    if (filled.evaluate().isNotEmpty) {
      return filled;
    }
    return find.descendant(
      of: sectionCard,
      matching: find.widgetWithText(OutlinedButton, buttonText).hitTestable(),
    );
  }

  Finder nextStageButton(String buttonText) => find.text(buttonText).last;

  Future<void> pumpDefaultApp(WidgetTester tester) async {
    await tester.pumpWidget(const FreshSaltApp());
    await tester.pumpAndSettle();
  }

  Future<void> pumpDemoApp(WidgetTester tester) async {
    await tester.pumpWidget(FreshSaltApp(scopeFuture: buildDemoScope()));
    await tester.pumpAndSettle();
  }

  Future<void> completeCaptureWizard(WidgetTester tester) async {
    await tester.tap(find.text('开始采集预测'));
    await tester.pumpAndSettle();
    await tester.tap(sectionButton('当前阶段主操作', '开始质控'));
    await tester.pumpAndSettle();
    await tester.tap(nextStageButton('下一步：I0 基线图'));
    await tester.pumpAndSettle();
    await tester.tap(sectionButton('当前阶段主操作', '使用模拟 I0'));
    await tester.pumpAndSettle();
    await tester.tap(nextStageButton('下一步：I1 待测图'));
    await tester.pumpAndSettle();
    await tester.tap(sectionButton('当前阶段主操作', '使用模拟 I1'));
    await tester.pumpAndSettle();
    await tester.tap(nextStageButton('下一步：ROI 摘要'));
    await tester.pumpAndSettle();
    await tester.tap(sectionButton('当前阶段主操作', '确认 ROI'));
    await tester.pumpAndSettle();
    await tester.tap(nextStageButton('下一步：特征预览'));
    await tester.pumpAndSettle();
    await tester.tap(sectionButton('当前阶段主操作', '提取特征'));
    await tester.pumpAndSettle();
    await tester.tap(nextStageButton('下一步：结果计算'));
    await tester.pumpAndSettle();
    await tester.tap(sectionButton('当前阶段主操作', '开始演示预测'));
    await tester.pumpAndSettle();
  }

  testWidgets('默认启动直接进入平台首页工作台', (tester) async {
    tester.view.physicalSize = const Size(1600, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await pumpDefaultApp(tester);

    expect(find.text('首页工作台'), findsOneWidget);
    expect(find.text('平台状态'), findsOneWidget);
    expect(find.text('核心入口'), findsOneWidget);
    expect(find.text('模块入口'), findsOneWidget);
    expect(find.text('最近模拟趋势'), findsWidgets);
    expect(find.text('模式选择与边界确认'), findsNothing);
  });

  testWidgets('首页显示平台观感而不是阶段直跳集合', (tester) async {
    tester.view.physicalSize = const Size(1600, 2600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await pumpDemoApp(tester);

    expect(find.text('主链概览'), findsOneWidget);
    expect(find.text('核心入口'), findsOneWidget);
    expect(find.text('点击验证台'), findsOneWidget);
    expect(find.text('阶段工作台入口'), findsNothing);
    expect(find.text('成像质控'), findsNothing);
    expect(find.text('特征预览'), findsNothing);
  });

  testWidgets('模式选择页仍可独立展示异步加载反馈', (tester) async {
    final completer = Completer<void>();

    await tester.pumpWidget(
      MaterialApp(
        home: ModeSelectionPage(
          onEnterDemoWorkbench: () => completer.future,
          onEnterCaptureDemo: () async {},
          onEnterValidationDemo: () async {},
        ),
      ),
    );

    await tester.tap(find.text('进入演示工作台'));
    await tester.pump();

    expect(find.text('正在加载演示模式...'), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    completer.complete();
    await tester.pumpAndSettle();

    expect(find.text('正在加载演示模式...'), findsNothing);
  });

  testWidgets('应用等待 scopeFuture 时不提前创建路由容器', (tester) async {
    final completer = Completer<AppScope>();

    await tester.pumpWidget(
      FreshSaltApp(scopeFuture: completer.future),
    );
    await tester.pump();

    expect(find.byType(MaterialApp), findsNothing);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('首页开始采集预测后直接进入成像质控阶段', (tester) async {
    tester.view.physicalSize = const Size(1600, 3200);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await pumpDemoApp(tester);

    await tester.tap(find.text('开始采集预测'));
    await tester.pumpAndSettle();

    expect(find.text('成像质控'), findsWidgets);
    expect(find.text('开始质控'), findsOneWidget);
  });

  testWidgets('采集主链完成预测后出现保存入口', (tester) async {
    tester.view.physicalSize = const Size(1600, 3200);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await pumpDemoApp(tester);
    await completeCaptureWizard(tester);

    expect(find.text('保存到历史'), findsOneWidget);
    expect(find.textContaining('mg/cm2 NaCl eq.'), findsWidgets);
  });

  testWidgets('保存后可打开结果详情并显示关键区块', (tester) async {
    tester.view.physicalSize = const Size(1600, 3200);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await pumpDemoApp(tester);
    await completeCaptureWizard(tester);

    await tester.tap(find.text('保存到历史'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('查看结果详情'));
    await tester.pumpAndSettle();

    expect(find.text('主结果卡片'), findsOneWidget);
    expect(find.text('范围标尺'), findsOneWidget);
    expect(find.text('模型输入摘要'), findsOneWidget);
    expect(find.text('图像证据'), findsOneWidget);
    expect(find.text('风险说明'), findsOneWidget);
    expect(find.text('后续动作'), findsOneWidget);
  });

  testWidgets('历史记录页显示模拟记录并提供删除入口', (tester) async {
    tester.view.physicalSize = const Size(1600, 3200);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await pumpDemoApp(tester);
    await completeCaptureWizard(tester);
    await tester.tap(find.text('保存到历史'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('查看结果详情'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('查看历史记录'));
    await tester.pumpAndSettle();

    expect(find.text('仅看模拟数据'), findsOneWidget);
    expect(find.byIcon(Icons.delete_outline), findsWidgets);
  });

  testWidgets('分析总览通过模块入口打开并显示平台状态与最近案例', (tester) async {
    tester.view.physicalSize = const Size(1600, 3200);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await pumpDemoApp(tester);
    await completeCaptureWizard(tester);
    await tester.tap(find.text('保存到历史'));
    await tester.pumpAndSettle();
    tester.state<NavigatorState>(find.byType(Navigator)).popUntil(
          (route) => route.isFirst,
        );
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('分析总览'));
    await tester.tap(find.text('分析总览'));
    await tester.pumpAndSettle();

    expect(find.text('模拟平台状态'), findsOneWidget);
    expect(find.text('最近案例'), findsOneWidget);
    expect(find.textContaining('模拟数据'), findsWidgets);
  });

  testWidgets('报告页显示导出与边界区块', (tester) async {
    tester.view.physicalSize = const Size(1600, 3200);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await pumpDemoApp(tester);
    await completeCaptureWizard(tester);
    await tester.tap(find.text('保存到历史'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('查看结果详情'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('生成报告预览'));
    await tester.pumpAndSettle();

    expect(find.text('CSV 导出内容'), findsOneWidget);
    expect(find.text('导出检查清单'), findsOneWidget);
    expect(find.text('平台边界'), findsOneWidget);
  });

  testWidgets('点击验证台可运行并显示平台覆盖范围与汇总', (tester) async {
    tester.view.physicalSize = const Size(1600, 3200);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await pumpDemoApp(tester);

    await tester.ensureVisible(find.text('打开验证台'));
    await tester.tap(find.text('打开验证台'));
    await tester.pumpAndSettle();

    expect(find.text('平台覆盖范围'), findsOneWidget);
    expect(find.textContaining('断言规则'), findsWidgets);

    await tester.tap(find.text('一键跑完整点击链'));
    await tester.pumpAndSettle();

    expect(find.textContaining('总数'), findsWidgets);
    expect(find.textContaining('通过'), findsWidgets);
  });

  testWidgets('样品页可带着指定样品进入成像质控阶段', (tester) async {
    tester.view.physicalSize = const Size(1600, 2800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await pumpDemoApp(tester);

    await tester.ensureVisible(find.text('样品管理'));
    await tester.tap(find.text('样品管理'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('开始该样品采集').at(1));
    await tester.pumpAndSettle();

    expect(find.text('成像质控'), findsWidgets);
    expect(find.text('开始质控'), findsOneWidget);
    expect(find.text('sample_demo_medium'), findsWidgets);
  });

  testWidgets('结果详情页根据传入 sessionId 打开指定记录', (tester) async {
    final scope = await buildDemoScope();

    await scope.sessionRepository.saveSession(
      sessionId: 'session_low',
      sampleId: 'sample_low',
      result: buildPredictionResult(
        sessionId: 'session_low',
        sampleId: 'sample_low',
        predictedValue: 0.05,
      ),
      featureVector: buildFeatureVector(),
      baselineImagePath: '/mock/baseline_low.png',
      saltedImagePath: '/mock/salted_low.png',
      roiPolygon: demoRoiPolygon,
    );
    await scope.sessionRepository.saveSession(
      sessionId: 'session_high',
      sampleId: 'sample_high',
      result: buildPredictionResult(
        sessionId: 'session_high',
        sampleId: 'sample_high',
        predictedValue: 0.70,
      ),
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

  test('buildFreshSaltInitialRoutes keeps /result in the initial route stack', () {
    final routes = buildFreshSaltInitialRoutes(
      initialRoute: AppRouter.result,
      onGenerateRoute: AppRouter.onGenerateRoute,
    );

    expect(routes.length, equals(2));
    expect(routes.first.settings.name, equals(AppRouter.home));
    expect(routes.last.settings.name, equals(AppRouter.result));
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
