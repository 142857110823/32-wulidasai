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
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '暂无真实结果',
                              style: theme.textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            const SizedBox(height: 10),
                            const Text(
                              '请先完成一次真实图像采集、特征提取与结果计算。当前页面不再回退展示内置模拟结果。',
                            ),
                            const SizedBox(height: 16),
                            FilledButton(
                              onPressed: () =>
                                  Navigator.of(context).pushNamed(AppRouter.capture),
                              child: const Text('进入采集流程'),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                )
              : _ResultDetailContent(
                  session: session,
                  allSessionsFuture:
                      scope.sessionRepository.getAllSessions(isSimulated: false),
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
        await scope.sessionRepository.getAllSessions(isSimulated: false);
    if (sessions.isEmpty) {
      return null;
    }
    return sessions.first;
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
                      title: '结果概览',
                      child: _PrimaryResultBlock(result: result),
                    ),
                    const SizedBox(height: 12),
                    _ResultSection(
                      title: 'AI 判断',
                      child: _AiInsightBlock(
                        result: result,
                        modelBundle: modelBundle,
                        contributions: contributions,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _ResultSection(
                      title: '输入摘要',
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
                  ],
                );

                final right = Column(
                  children: [
                    _ResultSection(
                      title: '范围与趋势',
                      child: _RangeScaleBlock(
                        result: result,
                        progress: progress,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _ResultSection(
                      title: '关键特征',
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
                    const SizedBox(height: 12),
                    _ResultSection(
                      title: '图像与 ROI',
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
                          const SizedBox(height: 12),
                          _HistoryTrendBlock(
                            currentResult: result,
                            sessions: sessions,
                          ),
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
            const SizedBox(height: 12),
            _ResultSection(
              title: '使用边界',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '本结果用于图像分析流程验证与方法比对，不提供食品安全、医疗或执法性质结论。',
                  ),
                  if (result.warnings.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    ...result.warnings.map((warning) => Text('• $warning')),
                  ],
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
                '先看结果，再看 AI 判断与后续建议。',
                style: theme.textTheme.bodyLarge?.copyWith(height: 1.45),
              ),
              const SizedBox(height: 14),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  Chip(label: Text('状态 ${result.resultStatus}')),
                  Chip(label: Text('置信 ${result.confidenceLevel}')),
                  Chip(label: Text(result.modelId)),
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
                label: const Text('进入历史记录'),
              ),
              OutlinedButton.icon(
                onPressed: onOpenReport,
                icon: const Icon(Icons.article_outlined),
                label: const Text('查看报告页'),
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
              value: result.sourceMode == 'simulated' ? '模拟' : '真实',
            ),
          ],
        ),
      ],
    );
  }
}

class _AiInsightBlock extends StatelessWidget {
  const _AiInsightBlock({
    required this.result,
    required this.modelBundle,
    required this.contributions,
  });

  final PredictionResult result;
  final ModelBundle? modelBundle;
  final List<(String, double)> contributions;

  @override
  Widget build(BuildContext context) {
    final confidenceLabel = _confidenceLabel(result);
    final confidenceNote = _confidenceNote(result);
    final driverSummary = _driverSummary();
    final levelReason = _levelReason();
    final recommendation = _recommendation();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            _InlineMetric(label: '可信度', value: confidenceLabel),
            _InlineMetric(
              label: '建议动作',
              value: recommendation.$1,
            ),
          ],
        ),
        const SizedBox(height: 12),
        Text(confidenceNote),
        const SizedBox(height: 12),
        _AiBullet(
          title: '关键影响因子',
          body: driverSummary,
        ),
        const SizedBox(height: 8),
        _AiBullet(
          title: '本次结果为何偏高/偏低',
          body: levelReason,
        ),
        const SizedBox(height: 8),
        _AiBullet(
          title: '是否建议重拍或补采',
          body: recommendation.$2,
        ),
      ],
    );
  }

  String _confidenceLabel(PredictionResult result) {
    switch (result.confidenceLevel) {
      case 'high':
        return '高';
      case 'medium':
        return '中';
      case 'low':
      default:
        return '低';
    }
  }

  String _confidenceNote(PredictionResult result) {
    if (result.resultStatus == 'error') {
      return '当前结果存在流程异常，AI 不建议直接采用本次判断。';
    }
    if (result.isOutOfRange) {
      return '结果已超出模型有效范围，可信度被主动下调，需谨慎解读。';
    }
    if (result.approachingUpperLimit) {
      return '结果接近模型上限，AI 认为本次判断可参考，但建议补充一次复测。';
    }
    if (result.isSimulated) {
      return '当前链路仍是模拟数据，AI 解释用于演示辅助判断逻辑，不代表真实实验强结论。';
    }
    return '结果位于模型有效范围内，且当前未触发明显警告，AI 认为本次结果具备可用参考价值。';
  }

  String _driverSummary() {
    if (contributions.isEmpty) {
      return '当前结果页缺少模型系数，暂时无法给出定量影响排序，可先结合特征页与警告信息人工判断。';
    }

    final top = contributions.take(3).map((item) {
      final direction = item.$2 >= 0 ? '推高结果' : '拉低结果';
      return '${_prettyFeatureName(item.$1)}（$direction）';
    }).join('、');
    return '本次判断主要受 $top 影响。AI 会优先关注这些特征对结果的正负拉动方向，而不是只报一个最终数值。';
  }

  String _levelReason() {
    final value = result.predictedValue;
    final mid = (result.validRangeMin + result.validRangeMax) / 2;

    if (result.resultStatus == 'error') {
      return '当前结果不是高低判断问题，而是流程本身出现错误，需要先修复输入或模型状态。';
    }
    if (value >= result.validRangeMax * 0.9) {
      return '本次结果偏高，并且已经接近模型上限。通常意味着白化、高光或差分强度中的至少一项明显上升。';
    }
    if (value >= mid) {
      return '本次结果位于中高区间，说明用于表征盐分变化的颜色/纹理差异已经比较明显，但尚未触发超范围。';
    }
    if (value <= result.validRangeMin + (result.validRangeMax - result.validRangeMin) * 0.25) {
      return '本次结果偏低，说明关键差分特征整体较弱，当前样品更接近低负载或弱响应状态。';
    }
    return '本次结果处于中间区间，没有出现极高或极低的异常形态，适合作为当前实验轮次的常规参考值。';
  }

  (String, String) _recommendation() {
    if (result.resultStatus == 'error') {
      return (
        '建议重拍',
        '当前结果包含错误态。建议优先检查输入、ROI、模型包或图像质量，再重新执行一次完整链路。',
      );
    }
    if (result.isOutOfRange) {
      return (
        '建议补采',
        '结果已经超出模型有效范围。AI 建议补采一组图像，必要时更换样品区或调整实验条件。',
      );
    }
    if (result.approachingUpperLimit || result.warnings.isNotEmpty) {
      return (
        '建议复拍',
        '当前结果接近边界或已触发警告。建议至少补一张同条件图像，用于确认本次判断是否稳定。',
      );
    }
    if (result.isSimulated) {
      return (
        '可继续流程',
        '当前是模拟链路，无需重拍；如果要进入真实实验展示，下一步应切换到真实图像采集与复测。',
      );
    }
    return (
      '可继续流程',
      '当前结果处于可解释区间，AI 不强制建议重拍；可以继续进入历史、分析或报告模块。',
    );
  }
}

class _AiBullet extends StatelessWidget {
  const _AiBullet({
    required this.title,
    required this.body,
  });

  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 2),
            child: Icon(Icons.auto_awesome, size: 16),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                ),
                const SizedBox(height: 4),
                Text(body),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

String _prettyFeatureName(String feature) {
  switch (feature) {
    case 'dL':
      return '亮度差 dL';
    case 'da':
      return '色度差 da';
    case 'db':
      return '色度差 db';
    case 'dS':
      return '饱和度差 dS';
    case 'whiteness_index':
      return '白化指数';
    case 'specular_ratio':
      return '高光比例';
    case 'glcm_contrast':
      return '纹理对比度';
    case 'glcm_energy':
      return '纹理能量';
    default:
      return feature;
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
        const SizedBox(height: 14),
        _HistoryTrendBlock(
          currentResult: result,
          sessions: const [],
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

