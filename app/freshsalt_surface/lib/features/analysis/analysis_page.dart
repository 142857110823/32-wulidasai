import 'package:flutter/material.dart';

import '../../core/demo/demo_app_scope_provider.dart';
import '../../core/models/prediction_result.dart';

class AnalysisPage extends StatelessWidget {
  const AnalysisPage({super.key});

  @override
  Widget build(BuildContext context) {
    final scope = DemoAppScopeProvider.of(context);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('分析总览')),
      body: SafeArea(
        child: FutureBuilder<List<Map<String, dynamic>>>(
          future: scope.sessionRepository.getAllSessions(isSimulated: true),
          builder: (context, snapshot) {
            final sessions = snapshot.data ?? const <Map<String, dynamic>>[];
            final results = sessions
                .map(
                  (item) => PredictionResult.fromJson(
                    Map<String, dynamic>.from(item['result'] as Map? ?? const {}),
                  ),
                )
                .toList();

            if (results.isEmpty) {
              return ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  Text('分析总览', style: theme.textTheme.headlineMedium),
                  const SizedBox(height: 12),
                  const Card(
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Text('尚无可分析的模拟记录，请先保存一条采集主链结果。'),
                    ),
                  ),
                ],
              );
            }

            final values = results.map((item) => item.predictedValue).toList();
            final average = values.reduce((a, b) => a + b) / values.length;
            final maxValue = values.reduce((a, b) => a > b ? a : b);
            final nearLimitCount =
                results.where((item) => item.warnings.isNotEmpty).length;

            return ListView(
              padding: const EdgeInsets.all(20),
              children: [
                _AnalysisHero(
                  average: average.toStringAsFixed(3),
                  count: results.length,
                  warningCount: nearLimitCount,
                ),
                const SizedBox(height: 20),
                const _SectionHeader(
                  title: '模拟平台状态',
                  subtitle: '分析页只汇总已保存的模拟记录、特征输入和平台状态，不输出食品安全或执法结论。',
                ),
                const SizedBox(height: 12),
                const Card(
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        Chip(label: Text('模拟数据')),
                        Chip(label: Text('演示模式')),
                        Chip(label: Text('主链结果已进入分析模块')),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    _MetricCard(
                      title: '记录数',
                      value: '${results.length}',
                      note: '已保存案例',
                    ),
                    _MetricCard(
                      title: '平均负载',
                      value: average.toStringAsFixed(3),
                      note: 'mg/cm2 NaCl eq.',
                    ),
                    _MetricCard(
                      title: '最高负载',
                      value: maxValue.toStringAsFixed(3),
                      note: '最近模拟上沿',
                    ),
                    _MetricCard(
                      title: '边界预警',
                      value: '$nearLimitCount',
                      note: '接近有效范围上限',
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                LayoutBuilder(
                  builder: (context, constraints) {
                    final wide = constraints.maxWidth >= 980;
                    final left = Column(
                      children: [
                        _SectionCard(
                          title: '最近案例',
                          child: Column(
                            children: sessions.take(3).map((session) {
                              final result = PredictionResult.fromJson(
                                Map<String, dynamic>.from(
                                  session['result'] as Map? ?? const {},
                                ),
                              );
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 14),
                                child: Row(
                                  children: [
                                    const Chip(label: Text('模拟数据')),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Text(
                                        session['sample_id'] as String? ?? '未知样品',
                                      ),
                                    ),
                                    Text(result.predictedValue.toStringAsFixed(3)),
                                  ],
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                        const SizedBox(height: 12),
                        _SectionCard(
                          title: '模型输入摘要',
                          child: Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              for (final key in const [
                                'dL',
                                'whiteness_index',
                                'specular_ratio',
                                'glcm_contrast',
                                'glcm_energy',
                              ])
                                Chip(
                                  label: Text(
                                    '$key 平均 ${_averageFeature(results, key).toStringAsFixed(3)}',
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ],
                    );

                    final right = Column(
                      children: [
                        _SectionCard(
                          title: '负载分布',
                          child: Column(
                            children: results.map((item) {
                              final span =
                                  item.validRangeMax - item.validRangeMin;
                              final progress = span <= 0
                                  ? 0.0
                                  : ((item.predictedValue - item.validRangeMin) /
                                          span)
                                      .clamp(0.0, 1.0);
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: Row(
                                  children: [
                                    Expanded(child: Text(item.sampleId)),
                                    Expanded(
                                      child: LinearProgressIndicator(
                                        value: progress,
                                        minHeight: 8,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Text(item.predictedValue.toStringAsFixed(3)),
                                  ],
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                        const SizedBox(height: 12),
                        const _SectionCard(
                          title: '平台解释',
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('分析总览用于答辩展示当前演示平台是否已经形成连续、可信的测量闭环。'),
                              SizedBox(height: 8),
                              Text('后续真实实验接入时，本页应复用同一结构，只替换数据来源与真实图像处理输出。'),
                            ],
                          ),
                        ),
                      ],
                    );

                    if (!wide) {
                      return Column(
                        children: [
                          left,
                          const SizedBox(height: 12),
                          right,
                        ],
                      );
                    }

                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(child: left),
                        const SizedBox(width: 12),
                        Expanded(child: right),
                      ],
                    );
                  },
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  double _averageFeature(List<PredictionResult> results, String key) {
    final values =
        results.map((item) => (item.featureVector[key] as num? ?? 0).toDouble());
    return values.reduce((a, b) => a + b) / values.length;
  }
}

class _AnalysisHero extends StatelessWidget {
  const _AnalysisHero({
    required this.average,
    required this.count,
    required this.warningCount,
  });

  final String average;
  final int count;
  final int warningCount;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: const LinearGradient(
          colors: [Color(0xFFE5F2EF), Color(0xFFF8FBFA)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      padding: const EdgeInsets.all(24),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final wide = constraints.maxWidth >= 900;
          final intro = Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '分析总览',
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                '该页用于汇总最近模拟结果、特征输入和平台状态，帮助判断当前演示平台是否形成连续、可信的测量闭环。',
                style: theme.textTheme.bodyLarge?.copyWith(height: 1.45),
              ),
            ],
          );

          final stats = Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              _HeroMetric(label: '记录数', value: '$count'),
              _HeroMetric(label: '平均负载', value: '$average mg/cm2'),
              _HeroMetric(label: '预警数', value: '$warningCount'),
            ],
          );

          if (!wide) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                intro,
                const SizedBox(height: 16),
                stats,
              ],
            );
          }

          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(flex: 7, child: intro),
              const SizedBox(width: 20),
              Expanded(flex: 5, child: Align(alignment: Alignment.topRight, child: stats)),
            ],
          );
        },
      ),
    );
  }
}

class _HeroMetric extends StatelessWidget {
  const _HeroMetric({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: 160,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.8),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: theme.textTheme.bodySmall),
          const SizedBox(height: 8),
          Text(
            value,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
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
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          subtitle,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
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
      width: 170,
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
