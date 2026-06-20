import 'package:flutter/material.dart';

import '../../core/models/capture_step_bundle.dart';
import '../../routing/app_router.dart';
import '../../shared/widgets/capture_stage_navigation.dart';
import '../../shared/widgets/capture_stage_shell.dart';

class FeaturePreviewPage extends StatefulWidget {
  const FeaturePreviewPage({
    super.key,
    this.bundle,
  });

  final CaptureStepBundle? bundle;

  @override
  State<FeaturePreviewPage> createState() => _FeaturePreviewPageState();
}

class _FeaturePreviewPageState extends State<FeaturePreviewPage> {
  bool _running = false;

  @override
  Widget build(BuildContext context) {
    final controller = widget.bundle?.controller;
    final featureVector = controller?.featureVector ?? widget.bundle?.featureVector;
    final workflowState = controller?.workflowState ?? widget.bundle?.workflowState;
    final canRunFeatureExtraction =
        widget.bundle?.runFeatureExtraction != null && !_running;
    final canAdvance = featureVector != null;
    final selectedCase = controller?.selectedCase;
    final featureCount = featureVector?.features.length ?? 0;

    return CaptureStageShell(
      appBarTitle: '特征预览',
      title: '特征预览',
      subtitle: '展示颜色差分、白化、高光和纹理特征摘要，并在本阶段完成特征提取后再进入结果计算。',
      stageLabel: '5 / 7',
      stageTitle: '特征',
      tags: [
        '模拟数据',
        if (selectedCase != null) selectedCase.sampleId,
        if (workflowState != null) '阶段 ${workflowState.currentStage}',
      ],
      metrics: [
        CaptureStageMetric(
          label: '样品',
          value: selectedCase?.sampleId ?? '未绑定',
          note: selectedCase?.title ?? '当前阶段负责形成 feature_vector。',
        ),
        CaptureStageMetric(
          label: '特征',
          value: featureVector == null ? '待提取' : '$featureCount 项',
          note: featureVector == null ? '需要先执行当前阶段主操作。' : '已可进入结果计算。',
        ),
      ],
      children: [
        CaptureStageSectionCard(
          title: '当前阶段主操作',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                featureVector == null
                    ? '请先提取当前案例的特征向量，再进入结果计算。'
                    : '当前阶段已完成，可直接进入结果计算。',
              ),
              const SizedBox(height: 6),
              Text(
                '完成当前阶段后进入结果计算。',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              if (featureVector == null) ...[
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: canRunFeatureExtraction ? _runFeatureExtraction : null,
                    child: Text(_running ? '运行中...' : '提取特征'),
                  ),
                ),
              ],
            ],
          ),
        ),
        CaptureStageSectionCard(
          title: '阶段导航',
          child: CaptureStageNavigation(
            previousLabel: '上一步：ROI 摘要',
            previousAction: () => Navigator.of(context).pop(),
            nextLabel: '下一步：结果计算',
            nextAction: canAdvance
                ? () => Navigator.of(context).pushNamed(
                      AppRouter.prediction,
                      arguments: widget.bundle,
                    )
                : null,
          ),
        ),
        CaptureStageSectionCard(
          title: '特征摘要',
          trailing: Chip(label: Text(featureVector == null ? '待生成' : '已生成')),
          child: featureVector == null
              ? const Text('尚未提取特征，请先执行当前阶段的特征提取动作。')
              : Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: featureVector.features.entries
                      .map(
                        (entry) => Chip(
                          label: Text(
                            '${entry.key}: ${entry.value.toStringAsFixed(3)}',
                          ),
                        ),
                      )
                      .toList(),
                ),
        ),
      ],
    );
  }

  Future<void> _runFeatureExtraction() async {
    final action = widget.bundle?.runFeatureExtraction;
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
}
