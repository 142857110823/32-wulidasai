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
      appBarTitle: '设置与说明',
      title: '设置与说明',
      subtitle: '统一查看当前运行模式、单位规范、设备配置和使用边界。',
      tags: [
        scope.isDemoMode ? '演示模式' : '普通模式',
        '模拟数据',
        scope.hardwareProfileLabel,
      ],
      summaryItems: [
        PlatformSummaryItem(
          label: '模式',
          value: scope.isDemoMode ? '演示模式' : '普通模式',
          note: '当前页面用于说明平台状态，不承载采集主操作。',
        ),
        PlatformSummaryItem(
          label: '模型',
          value: activeModel?.modelId ?? '未启用',
          note: activeModel == null ? '当前没有可用模型。' : '结果页、历史页和报告页会沿用该模型上下文。',
        ),
        const PlatformSummaryItem(
          label: '边界',
          value: '图像测量辅助',
          note: '本应用用于图像测量与过程辅助，不提供安全、执法或商业判定。',
        ),
      ],
      children: [
        PlatformSectionCard(
          title: '当前状态',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  Chip(label: Text(scope.isDemoMode ? '演示模式' : '普通模式')),
                  const Chip(label: Text('模拟数据')),
                  Chip(label: Text(scope.hardwareProfileLabel)),
                ],
              ),
              const SizedBox(height: 12),
              const Text(
                '所有记录、报告和结果都应持续显示“模拟数据”标记，结果单位统一为 mg/cm2 NaCl eq.',
              ),
            ],
          ),
        ),
        const PlatformSectionCard(
          title: '权限与接入',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _SettingsRow(
                title: '相机权限',
                subtitle: '用于后续真实拍摄接入，当前版本以图片导入为主。',
              ),
              SizedBox(height: 12),
              _SettingsRow(
                title: '文件权限',
                subtitle: '用于导入图片与导出报告。',
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
                title: '当前模式',
                subtitle: scope.isDemoMode ? '演示模式' : '普通模式',
              ),
              const SizedBox(height: 12),
              const _SettingsRow(
                title: '结果单位',
                subtitle: '统一显示为 mg/cm2 NaCl eq.',
              ),
              const SizedBox(height: 12),
              _SettingsRow(
                title: '当前模型',
                subtitle: activeModel?.modelId ?? '当前未启用模型。',
              ),
              const SizedBox(height: 12),
              _SettingsRow(
                title: '当前设备',
                subtitle: scope.hardwareProfileLabel,
              ),
            ],
          ),
        ),
        const PlatformSectionCard(
          title: '使用边界',
          child: _SettingsRow(
            title: '说明',
            subtitle: '本应用用于图像测量辅助与流程记录，不输出执法、医疗或安全定性结论。',
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
