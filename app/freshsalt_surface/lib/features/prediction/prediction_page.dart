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
    final selectedCase = controller?.selectedCase;

    return CaptureStageShell(
      appBarTitle: '结果计算',
      title: '结果计算',
      subtitle: '在本阶段完成模型推理、结果确认与显式保存，保存后才进入结果详情、历史与报告模块。',
      stageLabel: alreadySaved ? '7 / 7' : '6 / 7',
      stageTitle: alreadySaved ? '保存完成' : '预测与保存',
      tags: [
        '模拟数据',
        if (selectedCase != null) selectedCase.sampleId,
        if (workflowState != null) '阶段 ${workflowState.currentStage}',
      ],
      metrics: [
        CaptureStageMetric(
          label: '样品',
          value: selectedCase?.sampleId ?? '未绑定',
          note: selectedCase?.title ?? '当前阶段负责形成 prediction_result 与历史记录。',
        ),
        CaptureStageMetric(
          label: '结果',
          value: prediction == null
              ? '待计算'
              : '${prediction.predictedValue.toStringAsFixed(3)} ${prediction.unit}',
          note: prediction == null ? '需要先运行演示预测。' : '保存后再进入结果详情。',
        ),
      ],
      children: [
        CaptureStageSectionCard(
          title: '当前阶段主操作',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                prediction == null
                    ? '请先在本页完成演示预测，再进入保存与结果详情。'
                    : alreadySaved
                        ? '当前结果已保存，可直接查看结果详情。'
                        : '当前结果已生成，请先保存到历史。',
              ),
              const SizedBox(height: 6),
              Text(
                '完成保存后可查看结果详情。',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(height: 12),
              if (prediction == null)
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: canRunPrediction ? _runPrediction : null,
                    child: Text(_running ? '运行中...' : '开始演示预测'),
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
          title: '结果摘要',
          trailing: Chip(
            label: Text(
              prediction == null
                  ? '待计算'
                  : alreadySaved
                      ? '已保存到历史'
                      : '待保存',
            ),
          ),
          child: prediction == null
              ? const Text('尚未计算结果，请先执行当前阶段的演示预测动作。')
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${prediction.predictedValue.toStringAsFixed(4)} ${prediction.unit}',
                    ),
                    const SizedBox(height: 12),
                    Text('结果状态: ${prediction.resultStatus}'),
                    Text('置信等级: ${prediction.confidenceLevel}'),
                    const SizedBox(height: 12),
                    if (!alreadySaved) const Text('请使用上方当前阶段主操作完成保存。'),
                    ...prediction.warnings.map((item) => Text('• $item')),
                  ],
                ),
        ),
        CaptureStageSectionCard(
          title: '阶段导航',
          child: CaptureStageNavigation(
            previousLabel: '上一步：特征预览',
            previousAction: () => Navigator.of(context).pop(),
            nextLabel: alreadySaved ? '下一步：查看结果详情' : '下一步：返回采集页保存',
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
