import 'package:flutter/material.dart';

import '../../core/demo/demo_app_scope_provider.dart';
import '../../core/models/prediction_result.dart';
import '../../routing/app_router.dart';
import '../../shared/widgets/platform_module_shell.dart';

class ReportPage extends StatelessWidget {
  const ReportPage({
    super.key,
    this.embedInShell = false,
  });

  final bool embedInShell;

  @override
  Widget build(BuildContext context) {
    final scope = DemoAppScopeProvider.of(context);
    final theme = Theme.of(context);

    return FutureBuilder<List<Map<String, dynamic>>>(
      future: scope.sessionRepository.getAllSessions(isSimulated: true),
      builder: (context, snapshot) {
        final sessions = snapshot.data ?? const <Map<String, dynamic>>[];
        final latestSession = sessions.isEmpty ? null : sessions.first;
        final latestResult = latestSession == null
            ? null
            : PredictionResult.fromJson(
                Map<String, dynamic>.from(
                  latestSession['result'] as Map? ?? const {},
                ),
              );

        final shell = PlatformModuleShell(
          appBarTitle: '报告页面',
          title: '报告整理与导出预览',
          subtitle: '集中核对导出内容、图像路径和结果摘要，避免报告页首屏堆叠过多说明。',
          tags: const ['模拟数据', '导出预览', '材料整理'],
          summaryItems: [
            PlatformSummaryItem(
              label: '记录数',
              value: '${sessions.length} 条',
              note: '当前可用于生成导出预览的记录总数。',
            ),
            PlatformSummaryItem(
              label: '最近结果',
              value: latestResult == null
                  ? '暂无记录'
                  : latestResult.predictedValue.toStringAsFixed(2),
              note: latestResult == null ? '需先完成一次采集。' : latestResult.unit,
            ),
            PlatformSummaryItem(
              label: '导出状态',
              value: sessions.isEmpty ? '待生成' : '可预览',
              note: '支持 CSV 文本与报告摘要查看。',
            ),
          ],
          children: sessions.isEmpty
              ? [
                  PlatformSectionCard(
                    title: '主操作',
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('请先完成一次导入或采集，再返回此处查看报告摘要和导出内容。'),
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 10,
                          runSpacing: 10,
                          children: [
                            FilledButton.icon(
                              onPressed: () => Navigator.of(context)
                                  .pushNamed(AppRouter.capture),
                              icon: const Icon(Icons.add_a_photo_outlined),
                              label: const Text('进入采集'),
                            ),
                            OutlinedButton.icon(
                              onPressed: () => Navigator.of(context)
                                  .pushNamed(AppRouter.history),
                              icon: const Icon(Icons.history),
                              label: const Text('查看历史'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ]
              : [
                  PlatformSectionCard(
                    title: '主操作',
                    child: Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: [
                        FilledButton.icon(
                          onPressed: () =>
                              Navigator.of(context).pushNamed(AppRouter.history),
                          icon: const Icon(Icons.history),
                          label: const Text('回到历史记录'),
                        ),
                        OutlinedButton.icon(
                          onPressed: () =>
                              Navigator.of(context).pushNamed(AppRouter.result),
                          icon: const Icon(Icons.stacked_line_chart_outlined),
                          label: const Text('查看结果详情'),
                        ),
                      ],
                    ),
                  ),
                  const PlatformSectionCard(
                    title: '导出检查',
                    child: Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        Chip(label: Text('保留数据来源标记')),
                        Chip(label: Text('CSV 包含 source_mode')),
                        Chip(label: Text('报告包含 ROI 与结果摘要')),
                      ],
                    ),
                  ),
                  PlatformSectionCard(
                    title: 'CSV 导出内容',
                    child: SelectableText(
                      scope.exportService.generateCsv(sessions: sessions),
                      style: theme.textTheme.bodySmall,
                    ),
                  ),
                  PlatformSectionCard(
                    title: '报告预览列表',
                    child: Column(
                      children: sessions.map((session) {
                        final result = PredictionResult.fromJson(
                          Map<String, dynamic>.from(
                            session['result'] as Map? ?? const {},
                          ),
                        );
                        final roiArea =
                            ((session['roi_polygon'] as Map?)?['area'] as num? ??
                                    4.0)
                                .toDouble();
                        final preview = scope.exportService.generateReportPreview(
                          sampleId: session['sample_id'] as String? ?? 'unknown',
                          result: result,
                          roiAreaCm2: roiArea,
                          baselineImagePath:
                              session['baseline_image_path'] as String? ?? '',
                          saltedImagePath:
                              session['salted_image_path'] as String? ?? '',
                        );
                        final featureVector = Map<String, dynamic>.from(
                          (session['feature_vector'] as Map?)?['features'] as Map? ??
                              const <String, dynamic>{},
                        );

                        return Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          child: ExpansionTile(
                            tilePadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 4,
                            ),
                            title: Text(
                              session['sample_id'] as String? ?? '未命名样品',
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            subtitle: Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: [
                                  const Chip(label: Text('模拟数据')),
                                  Chip(label: Text(result.modelId)),
                                  Chip(label: Text(result.confidenceLevel)),
                                ],
                              ),
                            ),
                            childrenPadding:
                                const EdgeInsets.fromLTRB(16, 0, 16, 16),
                            children: [
                              _ReportSection(
                                title: '结果摘要',
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '预测值 ${result.predictedValue.toStringAsFixed(2)} ${result.unit}',
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      '有效范围 ${result.validRangeMin.toStringAsFixed(2)} - ${result.validRangeMax.toStringAsFixed(2)} ${result.unit}',
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 12),
                              _ReportSection(
                                title: '图像与 ROI',
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'I0: ${session['baseline_image_path'] as String? ?? '--'}',
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      'I1: ${session['salted_image_path'] as String? ?? '--'}',
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      'ROI 面积: ${roiArea.toStringAsFixed(2)} cm2',
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 12),
                              _ReportSection(
                                title: '特征输入',
                                child: SelectableText(
                                  featureVector.entries
                                      .map((entry) => '${entry.key}: ${entry.value}')
                                      .join('\n'),
                                  style: theme.textTheme.bodySmall,
                                ),
                              ),
                              const SizedBox(height: 12),
                              _ReportSection(
                                title: '文本预览',
                                child: SelectableText(
                                  preview,
                                  style: theme.textTheme.bodySmall,
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  const PlatformSectionCard(
                    title: '使用边界',
                    child: Text(
                      '本页面用于整理图像分析结果与导出材料，不提供执法、医疗或食品安全性质结论。',
                    ),
                  ),
                ],
        );

        if (embedInShell) {
          return SafeArea(child: shell.bodyContent(context));
        }

        return shell;
      },
    );
  }
}

class _ReportSection extends StatelessWidget {
  const _ReportSection({
    required this.title,
    required this.child,
  });

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w700,
              ),
        ),
        const SizedBox(height: 8),
        child,
      ],
    );
  }
}
