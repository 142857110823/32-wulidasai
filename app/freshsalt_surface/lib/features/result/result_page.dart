import 'package:flutter/material.dart';

import '../../core/demo/demo_app_scope_provider.dart';
import '../../core/models/model_bundle.dart';
import '../../core/models/prediction_result.dart';
import '../../routing/app_router.dart';

class ResultPage extends StatelessWidget {
  const ResultPage({
    super.key,
    this.sessionId,
    this.embedInShell = false,
  });

  final String? sessionId;
  final bool embedInShell;

  @override
  Widget build(BuildContext context) {
    final scope = DemoAppScopeProvider.of(context);

    return FutureBuilder<Map<String, dynamic>?>(
      future: _loadSession(scope),
      builder: (context, snapshot) {
        final session = snapshot.data;
        final theme = Theme.of(context);

        final body = SafeArea(
          child: session == null
              ? ListView(
                  padding: const EdgeInsets.all(20),
                  children: [
                    if (embedInShell) ...[
                      Text('结果详情', style: theme.textTheme.headlineMedium),
                      const SizedBox(height: 12),
                    ],
                    const Card(
                      child: Padding(
                        padding: EdgeInsets.all(16),
                        child: Text('暂无可展示结果，请先完成一次模拟预测并保存到历史。'),
                      ),
                    ),
                  ],
                )
              : _ResultDetailContent(
                  session: session,
                  allSessionsFuture:
                      scope.sessionRepository.getAllSessions(isSimulated: true),
                  modelBundle: scope.modelBundleService.activeModel,
                ),
        );

        if (embedInShell) {
          return body;
        }

        return Scaffold(
          appBar: AppBar(title: const Text('结果详情')),
          body: body,
        );
      },
    );
  }

  Future<Map<String, dynamic>?> _loadSession(dynamic scope) async {
    if (sessionId != null) {
      return scope.sessionRepository.getSession(sessionId!);
    }
    final sessions =
        await scope.sessionRepository.getAllSessions(isSimulated: true);
    if (sessions.isEmpty) {
      return _buildDemoResultSession(scope);
    }
    return sessions.first;
  }

  Map<String, dynamic> _buildDemoResultSession(dynamic scope) {
    final activeModel = scope.modelBundleService.activeModel;
    final modelId = activeModel?.modelId ?? 'freshsalt_rgb_cucumber_darkbox_v1';
    final validRange = activeModel?.validRange ?? const [0.0, 0.75];

    return {
      'session_id': 'demo-result-shell',
      'baseline_image_path': '/mock/mock_baseline.png',
      'salted_image_path': '/mock/mock_salted.png',
      'roi_polygon': {
        'area': 4.0,
        'center_x': 126,
        'center_y': 148,
      },
      'result': {
        'session_id': 'demo-result-shell',
        'sample_id': 'DEMO-CUCUMBER-01',
        'model_id': modelId,
        'predicted_mg_cm2': 0.35,
        'unit': 'mg/cm2 NaCl eq.',
        'source_mode': 'simulated',
        'result_status': 'valid',
        'confidence_level': 'medium',
        'valid_range_min': validRange.first,
        'valid_range_max': validRange.last,
        'feature_vector': {
          'dL': 0.31,
          'da': -0.04,
          'db': 0.06,
          'dS': -0.12,
          'whiteness_index': 0.42,
          'specular_ratio': 0.28,
          'glcm_contrast': 0.18,
          'glcm_energy': 0.63,
        },
        'hardware_profile_id': scope.hardwareProfileLabel,
        'warnings': const [
          '当前为演示结果骨架，用于结果页 UI 验收，不代表真实实验输出。',
          '接近中负载演示区间，请结合后续真实图像与模型验证。',
        ],
        'created_at': DateTime.now().toIso8601String(),
      },
    };
  }
}

class _ResultDetailContent extends StatelessWidget {
  const _ResultDetailContent({
    required this.session,
    required this.allSessionsFuture,
    required this.modelBundle,
  });

  final Map<String, dynamic> session;
  final Future<List<Map<String, dynamic>>> allSessionsFuture;
  final ModelBundle? modelBundle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final result = PredictionResult.fromJson(
      Map<String, dynamic>.from(session['result'] as Map? ?? const {}),
    );
    final roi = Map<String, dynamic>.from(
      session['roi_polygon'] as Map? ?? const {},
    );

    return FutureBuilder<List<Map<String, dynamic>>>(
      future: allSessionsFuture,
      builder: (context, snapshot) {
        final sessions = snapshot.data ?? const <Map<String, dynamic>>[];
        final contributions = _buildContributions(result, modelBundle);
        final rangeSpan = result.validRangeMax - result.validRangeMin;
        final progress = rangeSpan <= 0
            ? 0.0
            : ((result.predictedValue - result.validRangeMin) / rangeSpan)
                .clamp(0.0, 1.0);

        return ListView(
          padding: const EdgeInsets.all(20),
          children: [
            _ResultHero(
              result: result,
              onOpenHistory: () =>
                  Navigator.of(context).pushNamed(AppRouter.history),
              onOpenReport: () =>
                  Navigator.of(context).pushNamed(AppRouter.report),
            ),
            const SizedBox(height: 20),
            LayoutBuilder(
              builder: (context, constraints) {
                final wide = constraints.maxWidth >= 980;
                final left = Column(
                  children: [
                    _ResultSection(
                      title: '主结果卡片',
                      child: _PrimaryResultBlock(result: result),
                    ),
                    const SizedBox(height: 12),
                    _ResultSection(
                      title: '模型输入摘要',
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _InfoRow(label: '样品 ID', value: result.sampleId),
                          _InfoRow(label: '模型版本', value: result.modelId),
                          _InfoRow(label: '数据来源', value: result.sourceMode),
                          _InfoRow(
                            label: '硬件配置',
                            value: result.hardwareProfileId,
                          ),
                          _InfoRow(
                            label: 'ROI 面积',
                            value:
                                '${((roi['area'] as num?) ?? 4.0).toStringAsFixed(2)} cm2',
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    _ResultSection(
                      title: '图像证据',
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _InfoRow(
                            label: '基线图 I0',
                            value:
                                session['baseline_image_path'] as String? ?? '--',
                          ),
                          _InfoRow(
                            label: '待测图 I1',
                            value: session['salted_image_path'] as String? ?? '--',
                          ),
                          _InfoRow(
                            label: 'ROI 中心',
                            value:
                                '${roi['center_x'] ?? '--'}, ${roi['center_y'] ?? '--'}',
                          ),
                        ],
                      ),
                    ),
                  ],
                );

                final right = Column(
                  children: [
                    _ResultSection(
                      title: '范围标尺',
                      child: _RangeScaleBlock(
                        result: result,
                        progress: progress,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _ResultSection(
                      title: '历史趋势',
                      child: _HistoryTrendBlock(
                        currentResult: result,
                        sessions: sessions,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _ResultSection(
                      title: '模型解释',
                      child: contributions.isEmpty
                          ? const Text('当前缺少模型系数，无法生成解释。')
                          : Column(
                              children: contributions.map((item) {
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 12),
                                  child: Row(
                                    children: [
                                      SizedBox(
                                        width: 140,
                                        child: Text(item.$1),
                                      ),
                                      Expanded(
                                        child: LinearProgressIndicator(
                                          value:
                                              (item.$2.abs() / 3).clamp(0.0, 1.0),
                                          minHeight: 8,
                                          color: item.$2 >= 0
                                              ? theme.colorScheme.primary
                                              : theme.colorScheme.tertiary,
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Text(item.$2.toStringAsFixed(3)),
                                    ],
                                  ),
                                );
                              }).toList(),
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
            const SizedBox(height: 12),
            _ResultSection(
              title: '风险说明',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '本结果仅用于大学物理实验与方法验证，不作为食品安全、商品分级或执法检测依据。',
                  ),
                  if (result.warnings.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    ...result.warnings.map((warning) => Text('• $warning')),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 12),
            _ResultSection(
              title: '后续动作',
              child: Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  OutlinedButton.icon(
                    onPressed: () =>
                        Navigator.of(context).pushNamed(AppRouter.history),
                    icon: const Icon(Icons.history),
                    label: const Text('查看历史记录'),
                  ),
                  OutlinedButton.icon(
                    onPressed: () =>
                        Navigator.of(context).pushNamed(AppRouter.analysis),
                    icon: const Icon(Icons.insights_outlined),
                    label: const Text('查看分析总览'),
                  ),
                  OutlinedButton.icon(
                    onPressed: () =>
                        Navigator.of(context).pushNamed(AppRouter.report),
                    icon: const Icon(Icons.article_outlined),
                    label: const Text('生成报告预览'),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  List<(String, double)> _buildContributions(
    PredictionResult result,
    ModelBundle? bundle,
  ) {
    if (bundle == null) {
      return const [];
    }

    final contributions = <(String, double)>[];
    for (var index = 0; index < bundle.featureOrder.length; index++) {
      final featureName = bundle.featureOrder[index];
      final featureValue =
          (result.featureVector[featureName] as num? ?? 0).toDouble();
      contributions.add((featureName, featureValue * bundle.coefficients[index]));
    }
    contributions.sort((a, b) => b.$2.abs().compareTo(a.$2.abs()));
    return contributions.take(4).toList();
  }
}

class _HistoryTrendBlock extends StatelessWidget {
  const _HistoryTrendBlock({
    required this.currentResult,
    required this.sessions,
  });

  final PredictionResult currentResult;
  final List<Map<String, dynamic>> sessions;

  @override
  Widget build(BuildContext context) {
    final trendResults = sessions
        .take(4)
        .map(
          (item) => PredictionResult.fromJson(
            Map<String, dynamic>.from(item['result'] as Map? ?? const {}),
          ),
        )
        .toList()
        .reversed
        .toList();

    if (trendResults.isEmpty) {
      trendResults.add(currentResult);
    } else if (trendResults.length < 5) {
      trendResults.add(currentResult);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: 132,
          child: CustomPaint(
            painter: _TrendLinePainter(
              values: trendResults
                  .map((item) => item.predictedValue)
                  .toList(growable: false),
              color: Theme.of(context).colorScheme.primary,
            ),
            child: const SizedBox.expand(),
          ),
        ),
        const SizedBox(height: 14),
        ...trendResults.asMap().entries.map((entry) {
          final index = entry.key;
          final item = entry.value;
          final span = item.validRangeMax - item.validRangeMin;
          final progress = span <= 0
              ? 0.0
              : ((item.predictedValue - item.validRangeMin) / span)
                  .clamp(0.0, 1.0);

          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              children: [
                SizedBox(
                  width: 84,
                  child: Text(
                    index == trendResults.length - 1 ? '当前结果' : '历史 ${index + 1}',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                ),
                Expanded(
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 8,
                    backgroundColor:
                        Theme.of(context).colorScheme.surfaceContainerHighest,
                  ),
                ),
                const SizedBox(width: 12),
                SizedBox(
                  width: 68,
                  child: Text(
                    item.predictedValue.toStringAsFixed(3),
                    textAlign: TextAlign.right,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }
}

class _ResultHero extends StatelessWidget {
  const _ResultHero({
    required this.result,
    required this.onOpenHistory,
    required this.onOpenReport,
  });

  final PredictionResult result;
  final VoidCallback onOpenHistory;
  final VoidCallback onOpenReport;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: const LinearGradient(
          colors: [Color(0xFFE0F0EC), Color(0xFFF8FBFA)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      padding: const EdgeInsets.all(24),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final wide = constraints.maxWidth >= 900;
          final summary = Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '结果详情',
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                '模拟数据 | 本页仅用于大学物理实验与方法验证，不作为食品安全、商品分级或执法检测依据。',
                style: theme.textTheme.bodyLarge?.copyWith(height: 1.45),
              ),
              const SizedBox(height: 14),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  const Chip(label: Text('模拟数据')),
                  Chip(label: Text('状态 ${result.resultStatus}')),
                  Chip(label: Text('置信 ${result.confidenceLevel}')),
                  Chip(label: Text('模型 ${result.modelId}')),
                ],
              ),
            ],
          );

          final actions = Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              FilledButton.icon(
                onPressed: onOpenHistory,
                icon: const Icon(Icons.history),
                label: const Text('进入历史模块'),
              ),
              OutlinedButton.icon(
                onPressed: onOpenReport,
                icon: const Icon(Icons.article_outlined),
                label: const Text('报告页'),
              ),
            ],
          );

          if (!wide) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                summary,
                const SizedBox(height: 16),
                actions,
              ],
            );
          }

          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(flex: 7, child: summary),
              const SizedBox(width: 20),
              Expanded(flex: 3, child: Align(alignment: Alignment.topRight, child: actions)),
            ],
          );
        },
      ),
    );
  }
}

class _PrimaryResultBlock extends StatelessWidget {
  const _PrimaryResultBlock({
    required this.result,
  });

  final PredictionResult result;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          result.predictedValue.toStringAsFixed(4),
          style: theme.textTheme.displaySmall?.copyWith(
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 6),
        Text(result.unit, style: theme.textTheme.titleMedium),
        const SizedBox(height: 16),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            _InlineMetric(
              label: '结果状态',
              value: result.resultStatus,
            ),
            _InlineMetric(
              label: '置信等级',
              value: result.confidenceLevel,
            ),
            _InlineMetric(
              label: '数据来源',
              value: result.sourceMode,
            ),
          ],
        ),
      ],
    );
  }
}

class _RangeScaleBlock extends StatelessWidget {
  const _RangeScaleBlock({
    required this.result,
    required this.progress,
  });

  final PredictionResult result;
  final double progress;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        LinearProgressIndicator(value: progress, minHeight: 10),
        const SizedBox(height: 12),
        Text(
          '有效范围 ${result.validRangeMin.toStringAsFixed(2)} - ${result.validRangeMax.toStringAsFixed(2)} ${result.unit}',
        ),
        const SizedBox(height: 4),
        Text(
          '当前结果 ${result.predictedValue.toStringAsFixed(4)} ${result.unit}',
        ),
      ],
    );
  }
}

class _InlineMetric extends StatelessWidget {
  const _InlineMetric({
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
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: theme.textTheme.bodySmall),
          const SizedBox(height: 6),
          Text(
            value,
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _ResultSection extends StatelessWidget {
  const _ResultSection({
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

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 96,
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}

class _TrendLinePainter extends CustomPainter {
  const _TrendLinePainter({
    required this.values,
    required this.color,
  });

  final List<double> values;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    if (values.isEmpty) {
      return;
    }

    final maxValue = values.reduce((a, b) => a > b ? a : b);
    final minValue = values.reduce((a, b) => a < b ? a : b);
    final span = (maxValue - minValue).abs() < 0.001 ? 0.001 : maxValue - minValue;

    final points = <Offset>[];
    for (var i = 0; i < values.length; i++) {
      final x = values.length == 1 ? 0.0 : size.width * i / (values.length - 1);
      final y = size.height - ((values[i] - minValue) / span * (size.height - 12)) - 6;
      points.add(Offset(x, y));
    }

    final fillPath = Path()..moveTo(points.first.dx, size.height);
    for (final point in points) {
      fillPath.lineTo(point.dx, point.dy);
    }
    fillPath
      ..lineTo(points.last.dx, size.height)
      ..close();

    final strokePath = Path()..moveTo(points.first.dx, points.first.dy);
    for (var i = 1; i < points.length; i++) {
      strokePath.lineTo(points[i].dx, points[i].dy);
    }

    final fillPaint = Paint()
      ..color = color.withOpacity(0.12)
      ..style = PaintingStyle.fill;
    final strokePaint = Paint()
      ..color = color
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    canvas.drawPath(fillPath, fillPaint);
    canvas.drawPath(strokePath, strokePaint);

    for (final point in points) {
      canvas.drawCircle(point, 3.2, Paint()..color = color);
    }
  }

  @override
  bool shouldRepaint(covariant _TrendLinePainter oldDelegate) {
    return oldDelegate.values != values || oldDelegate.color != color;
  }
}

