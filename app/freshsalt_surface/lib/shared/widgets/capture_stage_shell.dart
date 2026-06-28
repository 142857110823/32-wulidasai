import 'package:flutter/material.dart';

class CaptureStageShell extends StatelessWidget {
  const CaptureStageShell({
    super.key,
    required this.appBarTitle,
    required this.title,
    required this.subtitle,
    required this.stageLabel,
    required this.stageTitle,
    this.tags = const <String>[],
    this.metrics = const <CaptureStageMetric>[],
    required this.children,
  });

  final String appBarTitle;
  final String title;
  final String subtitle;
  final String stageLabel;
  final String stageTitle;
  final List<String> tags;
  final List<CaptureStageMetric> metrics;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final summaryMetrics = metrics.take(2).toList(growable: false);
    final showSummary =
        summaryMetrics.isNotEmpty && MediaQuery.sizeOf(context).width >= 900;

    return Scaffold(
      appBar: AppBar(title: Text(appBarTitle)),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
          children: [
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(26),
                gradient: const LinearGradient(
                  colors: [Color(0xFFE7F4F1), Color(0xFFF9FCFB)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                border: Border.all(color: theme.colorScheme.outlineVariant),
              ),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final header = Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        subtitle,
                        maxLines: showSummary ? 2 : 3,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          Chip(
                            visualDensity: VisualDensity.compact,
                            label: Text(stageLabel),
                          ),
                          Chip(
                            visualDensity: VisualDensity.compact,
                            label: Text(stageTitle),
                          ),
                          ...tags
                              .where((tag) => tag.trim().isNotEmpty)
                              .take(showSummary ? 2 : 3)
                              .map(
                                (tag) => Chip(
                                  visualDensity: VisualDensity.compact,
                                  label: Text(tag),
                                ),
                              ),
                        ],
                      ),
                    ],
                  );

                  if (!showSummary) {
                    return header;
                  }

                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(flex: 7, child: header),
                      const SizedBox(width: 14),
                      Expanded(
                        flex: 5,
                        child: _StageSummaryCard(
                          stageLabel: stageLabel,
                          stageTitle: stageTitle,
                          metrics: summaryMetrics,
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
            const SizedBox(height: 14),
            ..._withSpacing(children),
          ],
        ),
      ),
    );
  }

  List<Widget> _withSpacing(List<Widget> items) {
    if (items.isEmpty) {
      return const <Widget>[];
    }

    final result = <Widget>[];
    for (var i = 0; i < items.length; i++) {
      result.add(items[i]);
      if (i < items.length - 1) {
        result.add(const SizedBox(height: 12));
      }
    }
    return result;
  }
}

class CaptureStageMetric {
  const CaptureStageMetric({
    required this.label,
    required this.value,
    required this.note,
  });

  final String label;
  final String value;
  final String note;
}

class CaptureStageSectionCard extends StatelessWidget {
  const CaptureStageSectionCard({
    super.key,
    required this.title,
    this.trailing,
    required this.child,
  });

  final String title;
  final Widget? trailing;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                ),
                if (trailing != null) ...[
                  const SizedBox(width: 10),
                  trailing!,
                ],
              ],
            ),
            const SizedBox(height: 12),
            child,
          ],
        ),
      ),
    );
  }
}

class _StageSummaryCard extends StatelessWidget {
  const _StageSummaryCard({
    required this.stageLabel,
    required this.stageTitle,
    required this.metrics,
  });

  final String stageLabel;
  final String stageTitle;
  final List<CaptureStageMetric> metrics;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.84),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '阶段摘要',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
          ),
          const SizedBox(height: 10),
          _MetricRow(label: '当前阶段', value: stageTitle),
          const Divider(height: 18),
          _MetricRow(label: '阶段编号', value: stageLabel),
          for (final metric in metrics) ...[
            const Divider(height: 18),
            _MetricRow(
              label: metric.label,
              value: metric.value,
              note: metric.note,
            ),
          ],
        ],
      ),
    );
  }
}

class _MetricRow extends StatelessWidget {
  const _MetricRow({
    required this.label,
    required this.value,
    this.note,
  });

  final String label;
  final String value;
  final String? note;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
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
        ),
        if (note != null && note!.isNotEmpty) ...[
          const SizedBox(height: 4),
          Text(
            note!,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              height: 1.35,
            ),
          ),
        ],
      ],
    );
  }
}
