import 'package:flutter/material.dart';

import '../../core/demo/demo_app_scope.dart';
import '../../core/demo/demo_capture_case.dart';
import '../../core/models/capture_step_bundle.dart';
import '../../core/models/capture_workflow_controller.dart';
import '../../core/models/feature_vector.dart';
import '../../core/models/prediction_result.dart';
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
  late final CaptureWorkflowController _controller;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
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
    );
  }

  @override
  Widget build(BuildContext context) {
    final selectedCase = _controller.selectedCase;
    final activeModel = widget.scope.modelBundleService.activeModel;

    if (!widget.scope.isDemoMode || selectedCase == null) {
      return const _UnavailableView();
    }

    final stepBundle = _buildStepBundle();
    final workflowState = _controller.workflowState;

    return Scaffold(
      appBar: AppBar(title: const Text('采集')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          children: [
            _HeroPanel(
              sampleId: selectedCase.sampleId,
              hardwareLabel: widget.scope.hardwareProfileLabel,
              modelId: activeModel?.modelId ?? '未启用模型包',
            ),
            const SizedBox(height: 16),
            _ImageEntryCard(
              importAction: () => _openStage(
                context,
                AppRouter.baselineStage,
                _stageArguments(stepBundle, AppRouter.baselineStage),
              ),
              cameraAction: () => _showCameraPermissionNotice(context),
            ),
            const SizedBox(height: 12),
            _StatusGrid(
              sourceStatus: _controller.baselineImagePath == null &&
                      _controller.saltedImagePath == null
                  ? '待选择'
                  : '已导入',
              grayCardStatus:
                  workflowState.qualityControlPassed ? '已检查' : '待检查',
              roiStatus: _controller.roiConfirmed ? '已确认' : '待确认',
              nextStep: _nextStageLabel(),
              baselineStatus: _controller.baselineImagePath == null ? '未完成' : '已完成',
              saltedStatus: _controller.saltedImagePath == null ? '未完成' : '已完成',
            ),
            const SizedBox(height: 12),
            _PrimaryFlowCard(
              currentStage: _currentStageTitle(),
              nextStage: _nextStageLabel(),
              onContinue: () => _openStage(
                context,
                _currentStageRoute(),
                _stageArguments(stepBundle, _currentStageRoute()),
              ),
              onQualityControl: _runQualityControl,
              qualityControlPassed: workflowState.qualityControlPassed,
            ),
            const SizedBox(height: 12),
            _SampleSwitchCard(
              cases: widget.scope.demoCaptureCases,
              selectedCase: selectedCase,
              onSelected: _selectCase,
            ),
            if (_errorMessage != null) ...[
              const SizedBox(height: 12),
              _ErrorCard(message: _errorMessage!),
            ],
          ],
        ),
      ),
      bottomNavigationBar: const _CaptureBottomNavBar(),
    );
  }

  CaptureStepBundle _buildStepBundle() {
    final workflowState = _controller.workflowState;
    return CaptureStepBundle(
      qualityControl: _controller.qualityControlResult,
      featureVector: _controller.featureVector,
      predictionResult: _controller.predictionResult,
      baselineImagePath: _controller.baselineImagePath,
      saltedImagePath: _controller.saltedImagePath,
      roiPolygon: widget.scope.demoRoiPolygon,
      workflowState: workflowState,
      controller: _controller,
      runQualityControl: _runQualityControl,
      useBaselineImage: _useBaselineImage,
      useSaltedImage: _useSaltedImage,
      confirmRoi: _confirmRoi,
      runFeatureExtraction: _runFeatureExtraction,
      runPredictionWorkflow: _runPredictionWorkflow,
      saveSession: _saveSession,
    );
  }

  void _selectCase(DemoCaptureCase item) {
    setState(() {
      _controller.selectCase(item);
      _errorMessage = null;
    });
  }

  void _openStage(BuildContext context, String routeName, Object? arguments) {
    Navigator.of(context).pushNamed(routeName, arguments: arguments);
  }

  void _showCameraPermissionNotice(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('真实拍照需要相机权限；当前原型先保留权限入口和测量预览。'),
      ),
    );
  }

  Future<void> _runQualityControl() async {
    final selectedCase = _controller.selectedCase;
    if (selectedCase == null) {
      return;
    }

    setState(() {
      _errorMessage = null;
      _controller.clearPredictionOutputs();
    });

    final qcResult = await widget.scope.qualityControlService.performQualityControl(
      imageMetadata: selectedCase.imageMetadata,
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

  void _confirmRoi() {
    setState(() {
      _controller.confirmRoi();
      _errorMessage = null;
    });
  }

  Future<void> _runFeatureExtraction() async {
    final selectedCase = _controller.selectedCase;
    if (selectedCase == null ||
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
      final featureVector = await widget.scope.featureExtractionService.extractFeatures(
        sessionId: sessionId,
        imageMetadata: selectedCase.imageMetadata,
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
    final selectedCase = _controller.selectedCase;
    if (selectedCase == null ||
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

    final result = await widget.scope.orchestrator.executeFullCaptureWorkflow(
      sessionId: sessionId,
      sampleId: selectedCase.sampleId,
      imageMetadata: selectedCase.imageMetadata,
      baselineImagePath: _controller.baselineImagePath!,
      saltedImagePath: _controller.saltedImagePath!,
      roiPolygon: widget.scope.demoRoiPolygon ?? const <String, dynamic>{},
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
        _errorMessage = '演示预测缺少必要输出。';
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
        return reasons.isEmpty ? '质控失败，请更换案例或重试。' : reasons.join('\n');
      case 'warning':
        return result['warning'] as String? ?? '当前硬件配置与模型包不匹配。';
      case 'feature_extraction_failed':
        return result['error'] as String? ?? '特征提取失败。';
      case 'error':
      default:
        return result['error'] as String? ?? '演示预测失败。';
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

  String _currentStageTitle() {
    if (!_controller.workflowState.qualityControlPassed) {
      return '成像质控';
    }
    if (_controller.baselineImagePath == null) {
      return 'I0 基线图';
    }
    if (_controller.saltedImagePath == null) {
      return 'I1 待测图';
    }
    if (!_controller.roiConfirmed) {
      return 'ROI 确认';
    }
    if (_controller.featureVector == null) {
      return '特征提取';
    }
    if (_controller.predictionResult == null) {
      return '预测计算';
    }
    if (!_controller.saved) {
      return '保存结果';
    }
    return '结果已保存';
  }

  String _nextStageLabel() {
    if (!_controller.workflowState.qualityControlPassed) {
      return '质控';
    }
    if (_controller.baselineImagePath == null) {
      return 'I0';
    }
    if (_controller.saltedImagePath == null) {
      return 'I1';
    }
    if (!_controller.roiConfirmed) {
      return 'ROI';
    }
    if (_controller.featureVector == null) {
      return '特征';
    }
    if (_controller.predictionResult == null) {
      return '预测';
    }
    if (!_controller.saved) {
      return '保存';
    }
    return '结果';
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

class _HeroPanel extends StatelessWidget {
  const _HeroPanel({
    required this.sampleId,
    required this.hardwareLabel,
    required this.modelId,
  });

  final String sampleId;
  final String hardwareLabel;
  final String modelId;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: const LinearGradient(
          colors: [Color(0xFFE7F4F1), Color(0xFFF9FCFB)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '采集工作台',
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '用于完成 I0 / I1 图像进入、灰卡状态确认与 ROI 预检查。',
            style: theme.textTheme.bodyMedium?.copyWith(height: 1.5),
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              const Chip(label: Text('模拟数据')),
              Chip(label: Text(hardwareLabel)),
              Chip(label: Text(sampleId)),
              Chip(label: Text(modelId)),
            ],
          ),
        ],
      ),
    );
  }
}

class _ImageEntryCard extends StatelessWidget {
  const _ImageEntryCard({
    required this.importAction,
    required this.cameraAction,
  });

  final VoidCallback importAction;
  final VoidCallback cameraAction;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '图像入口',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
            ),
            const SizedBox(height: 12),
            const _CapturePreview(),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: importAction,
                icon: const Icon(Icons.add_photo_alternate_outlined),
                label: const Text('导入图片 PNG / JPG'),
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: FilledButton.tonalIcon(
                onPressed: cameraAction,
                icon: const Icon(Icons.photo_camera_outlined),
                label: const Text('拍照采集（需相机权限）'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CapturePreview extends StatelessWidget {
  const _CapturePreview();

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 2.1,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: const Color(0xFFEEF5F3),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
        ),
        child: CustomPaint(
          painter: _CapturePreviewPainter(
            primary: Theme.of(context).colorScheme.primary,
          ),
          child: Align(
            alignment: const Alignment(0.86, -0.72),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFFD7DEDC),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFFAEBBB8)),
              ),
              child: const Text('灰卡'),
            ),
          ),
        ),
      ),
    );
  }
}

class _CapturePreviewPainter extends CustomPainter {
  const _CapturePreviewPainter({required this.primary});

  final Color primary;

  @override
  void paint(Canvas canvas, Size size) {
    final gridPaint = Paint()
      ..color = Colors.white.withOpacity(0.7)
      ..strokeWidth = 1;
    for (var x = size.width / 4; x < size.width; x += size.width / 4) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), gridPaint);
    }
    for (var y = size.height / 3; y < size.height; y += size.height / 3) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    final sampleRect = Rect.fromCenter(
      center: Offset(size.width * 0.48, size.height * 0.55),
      width: size.width * 0.44,
      height: size.height * 0.42,
    );
    final samplePaint = Paint()..color = const Color(0xFF5E8250);
    canvas.drawRRect(
      RRect.fromRectAndRadius(sampleRect, Radius.circular(size.height * 0.18)),
      samplePaint,
    );

    final roiRect = Rect.fromCenter(
      center: Offset(size.width * 0.48, size.height * 0.55),
      width: size.width * 0.56,
      height: size.height * 0.56,
    );
    final roiPaint = Paint()
      ..color = primary
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    canvas.drawRRect(
      RRect.fromRectAndRadius(roiRect, const Radius.circular(12)),
      roiPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _CapturePreviewPainter oldDelegate) {
    return oldDelegate.primary != primary;
  }
}

class _StatusGrid extends StatelessWidget {
  const _StatusGrid({
    required this.sourceStatus,
    required this.grayCardStatus,
    required this.roiStatus,
    required this.nextStep,
    required this.baselineStatus,
    required this.saltedStatus,
  });

  final String sourceStatus;
  final String grayCardStatus;
  final String roiStatus;
  final String nextStep;
  final String baselineStatus;
  final String saltedStatus;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final narrow = constraints.maxWidth < 520;
        return Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            SizedBox(
              width: narrow ? constraints.maxWidth : (constraints.maxWidth - 12) / 2,
              child: _InfoCard(
                title: '当前状态',
                rows: {
                  '来源': sourceStatus,
                  '灰卡': grayCardStatus,
                  'ROI': roiStatus,
                },
              ),
            ),
            SizedBox(
              width: narrow ? constraints.maxWidth : (constraints.maxWidth - 12) / 2,
              child: _InfoCard(
                title: '下一步',
                rows: {
                  '流程': nextStep,
                  'I0': baselineStatus,
                  'I1': saltedStatus,
                },
              ),
            ),
          ],
        );
      },
    );
  }
}

class _PrimaryFlowCard extends StatelessWidget {
  const _PrimaryFlowCard({
    required this.currentStage,
    required this.nextStage,
    required this.onContinue,
    required this.onQualityControl,
    required this.qualityControlPassed,
  });

  final String currentStage;
  final String nextStage;
  final VoidCallback onContinue;
  final VoidCallback onQualityControl;
  final bool qualityControlPassed;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '采集主链',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
            ),
            const SizedBox(height: 10),
            const Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                Chip(label: Text('1 质控')),
                Chip(label: Text('2 I0')),
                Chip(label: Text('3 I1')),
                Chip(label: Text('4 ROI')),
                Chip(label: Text('5 特征')),
                Chip(label: Text('6 预测')),
              ],
            ),
            const SizedBox(height: 12),
            _InfoRow(label: '当前阶段', value: currentStage),
            _InfoRow(label: '下一步', value: nextStage),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: onContinue,
                child: const Text('进入当前阶段页面'),
              ),
            ),
            if (!qualityControlPassed) ...[
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: onQualityControl,
                  icon: const Icon(Icons.fact_check_outlined),
                  label: const Text('直接运行模拟质控'),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _SampleSwitchCard extends StatelessWidget {
  const _SampleSwitchCard({
    required this.cases,
    required this.selectedCase,
    required this.onSelected,
  });

  final List<DemoCaptureCase> cases;
  final DemoCaptureCase selectedCase;
  final ValueChanged<DemoCaptureCase> onSelected;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '样品切换',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: cases.map((item) {
                return ChoiceChip(
                  selected: item.id == selectedCase.id,
                  label: Text(item.title),
                  onSelected: (_) => onSelected(item),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({
    required this.title,
    required this.rows,
  });

  final String title;
  final Map<String, String> rows;

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
                    fontWeight: FontWeight.w800,
                  ),
            ),
            const SizedBox(height: 8),
            ...rows.entries.map(
              (entry) => _InfoRow(label: entry.key, value: entry.value),
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorCard extends StatelessWidget {
  const _ErrorCard({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Text(
          message,
          style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.error),
        ),
      ),
    );
  }
}

class _CaptureBottomNavBar extends StatelessWidget {
  const _CaptureBottomNavBar();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final items = <({String label, IconData icon, String route, bool selected})>[
      (label: '首页', icon: Icons.home_outlined, route: AppRouter.home, selected: false),
      (
        label: '采集',
        icon: Icons.add_photo_alternate_outlined,
        route: AppRouter.capture,
        selected: true
      ),
      (
        label: '结果',
        icon: Icons.show_chart_outlined,
        route: AppRouter.result,
        selected: false
      ),
      (label: '历史', icon: Icons.history, route: AppRouter.history, selected: false),
      (
        label: '验证',
        icon: Icons.rule_folder_outlined,
        route: AppRouter.demoValidation,
        selected: false
      ),
    ];

    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(18, 0, 18, 6),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: theme.colorScheme.outlineVariant),
            boxShadow: const [
              BoxShadow(
                color: Color(0x12000000),
                blurRadius: 16,
                offset: Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            children: items.map((item) {
              return Expanded(
                child: InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: item.selected
                      ? null
                      : () => Navigator.of(context).pushReplacementNamed(item.route),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 38,
                          height: 28,
                          decoration: BoxDecoration(
                            color: item.selected
                                ? const Color(0xFFDFF3EC)
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Icon(
                            item.icon,
                            color: item.selected
                                ? theme.colorScheme.primary
                                : theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          item.label,
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: item.selected
                                ? theme.colorScheme.primary
                                : theme.colorScheme.onSurfaceVariant,
                            fontWeight: item.selected ? FontWeight.w700 : FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}

class _UnavailableView extends StatelessWidget {
  const _UnavailableView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('采集')),
      body: const SafeArea(
        child: Center(
          child: Padding(
            padding: EdgeInsets.all(24),
            child: Text('当前未注入可运行的演示范围，请先从平台首页进入演示模式。'),
          ),
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
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
            width: 78,
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}
