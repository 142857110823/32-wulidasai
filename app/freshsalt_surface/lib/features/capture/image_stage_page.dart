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
    final isBaselineStage = widget.title == 'I0 基线图';
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
    final stageTitle = isBaselineStage ? 'I0 基线图' : 'I1 待测图';

    return CaptureStageShell(
      appBarTitle: widget.title,
      title: widget.title,
      subtitle: widget.description,
      stageLabel: stageLabel,
      stageTitle: stageTitle,
      tags: [
        '模拟数据',
        if (selectedCase != null) selectedCase.sampleId,
        if (workflowState != null) '阶段 ${workflowState.currentStage}',
      ],
      metrics: [
        CaptureStageMetric(
          label: '样品',
          value: selectedCase?.sampleId ?? '未绑定',
          note: selectedCase?.title ?? '当前阶段由页面自身承担装载动作。',
        ),
        CaptureStageMetric(
          label: '图像',
          value: resolvedReady ? '已装载' : '待装载',
          note: resolvedImagePath ?? '当前还没有可展示的图像路径。',
        ),
      ],
      children: [
        CaptureStageSectionCard(
          title: '当前阶段主操作',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                resolvedReady
                    ? '当前阶段已完成，可直接继续下一步。'
                    : '请先装载当前阶段所需的模拟图像，再继续后续步骤。',
              ),
              const SizedBox(height: 6),
              Text(
                isBaselineStage
                    ? '完成当前阶段后将进入 I1 待测图。'
                    : '完成当前阶段后将进入 ROI 摘要。',
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
          trailing: Chip(label: Text(resolvedReady ? '已加载模拟图像' : '尚未加载')),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(resolvedImagePath ?? '当前还没有可展示的图像路径。'),
              const SizedBox(height: 12),
              Text(
                isBaselineStage
                    ? '本页负责确认 I0 基线图路径、缩略状态与阶段完成情况。'
                    : '本页负责确认 I1 待测图路径、缩略状态与后续 ROI 入口。',
              ),
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
  }

  void _useSaltedImage() {
    widget.bundle?.useSaltedImage?.call();
    if (!mounted) {
      return;
    }
    setState(() {});
  }
}
