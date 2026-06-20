import 'package:flutter/material.dart';

import '../../core/demo/demo_app_scope_provider.dart';
import '../../core/models/prediction_result.dart';
import '../../routing/app_router.dart';

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
        final body = SafeArea(
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              if (embedInShell) ...[
                Text('报告页', style: theme.textTheme.headlineMedium),
                const SizedBox(height: 12),
              ],
              _ReportHero(recordCount: sessions.length),
              const SizedBox(height: 20),
              if (sessions.isEmpty)
                _SectionCard(
                  title: '尚无可导出记录',
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('请先完成一次模拟预测并保存，然后在此页核对报告摘要、CSV 内容和边界说明。'),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        children: [
                          FilledButton.icon(
                            onPressed: () =>
                                Navigator.of(context).pushNamed(AppRouter.capture),
                            icon: const Icon(Icons.add_a_photo_outlined),
                            label: const Text('进入采集'),
                          ),
                          OutlinedButton.icon(
                            onPressed: () =>
                                Navigator.of(context).pushNamed(AppRouter.history),
                            icon: const Icon(Icons.history),
                            label: const Text('查看历史'),
                          ),
                        ],
                      ),
                    ],
                  ),
                )
              else ...[
                const _SectionHeader(
                  title: '导出准备',
                  subtitle: '报告页必须持续保留模拟数据、模型输入、图像证据和平台边界说明。',
                ),
                const SizedBox(height: 12),
                const _SectionCard(
                  title: '导出检查清单',
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      Chip(label: Text('模拟数据持续标记')),
                      Chip(label: Text('CSV 包含 source_mode')),
                      Chip(label: Text('报告包含 ROI / 特征 / 结果')),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                _SectionCard(
                  title: 'CSV 导出内容',
                  child: SelectableText(
                    scope.exportService.generateCsv(sessions: sessions),
                    style: theme.textTheme.bodySmall,
                  ),
                ),
                const SizedBox(height: 12),
                const _SectionCard(
                  title: '平台边界',
                  child: Text(
                    '本报告仅用于大学物理实验与方法验证，不作为食品安全、商品分级或执法检测依据。',
                  ),
                ),
                const SizedBox(height: 20),
                const _SectionHeader(
                  title: '报告预览列表',
                  subtitle: '每条记录都应具备图像、ROI、模型输入、结果摘要、风险说明和可截图预览。',
                ),
                const SizedBox(height: 12),
                ...sessions.map((session) {
                  final result = PredictionResult.fromJson(
                    Map<String, dynamic>.from(session['result'] as Map? ?? const {}),
                  );
                  final roiArea =
                      ((session['roi_polygon'] as Map?)?['area'] as num? ?? 4.0)
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
                    child: ExpansionTile(
                      tilePadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 4,
                      ),
                      title: Text(
                        session['sample_id'] as String? ?? '未知样品',
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
                      childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                      children: [
                        _ReportSection(
                          title: '结果摘要',
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '表面盐分估计: ${result.predictedValue.toStringAsFixed(2)} ${result.unit}',
                              ),
                              const SizedBox(height: 8),
                              Text(
                                '适用范围: ${result.validRangeMin.toStringAsFixed(2)} - ${result.validRangeMax.toStringAsFixed(2)} ${result.unit}',
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
                              Text('I0: ${session['baseline_image_path'] as String? ?? '--'}'),
                              const SizedBox(height: 6),
                              Text('I1: ${session['salted_image_path'] as String? ?? '--'}'),
                              const SizedBox(height: 6),
                              Text('ROI 面积: ${roiArea.toStringAsFixed(2)} cm2'),
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
                        const _ReportSection(
                          title: '风险说明',
                          child: Text(
                            '本结果仅用于大学物理实验与方法验证，不作为食品安全、商品分级或执法检测依据。',
                          ),
                        ),
                        const SizedBox(height: 12),
                        _ReportSection(
                          title: '模拟报告预览',
                          child: SelectableText(
                            preview,
                            style: theme.textTheme.bodySmall,
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ],
            ],
          ),
        );

        if (embedInShell) {
          return body;
        }

        return Scaffold(
          appBar: AppBar(title: const Text('报告页')),
          body: body,
        );
      },
    );
  }
}

class _ReportHero extends StatelessWidget {
  const _ReportHero({
    required this.recordCount,
  });

  final int recordCount;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: const LinearGradient(
          colors: [Color(0xFFDDEFEA), Color(0xFFF8FBFA)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '报告导出与答辩预览',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            '当前已准备 $recordCount 条模拟记录，可直接核对 CSV 内容、报告摘要和平台边界说明。',
            style: theme.textTheme.bodyMedium?.copyWith(
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.title,
    required this.subtitle,
  });

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 6),
        Text(
          subtitle,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
            height: 1.5,
          ),
        ),
      ],
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({
    required this.title,
    required this.child,
  });

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
            ),
            const SizedBox(height: 12),
            child,
          ],
        ),
      ),
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
