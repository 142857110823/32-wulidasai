import 'package:flutter/material.dart';

import '../../core/models/capture_step_bundle.dart';
import '../../routing/app_router.dart';
import '../../shared/widgets/capture_stage_navigation.dart';
import '../../shared/widgets/capture_stage_shell.dart';

class PredictionPage extends StatefulWidget {
  const PredictionPage({
    super.key,
    this.bundle,
  });

  final CaptureStepBundle? bundle;

  @override
  State<PredictionPage> createState() => _PredictionPageState();
}

class _PredictionPageState extends State<PredictionPage> {
  bool _running = false;
  bool _saving = false;

  @override
  Widget build(BuildContext context) {
    final controller = widget.bundle?.controller;
    final prediction =
        controller?.predictionResult ?? widget.bundle?.predictionResult;
    final workflowState =
        controller?.workflowState ?? widget.bundle?.workflowState;
    final canRunPrediction =
        widget.bundle?.runPredictionWorkflow != null && !_running;
    final canSave =
        prediction != null &&
        widget.bundle?.saveSession != null &&
        !(controller?.saved ?? false) &&
        !_saving;
    final alreadySaved = controller?.saved ?? false;
    final statusText = prediction == null
        ? '待计算'
        : alreadySaved
            ? '已保存'
            : '待保存';

    return CaptureStageShell(
      appBarTitle: '结果计算',
      title: '结果计算',
      subtitle: '这里只展示当前真实计算状态，不再预填任何模拟结果。',
      stageLabel: alreadySaved ? '7 / 7' : '6 / 7',
      stageTitle: alreadySaved ? '保存完成' : '预测与保存',
      tags: [
        if (workflowState != null) '阶段 ${workflowState.currentStage}',
        if (prediction != null) prediction.sourceMode,
      ],
      metrics: [
        CaptureStageMetric(
          label: '当前结果',
          value: prediction == null
              ? '未生成'
              : '${prediction.predictedValue.toStringAsFixed(3)} ${prediction.unit}',
          note: prediction == null ? '先运行计算流程' : '结果生成后可进入详情页',
        ),
        CaptureStageMetric(
          label: '保存状态',
          value: statusText,
          note: alreadySaved ? '已写入历史记录' : '结果仍停留在当前流程中',
        ),
      ],
      children: [
        CaptureStageSectionCard(
          title: '当前操作',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                prediction == null
                    ? '当前还没有真实计算结果。请先运行结果计算。'
                    : alreadySaved
                        ? '当前结果已经保存，可以直接打开结果详情页。'
                        : '当前结果已经生成，但还没有写入历史记录。',
              ),
              const SizedBox(height: 12),
              if (prediction == null)
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: canRunPrediction ? _runPrediction : null,
                    child: Text(_running ? '计算中...' : '开始结果计算'),
                  ),
                )
              else if (!alreadySaved)
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: canSave ? _saveSession : null,
                    child: Text(_saving ? '保存中...' : '保存到历史'),
                  ),
                )
              else
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () => Navigator.of(context).pushNamed(
                      AppRouter.result,
                      arguments: controller?.sessionId,
                    ),
                    icon: const Icon(Icons.open_in_new),
                    label: const Text('查看结果详情'),
                  ),
                ),
            ],
          ),
        ),
        CaptureStageSectionCard(
          title: '结果概览',
          trailing: Chip(label: Text(statusText)),
          child: prediction == null
              ? const Text('未运行前不展示默认数值。完成 I0、I1、ROI 与特征流程后，再在此生成真实结果。')
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      prediction.predictedValue.toStringAsFixed(4),
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.w800,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(prediction.unit),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: [
                        _PredictionMetaCard(
                          label: '结果状态',
                          value: prediction.resultStatus,
                        ),
                        _PredictionMetaCard(
                          label: '置信等级',
                          value: prediction.confidenceLevel,
                        ),
                        _PredictionMetaCard(
                          label: '数据来源',
                          value: prediction.sourceMode,
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      '有效范围: ${prediction.validRangeMin.toStringAsFixed(2)} - ${prediction.validRangeMax.toStringAsFixed(2)} ${prediction.unit}',
                    ),
                    if (prediction.warnings.isNotEmpty) ...[
                      const SizedBox(height: 10),
                      ...prediction.warnings.map(
                        (item) => Padding(
                          padding: const EdgeInsets.only(bottom: 6),
                          child: Text('• $item'),
                        ),
                      ),
                    ],
                  ],
                ),
        ),
        CaptureStageSectionCard(
          title: '阶段导航',
          child: CaptureStageNavigation(
            previousLabel: '上一步：特征预览',
            previousAction: () => Navigator.of(context).pop(),
            nextLabel: alreadySaved ? '下一步：结果详情' : '下一步：返回采集流程',
            nextAction: alreadySaved
                ? () => Navigator.of(context).pushNamed(
                      AppRouter.result,
                      arguments: controller?.sessionId,
                    )
                : () => Navigator.of(context).popUntil(
                      (route) => route.settings.name == null || route.isFirst,
                    ),
          ),
        ),
      ],
    );
  }

  Future<void> _runPrediction() async {
    final action = widget.bundle?.runPredictionWorkflow;
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

  Future<void> _saveSession() async {
    final action = widget.bundle?.saveSession;
    if (action == null) {
      return;
    }

    setState(() {
      _saving = true;
    });
    await action();
    if (!mounted) {
      return;
    }
    setState(() {
      _saving = false;
    });
  }
}

class _PredictionMetaCard extends StatelessWidget {
  const _PredictionMetaCard({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: 132,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: theme.textTheme.bodySmall),
          const SizedBox(height: 6),
          Text(
            value,
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
