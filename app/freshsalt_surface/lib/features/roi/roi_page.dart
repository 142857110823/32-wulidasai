import 'package:flutter/material.dart';

import '../../core/models/capture_step_bundle.dart';
import '../../routing/app_router.dart';
import '../../shared/widgets/capture_stage_navigation.dart';
import '../../shared/widgets/capture_stage_shell.dart';

class RoiPage extends StatefulWidget {
  const RoiPage({
    super.key,
    this.bundle,
  });

  final CaptureStepBundle? bundle;

  @override
  State<RoiPage> createState() => _RoiPageState();
}

class _RoiPageState extends State<RoiPage> {
  @override
  Widget build(BuildContext context) {
    final controller = widget.bundle?.controller;
    final roi = widget.bundle?.roiPolygon;
    final workflowState =
        controller?.workflowState ?? widget.bundle?.workflowState;
    final confirmed = controller?.roiConfirmed ?? false;
    final selectedCase = controller?.selectedCase;

    return CaptureStageShell(
      appBarTitle: 'ROI 与灰卡',
      title: 'ROI 与灰卡',
      subtitle: '当前版本使用固定 2 cm × 2 cm ROI 和固定灰卡参考区，不做真实拖拽，但仍按主链页承担确认动作。',
      stageLabel: '4 / 7',
      stageTitle: 'ROI',
      tags: [
        '模拟数据',
        if (selectedCase != null) selectedCase.sampleId,
        if (workflowState != null) '阶段 ${workflowState.currentStage}',
      ],
      metrics: [
        CaptureStageMetric(
          label: '样品',
          value: selectedCase?.sampleId ?? '未绑定',
          note: selectedCase?.title ?? 'ROI 与灰卡在当前阶段统一确认。',
        ),
        CaptureStageMetric(
          label: '状态',
          value: confirmed ? '已确认' : '待确认',
          note: confirmed ? '可进入特征预览。' : '需要先执行当前阶段主操作。',
        ),
      ],
      children: [
        CaptureStageSectionCard(
          title: '当前阶段主操作',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                confirmed
                    ? '当前阶段已完成，可直接进入特征预览。'
                    : '请先确认当前案例的 ROI 与灰卡摘要，再继续后续步骤。',
              ),
              const SizedBox(height: 6),
              Text(
                '完成当前阶段后进入特征预览。',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: widget.bundle?.confirmRoi == null ? null : _confirmRoi,
                  child: const Text('确认 ROI'),
                ),
              ),
            ],
          ),
        ),
        CaptureStageSectionCard(
          title: '阶段状态与导航',
          trailing: Chip(label: Text(confirmed ? '已确认' : '待确认')),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(confirmed ? '当前 ROI 已确认。' : '当前 ROI 尚未确认。'),
              const SizedBox(height: 6),
              Text(
                confirmed ? '已解锁特征预览阶段。' : '请先完成 ROI 确认。',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(height: 12),
              CaptureStageNavigation(
                previousLabel: '返回 I1 待测图',
                previousAction: () => Navigator.of(context).pop(),
                nextLabel: '下一步：特征预览',
                nextAction: confirmed
                    ? () => Navigator.of(context).pushNamed(
                          AppRouter.featurePreview,
                          arguments: widget.bundle,
                        )
                    : null,
              ),
            ],
          ),
        ),
        CaptureStageSectionCard(
          title: 'ROI 与灰卡摘要',
          child: roi == null
              ? const Text('尚未提供 ROI 摘要，请先完成前序阶段。')
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('ROI 面积: ${roi['area']} cm2'),
                    Text('宽度: ${roi['width_cm']} cm'),
                    Text('高度: ${roi['height_cm']} cm'),
                    Text('中心点: ${roi['center_x']}, ${roi['center_y']}'),
                    Text(
                      '边界状态: ${(roi['within_bounds'] as bool? ?? false) ? '有效' : '越界'}',
                    ),
                  ],
                ),
        ),
      ],
    );
  }

  void _confirmRoi() {
    widget.bundle?.confirmRoi?.call();
    if (!mounted) {
      return;
    }
    setState(() {});
  }
}
