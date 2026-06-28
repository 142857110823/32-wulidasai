import 'package:flutter/material.dart';

import '../../core/demo/demo_app_scope_provider.dart';
import '../../shared/widgets/platform_module_shell.dart';

class HardwareConfigPage extends StatefulWidget {
  const HardwareConfigPage({super.key});

  @override
  State<HardwareConfigPage> createState() => _HardwareConfigPageState();
}

class _HardwareConfigPageState extends State<HardwareConfigPage> {
  static const _profiles = <String>[
    'darkbox_v1',
    'field_capture_v1',
  ];

  @override
  Widget build(BuildContext context) {
    final scope = DemoAppScopeProvider.of(context);
    final activeModel = scope.modelBundleService.activeModel;
    final currentHardware = scope.hardwareProfileLabel;
    final matchesModel = activeModel == null
        ? false
        : scope.modelBundleService.validateHardwareCompatibility(
            currentHardware,
            activeModel,
          );

    return PlatformModuleShell(
      appBarTitle: '硬件配置',
      title: '硬件配置与匹配检查',
      subtitle:
          '当前模块负责展示演示硬件配置、匹配状态和异常配置切换，用来支撑平台主链中的“模型包与硬件是否就绪”判断，而不是只做单行配置列表。',
      tags: [
        '模拟数据',
        '演示模式',
        currentHardware,
      ],
      summaryItems: [
        PlatformSummaryItem(
          label: '当前配置',
          value: currentHardware,
          note: '这是当前平台采集链默认使用的硬件配置。',
        ),
        PlatformSummaryItem(
          label: '当前模型',
          value: activeModel?.modelId ?? '未启用',
          note: activeModel == null ? '缺少模型包时不能形成正式推理。' : '硬件匹配状态会影响采集主链的可用性。',
        ),
        PlatformSummaryItem(
          label: '匹配',
          value: activeModel == null
              ? '缺少模型'
              : matchesModel
                  ? '已匹配'
                  : '不匹配',
          note: matchesModel
              ? '当前配置可用于演示推理与结果保存。'
              : '不匹配配置只适合作为异常演示。',
        ),
      ],
      children: [
        PlatformSectionCard(
          title: '当前配置摘要',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _ConfigRow(label: '当前配置', value: currentHardware),
              const _ConfigRow(label: 'ROI', value: 'ROI 4.0 cm2'),
              const _ConfigRow(label: '灰卡类型', value: 'X-Rite ColorChecker'),
              const _ConfigRow(label: '光源策略', value: '固定暗箱照明'),
            ],
          ),
        ),
        PlatformSectionCard(
          title: '应用演示配置',
          child: Column(
            children: _profiles
                .map(
                  (profile) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _HardwareProfileCard(
                      profile: profile,
                      currentHardware: currentHardware,
                      description: profile == 'darkbox_v1'
                          ? '暗箱标准演示配置，默认与当前模拟模型匹配。'
                          : '非匹配异常配置，用于验证硬件不匹配提示。',
                      onApply: () => _applyHardware(scope, profile),
                    ),
                  ),
                )
                .toList(),
          ),
        ),
        PlatformSectionCard(
          title: '模型匹配检查',
          trailing: Chip(label: Text(matchesModel ? '已匹配' : '需警告')),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _ConfigRow(
                label: '当前模型',
                value: activeModel?.modelId ?? '未启用',
              ),
              _ConfigRow(
                label: '匹配结果',
                value: activeModel == null
                    ? '缺少模型包'
                    : matchesModel
                        ? '已匹配 $currentHardware'
                        : '$currentHardware 与当前模型不匹配',
              ),
              const SizedBox(height: 8),
              Text(
                matchesModel
                    ? '当前配置可用于演示推理与结果保存。'
                    : '当前配置只适合作为异常演示；若继续推理，应给出硬件不匹配警告。',
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _applyHardware(dynamic scope, String hardwareProfileId) {
    setState(() {
      scope.applyHardwareProfile(hardwareProfileId);
    });
  }
}

class _HardwareProfileCard extends StatelessWidget {
  const _HardwareProfileCard({
    required this.profile,
    required this.currentHardware,
    required this.description,
    required this.onApply,
  });

  final String profile;
  final String currentHardware;
  final String description;
  final VoidCallback onApply;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final selected = currentHardware == profile;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  profile,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Chip(label: Text(selected ? '当前配置' : '可切换')),
            ],
          ),
          const SizedBox(height: 8),
          Text(description),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: selected ? null : onApply,
              child: Text('应用 $profile'),
            ),
          ),
        ],
      ),
    );
  }
}

class _ConfigRow extends StatelessWidget {
  const _ConfigRow({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 96,
            child: Text(label, style: Theme.of(context).textTheme.bodySmall),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}
