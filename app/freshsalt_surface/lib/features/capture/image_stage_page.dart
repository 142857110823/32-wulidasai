import 'package:flutter/material.dart';

import '../../core/models/capture_step_bundle.dart';
import '../../shared/widgets/capture_stage_navigation.dart';
import '../../shared/widgets/capture_stage_shell.dart';

class ImageStagePage extends StatefulWidget {
  const ImageStagePage({
    super.key,
    required this.title,
    required this.description,
    required this.imagePath,
    required this.isReady,
    this.previousLabel,
    this.previousAction,
    this.nextLabel,
    this.nextAction,
    this.bundle,
  });

  final String title;
  final String description;
  final String? imagePath;
  final bool isReady;
  final String? previousLabel;
  final VoidCallback? previousAction;
  final String? nextLabel;
  final VoidCallback? nextAction;
  final CaptureStepBundle? bundle;

  @override
  State<ImageStagePage> createState() => _ImageStagePageState();
}

class _ImageStagePageState extends State<ImageStagePage> {
  @override
  Widget build(BuildContext context) {
    final controller = widget.bundle?.controller;
    final isBaselineStage = widget.title.contains('I0');
    final resolvedImagePath = isBaselineStage
        ? controller?.baselineImagePath ??
            widget.bundle?.baselineImagePath ??
            widget.imagePath
        : controller?.saltedImagePath ??
            widget.bundle?.saltedImagePath ??
            widget.imagePath;
    final resolvedReady =
        resolvedImagePath != null && resolvedImagePath.isNotEmpty;
    final workflowState =
        controller?.workflowState ?? widget.bundle?.workflowState;
    final canAdvance = resolvedReady;
    final selectedCase = controller?.selectedCase;
    final stageLabel = isBaselineStage ? '2 / 7' : '3 / 7';
    final hasImportAction = isBaselineStage
        ? widget.bundle?.importBaselineImage != null
        : widget.bundle?.importSaltedImage != null;
    final stageTitle = isBaselineStage ? 'I0 基线图' : 'I1 待测图';
    final isRealImage = isBaselineStage
        ? (controller?.baselineUsesSimulatedSource == false)
        : (controller?.saltedUsesSimulatedSource == false);
    final imageSourceText = isRealImage ? '真实图片已导入' : '模拟数据';

    return CaptureStageShell(
      appBarTitle: widget.title,
      title: widget.title,
      subtitle: widget.description,
      stageLabel: stageLabel,
      stageTitle: stageTitle,
      tags: [
        imageSourceText,
        hasImportAction ? '支持真实图片导入' : '仅演示图片',
        if (selectedCase != null) selectedCase.sampleId,
        if (workflowState != null) '阶段 ${workflowState.currentStage}',
      ],
      metrics: [
        CaptureStageMetric(
          label: '样品',
          value: selectedCase?.sampleId ?? '未绑定',
          note: selectedCase?.title ?? '当前阶段负责完成图像加载。',
        ),
        CaptureStageMetric(
          label: '图像',
          value: resolvedReady ? '已加载' : '待加载',
          note: resolvedImagePath ?? '当前还没有可展示的图像路径。',
        ),
        CaptureStageMetric(
          label: '来源',
          value: isRealImage ? '真实图片' : '模拟数据',
          note: isRealImage
              ? '来自本地 PNG / JPG 文件，后续进入真实像素质控。'
              : '来自演示目录，仅用于流程演示。',
        ),
      ],
      children: [
        CaptureStageSectionCard(
          title: '当前阶段主操作',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (isRealImage) ...[
                const Text('真实图片已导入'),
                const SizedBox(height: 6),
              ],
              Text(
                resolvedReady
                    ? '当前阶段已完成，可以继续下一步。'
                    : '请先加载当前阶段所需图像，再继续后续步骤。',
              ),
              const SizedBox(height: 6),
              Text(
                isBaselineStage ? '完成后进入 I1 待测图。' : '完成后进入 ROI 圈定。',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: isBaselineStage
                      ? widget.bundle?.useBaselineImage == null
                          ? null
                          : _useBaselineImage
                      : widget.bundle?.useSaltedImage == null
                          ? null
                          : _useSaltedImage,
                  child: Text(isBaselineStage ? '使用模拟 I0' : '使用模拟 I1'),
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: isBaselineStage
                      ? widget.bundle?.importBaselineImage == null
                          ? null
                          : _importBaselineImage
                      : widget.bundle?.importSaltedImage == null
                          ? null
                          : _importSaltedImage,
                  icon: const Icon(Icons.file_open_outlined),
                  label: Text(
                    isBaselineStage
                        ? '导入真实 I0 PNG / JPG'
                        : '导入真实 I1 PNG / JPG',
                  ),
                ),
              ),
            ],
          ),
        ),
        CaptureStageSectionCard(
          title: '阶段导航',
          child: CaptureStageNavigation(
            previousLabel: widget.previousLabel,
            previousAction: widget.previousAction,
            nextLabel: widget.nextLabel,
            nextAction: canAdvance ? widget.nextAction : null,
          ),
        ),
        CaptureStageSectionCard(
          title: '阶段状态',
          trailing: Chip(label: Text(resolvedReady ? '已加载图像' : '尚未加载')),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(resolvedImagePath ?? '当前还没有可展示的图像路径。'),
              const SizedBox(height: 12),
              Text(
                isBaselineStage
                    ? '本页负责确认 I0 基线图路径、来源状态与阶段完成情况。'
                    : '本页负责确认 I1 待测图路径、来源状态与后续 ROI 入口。',
              ),
              if (isRealImage) ...[
                const SizedBox(height: 8),
                Text(
                  '真实图片仅表示已进入本地图像质控链路，最终结果仍需经过 ROI、特征提取与模型范围判断。',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  void _useBaselineImage() {
    widget.bundle?.useBaselineImage?.call();
    if (!mounted) {
      return;
    }
    setState(() {});
    final controller = widget.bundle?.controller;
    final baselineReady =
        (controller?.baselineImagePath ?? widget.bundle?.baselineImagePath) !=
            null;
    if (baselineReady) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) {
          return;
        }
        widget.nextAction?.call();
      });
    }
  }

  void _useSaltedImage() {
    widget.bundle?.useSaltedImage?.call();
    if (!mounted) {
      return;
    }
    setState(() {});
    final controller = widget.bundle?.controller;
    final saltedReady =
        (controller?.saltedImagePath ?? widget.bundle?.saltedImagePath) != null;
    if (saltedReady) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) {
          return;
        }
        widget.nextAction?.call();
      });
    }
  }

  Future<void> _importBaselineImage() async {
    final action = widget.bundle?.importBaselineImage;
    if (action == null) {
      return;
    }
    await action();
    if (!mounted) {
      return;
    }
    setState(() {});
    final controller = widget.bundle?.controller;
    final baselineReady =
        (controller?.baselineImagePath ?? widget.bundle?.baselineImagePath) != null;
    if (baselineReady) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) {
          return;
        }
        widget.nextAction?.call();
      });
    }
  }

  Future<void> _importSaltedImage() async {
    final action = widget.bundle?.importSaltedImage;
    if (action == null) {
      return;
    }
    await action();
    if (!mounted) {
      return;
    }
    setState(() {});
    final controller = widget.bundle?.controller;
    final saltedReady =
        (controller?.saltedImagePath ?? widget.bundle?.saltedImagePath) != null;
    if (saltedReady) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) {
          return;
        }
        widget.nextAction?.call();
      });
    }
  }
}
