import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/demo/demo_app_scope.dart';
import '../../core/demo/demo_capture_case.dart';
import '../../core/models/ai_capture_assistant_advice.dart';
import '../../core/models/capture_step_bundle.dart';
import '../../core/models/capture_workflow_controller.dart';
import '../../core/models/feature_vector.dart';
import '../../core/models/prediction_result.dart';
import '../../core/services/ai_capture_assistant_service.dart';
import '../../core/services/local_image_picker.dart';
import '../../routing/app_router.dart';

class CapturePage extends StatefulWidget {
  const CapturePage({
    super.key,
    required this.scope,
    this.initialCaseId,
  });

  final AppScope scope;
  final String? initialCaseId;

  @override
  State<CapturePage> createState() => _CapturePageState();
}

class _CapturePageState extends State<CapturePage> {
  static const AiCaptureAssistantService _aiCaptureAssistantService =
      AiCaptureAssistantService();

  late final CaptureWorkflowController _controller;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    final existingController = widget.scope.captureWorkflowController;
    if (existingController != null) {
      _controller = existingController;
      return;
    }

    final cases = widget.scope.demoCaptureCases;
    DemoCaptureCase? initialCase;
    if (widget.initialCaseId != null) {
      for (final item in cases) {
        if (item.id == widget.initialCaseId) {
          initialCase = item;
          break;
        }
      }
    }

    _controller = CaptureWorkflowController(
      selectedCase: initialCase ??
          (cases.isNotEmpty ? (cases.length > 1 ? cases[1] : cases.first) : null),
      initialRoiPolygon: widget.scope.demoRoiPolygon,
    );
    widget.scope.captureWorkflowController = _controller;
  }

  @override
  Widget build(BuildContext context) {
    final currentCase = _controller.selectedCase;
    final activeModel = widget.scope.modelBundleService.activeModel;

    if (!widget.scope.isDemoMode || currentCase == null) {
      return const _UnavailableView();
    }

    final stepBundle = _buildStepBundle();
    final workflowState = _controller.workflowState;
    final qcSourceMode =
        _controller.qualityControlResult?.metrics['source_mode'] as String?;
    final extractionMethod =
        _controller.featureVector?.metadata['extraction_method'] as String?;
    final aiAdvice = _aiCaptureAssistantService.build(
      hasImportedRealImages: _controller.hasImportedRealImages,
      qualityControlResult: _controller.qualityControlResult,
      roiPolygon: _controller.roiPolygon,
    );
    final currentStageTitle = _currentStageTitle();
    final currentStageRoute = _currentStageRoute();
    final currentStageArguments =
        _stageArguments(stepBundle, currentStageRoute);

    return Scaffold(
      appBar: AppBar(title: const Text('图像采集')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
          children: [
            _SectionCard(
              title: '当前进度',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _KeyValueRow(label: '当前阶段', value: currentStageTitle),
                  _KeyValueRow(
                    label: '图像来源',
                    value: _controller.hasImportedRealImages ? '真实图片' : '内置图片',
                  ),
                  _KeyValueRow(
                    label: '模型状态',
                    value: activeModel?.modelId ?? '未启用模型',
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: () => _openStage(
                        context,
                        currentStageRoute,
                        currentStageArguments,
                      ),
                      child: Text('进入$currentStageTitle'),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            _SectionCard(
              title: '导入状态',
              child: ValueListenableBuilder<String>(
                valueListenable: LocalImagePicker.status,
                builder: (context, pickerState, _) {
                  return Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      Chip(label: Text('picker_state: $pickerState')),
                      Chip(
                        label: Text(
                          _controller.hasImportedRealImages
                              ? 'real_image_ready'
                              : 'waiting_for_real_image',
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
            const SizedBox(height: 12),
            _SectionCard(
              title: '导入图片',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '先导入基线图和待测图，再继续质控、ROI 圈定、特征提取和结果计算。',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: _importBaselineImage,
                      icon: const Icon(Icons.file_open_outlined),
                      label: const Text('导入基线图'),
                    ),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: _importSaltedImage,
                      icon: const Icon(Icons.file_open_outlined),
                      label: const Text('导入待测图'),
                    ),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: _loadBuiltInRealSamples,
                      icon: const Icon(Icons.image_outlined),
                      label: const Text('加载内置图片'),
                    ),
                  ),
                ],
              ),
            ),
            if (aiAdvice != null) ...[
              const SizedBox(height: 12),
              _SectionCard(
                title: 'AI 采集助手',
                child: _AiCaptureAssistantCard(advice: aiAdvice),
              ),
            ],
            const SizedBox(height: 12),
            _SectionCard(
              title: '快捷操作',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '当前页面优先保留采集主链路。内置图片仅用于快速体验。',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: _useBaselineImage,
                          child: const Text('使用内置基线图'),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: OutlinedButton(
                          onPressed: _useSaltedImage,
                          child: const Text('使用内置待测图'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            _SectionCard(
              title: '主链路',
              child: Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: _runQualityControl,
                      child: const Text('执行质控'),
                    ),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed:
                          _controller.roiConfirmed ? _runFeatureExtraction : null,
                      child: const Text('执行特征提取'),
                    ),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: _runPredictionWorkflow,
                      child: const Text('执行结果计算'),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            _SectionCard(
              title: '功能入口',
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _RouteChip(
                    label: '质控',
                    onTap: () => _openStage(
                      context,
                      AppRouter.qualityControl,
                      stepBundle,
                    ),
                  ),
                  _RouteChip(
                    label: '基线图',
                    onTap: () => _openStage(
                      context,
                      AppRouter.baselineStage,
                      _stageArguments(stepBundle, AppRouter.baselineStage),
                    ),
                  ),
                  _RouteChip(
                    label: '待测图',
                    onTap: () => _openStage(
                      context,
                      AppRouter.saltedStage,
                      _stageArguments(stepBundle, AppRouter.saltedStage),
                    ),
                  ),
                  _RouteChip(
                    label: 'ROI',
                    onTap: () => _openStage(context, AppRouter.roi, stepBundle),
                  ),
                  _RouteChip(
                    label: '特征',
                    onTap: () => _openStage(
                      context,
                      AppRouter.featurePreview,
                      stepBundle,
                    ),
                  ),
                  _RouteChip(
                    label: '结果',
                    onTap: () => _openStage(
                      context,
                      AppRouter.prediction,
                      stepBundle,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            _SectionCard(
              title: '图像状态',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _KeyValueRow(
                    label: '基线图',
                    value: _controller.baselineImagePath ?? '未加载',
                  ),
                  _KeyValueRow(
                    label: '待测图',
                    value: _controller.saltedImagePath ?? '未加载',
                  ),
                  _KeyValueRow(
                    label: '质控',
                    value: workflowState.qualityControlPassed ? '已通过' : '未通过',
                  ),
                  _KeyValueRow(
                    label: 'ROI',
                    value: _controller.roiConfirmed ? '已确认' : '未确认',
                  ),
                  _KeyValueRow(
                    label: '特征',
                    value: _controller.featureVector == null ? '未提取' : '已提取',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            _SectionCard(
              title: '运行证据',
              child: ValueListenableBuilder<String>(
                valueListenable: LocalImagePicker.status,
                builder: (context, pickerState, _) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _KeyValueRow(label: 'picker_state', value: pickerState),
                      _KeyValueRow(
                        label: 'I0_source',
                        value: _controller.baselineImagePath == null
                            ? 'not_selected'
                            : (_controller.baselineUsesSimulatedSource
                                ? 'simulated_image'
                                : 'real_image_file'),
                      ),
                      _KeyValueRow(
                        label: 'I1_source',
                        value: _controller.saltedImagePath == null
                            ? 'not_selected'
                            : (_controller.saltedUsesSimulatedSource
                                ? 'simulated_image'
                                : 'real_image_file'),
                      ),
                      _KeyValueRow(
                        label: 'qc_source_mode',
                        value: qcSourceMode ?? 'not_run',
                      ),
                      _KeyValueRow(
                        label: 'feature_extraction',
                        value: extractionMethod ?? 'not_run',
                      ),
                      if (activeModel != null)
                        _KeyValueRow(label: 'model_id', value: activeModel.modelId),
                    ],
                  );
                },
              ),
            ),
            const SizedBox(height: 12),
            _SectionCard(
              title: '拍摄入口',
              child: SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () => _showCameraPermissionNotice(context),
                  icon: const Icon(Icons.photo_camera_outlined),
                  label: const Text('拍摄入口暂未接入'),
                ),
              ),
            ),
            if (_errorMessage != null) ...[
              const SizedBox(height: 12),
              _SectionCard(
                title: '提示信息',
                child: Text(
                  _errorMessage!,
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  CaptureStepBundle _buildStepBundle() {
    return CaptureStepBundle(
      qualityControl: _controller.qualityControlResult,
      featureVector: _controller.featureVector,
      predictionResult: _controller.predictionResult,
      baselineImagePath: _controller.baselineImagePath,
      saltedImagePath: _controller.saltedImagePath,
      roiPolygon: _controller.roiPolygon,
      workflowState: _controller.workflowState,
      controller: _controller,
      runQualityControl: _runQualityControl,
      useBaselineImage: _useBaselineImage,
      useSaltedImage: _useSaltedImage,
      importBaselineImage: _importBaselineImage,
      importSaltedImage: _importSaltedImage,
      confirmRoi: _confirmRoi,
      updateRoiPolygon: _updateRoiPolygon,
      runFeatureExtraction: _runFeatureExtraction,
      runPredictionWorkflow: _runPredictionWorkflow,
      saveSession: _saveSession,
    );
  }

  void _openStage(BuildContext context, String routeName, Object? arguments) {
    Navigator.of(context).pushNamed(routeName, arguments: arguments);
  }

  void _showCameraPermissionNotice(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('真实拍摄需要相机权限；当前版本先打通图片导入链路。'),
      ),
    );
  }

  Future<void> _runQualityControl() async {
    final currentCase = _controller.selectedCase;
    if (currentCase == null) {
      return;
    }

    if (_controller.hasImportedRealImages) {
      final baselineBytes = _controller.baselineImageBytes;
      if (baselineBytes == null) {
        setState(() {
          _errorMessage = '基线图数据缺失，请重新导入。';
        });
        return;
      }

      final qcResult = await widget.scope.realImageAnalysisService
          .performQualityControl(
        imageBytes: baselineBytes,
      );

      if (!mounted) {
        return;
      }

      setState(() {
        _controller.applyQualityControl(qcResult);
        _errorMessage =
            qcResult.isPassed ? null : qcResult.failureReasons.join('\n');
      });
      return;
    }

    setState(() {
      _errorMessage = null;
      _controller.clearPredictionOutputs();
    });

    final qcResult = await widget.scope.qualityControlService.performQualityControl(
      imageMetadata: currentCase.imageMetadata,
    );

    if (!mounted) {
      return;
    }

    setState(() {
      _controller.applyQualityControl(qcResult);
      _errorMessage = qcResult.isPassed ? null : qcResult.failureReasons.join('\n');
    });
  }

  void _useBaselineImage() {
    setState(() {
      _controller.useBaselineImage(_controller.selectedCase?.baselineImagePath);
      _errorMessage = null;
    });
  }

  void _useSaltedImage() {
    setState(() {
      _controller.useSaltedImage(_controller.selectedCase?.saltedImagePath);
      _errorMessage = null;
    });
  }

  Future<void> _importBaselineImage() async {
    await _pickImage(isBaseline: true);
  }

  Future<void> _importSaltedImage() async {
    await _pickImage(isBaseline: false);
  }

  Future<void> _loadBuiltInRealSamples() async {
    try {
      final baseline = await rootBundle.load('assets/real_samples/public_i0.png');
      final salted = await rootBundle.load('assets/real_samples/public_i1.png');
      if (!mounted) {
        return;
      }
      setState(() {
        _controller.useBaselineImage(
          'builtin_i0.png',
          isSimulated: false,
          imageBytes: baseline.buffer.asUint8List(),
        );
        _controller.useSaltedImage(
          'builtin_i1.png',
          isSimulated: false,
          imageBytes: salted.buffer.asUint8List(),
        );
        _controller.clearPredictionOutputs();
        _errorMessage = null;
      });
    } catch (_) {
      if (!mounted) {
        return;
      }
      setState(() {
        _errorMessage = '内置图片加载失败，请检查资源配置。';
      });
    }
  }

  void _confirmRoi() {
    setState(() {
      _controller.confirmRoi();
      _errorMessage = null;
    });
  }

  void _updateRoiPolygon(Map<String, dynamic> roiPolygon) {
    setState(() {
      _controller.updateRoiPolygon(roiPolygon);
      _errorMessage = null;
    });
  }

  Future<void> _runFeatureExtraction() async {
    final currentCase = _controller.selectedCase;
    if (currentCase == null ||
        _controller.baselineImagePath == null ||
        _controller.saltedImagePath == null ||
        !_controller.roiConfirmed) {
      return;
    }

    final sessionId =
        _controller.sessionId ?? 'session_${DateTime.now().millisecondsSinceEpoch}';

    setState(() {
      _errorMessage = null;
      _controller.clearPredictionOutputs();
    });

    try {
      final featureVector = _controller.hasImportedRealImages
          ? await widget.scope.realImageAnalysisService.extractFeatures(
              sessionId: sessionId,
              baselineImageBytes: _controller.baselineImageBytes!,
              saltedImageBytes: _controller.saltedImageBytes!,
            )
          : await widget.scope.featureExtractionService.extractFeatures(
              sessionId: sessionId,
              imageMetadata: currentCase.imageMetadata,
              differenceImagePath: '/mock/diff_$sessionId.png',
            );

      if (!mounted) {
        return;
      }

      setState(() {
        _controller.applyFeatureVector(
          sessionId: sessionId,
          featureVector: featureVector,
        );
      });
    } catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        _errorMessage = error.toString();
      });
    }
  }

  Future<void> _runPredictionWorkflow() async {
    final currentCase = _controller.selectedCase;
    if (_controller.baselineImagePath == null ||
        _controller.saltedImagePath == null ||
        !_controller.roiConfirmed) {
      return;
    }

    if (_controller.hasImportedRealImages) {
      final activeModel = widget.scope.modelBundleService.activeModel;
      final baselineBytes = _controller.baselineImageBytes;
      final saltedBytes = _controller.saltedImageBytes;
      if (activeModel == null || baselineBytes == null || saltedBytes == null) {
        setState(() {
          _errorMessage = '真实图片结果计算缺少模型或图像数据，请重新导入后重试。';
        });
        return;
      }

      final sessionId =
          _controller.sessionId ?? 'session_${DateTime.now().millisecondsSinceEpoch}';

      setState(() {
        _errorMessage = null;
        _controller.clearPredictionOutputs();
      });

      try {
        final featureVector = await widget.scope.realImageAnalysisService.extractFeatures(
          sessionId: sessionId,
          baselineImageBytes: baselineBytes,
          saltedImageBytes: saltedBytes,
        );
        final predictionResult = await widget.scope.predictionService.predict(
          sessionId: sessionId,
          sampleId: currentCase?.sampleId ?? 'real_image_import',
          featureVector: featureVector,
          modelBundle: activeModel,
          hardwareProfileId: widget.scope.hardwareProfileLabel,
          sourceMode: 'real_image_pixels',
        );

        if (!mounted) {
          return;
        }

        setState(() {
          _controller.applyPrediction(
            sessionId: sessionId,
            featureVector: featureVector,
            predictionResult: predictionResult,
            pendingSavePayload: {
              'session_id': sessionId,
              'sample_id': currentCase?.sampleId ?? 'real_image_import',
              'baseline_image_path': _controller.baselineImagePath!,
              'salted_image_path': _controller.saltedImagePath!,
              'roi_polygon': _controller.roiPolygon ?? const <String, dynamic>{},
            },
          );
          _errorMessage = null;
        });
      } catch (error) {
        if (!mounted) {
          return;
        }
        setState(() {
          _errorMessage = error.toString();
        });
      }
      return;
    }

    if (currentCase == null) {
      return;
    }

    final sessionId =
        _controller.sessionId ?? 'session_${DateTime.now().millisecondsSinceEpoch}';

    setState(() {
      _errorMessage = null;
      _controller.clearPredictionOutputs();
    });

    final result = await widget.scope.orchestrator.executeFullCaptureWorkflow(
      sessionId: sessionId,
      sampleId: currentCase.sampleId,
      imageMetadata: currentCase.imageMetadata,
      baselineImagePath: _controller.baselineImagePath!,
      saltedImagePath: _controller.saltedImagePath!,
      roiPolygon: _controller.roiPolygon ?? const <String, dynamic>{},
    );

    if (!mounted) {
      return;
    }

    final status = result['status'] as String? ?? 'error';
    if (status != 'success') {
      setState(() {
        _errorMessage = _resolveWorkflowError(result);
      });
      return;
    }

    final results = result['results'] as Map<String, dynamic>? ?? result;
    final featureVector = _readFeatureVector(results['feature_vector']);
    final predictionResult = _readPredictionResult(results['prediction']);
    final pendingSavePayload =
        results['pending_save_payload'] as Map<String, dynamic>?;
    if (featureVector == null ||
        predictionResult == null ||
        pendingSavePayload == null) {
      setState(() {
        _errorMessage = '结果计算流程缺少必要输出。';
      });
      return;
    }

    setState(() {
      _controller.applyPrediction(
        sessionId: sessionId,
        featureVector: featureVector,
        predictionResult: predictionResult,
        pendingSavePayload: pendingSavePayload,
      );
      _errorMessage = null;
    });
  }

  FeatureVector? _readFeatureVector(Object? value) {
    if (value is FeatureVector) {
      return value;
    }
    if (value is Map) {
      return FeatureVector.fromJson(Map<String, dynamic>.from(value));
    }
    return null;
  }

  PredictionResult? _readPredictionResult(Object? value) {
    if (value is PredictionResult) {
      return value;
    }
    if (value is Map) {
      return PredictionResult.fromJson(Map<String, dynamic>.from(value));
    }
    return null;
  }

  String _resolveWorkflowError(Map<String, dynamic> result) {
    final status = result['status'] as String? ?? 'error';
    switch (status) {
      case 'qc_failed':
        final reasons =
            List<String>.from(result['failure_reasons'] as List? ?? const []);
        return reasons.isEmpty ? '质控失败，请重试。' : reasons.join('\n');
      case 'warning':
        return result['warning'] as String? ?? '当前配置与模型包不匹配。';
      case 'feature_extraction_failed':
        return result['error'] as String? ?? '特征提取失败。';
      case 'error':
      default:
        return result['error'] as String? ?? '结果计算流程失败。';
    }
  }

  Future<void> _saveSession() async {
    final prediction = _controller.predictionResult;
    final featureVector = _controller.featureVector;
    final payload = _controller.pendingSavePayload;
    if (prediction == null || featureVector == null || payload == null) {
      return;
    }

    await widget.scope.sessionRepository.saveSession(
      sessionId: payload['session_id'] as String,
      sampleId: payload['sample_id'] as String,
      result: prediction,
      featureVector: featureVector,
      baselineImagePath: payload['baseline_image_path'] as String,
      saltedImagePath: payload['salted_image_path'] as String,
      roiPolygon: Map<String, dynamic>.from(
        payload['roi_polygon'] as Map? ?? const <String, dynamic>{},
      ),
    );

    if (!mounted) {
      return;
    }

    setState(() {
      _controller.markSaved();
      _errorMessage = null;
    });
  }

  Future<void> _pickImage({required bool isBaseline}) async {
    final picked = await LocalImagePicker.pickImage();
    if (picked == null) {
      setState(() {
        _errorMessage = '未选择文件，本次导入已取消。';
      });
      return;
    }

    if (picked.bytes.isEmpty || picked.displayPath.isEmpty) {
      setState(() {
        _errorMessage = '无法读取所选图片，请重新选择 PNG 或 JPG 文件。';
      });
      return;
    }

    setState(() {
      if (isBaseline) {
        _controller.useBaselineImage(
          picked.displayPath,
          isSimulated: false,
          imageBytes: picked.bytes,
        );
      } else {
        _controller.useSaltedImage(
          picked.displayPath,
          isSimulated: false,
          imageBytes: picked.bytes,
        );
      }
      _controller.clearPredictionOutputs();
      _errorMessage = null;
    });
  }

  String _currentStageTitle() {
    if (!_controller.workflowState.qualityControlPassed) {
      return '成像质控';
    }
    if (_controller.baselineImagePath == null) {
      return '基线图';
    }
    if (_controller.saltedImagePath == null) {
      return '待测图';
    }
    if (!_controller.roiConfirmed) {
      return 'ROI确认';
    }
    if (_controller.featureVector == null) {
      return '特征提取';
    }
    if (_controller.predictionResult == null) {
      return '结果计算';
    }
    if (!_controller.saved) {
      return '保存结果';
    }
    return '结果已保存';
  }

  String _currentStageRoute() {
    if (!_controller.workflowState.qualityControlPassed) {
      return AppRouter.qualityControl;
    }
    if (_controller.baselineImagePath == null) {
      return AppRouter.baselineStage;
    }
    if (_controller.saltedImagePath == null) {
      return AppRouter.saltedStage;
    }
    if (!_controller.roiConfirmed) {
      return AppRouter.roi;
    }
    if (_controller.featureVector == null) {
      return AppRouter.featurePreview;
    }
    return AppRouter.prediction;
  }

  Object _stageArguments(CaptureStepBundle stepBundle, String routeName) {
    switch (routeName) {
      case AppRouter.baselineStage:
        return {
          'image_path': _controller.baselineImagePath,
          'is_ready': _controller.baselineImagePath != null,
          'bundle': stepBundle,
          'next_args': {
            'image_path': _controller.saltedImagePath,
            'is_ready': _controller.saltedImagePath != null,
            'bundle': stepBundle,
          },
        };
      case AppRouter.saltedStage:
        return {
          'image_path': _controller.saltedImagePath,
          'is_ready': _controller.saltedImagePath != null,
          'bundle': stepBundle,
        };
      default:
        return stepBundle;
    }
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({
    required this.title,
    required this.child,
  });

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
            ),
            const SizedBox(height: 12),
            child,
          ],
        ),
      ),
    );
  }
}

class _KeyValueRow extends StatelessWidget {
  const _KeyValueRow({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}

class _RouteChip extends StatelessWidget {
  const _RouteChip({
    required this.label,
    required this.onTap,
  });

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ActionChip(
      label: Text(label),
      onPressed: onTap,
    );
  }
}

class _AiCaptureAssistantCard extends StatelessWidget {
  const _AiCaptureAssistantCard({required this.advice});

  final AiCaptureAssistantAdvice advice;

  @override
  Widget build(BuildContext context) {
    final qualityColor =
        advice.retakeRecommended ? Colors.orange.shade700 : Colors.green.shade700;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            Chip(
              label: Text('AI质控：${advice.qualityStatus}'),
              backgroundColor: qualityColor.withOpacity(0.12),
              labelStyle: TextStyle(
                color: qualityColor,
                fontWeight: FontWeight.w700,
              ),
            ),
            Chip(
              label: Text(
                advice.retakeRecommended ? '建议重拍' : '可继续下一步',
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Text(
          'AI建议ROI',
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w700,
              ),
        ),
        const SizedBox(height: 6),
        Text(advice.roiSuggestion),
        const SizedBox(height: 12),
        Text(
          '原因说明',
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w700,
              ),
        ),
        const SizedBox(height: 6),
        ...advice.reasons.map(
          (item) => Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Text('- $item'),
          ),
        ),
      ],
    );
  }
}

class _UnavailableView extends StatelessWidget {
  const _UnavailableView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('图像采集')),
      body: const SafeArea(
        child: Center(
          child: Padding(
            padding: EdgeInsets.all(24),
            child: Text('当前页面暂不可用，请先返回首页重新进入。'),
          ),
        ),
      ),
    );
  }
}
