import 'package:flutter/material.dart';

import '../../core/models/capture_step_bundle.dart';
import '../../routing/app_router.dart';
import '../../shared/widgets/capture_stage_navigation.dart';
import '../../shared/widgets/capture_stage_shell.dart';

class QualityControlPage extends StatefulWidget {
  const QualityControlPage({
    super.key,
    this.bundle,
  });

  final CaptureStepBundle? bundle;

  @override
  State<QualityControlPage> createState() => _QualityControlPageState();
}

class _QualityControlPageState extends State<QualityControlPage> {
  bool _running = false;

  @override
  Widget build(BuildContext context) {
    final controller = widget.bundle?.controller;
    final qc = controller?.qualityControlResult ?? widget.bundle?.qualityControl;
    final selectedCase = controller?.selectedCase;
    final workflowState = controller?.workflowState ?? widget.bundle?.workflowState;
    final canRun = widget.bundle?.runQualityControl != null && !_running;
    final canContinue = workflowState?.canUseBaseline ?? false;
    final usingRealPixels = controller?.hasImportedRealImages ?? false;
    final qcSourceMode = qc?.metrics['source_mode'] as String?;
    final imagePath = controller?.baselineImagePath;

    return CaptureStageShell(
      appBarTitle: '成像质控',
      title: '成像质控',
      subtitle: '检查曝光、清晰度、灰卡稳定性和 ROI 完整性，通过后再进入 I0 基线图。',
      stageLabel: '1 / 7',
      stageTitle: '质控',
      tags: [
        usingRealPixels ? '真实图片' : '模拟数据',
        if (usingRealPixels) 'real_image_pixels',
        if (selectedCase != null) selectedCase.sampleId,
        if (selectedCase != null) selectedCase.title,
      ],
      metrics: [
        CaptureStageMetric(
          label: '样品',
          value: selectedCase?.sampleId ?? '未选择',
          note: selectedCase?.subtitle ?? '当前页面直接服务于采集主链。',
        ),
        CaptureStageMetric(
          label: '结果',
          value: qc == null ? '待执行' : (qc.isPassed ? '已通过' : '未通过'),
          note: qc == null ? '需要先执行当前阶段。' : '通过后解锁 I0 基线图。',
        ),
        CaptureStageMetric(
          label: 'source',
          value: usingRealPixels ? 'real pixels' : 'simulated',
          note: qcSourceMode ?? (usingRealPixels ? 'pending' : 'simulated'),
        ),
      ],
      children: [
        CaptureStageSectionCard(
          title: '当前阶段主操作',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                qc == null
                    ? '请先完成当前案例的成像质控，再进入 I0 基线图阶段。'
                    : '当前阶段已完成，可以继续进入 I0 基线图阶段。',
              ),
              const SizedBox(height: 6),
              Text(
                qc == null ? '下一步：开始质控' : '下一步：I0 基线图',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: qc == null
                      ? (canRun ? _runQualityControl : null)
                      : (canContinue ? _goToBaselineStage : null),
                  child: Text(
                    _running ? '运行中...' : (qc == null ? '开始质控' : '进入 I0 基线图'),
                  ),
                ),
              ),
            ],
          ),
        ),
        CaptureStageSectionCard(
          title: qc == null ? '质控摘要' : (qc.isPassed ? '质控通过' : '质控失败'),
          trailing: Chip(
            label: Text(qc == null ? '待执行' : (qc.isPassed ? '通过' : '失败')),
          ),
          child: qc == null
              ? const Text('尚未运行质控，请先点击上方“开始质控”。')
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ...qc.checks.entries.map(
                      (entry) => Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Text('${entry.key}: ${entry.value ? '通过' : '失败'}'),
                      ),
                    ),
                    if (qc.failureReasons.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      ...qc.failureReasons.map((item) => Text('- $item')),
                    ],
                  ],
                ),
        ),
        if (usingRealPixels)
          CaptureStageSectionCard(
            title: 'Real Image Input',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('real_image_pixels'),
                const SizedBox(height: 8),
                Text(imagePath ?? 'unknown'),
                if (qc != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    'saturation_ratio: ${((qc.metrics['exposure_saturation_ratio'] as num? ?? 0).toDouble()).toStringAsFixed(4)}',
                  ),
                  Text(
                    'laplacian_variance: ${((qc.metrics['laplacian_variance'] as num? ?? 0).toDouble()).toStringAsFixed(2)}',
                  ),
                  Text(
                    'gray_card_rsd: ${((qc.metrics['gray_card_rsd'] as num? ?? 0).toDouble()).toStringAsFixed(4)}',
                  ),
                ],
              ],
            ),
          ),
        if (selectedCase != null)
          CaptureStageSectionCard(
            title: '当前样品',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(selectedCase.sampleId),
                const SizedBox(height: 6),
                Text(
                  selectedCase.title,
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                const SizedBox(height: 6),
                Text(
                  selectedCase.subtitle,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
        CaptureStageSectionCard(
          title: '阶段导航',
          child: CaptureStageNavigation(
            previousLabel: '返回采集页',
            previousAction: () => Navigator.of(context).pop(),
            nextLabel: '下一步：I0 基线图',
            nextAction: canContinue ? _goToBaselineStage : null,
          ),
        ),
      ],
    );
  }

  Future<void> _runQualityControl() async {
    final action = widget.bundle?.runQualityControl;
    if (action == null) {
      return;
    }

    setState(() {
      _running = true;
    });
    await action();
    if (!mounted) {
      return;
    }
    setState(() {
      _running = false;
    });
  }

  void _goToBaselineStage() {
    Navigator.of(context).pushNamed(
      AppRouter.baselineStage,
      arguments: {
        'image_path':
            widget.bundle?.controller?.baselineImagePath ??
                widget.bundle?.baselineImagePath,
        'is_ready':
            (widget.bundle?.controller?.baselineImagePath ??
                    widget.bundle?.baselineImagePath) !=
                null,
        'bundle': widget.bundle,
        'next_args': {
          'image_path':
              widget.bundle?.controller?.saltedImagePath ??
                  widget.bundle?.saltedImagePath,
          'is_ready':
              (widget.bundle?.controller?.saltedImagePath ??
                      widget.bundle?.saltedImagePath) !=
                  null,
          'bundle': widget.bundle,
        },
      },
    );
  }
}
