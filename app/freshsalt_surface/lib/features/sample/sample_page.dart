import 'package:flutter/material.dart';

import '../../core/demo/demo_app_scope_provider.dart';
import '../../core/demo/demo_capture_bundle_factory.dart';
import '../../routing/app_router.dart';
import '../../shared/widgets/platform_module_shell.dart';

class SamplePage extends StatelessWidget {
  const SamplePage({super.key});

  @override
  Widget build(BuildContext context) {
    final scope = DemoAppScopeProvider.of(context);
    final cases = scope.demoCaptureCases;

    return PlatformModuleShell(
      appBarTitle: '样品管理',
      title: '样品管理与建档',
      subtitle:
          '当前使用演示样品卡管理模拟采集案例，模块要服务平台主链：查看样品、理解案例差异、带着样品上下文进入质控，而不是停留在轻量列表页。',
      tags: const ['模拟数据', '演示模式', '平台模块'],
      summaryItems: [
        PlatformSummaryItem(
          label: '样品数',
          value: '${cases.length} 个',
          note: '当前覆盖低负载、中负载、高负载与异常案例。',
        ),
        const PlatformSummaryItem(
          label: '入口',
          value: '质控起步',
          note: '样品管理不绕回兼容工作台，直接带案例进入成像质控。',
        ),
        const PlatformSummaryItem(
          label: '状态',
          value: '模拟建档',
          note: '后续可扩展批次、备注、真实样品来源与实验编号。',
        ),
      ],
      children: [
        const PlatformSectionCard(
          title: '模块定位',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('样品管理模块负责组织演示案例、样品标签和采集入口。'),
              SizedBox(height: 8),
              Text('用户在这里决定“拿哪个样品进入主链”，而不是直接执行 ROI、特征或预测动作。'),
            ],
          ),
        ),
        PlatformSectionCard(
          title: '样品案例',
          child: Column(
            children: cases
                .map(
                  (item) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _SampleCaseCard(
                      sampleId: item.sampleId,
                      title: item.title,
                      subtitle: item.subtitle,
                      baselinePath: item.baselineImagePath,
                      saltedPath: item.saltedImagePath,
                      onPressed: () => Navigator.of(context).pushNamed(
                        AppRouter.qualityControl,
                        arguments: buildDemoCaptureBundle(
                          scope,
                          initialCaseId: item.id,
                        ),
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
        ),
      ],
    );
  }
}

class _SampleCaseCard extends StatelessWidget {
  const _SampleCaseCard({
    required this.sampleId,
    required this.title,
    required this.subtitle,
    required this.baselinePath,
    required this.saltedPath,
    required this.onPressed,
  });

  final String sampleId;
  final String title;
  final String subtitle;
  final String baselinePath;
  final String saltedPath;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: theme.colorScheme.outlineVariant),
        color: theme.colorScheme.surface,
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      sampleId,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      title,
                      style: theme.textTheme.titleSmall,
                    ),
                  ],
                ),
              ),
              const Chip(label: Text('模拟数据')),
            ],
          ),
          const SizedBox(height: 8),
          Text(subtitle),
          const SizedBox(height: 12),
          Text(
            '基线图：$baselinePath',
            style: theme.textTheme.bodySmall,
          ),
          const SizedBox(height: 4),
          Text(
            '待测图：$saltedPath',
            style: theme.textTheme.bodySmall,
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: onPressed,
              child: const Text('开始该样品采集'),
            ),
          ),
        ],
      ),
    );
  }
}
