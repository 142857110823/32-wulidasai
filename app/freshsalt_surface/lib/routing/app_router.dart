import 'package:flutter/material.dart';

import '../core/demo/demo_app_scope.dart';
import '../core/demo/demo_app_scope_provider.dart';
import '../core/demo/demo_capture_bundle_factory.dart';
import '../core/models/capture_step_bundle.dart';
import '../features/analysis/analysis_page.dart';
import '../features/capture/capture_page.dart';
import '../features/feature_preview/feature_preview_page.dart';
import '../features/hardware/hardware_config_page.dart';
import '../features/model_bundle/model_bundle_page.dart';
import '../features/prediction/prediction_page.dart';
import '../features/quality_control/quality_control_page.dart';
import '../features/roi/roi_page.dart';
import '../features/sample/sample_page.dart';
import '../features/settings/settings_page.dart';
import '../shared/widgets/platform_bottom_nav_shell.dart';

class AppRouter {
  static const home = '/';
  static const capture = '/capture';
  static const result = '/result';
  static const history = '/history';
  static const report = '/report';
  static const demoValidation = '/demo-validation';
  static const modelBundle = '/model-bundle';
  static const analysis = '/analysis';
  static const sample = '/sample';
  static const settingsRoute = '/settings';
  static const qualityControl = '/quality-control';
  static const roi = '/roi';
  static const featurePreview = '/feature-preview';
  static const prediction = '/prediction';
  static const hardwareConfig = '/hardware-config';
  static const baselineStage = '/capture/baseline-stage';
  static const saltedStage = '/capture/salted-stage';

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    return MaterialPageRoute<void>(
      settings: settings,
      builder: (context) {
        final scope =
            DemoAppScopeProvider.maybeOf(context) ?? DemoAppScopeProvider.of(context);

        switch (settings.name) {
          case home:
            return const PlatformBottomNavShell(currentRoute: home);
          case result:
            return PlatformBottomNavShell(
              currentRoute: result,
              resultSessionId: settings.arguments as String?,
            );
          case history:
            return const PlatformBottomNavShell(currentRoute: history);
          case report:
            return const PlatformBottomNavShell(currentRoute: report);
          case demoValidation:
            return const PlatformBottomNavShell(currentRoute: demoValidation);
          case capture:
            final args = Map<String, dynamic>.from(
              settings.arguments as Map? ?? const <String, dynamic>{},
            );
            return CapturePage(
              scope: scope,
              initialCaseId: args['initial_case_id'] as String?,
            );
          case baselineStage:
          case saltedStage:
            final args = Map<String, dynamic>.from(
              settings.arguments as Map? ?? const <String, dynamic>{},
            );
            return CapturePage(
              scope: scope,
              initialCaseId: args['initial_case_id'] as String?,
            );
          case hardwareConfig:
            return const HardwareConfigPage();
          case modelBundle:
            return const ModelBundlePage();
          case analysis:
            return const AnalysisPage();
          case sample:
            return const SamplePage();
          case settingsRoute:
            return const SettingsPage();
          case qualityControl:
            return QualityControlPage(
              bundle: _resolveBundle(
                scope,
                settings.arguments as CaptureStepBundle?,
              ),
            );
          case roi:
            return RoiPage(
              bundle: _resolveBundle(
                scope,
                settings.arguments as CaptureStepBundle?,
              ),
            );
          case featurePreview:
            return FeaturePreviewPage(
              bundle: _resolveBundle(
                scope,
                settings.arguments as CaptureStepBundle?,
              ),
            );
          case prediction:
            return PredictionPage(
              bundle: _resolveBundle(
                scope,
                settings.arguments as CaptureStepBundle?,
              ),
            );
          default:
            return const PlatformBottomNavShell(currentRoute: home);
        }
      },
    );
  }

  static CaptureStepBundle _resolveBundle(
    AppScope? scope,
    CaptureStepBundle? bundle,
  ) {
    if (bundle != null) {
      return bundle;
    }
    return scope == null ? const CaptureStepBundle() : buildDemoCaptureBundle(scope);
  }
}
