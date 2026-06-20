import 'package:flutter/material.dart';

import '../../core/demo/demo_app_scope_provider.dart';
import '../../shared/widgets/platform_module_shell.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final scope = DemoAppScopeProvider.of(context);
    final activeModel = scope.modelBundleService.activeModel;

    return PlatformModuleShell(
      appBarTitle: '设置与权限',
      title: '设置与权限',
      subtitle: '当前模块负责集中展示运行模式、权限占位、单位规范和平台边界说明，让用户明确这是一套实验测量型平台，而不是营销页或通用检测工具。',
      tags: [
        scope.isDemoMode ? '演示模式' : '非演示模式',
        '模拟数据',
        scope.hardwareProfileLabel,
      ],
      summaryItems: [
        PlatformSummaryItem(
          label: '模式',
          value: scope.isDemoMode ? '演示模式' : '非演示模式',
          note: '当前预览默认通过平台工作台进入演示环境。',
        ),
        PlatformSummaryItem(
          label: '模型',
          value: activeModel?.modelId ?? '未启用',
          note: activeModel == null ? '当前缺少模型包。' : '平台结果页、历史页和报告页会沿用该模型上下文。',
        ),
        const PlatformSummaryItem(
          label: '边界',
          value: '实验验证',
          note: '本应用仅用于大学物理实验与方法验证，不作为食品安全、商品分级或执法检测依据。',
        ),
      ],
      children: [
        PlatformSectionCard(
          title: '当前运行状态',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  Chip(label: Text(scope.isDemoMode ? '演示模式' : '非演示模式')),
                  const Chip(label: Text('模拟数据')),
                  Chip(label: Text(scope.hardwareProfileLabel)),
                ],
              ),
              const SizedBox(height: 12),
              const Text(
                '所有记录、报告和结果都必须持续显示“模拟数据”标记，结果单位统一为 mg/cm2 NaCl eq.',
              ),
            ],
          ),
        ),
        const PlatformSectionCard(
          title: '权限与接入占位',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _SettingsRow(
                title: '相机权限',
                subtitle: '真实相机采集接入前保留，当前演示模式无需授权。',
              ),
              SizedBox(height: 12),
              _SettingsRow(
                title: '文件权限',
                subtitle: '后续用于真实图像导入和报告导出，当前仅展示占位说明。',
              ),
            ],
          ),
        ),
        PlatformSectionCard(
          title: '平台参数',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _SettingsRow(
                title: '模拟模式',
                subtitle: scope.isDemoMode ? '当前为演示模式。' : '当前未进入演示模式。',
              ),
              const SizedBox(height: 12),
              const _SettingsRow(
                title: '单位说明',
                subtitle: '所有结果统一显示 mg/cm2 NaCl eq.',
              ),
              const SizedBox(height: 12),
              _SettingsRow(
                title: '当前模型',
                subtitle: activeModel?.modelId ?? '当前未启用模型包。',
              ),
              const SizedBox(height: 12),
              _SettingsRow(
                title: '当前硬件',
                subtitle: scope.hardwareProfileLabel,
              ),
            ],
          ),
        ),
        const PlatformSectionCard(
          title: '平台边界',
          child: _SettingsRow(
            title: '风险说明',
            subtitle: '本应用仅用于大学物理实验与方法验证，不作为食品安全、商品分级或执法检测依据。',
          ),
        ),
      ],
    );
  }
}

class _SettingsRow extends StatelessWidget {
  const _SettingsRow({
    required this.title,
    required this.subtitle,
  });

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 96,
          child: Text(
            title,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
        Expanded(
          child: Text(
            subtitle,
            style: theme.textTheme.bodyMedium,
          ),
        ),
      ],
    );
  }
}
