import 'package:flutter/material.dart';

import '../../core/demo/demo_app_scope_provider.dart';
import '../../core/models/prediction_result.dart';
import '../../routing/app_router.dart';
import '../../shared/widgets/platform_module_shell.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({
    super.key,
    this.embedInShell = false,
  });

  final bool embedInShell;

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  bool _showSimulatedOnly = true;
  String? _selectedModelId;

  @override
  Widget build(BuildContext context) {
    final scope = DemoAppScopeProvider.of(context);

    return FutureBuilder<List<Map<String, dynamic>>>(
      future: scope.sessionRepository.getAllSessions(
        isSimulated: _showSimulatedOnly ? true : null,
        modelId: _selectedModelId,
      ),
      builder: (context, snapshot) {
        final sessions = snapshot.data ?? const <Map<String, dynamic>>[];
        final allModelIds = sessions
            .map(
              (session) =>
                  ((session['result'] as Map?)?['model_id'] as String?) ?? '',
            )
            .where((item) => item.isNotEmpty)
            .toSet()
            .toList()
          ..sort();

        final latestSampleId = sessions.isEmpty
            ? '暂无记录'
            : sessions.first['sample_id'] as String? ?? '未知样品';

        final shell = PlatformModuleShell(
          appBarTitle: '历史记录',
          title: '历史记录与结果回看',
          subtitle:
              '在这里回看已保存结果，快速进入结果、分析与报告链路。',
          tags: const ['模拟数据', '结果仓', '平台模块'],
          summaryItems: [
            PlatformSummaryItem(
              label: '记录数',
              value: '${sessions.length} 条',
              note: '当前可回看的记录数量。',
            ),
            PlatformSummaryItem(
              label: '筛选',
              value: _showSimulatedOnly ? '模拟数据' : '全部记录',
              note: _selectedModelId ?? '未限定模型',
            ),
            PlatformSummaryItem(
              label: '最近样品',
              value: latestSampleId,
              note: '可直接跳转到结果与报告。',
            ),
          ],
          children: [
            PlatformSectionCard(
              title: '筛选与模块动作',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _FilterBar(
                    showSimulatedOnly: _showSimulatedOnly,
                    selectedModelId: _selectedModelId,
                    availableModelIds: allModelIds,
                    onChanged: (value) {
                      setState(() {
                        _showSimulatedOnly = value;
                      });
                    },
                    onModelChanged: (value) {
                      setState(() {
                        _selectedModelId = value;
                      });
                    },
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: [
                      FilledButton.icon(
                        onPressed: sessions.isEmpty
                            ? null
                            : () => Navigator.of(context).pushNamed(
                                  AppRouter.result,
                                  arguments: sessions.first['session_id'] as String?,
                                ),
                        icon: const Icon(Icons.open_in_new),
                        label: const Text('打开最近结果'),
                      ),
                      OutlinedButton.icon(
                        onPressed: () =>
                            Navigator.of(context).pushNamed(AppRouter.analysis),
                        icon: const Icon(Icons.insights_outlined),
                        label: const Text('分析总览'),
                      ),
                      OutlinedButton.icon(
                        onPressed: () =>
                            Navigator.of(context).pushNamed(AppRouter.report),
                        icon: const Icon(Icons.article_outlined),
                        label: const Text('报告页'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            PlatformSectionCard(
              title: '记录概览',
              child: Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  _MetricCard(
                    title: '记录总数',
                    value: '${sessions.length}',
                    note: '当前筛选结果',
                  ),
                  _MetricCard(
                    title: '当前筛选',
                    value: _showSimulatedOnly ? '模拟数据' : '全部',
                    note: _selectedModelId ?? '未限定模型',
                  ),
                  _MetricCard(
                    title: '状态',
                    value: sessions.isEmpty ? '待生成' : '可回看',
                    note: '支持结果详情、分析与报告联动',
                  ),
                ],
              ),
            ),
            PlatformSectionCard(
              title: '记录列表',
              child: sessions.isEmpty
                  ? const Text('尚无可展示记录，请先完成一次模拟预测并保存。')
                  : Column(
                      children: sessions.map((session) {
                        final result = PredictionResult.fromJson(
                          Map<String, dynamic>.from(
                            session['result'] as Map? ?? const {},
                          ),
                        );
                        final span = result.validRangeMax - result.validRangeMin;
                        final progress = span <= 0
                            ? 0.0
                            : ((result.predictedValue - result.validRangeMin) / span)
                                .clamp(0.0, 1.0);

                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: _HistoryRecordCard(
                            session: session,
                            result: result,
                            progress: progress,
                            onDelete: () => _confirmDelete(
                              context,
                              session['session_id'] as String,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
            ),
          ],
        );

        if (widget.embedInShell) {
          return SafeArea(child: shell.bodyContent(context));
        }

        return shell;
      },
    );
  }

  Future<void> _confirmDelete(BuildContext context, String sessionId) async {
    final scope = DemoAppScopeProvider.of(context);

    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('删除模拟记录'),
          content: const Text('是否删除当前模拟记录？此操作只影响本地演示数据。'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('取消'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('删除'),
            ),
          ],
        );
      },
    );

    if (shouldDelete != true) {
      return;
    }

    await scope.sessionRepository.deleteSession(sessionId);
    if (!mounted) {
      return;
    }
    setState(() {});
  }
}

class _HistoryRecordCard extends StatelessWidget {
  const _HistoryRecordCard({
    required this.session,
    required this.result,
    required this.progress,
    required this.onDelete,
  });

  final Map<String, dynamic> session;
  final PredictionResult result;
  final double progress;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
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
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        const Chip(label: Text('模拟数据')),
                        Chip(label: Text(result.resultStatus)),
                        Chip(label: Text(result.confidenceLevel)),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      session['sample_id'] as String? ?? '未知样品',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '${result.predictedValue.toStringAsFixed(4)} ${result.unit}',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              IconButton(
                icon: const Icon(Icons.delete_outline),
                onPressed: onDelete,
              ),
            ],
          ),
          const SizedBox(height: 12),
          LinearProgressIndicator(value: progress, minHeight: 8),
          const SizedBox(height: 12),
          Wrap(
            spacing: 16,
            runSpacing: 8,
            children: [
              _InlineInfo(label: '模型', value: result.modelId),
              _InlineInfo(label: '硬件', value: result.hardwareProfileId),
              _InlineInfo(label: '来源', value: result.sourceMode),
            ],
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              FilledButton(
                onPressed: () => Navigator.of(context).pushNamed(
                  AppRouter.result,
                  arguments: session['session_id'] as String?,
                ),
                child: const Text('查看结果详情'),
              ),
              OutlinedButton(
                onPressed: () => Navigator.of(context).pushNamed(AppRouter.report),
                child: const Text('进入报告页'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _FilterBar extends StatelessWidget {
  const _FilterBar({
    required this.showSimulatedOnly,
    required this.selectedModelId,
    required this.availableModelIds,
    required this.onChanged,
    required this.onModelChanged,
  });

  final bool showSimulatedOnly;
  final String? selectedModelId;
  final List<String> availableModelIds;
  final ValueChanged<bool> onChanged;
  final ValueChanged<String?> onModelChanged;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        FilterChip(
          label: const Text('仅看模拟数据'),
          selected: showSimulatedOnly,
          onSelected: onChanged,
        ),
        if (availableModelIds.isNotEmpty)
          ChoiceChip(
            label: Text(selectedModelId ?? availableModelIds.first),
            selected: selectedModelId != null,
            onSelected: (_) {
              onModelChanged(
                selectedModelId == null ? availableModelIds.first : null,
              );
            },
          ),
      ],
    );
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({
    required this.title,
    required this.value,
    required this.note,
  });

  final String title;
  final String value;
  final String note;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 190,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: Theme.of(context).textTheme.bodySmall),
              const SizedBox(height: 8),
              Text(
                value,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
              ),
              const SizedBox(height: 8),
              Text(note, style: Theme.of(context).textTheme.bodySmall),
            ],
          ),
        ),
      ),
    );
  }
}

class _InlineInfo extends StatelessWidget {
  const _InlineInfo({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
