import 'package:flutter/material.dart';

import '../../core/demo/demo_app_scope_provider.dart';
import '../../routing/app_router.dart';

class HomePage extends StatelessWidget {
  const HomePage({
    super.key,
    this.embedInShell = false,
  });

  final bool embedInShell;

  @override
  Widget build(BuildContext context) {
    final scope = DemoAppScopeProvider.of(context);
    final activeModel = scope.modelBundleService.activeModel;

    return FutureBuilder<List<Map<String, dynamic>>>(
      future: scope.sessionRepository.getAllSessions(isSimulated: false),
      builder: (context, snapshot) {
        final sessions = snapshot.data ?? const <Map<String, dynamic>>[];
        final latestSession = sessions.isEmpty ? null : sessions.first;
        final latestResult = latestSession == null
            ? null
            : Map<String, dynamic>.from(
                latestSession['result'] as Map? ?? const {},
              );
        final latestValue =
            (latestResult?['predicted_mg_cm2'] as num?)?.toDouble();
        final content = SafeArea(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
            children: [
              _HomeHeader(
                hardwareProfileLabel: scope.hardwareProfileLabel,
                activeModelId: activeModel?.modelId,
              ),
              const SizedBox(height: 18),
              _PrimaryWorkbenchCard(
                hasRealResult: latestValue != null,
                latestValue: latestValue,
                onStartCapture: () =>
                    Navigator.of(context).pushNamed(AppRouter.capture),
                onOpenResult: latestValue == null
                    ? null
                    : () => Navigator.of(context).pushNamed(AppRouter.result),
              ),
              const SizedBox(height: 18),
              LayoutBuilder(
                builder: (context, constraints) {
                  final wide = constraints.maxWidth >= 760;
                  final children = [
                    _StatusCard(
                      title: '当前状态',
                      rows: [
                        _StatusRowData(
                          label: '模型',
                          value: activeModel?.modelId ?? '未启用',
                        ),
                        _StatusRowData(
                          label: '硬件',
                          value: scope.hardwareProfileLabel,
                        ),
                        _StatusRowData(
                          label: '结果',
                          value: latestValue == null ? '暂无真实记录' : '已有结果',
                        ),
                      ],
                    ),
                    _StatusCard(
                      title: '下一步',
                      rows: [
                        _StatusRowData(
                          label: '采集',
                          value: '完成 I0、I1 与 ROI',
                        ),
                        _StatusRowData(
                          label: '计算',
                          value: '生成真实预测结果',
                        ),
                        _StatusRowData(
                          label: '沉淀',
                          value: '进入历史或报告页复核',
                        ),
                      ],
                    ),
                  ];

                  if (!wide) {
                    return Column(
                      children: [
                        children[0],
                        const SizedBox(height: 12),
                        children[1],
                      ],
                    );
                  }

                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(child: children[0]),
                      const SizedBox(width: 12),
                      Expanded(child: children[1]),
                    ],
                  );
                },
              ),
              const SizedBox(height: 18),
              const _SectionTitle(title: '常用入口'),
              const SizedBox(height: 10),
              _EntryGrid(
                items: [
                  _EntryItem(
                    title: '开始采集',
                    icon: Icons.photo_camera_back_outlined,
                    onTap: () => Navigator.of(context).pushNamed(AppRouter.capture),
                  ),
                  _EntryItem(
                    title: '结果详情',
                    icon: Icons.show_chart_outlined,
                    onTap: () => Navigator.of(context).pushNamed(AppRouter.result),
                  ),
                  _EntryItem(
                    title: '历史记录',
                    icon: Icons.history,
                    onTap: () => Navigator.of(context).pushNamed(AppRouter.history),
                  ),
                  _EntryItem(
                    title: '报告预览',
                    icon: Icons.article_outlined,
                    onTap: () => Navigator.of(context).pushNamed(AppRouter.report),
                  ),
                ],
              ),
            ],
          ),
        );

        if (embedInShell) {
          return content;
        }

        return Scaffold(body: content);
      },
    );
  }
}

class _HomeHeader extends StatelessWidget {
  const _HomeHeader({
    required this.hardwareProfileLabel,
    required this.activeModelId,
  });

  final String hardwareProfileLabel;
  final String? activeModelId;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'FreshSalt Surface',
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w800,
            letterSpacing: -0.4,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          '围绕真实采集、结果判断与后续复核组织主流程。',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _TagChip(label: hardwareProfileLabel),
            _TagChip(label: activeModelId ?? '未启用模型'),
          ],
        ),
      ],
    );
  }
}

class _PrimaryWorkbenchCard extends StatelessWidget {
  const _PrimaryWorkbenchCard({
    required this.hasRealResult,
    required this.latestValue,
    required this.onStartCapture,
    required this.onOpenResult,
  });

  final bool hasRealResult;
  final double? latestValue;
  final VoidCallback onStartCapture;
  final VoidCallback? onOpenResult;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: const LinearGradient(
          colors: [Color(0xFFF2F7F5), Color(0xFFFFFFFF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionTitle(title: '主工作区'),
          const SizedBox(height: 8),
          Text(
            hasRealResult
                ? '最近一条真实结果已生成，可继续复核或进入报告。'
                : '当前还没有真实结果，先进入采集流程。',
            style: theme.textTheme.bodyLarge,
          ),
          const SizedBox(height: 18),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.88),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                Expanded(
                  child: _MetricBlock(
                    label: '最近结果',
                    value: latestValue == null
                        ? '暂无'
                        : '${latestValue!.toStringAsFixed(3)} mg/cm2',
                  ),
                ),
                Expanded(
                  child: _MetricBlock(
                    label: '数据状态',
                    value: hasRealResult ? '真实记录' : '等待采集',
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: onStartCapture,
              child: const Text('进入采集流程'),
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: onOpenResult,
              child: const Text('查看结果页'),
            ),
          ),
        ],
      ),
    );
  }
}

class _MetricBlock extends StatelessWidget {
  const _MetricBlock({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusCard extends StatelessWidget {
  const _StatusCard({
    required this.title,
    required this.rows,
  });

  final String title;
  final List<_StatusRowData> rows;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _SectionTitle(title: title),
            const SizedBox(height: 12),
            ...rows.map(
              (row) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: 56,
                      child: Text(
                        row.label,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ),
                    Expanded(child: Text(row.value)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EntryGrid extends StatelessWidget {
  const _EntryGrid({
    required this.items,
  });

  final List<_EntryItem> items;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: items.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisExtent: 84,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemBuilder: (context, index) {
        final item = items[index];
        return Material(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
          child: InkWell(
            borderRadius: BorderRadius.circular(22),
            onTap: item.onTap,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              child: Row(
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE9F4F1),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(
                      item.icon,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      item.title,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _TagChip extends StatelessWidget {
  const _TagChip({
    required this.label,
  });

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFE9F4F1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelLarge?.copyWith(
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({
    required this.title,
  });

  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleLarge?.copyWith(
        fontWeight: FontWeight.w800,
      ),
    );
  }
}

class _StatusRowData {
  const _StatusRowData({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;
}

class _EntryItem {
  const _EntryItem({
    required this.title,
    required this.icon,
    required this.onTap,
  });

  final String title;
  final IconData icon;
  final VoidCallback onTap;
}
