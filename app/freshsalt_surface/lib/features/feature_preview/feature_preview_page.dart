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

  static const Map<String, double> _previewFeatureFallback = {
    'dL': -8.5,
    'whiteness_index': 0.24,
    'specular_ratio': 0.18,
    'dS': -1.8,
  };

  @override
  Widget build(BuildContext context) {
    final controller = widget.bundle?.controller;
    final featureVector =
        controller?.featureVector ?? widget.bundle?.featureVector;
    final workflowState =
        controller?.workflowState ?? widget.bundle?.workflowState;
    final canRunFeatureExtraction =
        widget.bundle?.runFeatureExtraction != null && !_running;
    final canAdvance = featureVector != null;
    final featureCount = featureVector?.features.length ?? 0;
    final usingRealPixels = controller?.hasImportedRealImages ?? false;
    final extractionMethod =
        featureVector?.metadata['extraction_method'] as String?;
    final roiSource = featureVector?.metadata['roi_source'] as String?;
    final differenceImagePath = featureVector?.differenceImagePath;
    final topFeatures = [
      'dL',
      'whiteness_index',
      'specular_ratio',
      'dS',
    ]
        .where((key) => featureVector?.features.containsKey(key) ?? false)
        .map((key) => MapEntry(key, featureVector!.features[key]!))
        .toList(growable: false);
    final previewFeatureRows = topFeatures.isNotEmpty
        ? topFeatures
        : _previewFeatureFallback.entries.toList(growable: false);

    return CaptureStageShell(
      appBarTitle: '特征提取',
      title: '特征预览',
      subtitle: '先展示当前图像可用于计算的关键特征，再进入结果计算。',
      stageLabel: '5 / 7',
      stageTitle: '特征',
      tags: [
        usingRealPixels ? '真实图片' : '内置图片',
        if (usingRealPixels) 'real_image_pixels',
        if (workflowState != null) '阶段 ${workflowState.currentStage}',
      ],
      metrics: [
        CaptureStageMetric(
          label: '特征数量',
          value: featureVector == null ? '4 项预览' : '$featureCount 项',
          note: featureVector == null ? '先展示默认预览，执行后刷新为当前结果。' : '可以进入结果计算。',
        ),
        CaptureStageMetric(
          label: '来源',
          value: usingRealPixels ? 'real pixels' : 'simulated',
          note: extractionMethod ?? (usingRealPixels ? 'pending' : 'simulated'),
        ),
      ],
      children: [
        CaptureStageSectionCard(
          title: '当前操作',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                featureVector == null
                    ? '当前先展示一组默认特征预览，便于快速确认本页会输出哪些关键量。'
                    : '当前特征已经生成，可以直接进入结果计算。',
              ),
              const SizedBox(height: 6),
              Text(
                '本页优先展示结果，不再保留空白壳页面。',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              if (featureVector == null) ...[
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed:
                        canRunFeatureExtraction ? _runFeatureExtraction : null,
                    child: Text(_running ? '运行中...' : '提取特征'),
                  ),
                ),
              ],
            ],
          ),
        ),
        CaptureStageSectionCard(
          title: '关键结果',
          trailing: Chip(label: Text(featureVector == null ? '预览中' : '已生成')),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (featureVector == null)
                const Text('当前显示的是默认特征预览，执行后会切换为当前图像链路的实际特征。'),
              if (featureVector != null)
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    _FeatureMetricCard(
                      label: '特征数量',
                      value: '$featureCount',
                      note: 'feature vector 已生成',
                    ),
                    _FeatureMetricCard(
                      label: '提取方式',
                      value: extractionMethod ?? 'unknown',
                      note: usingRealPixels ? '来自真实图片像素' : '来自内置数据',
                    ),
                    _FeatureMetricCard(
                      label: 'ROI 来源',
                      value: roiSource ?? 'unknown',
                      note: '当前用于计算的选区',
                    ),
                  ],
                )
              else
                const Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    _FeatureMetricCard(
                      label: '特征数量',
                      value: '4',
                      note: '默认预览',
                    ),
                    _FeatureMetricCard(
                      label: '提取方式',
                      value: 'demo preview',
                      note: '等待实际提取',
                    ),
                    _FeatureMetricCard(
                      label: 'ROI 来源',
                      value: 'current ROI',
                      note: '来自当前圈定区域',
                    ),
                  ],
                ),
              const SizedBox(height: 12),
              ...previewFeatureRows.map(
                (entry) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: _FeatureValueRow(
                    label: entry.key,
                    value: entry.value.toStringAsFixed(3),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'difference_image_path: ${differenceImagePath ?? 'preview_pending'}',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ),
        CaptureStageSectionCard(
          title: '完整特征列表',
          trailing: Chip(label: Text(featureVector == null ? '待生成' : '已生成')),
          child: featureVector == null
              ? const Text('执行特征提取后，这里会展开当前图像链路的完整特征列表。')
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
        CaptureStageSectionCard(
          title: '阶段导航',
          child: CaptureStageNavigation(
            previousLabel: '上一步：ROI',
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

class _FeatureMetricCard extends StatelessWidget {
  const _FeatureMetricCard({
    required this.label,
    required this.value,
    required this.note,
  });

  final String label;
  final String value;
  final String note;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: 156,
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
          const SizedBox(height: 4),
          Text(note, style: theme.textTheme.bodySmall),
        ],
      ),
    );
  }
}

class _FeatureValueRow extends StatelessWidget {
  const _FeatureValueRow({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
        Text(
          value,
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}
