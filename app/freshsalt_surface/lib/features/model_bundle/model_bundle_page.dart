import 'package:flutter/material.dart';

import '../../core/demo/demo_app_scope_provider.dart';
import '../../core/models/model_bundle.dart';
import '../../shared/widgets/platform_module_shell.dart';

class ModelBundlePage extends StatefulWidget {
  const ModelBundlePage({super.key});

  @override
  State<ModelBundlePage> createState() => _ModelBundlePageState();
}

class _ModelBundlePageState extends State<ModelBundlePage> {
  bool _busy = false;

  @override
  Widget build(BuildContext context) {
    final scope = DemoAppScopeProvider.of(context);
    final bundles = scope.modelBundleService.getCachedModelBundles();
    final activeModel = scope.modelBundleService.activeModel;

    return PlatformModuleShell(
      appBarTitle: '模型包管理',
      title: '模型包管理',
      subtitle: '当前模块负责查看、启用和停用本地模型包，并把有效范围、样品类型和特征维度明确展示给平台其他模块使用，而不是只保留一个“启用”按钮。',
      tags: const ['模拟数据', '演示模式', '平台模块'],
      summaryItems: [
        PlatformSummaryItem(
          label: '当前模型',
          value: activeModel?.modelId ?? '未启用',
          note: activeModel == null ? '当前主链会缺少推理能力。' : '这是平台结果、历史和报告使用的模型包。',
        ),
        PlatformSummaryItem(
          label: '模型数',
          value: '${bundles.length} 个',
          note: '当前版本以内置模拟模型为主，后续再扩展导入链路。',
        ),
        const PlatformSummaryItem(
          label: '边界',
          value: '实验验证',
          note: '模型包仅用于大学物理实验与方法验证，不作为食品安全或执法依据。',
        ),
      ],
      children: [
        PlatformSectionCard(
          title: '激活状态',
          trailing: Chip(label: Text(activeModel == null ? '未启用' : '已启用')),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(activeModel == null ? '当前未启用模型包。' : '当前激活模型'),
              const SizedBox(height: 8),
              Text(activeModel?.modelId ?? '未启用'),
              const SizedBox(height: 12),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  FilledButton(
                    onPressed: activeModel == null || _busy
                        ? null
                        : () => _deactivate(scope),
                    child: Text(_busy ? '处理中...' : '停用当前模型'),
                  ),
                  OutlinedButton(
                    onPressed: activeModel != null || bundles.isEmpty || _busy
                        ? null
                        : () => _activate(scope, bundles.first.modelId),
                    child: const Text('恢复默认模型'),
                  ),
                ],
              ),
            ],
          ),
        ),
        PlatformSectionCard(
          title: '模型包目录',
          child: Column(
            children: bundles
                .map(
                  (bundle) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _ModelBundleCard(
                      bundle: bundle,
                      isActive: activeModel?.modelId == bundle.modelId,
                      busy: _busy,
                      onActivate: () => _activate(scope, bundle.modelId),
                    ),
                  ),
                )
                .toList(),
          ),
        ),
      ],
    );
  }

  Future<void> _activate(dynamic scope, String modelId) async {
    setState(() {
      _busy = true;
    });
    await scope.modelBundleService.activateModelBundle(modelId);
    if (!mounted) {
      return;
    }
    setState(() {
      _busy = false;
    });
  }

  void _deactivate(dynamic scope) {
    setState(() {
      _busy = true;
    });
    scope.modelBundleService.deactivateModelBundle();
    setState(() {
      _busy = false;
    });
  }
}

class _ModelBundleCard extends StatelessWidget {
  const _ModelBundleCard({
    required this.bundle,
    required this.isActive,
    required this.busy,
    required this.onActivate,
  });

  final ModelBundle bundle;
  final bool isActive;
  final bool busy;
  final VoidCallback onActivate;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

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
                  bundle.modelId,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Chip(label: Text(isActive ? '已启用' : '可用')),
            ],
          ),
          const SizedBox(height: 10),
          Text('有效范围 ${bundle.validRange[0]} - ${bundle.validRange[1]} mg/cm2 NaCl eq.'),
          const SizedBox(height: 4),
          Text('目标变量 ${bundle.target}'),
          const SizedBox(height: 4),
          Text('样品类型 ${bundle.sampleType}'),
          const SizedBox(height: 4),
          Text('特征维度 ${bundle.featureOrder.length}'),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: isActive || busy ? null : onActivate,
              child: const Text('启用该模型'),
            ),
          ),
        ],
      ),
    );
  }
}
