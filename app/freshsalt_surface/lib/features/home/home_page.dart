import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/demo/demo_app_scope_provider.dart';
import '../../core/demo/demo_capture_bundle_factory.dart';
import '../../core/models/capture_step_bundle.dart';
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
    final previewBundle = buildDemoCaptureBundle(scope);

    return FutureBuilder<List<Map<String, dynamic>>>(
      future: scope.sessionRepository.getAllSessions(isSimulated: true),
      builder: (context, snapshot) {
        final sessions = snapshot.data ?? const <Map<String, dynamic>>[];
        final latestSession = sessions.isEmpty ? null : sessions.first;
        final latestValue =
            (((latestSession?['result'] as Map?)?['predicted_mg_cm2'] as num?) ??
                    0.35)
                .toDouble();
        final trendValues = _buildTrendValues(sessions, fallback: latestValue);

        final content = SafeArea(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(18, 16, 18, 8),
            children: [
              _HomeHeader(
                activeModelId:
                    activeModel?.modelId ?? 'freshsalt_rgb_cucumber_darkbox_v1',
                hardwareProfileLabel: scope.hardwareProfileLabel,
              ),
              const SizedBox(height: 10),
              _WorkbenchOverviewCard(
                activeModelReady: activeModel != null,
                hasSavedHistory: sessions.isNotEmpty,
                onOpenCapture: () => _openQualityControl(context, previewBundle),
                onOpenResult: () =>
                    Navigator.of(context).pushNamed(AppRouter.result),
                onOpenValidation: () =>
                    Navigator.of(context).pushNamed(AppRouter.demoValidation),
                activeModelId: activeModel?.modelId ?? '未启用',
                hardwareProfileLabel: scope.hardwareProfileLabel,
                latestValue: latestValue,
                trendValues: trendValues,
              ),
              const SizedBox(height: 14),
              const _SectionLabel(title: '模块入口'),
              const SizedBox(height: 12),
              _ModuleEntryGrid(
                onOpenSample: () => Navigator.of(context).pushNamed(AppRouter.sample),
                onOpenModel: () =>
                    Navigator.of(context).pushNamed(AppRouter.modelBundle),
                onOpenHardware: () =>
                    Navigator.of(context).pushNamed(AppRouter.hardwareConfig),
                onOpenResult: () =>
                    Navigator.of(context).pushNamed(AppRouter.result),
                onOpenHistory: () =>
                    Navigator.of(context).pushNamed(AppRouter.history),
                onOpenAnalysis: () =>
                    Navigator.of(context).pushNamed(AppRouter.analysis),
                onOpenReport: () =>
                    Navigator.of(context).pushNamed(AppRouter.report),
                onOpenSettings: () =>
                    Navigator.of(context).pushNamed(AppRouter.settingsRoute),
              ),
            ],
          ),
        );

        if (embedInShell) {
          return content;
        }

        return Scaffold(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          body: content,
        );
      },
    );
  }

  List<double> _buildTrendValues(
    List<Map<String, dynamic>> sessions, {
    required double fallback,
  }) {
    if (sessions.isEmpty) {
      return const [0.05, 0.09, 0.18, 0.15, 0.35];
    }

    return sessions
        .take(5)
        .map(
          (item) =>
              (((item['result'] as Map?)?['predicted_mg_cm2'] as num?) ?? fallback)
                  .toDouble(),
        )
        .toList()
        .reversed
        .toList();
  }
}

void _openQualityControl(
  BuildContext context,
  CaptureStepBundle bundle,
) {
  Navigator.of(context).pushNamed(
    AppRouter.qualityControl,
    arguments: bundle,
  );
}

class _WorkbenchOverviewCard extends StatelessWidget {
  const _WorkbenchOverviewCard({
    required this.activeModelReady,
    required this.hasSavedHistory,
    required this.onOpenCapture,
    required this.onOpenResult,
    required this.onOpenValidation,
    required this.activeModelId,
    required this.hardwareProfileLabel,
    required this.latestValue,
    required this.trendValues,
  });

  final bool activeModelReady;
  final bool hasSavedHistory;
  final VoidCallback onOpenCapture;
  final VoidCallback onOpenResult;
  final VoidCallback onOpenValidation;
  final String activeModelId;
  final String hardwareProfileLabel;
  final double latestValue;
  final List<double> trendValues;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: const LinearGradient(
          colors: [Color(0xFFF2FAF7), Color(0xFFFBFDFC)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(color: const Color(0xFFD3E6DE)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionLabel(title: '首页工作台'),
          const SizedBox(height: 6),
          Text(
            '首屏只承载模式状态、采集主链入口与结果复核入口，避免继续分散成说明页。',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 6,
                child: Column(
                  children: [
                    _TaskStatusCard(
                      activeModelReady: activeModelReady,
                      hasSavedHistory: hasSavedHistory,
                      compact: true,
                      latestValue: latestValue,
                    ),
                    const SizedBox(height: 10),
                    _PrimaryEntryCard(
                      onOpenCapture: onOpenCapture,
                      onOpenResult: onOpenResult,
                      onOpenValidation: onOpenValidation,
                      compact: true,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                flex: 5,
                child: Column(
                  children: [
                    _PlatformStateCard(
                      activeModelId: activeModelId,
                      hardwareProfileLabel: hardwareProfileLabel,
                      latestValue: latestValue,
                      hasSavedHistory: hasSavedHistory,
                      compact: true,
                    ),
                    const SizedBox(height: 10),
                    _TrendSummaryCard(
                      values: trendValues,
                      latestValue: latestValue,
                      hasSavedHistory: hasSavedHistory,
                      compact: true,
                    ),
                    const SizedBox(height: 10),
                    const _MainChainCard(compact: true),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _HomeHeader extends StatelessWidget {
  const _HomeHeader({
    required this.activeModelId,
    required this.hardwareProfileLabel,
  });

  final String activeModelId;
  final String hardwareProfileLabel;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'FreshSalt Surface',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.4,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '受控 RGB 成像 · 实验模型 · APP 验证',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 10),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                  const _PillTag(
                    text: '演示模式',
                    background: Color(0xFFFFF0E4),
                    foreground: Color(0xFFCB6A28),
                  ),
                  _PillTag(
                    text: '暗箱 $hardwareProfileLabel',
                    background: const Color(0xFFD9F2EB),
                    foreground: const Color(0xFF0F766E),
                  ),
                  _PillTag(
                    text: activeModelId,
                    background: const Color(0xFFE8F1F0),
                    foreground: theme.colorScheme.onSurface,
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: const Color(0xFFDFF3EC),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            '模拟',
            style: theme.textTheme.labelLarge?.copyWith(
              color: const Color(0xFF0F766E),
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.title});

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

class _TaskStatusCard extends StatelessWidget {
  const _TaskStatusCard({
    required this.activeModelReady,
    required this.hasSavedHistory,
    this.compact = false,
    this.latestValue = 0.35,
  });

  final bool activeModelReady;
  final bool hasSavedHistory;
  final bool compact;
  final double latestValue;

  @override
  Widget build(BuildContext context) {
    return _ModuleCard(
      compact: compact,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '今日任务',
            style: (compact
                    ? Theme.of(context).textTheme.titleLarge
                    : Theme.of(context).textTheme.headlineSmall)
                ?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
          ),
          const SizedBox(height: 6),
          Text(
            compact
                ? '优先跑通采集、质控、特征、推理和结果复核。'
                : '用模拟图像跑通采集、质控、特征、推理和报告。',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          SizedBox(height: compact ? 10 : 18),
          Wrap(
            spacing: compact ? 8 : 10,
            runSpacing: compact ? 8 : 10,
            children: [
              _StatusPill(
                title: '配置',
                status: activeModelReady ? '已完成' : '待处理',
                compact: compact,
              ),
              _StatusPill(
                title: '质控',
                status: '待执行',
                compact: compact,
              ),
              _StatusPill(
                title: '推理',
                status: hasSavedHistory ? '已生成' : '待执行',
                compact: compact,
              ),
              if (compact)
                _StatusPill(
                  title: '最近结果',
                  status: hasSavedHistory
                      ? '${latestValue.toStringAsFixed(2)} mg/cm2'
                      : '暂无记录',
                  compact: true,
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PrimaryEntryCard extends StatelessWidget {
  const _PrimaryEntryCard({
    required this.onOpenCapture,
    required this.onOpenResult,
    required this.onOpenValidation,
    this.compact = false,
  });

  final VoidCallback onOpenCapture;
  final VoidCallback onOpenResult;
  final VoidCallback onOpenValidation;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return _ModuleCard(
      compact: compact,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '核心入口',
            style: (compact
                    ? Theme.of(context).textTheme.titleLarge
                    : Theme.of(context).textTheme.headlineSmall)
                ?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
            ),
          const SizedBox(height: 6),
          Text(
            compact ? '采集主链 + 结果复核' : '采集主链',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
          SizedBox(height: compact ? 12 : 18),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: onOpenCapture,
              style: FilledButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: compact ? 12 : 18),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
              ),
              child: const Text('开始采集预测'),
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: onOpenResult,
                  style: OutlinedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: compact ? 10 : 16),
                    backgroundColor: const Color(0xFFE9EEFF),
                    foregroundColor: const Color(0xFF4463DD),
                    side: BorderSide.none,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: const Text('查看结果图表'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      '点击验证台',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                            color: const Color(0xFF7965D2),
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                    const SizedBox(height: 4),
                    OutlinedButton(
                      onPressed: onOpenValidation,
                      style: OutlinedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: compact ? 10 : 16),
                        backgroundColor: const Color(0xFFF0EAFE),
                        foregroundColor: const Color(0xFF7965D2),
                        side: BorderSide.none,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: const Text('打开验证台'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PlatformStateCard extends StatelessWidget {
  const _PlatformStateCard({
    required this.activeModelId,
    required this.hardwareProfileLabel,
    required this.latestValue,
    required this.hasSavedHistory,
    this.compact = false,
  });

  final String activeModelId;
  final String hardwareProfileLabel;
  final double latestValue;
  final bool hasSavedHistory;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return _ModuleCard(
      compact: compact,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (compact) ...[
            Text(
              '平台状态',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
            ),
            const SizedBox(height: 12),
          ],
          const _StateRow(label: '当前模式', value: '演示模式'),
          Divider(height: compact ? 16 : 24),
          const _StateRow(label: '数据来源', value: '模拟数据'),
          Divider(height: compact ? 16 : 24),
          _StateRow(label: '启用模型', value: activeModelId),
          Divider(height: compact ? 16 : 24),
          _StateRow(label: '硬件配置', value: hardwareProfileLabel),
          Divider(height: compact ? 16 : 24),
          _StateRow(
            label: '最近趋势',
            value: hasSavedHistory ? '${latestValue.toStringAsFixed(2)} mg/cm2' : '暂无记录',
          ),
        ],
      ),
    );
  }
}

class _MainChainCard extends StatelessWidget {
  const _MainChainCard({this.compact = false});

  final bool compact;

  @override
  Widget build(BuildContext context) {
    const steps = ['质控', 'I0', 'I1', 'ROI', '特征', '预测', '保存'];

    return _ModuleCard(
      compact: compact,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (compact) ...[
            Text(
              '主链概览',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
            ),
            const SizedBox(height: 8),
          ],
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: steps
                .map((step) => Chip(label: Text(step)))
                .toList(growable: false),
          ),
          if (!compact) ...[
            const SizedBox(height: 12),
            Text(
              '首页不再承担阶段内主操作，只保留平台结构、主链入口与模块导航。',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ],
      ),
    );
  }
}

class _TrendSummaryCard extends StatelessWidget {
  const _TrendSummaryCard({
    required this.values,
    required this.latestValue,
    required this.hasSavedHistory,
    this.compact = false,
  });

  final List<double> values;
  final double latestValue;
  final bool hasSavedHistory;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return _ModuleCard(
      compact: compact,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (compact) ...[
                  Text(
                    '最近模拟趋势',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 10),
                ],
                SizedBox(
                  height: compact ? 52 : 88,
                  child: CustomPaint(
                    painter: _SparklinePainter(
                      values: values,
                      color: theme.colorScheme.primary,
                    ),
                    child: const SizedBox.expand(),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  hasSavedHistory ? '最近模拟趋势' : '演示趋势',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                latestValue.toStringAsFixed(2),
                style: (compact
                        ? theme.textTheme.headlineMedium
                        : theme.textTheme.displaySmall)
                    ?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: theme.colorScheme.primary,
                ),
              ),
              Text(
                'mg/cm2\nNaCl eq.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ModuleEntryGrid extends StatelessWidget {
  const _ModuleEntryGrid({
    required this.onOpenSample,
    required this.onOpenModel,
    required this.onOpenHardware,
    required this.onOpenResult,
    required this.onOpenHistory,
    required this.onOpenAnalysis,
    required this.onOpenReport,
    required this.onOpenSettings,
  });

  final VoidCallback onOpenSample;
  final VoidCallback onOpenModel;
  final VoidCallback onOpenHardware;
  final VoidCallback onOpenResult;
  final VoidCallback onOpenHistory;
  final VoidCallback onOpenAnalysis;
  final VoidCallback onOpenReport;
  final VoidCallback onOpenSettings;

  @override
  Widget build(BuildContext context) {
    final items = <_ModuleAction>[
      _ModuleAction('样品管理', Icons.inventory_2_outlined, onOpenSample),
      _ModuleAction('模型包', Icons.dataset_linked_outlined, onOpenModel),
      _ModuleAction('硬件配置', Icons.memory_outlined, onOpenHardware),
      _ModuleAction('结果详情', Icons.stacked_line_chart_outlined, onOpenResult),
      _ModuleAction('历史记录', Icons.history, onOpenHistory),
      _ModuleAction('分析总览', Icons.insights_outlined, onOpenAnalysis),
      _ModuleAction('报告页', Icons.article_outlined, onOpenReport),
      _ModuleAction('设置', Icons.settings_outlined, onOpenSettings),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: items.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisExtent: 92,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemBuilder: (context, index) {
        final item = items[index];
        return _ModuleEntryTile(item: item);
      },
    );
  }
}


class _ModuleEntryTile extends StatelessWidget {
  const _ModuleEntryTile({required this.item});

  final _ModuleAction item;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: item.onTap,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: theme.colorScheme.outlineVariant),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: const Color(0xFFE9F4F1),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(item.icon, color: theme.colorScheme.primary),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  item.title,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ModuleCard extends StatelessWidget {
  const _ModuleCard({
    required this.child,
    this.compact = false,
  });

  final Widget child;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(compact ? 16 : 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
      ),
      child: child,
    );
  }
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({
    required this.title,
    required this.status,
    this.compact = false,
  });

  final String title;
  final String status;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: compact ? 132 : null,
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 12 : 0,
        vertical: compact ? 10 : 14,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F6F3),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Text(
            title,
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            status,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

class _StateRow extends StatelessWidget {
  const _StateRow({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 72,
          child: Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }
}

class _PillTag extends StatelessWidget {
  const _PillTag({
    required this.text,
    required this.background,
    required this.foreground,
  });

  final String text;
  final Color background;
  final Color foreground;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Text(
        text,
        style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: foreground,
              fontWeight: FontWeight.w700,
            ),
      ),
    );
  }
}

class _ModuleAction {
  const _ModuleAction(this.title, this.icon, this.onTap);

  final String title;
  final IconData icon;
  final VoidCallback onTap;
}

class _SparklinePainter extends CustomPainter {
  const _SparklinePainter({
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

    final maxValue = values.reduce(math.max);
    final minValue = values.reduce(math.min);
    final span = math.max(maxValue - minValue, 0.001);

    final points = <Offset>[];
    for (var i = 0; i < values.length; i++) {
      final x = values.length == 1 ? 0.0 : (size.width * i / (values.length - 1));
      final y = size.height - ((values[i] - minValue) / span * (size.height - 8)) - 4;
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
      ..color = color.withOpacity(0.14)
      ..style = PaintingStyle.fill;
    final strokePaint = Paint()
      ..color = color
      ..strokeWidth = 2.4
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    canvas.drawPath(fillPath, fillPaint);
    canvas.drawPath(strokePath, strokePaint);
    canvas.drawCircle(points.last, 3.4, Paint()..color = color);
  }

  @override
  bool shouldRepaint(covariant _SparklinePainter oldDelegate) {
    return oldDelegate.values != values || oldDelegate.color != color;
  }
}
