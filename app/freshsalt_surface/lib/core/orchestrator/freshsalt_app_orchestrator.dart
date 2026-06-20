import '../export/export_service.dart';
import '../models/click_validation_case.dart';
import '../repositories/session_repository.dart';
import '../services/click_validation_service.dart';
import '../services/feature_extraction_service.dart';
import '../services/model_bundle_service.dart';
import '../services/prediction_service.dart';
import '../services/quality_control_service.dart';

class FreshSaltAppOrchestrator {
  FreshSaltAppOrchestrator({
    required this.modelBundleService,
    required this.qualityControlService,
    required this.featureExtractionService,
    required this.predictionService,
    required this.clickValidationService,
    required this.sessionRepository,
    required this.exportService,
  });

  final ModelBundleService modelBundleService;
  final QualityControlService qualityControlService;
  final FeatureExtractionService featureExtractionService;
  final PredictionService predictionService;
  final ClickValidationService clickValidationService;
  final SessionRepository sessionRepository;
  final ExportService exportService;

  String? _currentHardwareProfileId;
  String _currentSourceMode = 'simulated';

  void setHardwareProfile(String hardwareProfileId) {
    _currentHardwareProfileId = hardwareProfileId;
  }

  void setSourceMode(String sourceMode) {
    _currentSourceMode = sourceMode;
  }

  Future<Map<String, dynamic>> executeFullCaptureWorkflow({
    required String sessionId,
    required String sampleId,
    required Map<String, dynamic> imageMetadata,
    required String baselineImagePath,
    required String saltedImagePath,
    required Map<String, dynamic> roiPolygon,
  }) async {
    final activeModel = modelBundleService.activeModel;
    if (activeModel == null) {
      return {
        'status': 'error',
        'error': '未启用可用模型包',
      };
    }

    if (_currentHardwareProfileId == null) {
      return {
        'status': 'error',
        'error': '未设置硬件配置',
      };
    }

    final hardwareCompatible = modelBundleService.validateHardwareCompatibility(
      _currentHardwareProfileId!,
      activeModel,
    );
    if (!hardwareCompatible) {
      return {
        'status': 'warning',
        'warning': '当前硬件配置与模型包不匹配',
        'hardware_profile_id': _currentHardwareProfileId,
      };
    }

    final qcResult = await qualityControlService.performQualityControl(
      imageMetadata: imageMetadata,
    );
    if (!qcResult.isPassed) {
      return {
        'status': 'qc_failed',
        'quality_control': qcResult.toJson(),
        'failure_reasons': qcResult.failureReasons,
      };
    }

    final featureVector = await featureExtractionService.extractFeatures(
      sessionId: sessionId,
      imageMetadata: imageMetadata,
      differenceImagePath: '/mock/diff_$sessionId.png',
    );

    if (!featureVector.isValid) {
      return {
        'status': 'feature_extraction_failed',
        'error': '特征提取失败',
      };
    }

    final predictionResult = await predictionService.predict(
      sessionId: sessionId,
      sampleId: sampleId,
      featureVector: featureVector,
      modelBundle: activeModel,
      hardwareProfileId: _currentHardwareProfileId!,
      sourceMode: _currentSourceMode,
    );

    return {
      'status': 'success',
      'session_id': sessionId,
      'results': {
        'model_id': activeModel.modelId,
        'quality_control': qcResult.toJson(),
        'feature_vector': featureVector.toJson(),
        'prediction': predictionResult.toJson(),
        'result_status': predictionResult.resultStatus,
        'session_saved': false,
        'pending_save_payload': {
          'session_id': sessionId,
          'sample_id': sampleId,
          'baseline_image_path': baselineImagePath,
          'salted_image_path': saltedImagePath,
          'roi_polygon': roiPolygon,
        },
      },
    };
  }

  Future<Map<String, dynamic>> executeFullClickValidation(
    List<ClickValidationCase> testCases,
  ) async {
    return clickValidationService.executeFullChain(
      testCases,
      (module, input) async {
        switch (module) {
          case 'home_router':
            return {'status': 'success', 'route': '/quality-control'};
          case 'model_bundle':
            return _handleModelBundleModule(input);
          case 'quality_control':
            return _handleQualityControlModule(input);
          case 'capture_i0':
            return {
              'status': 'success',
              'baseline_loaded':
                  (input['baseline_image_path'] as String?) != null,
            };
          case 'capture_i1':
            return {
              'status': 'success',
              'salted_loaded': (input['salted_image_path'] as String?) != null,
            };
          case 'roi':
            return {
              'status': 'success',
              'roi_valid': (input['roi_within_bounds'] as bool? ?? false) &&
                  ((input['roi_area_cm2'] as num? ?? 0) > 0),
            };
          case 'feature_extraction':
            return _handleFeatureExtractionModule(input);
          case 'prediction':
            return _handlePredictionModule(input);
          case 'result_view':
            return {'status': 'success', 'charts_ready': true};
          case 'save_history':
            return _handleSaveHistoryModule(input);
          case 'history_view':
            return _handleHistoryViewModule();
          case 'analysis_view':
            return _handleAnalysisViewModule();
          case 'export_csv':
            return _handleExportModule();
          case 'full_chain':
            return _handleFullChainModule();
          default:
            return {'status': 'error', 'message': '未支持的验证模块'};
        }
      },
    );
  }

  Future<Map<String, dynamic>> _handleModelBundleModule(
    Map<String, dynamic> input,
  ) async {
    final modelId = input['model_id'] as String?;
    if (modelId == null) {
      return {'status': 'error'};
    }
    final errors = await modelBundleService.activateModelBundle(modelId);
    if (errors.isEmpty) {
      return {'status': 'success', 'active_model_id': modelId};
    }
    return {'status': 'error', 'errors': errors};
  }

  Future<Map<String, dynamic>> _handleQualityControlModule(
    Map<String, dynamic> input,
  ) async {
    final metadata = Map<String, dynamic>.from(
      input['image_metadata'] as Map? ?? const <String, dynamic>{},
    );
    if (metadata.isEmpty) {
      return {'status': 'error'};
    }

    final qcResult = await qualityControlService.performQualityControl(
      imageMetadata: metadata,
    );
    if (!qcResult.isPassed) {
      return {
        'qc_status': 'failed',
        'failed_checks': qcResult.checks.entries
            .where((entry) => !entry.value)
            .map((entry) => entry.key)
            .join(','),
      };
    }
    return {'qc_status': 'passed', 'all_checks': true};
  }

  Future<Map<String, dynamic>> _handleFeatureExtractionModule(
    Map<String, dynamic> input,
  ) async {
    final metadata = Map<String, dynamic>.from(
      input['image_metadata'] as Map? ?? const <String, dynamic>{},
    );
    if (metadata.isEmpty) {
      return {'status': 'error'};
    }
    final featureVector = await featureExtractionService.extractFeatures(
      sessionId: input['session_id'] as String? ?? 'validation_session',
      imageMetadata: metadata,
      differenceImagePath: '/mock/validation_diff.png',
    );
    return {
      'status': 'success',
      'feature_count': featureVector.features.length,
    };
  }

  Future<Map<String, dynamic>> _handlePredictionModule(
    Map<String, dynamic> input,
  ) async {
    final activeModel = modelBundleService.activeModel;
    final metadata = Map<String, dynamic>.from(
      input['image_metadata'] as Map? ?? const <String, dynamic>{},
    );
    if (activeModel == null ||
        metadata.isEmpty ||
        _currentHardwareProfileId == null) {
      return {'status': 'error'};
    }
    final featureVector = await featureExtractionService.extractFeatures(
      sessionId: input['session_id'] as String? ?? 'validation_session',
      imageMetadata: metadata,
      differenceImagePath: '/mock/validation_diff.png',
    );
    final prediction = await predictionService.predict(
      sessionId: input['session_id'] as String? ?? 'validation_session',
      sampleId: input['sample_id'] as String? ?? 'validation_sample',
      featureVector: featureVector,
      modelBundle: activeModel,
      hardwareProfileId: _currentHardwareProfileId!,
      sourceMode: _currentSourceMode,
    );
    return {
      'status': 'success',
      'predicted_value': double.parse(
        prediction.predictedValue.toStringAsFixed(2),
      ),
    };
  }

  Future<Map<String, dynamic>> _handleSaveHistoryModule(
    Map<String, dynamic> input,
  ) async {
    final metadata = Map<String, dynamic>.from(
      input['image_metadata'] as Map? ?? const <String, dynamic>{},
    );
    final sampleId = input['sample_id'] as String? ?? 'validation_sample';
    final sessionId =
        input['session_id'] as String? ?? 'validation_session_saved';
    final activeModel = modelBundleService.activeModel;

    if (activeModel == null ||
        _currentHardwareProfileId == null ||
        metadata.isEmpty) {
      return {'status': 'error'};
    }

    final featureVector = await featureExtractionService.extractFeatures(
      sessionId: sessionId,
      imageMetadata: metadata,
      differenceImagePath: '/mock/validation_diff.png',
    );
    final prediction = await predictionService.predict(
      sessionId: sessionId,
      sampleId: sampleId,
      featureVector: featureVector,
      modelBundle: activeModel,
      hardwareProfileId: _currentHardwareProfileId!,
      sourceMode: _currentSourceMode,
    );
    await sessionRepository.saveSession(
      sessionId: sessionId,
      sampleId: sampleId,
      result: prediction,
      featureVector: featureVector,
      baselineImagePath:
          input['baseline_image_path'] as String? ?? '/mock/validation_i0.png',
      saltedImagePath:
          input['salted_image_path'] as String? ?? '/mock/validation_i1.png',
      roiPolygon: Map<String, dynamic>.from(
        input['roi_polygon'] as Map? ??
            const <String, dynamic>{'area': 4.0, 'within_bounds': true},
      ),
    );
    return {'status': 'success', 'session_saved': true};
  }

  Future<Map<String, dynamic>> _handleHistoryViewModule() async {
    final sessions = await sessionRepository.getAllSessions(isSimulated: true);
    return {
      'status': 'success',
      'simulated_badge': sessions.isNotEmpty,
    };
  }

  Future<Map<String, dynamic>> _handleAnalysisViewModule() async {
    final sessions = await sessionRepository.getAllSessions(isSimulated: true);
    return {
      'status': 'success',
      'analysis_ready': sessions.isNotEmpty,
    };
  }

  Future<Map<String, dynamic>> _handleExportModule() async {
    final sessions = await sessionRepository.getAllSessions(isSimulated: true);
    if (sessions.isEmpty) {
      return {'status': 'error'};
    }
    final csv = exportService.generateCsv(sessions: sessions);
    return {
      'status': 'success',
      'csv_fields_complete': csv.contains('source_mode'),
    };
  }

  Future<Map<String, dynamic>> _handleFullChainModule() async {
    final steps = <Map<String, dynamic>>[
      {'module': 'home_router', 'input': const {'source_mode': 'simulated'}},
      {
        'module': 'model_bundle',
        'input': {'model_id': modelBundleService.activeModel?.modelId},
      },
      {
        'module': 'quality_control',
        'input': {'image_metadata': {'saturation_ratio': 0.003, 'laplacian_variance': 155.0, 'gray_card_rsd': 0.012, 'roi_area_cm2': 4.0, 'roi_within_bounds': true, 'color_dL': -8.5, 'color_da': 3.5, 'color_db': 2.1, 'color_dS': -1.8, 'whiteness_index': 0.24, 'specular_ratio': 0.18, 'glcm_contrast': 0.28, 'glcm_energy': 0.78, 'dL2': 72.25, 'specular_ratio2': 0.0324, 'roi_source': 'demo_case_medium'}},
      },
      {
        'module': 'capture_i0',
        'input': const {'baseline_image_path': '/mock/baseline_medium.png'},
      },
      {
        'module': 'capture_i1',
        'input': const {'salted_image_path': '/mock/salted_medium.png'},
      },
      {
        'module': 'roi',
        'input': const {'roi_area_cm2': 4.0, 'roi_within_bounds': true},
      },
      {
        'module': 'feature_extraction',
        'input': {
          'session_id': 'full_chain_feature_session',
          'image_metadata': {
            'saturation_ratio': 0.003,
            'laplacian_variance': 155.0,
            'gray_card_rsd': 0.012,
            'roi_area_cm2': 4.0,
            'roi_within_bounds': true,
            'color_dL': -8.5,
            'color_da': 3.5,
            'color_db': 2.1,
            'color_dS': -1.8,
            'whiteness_index': 0.24,
            'specular_ratio': 0.18,
            'glcm_contrast': 0.28,
            'glcm_energy': 0.78,
            'dL2': 72.25,
            'specular_ratio2': 0.0324,
            'roi_source': 'demo_case_medium',
          },
        },
      },
      {
        'module': 'prediction',
        'input': {
          'session_id': 'full_chain_prediction_session',
          'sample_id': 'full_chain_sample',
          'image_metadata': {
            'saturation_ratio': 0.003,
            'laplacian_variance': 155.0,
            'gray_card_rsd': 0.012,
            'roi_area_cm2': 4.0,
            'roi_within_bounds': true,
            'color_dL': -8.5,
            'color_da': 3.5,
            'color_db': 2.1,
            'color_dS': -1.8,
            'whiteness_index': 0.24,
            'specular_ratio': 0.18,
            'glcm_contrast': 0.28,
            'glcm_energy': 0.78,
            'dL2': 72.25,
            'specular_ratio2': 0.0324,
            'roi_source': 'demo_case_medium',
          },
        },
      },
      {'module': 'result_view', 'input': const {'result_status': 'valid'}},
      {
        'module': 'save_history',
        'input': {
          'session_id': 'full_chain_saved_session',
          'sample_id': 'full_chain_saved_sample',
          'baseline_image_path': '/mock/baseline_medium.png',
          'salted_image_path': '/mock/salted_medium.png',
          'roi_polygon': const {'area': 4.0, 'within_bounds': true},
          'image_metadata': {
            'saturation_ratio': 0.003,
            'laplacian_variance': 155.0,
            'gray_card_rsd': 0.012,
            'roi_area_cm2': 4.0,
            'roi_within_bounds': true,
            'color_dL': -8.5,
            'color_da': 3.5,
            'color_db': 2.1,
            'color_dS': -1.8,
            'whiteness_index': 0.24,
            'specular_ratio': 0.18,
            'glcm_contrast': 0.28,
            'glcm_energy': 0.78,
            'dL2': 72.25,
            'specular_ratio2': 0.0324,
            'roi_source': 'demo_case_medium',
          },
        },
      },
      {'module': 'history_view', 'input': const {'is_simulated': true}},
      {'module': 'analysis_view', 'input': const {'record_count': 1}},
      {
        'module': 'export_csv',
        'input': const {'session_id': 'full_chain_saved_session'},
      },
    ];

    final outputs = <Map<String, dynamic>>[];
    for (final step in steps) {
      switch (step['module']) {
        case 'home_router':
          outputs.add({'status': 'success', 'route': '/quality-control'});
          break;
        case 'model_bundle':
          outputs.add(
            await _handleModelBundleModule(
              Map<String, dynamic>.from(step['input'] as Map),
            ),
          );
          break;
        case 'quality_control':
          outputs.add(
            await _handleQualityControlModule(
              Map<String, dynamic>.from(step['input'] as Map),
            ),
          );
          break;
        case 'capture_i0':
          outputs.add({
            'status': 'success',
            'baseline_loaded':
                ((step['input'] as Map)['baseline_image_path'] as String?) !=
                    null,
          });
          break;
        case 'capture_i1':
          outputs.add({
            'status': 'success',
            'salted_loaded':
                ((step['input'] as Map)['salted_image_path'] as String?) !=
                    null,
          });
          break;
        case 'roi':
          final roiInput = step['input'] as Map;
          outputs.add({
            'status': 'success',
            'roi_valid': (roiInput['roi_within_bounds'] as bool? ?? false) &&
                ((roiInput['roi_area_cm2'] as num? ?? 0) > 0),
          });
          break;
        case 'feature_extraction':
          outputs.add(
            await _handleFeatureExtractionModule(
              Map<String, dynamic>.from(step['input'] as Map),
            ),
          );
          break;
        case 'prediction':
          outputs.add(
            await _handlePredictionModule(
              Map<String, dynamic>.from(step['input'] as Map),
            ),
          );
          break;
        case 'result_view':
          outputs.add({'status': 'success', 'charts_ready': true});
          break;
        case 'save_history':
          outputs.add(
            await _handleSaveHistoryModule(
              Map<String, dynamic>.from(step['input'] as Map),
            ),
          );
          break;
        case 'history_view':
          outputs.add(await _handleHistoryViewModule());
          break;
        case 'analysis_view':
          outputs.add(await _handleAnalysisViewModule());
          break;
        case 'export_csv':
          outputs.add(await _handleExportModule());
          break;
      }
    }

    final passedSteps = outputs.where((output) {
      final status = output['status'];
      final qcStatus = output['qc_status'];
      return status == null || status == 'success'
          ? qcStatus == null || qcStatus == 'passed'
          : false;
    }).length;
    final allPassed = passedSteps == outputs.length;

    return {
      'status': allPassed ? 'success' : 'error',
      'chain_complete': allPassed,
      'steps_passed': passedSteps,
      'history_saved': outputs.any(
        (output) => output['session_saved'] == true,
      ),
      'export_ready': outputs.any(
        (output) => output['csv_fields_complete'] == true,
      ),
    };
  }

  Future<List<Map<String, dynamic>>> getAllSessions() async {
    return sessionRepository.getAllSessions();
  }

  void clearActiveModel() {
    modelBundleService.deactivateModelBundle();
  }
}
