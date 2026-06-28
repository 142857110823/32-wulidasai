import 'dart:convert';

import 'package:flutter/material.dart';

import '../../core/demo/demo_app_scope_provider.dart';
import '../../core/demo/demo_catalog.dart';
import '../../core/models/click_validation_case.dart';
import '../../core/models/click_validation_case.dart' as click_models;

class DemoValidationPage extends StatefulWidget {
  const DemoValidationPage({
    super.key,
    this.embedInShell = false,
  });

  final bool embedInShell;

  @override
  State<DemoValidationPage> createState() => _DemoValidationPageState();
}

class _DemoValidationPageState extends State<DemoValidationPage> {
  bool _running = false;
  Map<String, dynamic>? _summary;

  List<ClickValidationCase> _buildCases() {
    return [
      ClickValidationCase(
        caseId: 'M01_HOME',
        module: 'home_router',
        action: '验证首页主入口进入质控阶段',
        mockInput: const {'source_mode': 'simulated'},
        expectedOutput: const {
          'status': 'success',
          'route': '/quality-control',
        },
        assertionRule: '首页主入口必须先进入质控阶段，而不是回到兼容工作台。',
      ),
      ClickValidationCase(
        caseId: 'M02_MODEL',
        module: 'model_bundle',
        action: '启用默认模拟模型包',
        mockInput: const {'model_id': 'freshsalt_rgb_cucumber_darkbox_v1'},
        expectedOutput: const {
          'status': 'success',
          'active_model_id': 'freshsalt_rgb_cucumber_darkbox_v1',
        },
        assertionRule: '默认模型包必须可激活，并暴露 active_model_id。',
      ),
      ClickValidationCase(
        caseId: 'M03_QC_PASS',
        module: 'quality_control',
        action: '执行质控通过案例',
        mockInput: {'image_metadata': demoImageMetadataMedium},
        expectedOutput: const {'qc_status': 'passed', 'all_checks': true},
        assertionRule: '曝光、清晰度、灰卡 RSD 与 ROI 必须全部通过。',
      ),
      ClickValidationCase(
        caseId: 'M04_QC_FAIL',
        module: 'quality_control',
        action: '执行过曝失败案例',
        mockInput: {'image_metadata': demoImageMetadataOverexposed},
        expectedOutput: const {
          'qc_status': 'failed',
          'failed_checks': 'exposure',
        },
        assertionRule: '过曝案例必须阻断采集主链继续推进。',
      ),
      ClickValidationCase(
        caseId: 'M05_CAPTURE_I0',
        module: 'capture_i0',
        action: '加载模拟 I0 基线图',
        mockInput: const {'baseline_image_path': '/mock/baseline_medium.png'},
        expectedOutput: const {'status': 'success', 'baseline_loaded': true},
        assertionRule: 'I0 阶段必须保存基线图路径。',
      ),
      ClickValidationCase(
        caseId: 'M06_CAPTURE_I1',
        module: 'capture_i1',
        action: '加载模拟 I1 待测图',
        mockInput: const {'salted_image_path': '/mock/salted_medium.png'},
        expectedOutput: const {'status': 'success', 'salted_loaded': true},
        assertionRule: 'I1 阶段必须保存待测图路径。',
      ),
      ClickValidationCase(
        caseId: 'M07_ROI',
        module: 'roi',
        action: '确认 ROI 与灰卡区域',
        mockInput: const {'roi_area_cm2': 4.0, 'roi_within_bounds': true},
        expectedOutput: const {'status': 'success', 'roi_valid': true},
        assertionRule: 'ROI 必须在边界内且面积有效。',
      ),
      ClickValidationCase(
        caseId: 'M08_FEATURE',
        module: 'feature_extraction',
        action: '提取演示特征向量',
        mockInput: {
          'session_id': 'validation_feature_session',
          'image_metadata': demoImageMetadataMedium,
        },
        expectedOutput: const {'status': 'success', 'feature_count': 10},
        assertionRule: '特征页必须返回完整十维特征向量。',
      ),
      ClickValidationCase(
        caseId: 'M09_PREDICT',
        module: 'prediction',
        action: '计算模拟预测结果',
        mockInput: {
          'session_id': 'validation_prediction_session',
          'sample_id': 'validation_sample_medium',
          'image_metadata': demoImageMetadataMedium,
        },
        expectedOutput: const {'status': 'success', 'predicted_value': 0.35},
        assertionRule: '预测页必须返回目标值，并保留单位上下文。',
      ),
      ClickValidationCase(
        caseId: 'M10_RESULT',
        module: 'result_view',
        action: '检查结果详情图表状态',
        mockInput: const {'result_status': 'valid'},
        expectedOutput: const {'status': 'success', 'charts_ready': true},
        assertionRule: '结果详情必须具备图表型展示能力。',
      ),
      ClickValidationCase(
        caseId: 'M11_SAVE',
        module: 'save_history',
        action: '保存到历史记录',
        mockInput: {
          'session_id': 'validation_saved_session',
          'sample_id': 'validation_saved_sample',
          'baseline_image_path': '/mock/baseline_medium.png',
          'salted_image_path': '/mock/salted_medium.png',
          'roi_polygon': demoRoiPolygon,
          'image_metadata': demoImageMetadataMedium,
        },
        expectedOutput: const {'status': 'success', 'session_saved': true},
        assertionRule: '预测成功后必须显式保存到历史。',
      ),
      ClickValidationCase(
        caseId: 'M12_HISTORY',
        module: 'history_view',
        action: '检查历史页模拟记录显示',
        mockInput: const {'is_simulated': true},
        expectedOutput: const {'status': 'success', 'simulated_badge': true},
        assertionRule: '历史页必须持续显示模拟数据标记。',
      ),
      ClickValidationCase(
        caseId: 'M13_ANALYSIS',
        module: 'analysis_view',
        action: '检查分析总览可用性',
        mockInput: const {'record_count': 1},
        expectedOutput: const {'status': 'success', 'analysis_ready': true},
        assertionRule: '分析总览必须能基于已有记录生成摘要。',
      ),
      ClickValidationCase(
        caseId: 'M14_EXPORT',
        module: 'export_csv',
        action: '检查 CSV 导出字段',
        mockInput: const {'session_id': 'validation_saved_session'},
        expectedOutput: const {
          'status': 'success',
          'csv_fields_complete': true,
        },
        assertionRule: '导出结果必须包含 source_mode 等关键字段。',
      ),
      ClickValidationCase(
        caseId: 'M15_FULL_CHAIN',
        module: 'full_chain',
        action: '一键运行完整平台闭环',
        mockInput: const {'chain': 'm01_m14'},
        expectedOutput: const {'status': 'success', 'chain_complete': true},
        assertionRule: 'M01-M14 必须串成完整闭环，并返回汇总结果。',
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final scope = DemoAppScopeProvider.of(context);
    final theme = Theme.of(context);
    final cases = _buildCases();
    final groupedCases = _groupCases(cases);

    return FutureBuilder<List<click_models.ClickValidationLog>>(
      future: scope.clickValidationRepository.getAllClickLogs(),
      builder: (context, snapshot) {
        final logs = snapshot.data ?? const <click_models.ClickValidationLog>[];
        final latestLog = logs.isEmpty ? null : logs.last;

        final body = SafeArea(
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              if (widget.embedInShell) ...[
                Text('点击验证台', style: theme.textTheme.headlineMedium),
                const SizedBox(height: 12),
              ],
              _ValidationHero(
                caseCount: cases.length,
                latestResult: latestLog?.result ?? '--',
              ),
              const SizedBox(height: 20),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  FilledButton.icon(
                    onPressed: _running ? null : () => _runFullValidation(scope, cases),
                    icon: const Icon(Icons.play_arrow_rounded),
                    label: Text(_running ? '运行中...' : '一键运行验证'),
                  ),
                  OutlinedButton.icon(
                    onPressed: _running ? null : () => _clearLogs(scope),
                    icon: const Icon(Icons.delete_outline),
                    label: const Text('清空日志'),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              const _SectionHeader(
                title: '覆盖范围',
                subtitle: '验证台服务于平台闭环核对，不是孤立测试页；它必须和真实 UI 主链保持同一阶段语义。',
              ),
              const SizedBox(height: 12),
              const _SectionCard(
                title: '平台覆盖范围',
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    Chip(label: Text('首页工作台')),
                    Chip(label: Text('模型与硬件')),
                    Chip(label: Text('质控 -> I0 -> I1 -> ROI')),
                    Chip(label: Text('特征 -> 预测 -> 保存')),
                    Chip(label: Text('结果 / 历史 / 分析 / 报告')),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              const _SectionCard(
                title: '链路对齐说明',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '验证链顺序与真实 UI 主链保持一致：质控 -> I0 -> I1 -> ROI -> 特征 -> 预测 -> 保存。',
                    ),
                    SizedBox(height: 8),
                    Text(
                      '验证台保留服务级断言视角，但案例分组、顺序和结果摘要必须对齐平台页面结构。',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  _MetricCard(
                    title: '案例总数',
                    value: '${cases.length}',
                    note: '覆盖平台入口、主链与模块页。',
                  ),
                  _MetricCard(
                    title: '最近结果',
                    value: latestLog == null ? '--' : latestLog.result,
                    note: latestLog == null ? '尚未运行验证' : latestLog.caseId,
                  ),
                  const _MetricCard(
                    title: '当前模式',
                    value: '模拟数据',
                    note: '验证结果不伪装成真实实验。',
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  FilledButton.icon(
                    onPressed: _running ? null : () => _runFullValidation(scope, cases),
                    icon: const Icon(Icons.play_arrow_rounded),
                    label: Text(_running ? '运行中...' : '一键跑完整点击链'),
                  ),
                  OutlinedButton.icon(
                    onPressed: _running ? null : () => _clearLogs(scope),
                    icon: const Icon(Icons.delete_outline),
                    label: const Text('清空日志'),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              if (_summary != null)
                _SectionCard(
                  title: '汇总结果',
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      Chip(label: Text('总数 ${_summary!['total']}')),
                      Chip(label: Text('通过 ${_summary!['passed']}')),
                      Chip(label: Text('失败 ${_summary!['failed']}')),
                    ],
                  ),
                ),
              const SizedBox(height: 20),
              const _SectionHeader(
                title: '用例分组',
                subtitle: '按平台入口、采集主链、结果模块和全链路汇总分组，便于答辩和回归核查。',
              ),
              const SizedBox(height: 12),
              ...groupedCases.entries.map(
                (entry) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _SectionCard(
                    title: entry.key,
                    child: Column(
                      children: entry.value.map((item) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Card(
                            margin: EdgeInsets.zero,
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              '${item.caseId} | ${item.action}',
                                              style: theme.textTheme.titleMedium
                                                  ?.copyWith(
                                                    fontWeight: FontWeight.w700,
                                                  ),
                                            ),
                                            const SizedBox(height: 6),
                                            Text('模块: ${item.module}'),
                                            const SizedBox(height: 8),
                                            Text(
                                              '断言规则: ${item.assertionRule ?? '未提供'}',
                                              style: theme.textTheme.bodySmall,
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      OutlinedButton(
                                        onPressed: _running
                                            ? null
                                            : () => _runSingleCase(scope, item),
                                        child: const Text('运行'),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),
              ),
              _SectionCard(
                title: '断言日志',
                child: logs.isEmpty
                    ? const Text('尚无点击验证日志，请先运行单项或完整链路。')
                    : Column(
                        children: logs.reversed.map((log) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: Card(
                              margin: EdgeInsets.zero,
                              child: ExpansionTile(
                                title: Text('${log.caseId} | ${log.module}'),
                                subtitle: Text(
                                  log.errorMessage == null ? '断言通过' : log.errorMessage!,
                                ),
                                trailing: Chip(
                                  label: Text(log.isPassed ? 'pass' : 'fail'),
                                ),
                                childrenPadding:
                                    const EdgeInsets.fromLTRB(16, 0, 16, 16),
                                children: [
                                  _LogSection(
                                    title: '模拟输入',
                                    value: _prettyJson(log.mockInput),
                                  ),
                                  const SizedBox(height: 12),
                                  _LogSection(
                                    title: '期望输出',
                                    value: _prettyJson(log.expectedOutput),
                                  ),
                                  const SizedBox(height: 12),
                                  _LogSection(
                                    title: '实际输出',
                                    value: _prettyJson(log.actualOutput),
                                  ),
                                  const SizedBox(height: 12),
                                  _LogSection(
                                    title: '耗时',
                                    value: '${log.durationMs} ms',
                                  ),
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                      ),
              ),
            ],
          ),
        );

        if (widget.embedInShell) {
          return body;
        }

        return Scaffold(
          appBar: AppBar(title: const Text('点击验证台')),
          body: body,
        );
      },
    );
  }

  Map<String, List<ClickValidationCase>> _groupCases(List<ClickValidationCase> cases) {
    return {
      '平台入口与前置条件': cases
          .where((item) => ['M01_HOME', 'M02_MODEL'].contains(item.caseId))
          .toList(),
      '采集主链': cases
          .where((item) => [
                'M03_QC_PASS',
                'M04_QC_FAIL',
                'M05_CAPTURE_I0',
                'M06_CAPTURE_I1',
                'M07_ROI',
                'M08_FEATURE',
                'M09_PREDICT',
                'M11_SAVE',
              ].contains(item.caseId))
          .toList(),
      '结果与平台模块': cases
          .where((item) => [
                'M10_RESULT',
                'M12_HISTORY',
                'M13_ANALYSIS',
                'M14_EXPORT',
              ].contains(item.caseId))
          .toList(),
      '全链路汇总': cases.where((item) => item.caseId == 'M15_FULL_CHAIN').toList(),
    };
  }

  Future<void> _runSingleCase(dynamic scope, ClickValidationCase testCase) async {
    setState(() {
      _running = true;
    });
    await scope.orchestrator.executeFullClickValidation([testCase]);
    if (!mounted) {
      return;
    }
    setState(() {
      _running = false;
    });
  }

  Future<void> _runFullValidation(
    dynamic scope,
    List<ClickValidationCase> cases,
  ) async {
    setState(() {
      _running = true;
    });
    final summary = await scope.orchestrator.executeFullClickValidation(cases);
    if (!mounted) {
      return;
    }
    setState(() {
      _summary = summary;
      _running = false;
    });
  }

  Future<void> _clearLogs(dynamic scope) async {
    await scope.clickValidationRepository.clearAll();
    if (!mounted) {
      return;
    }
    setState(() {
      _summary = null;
    });
  }

  String _prettyJson(Map<String, dynamic> value) {
    return const JsonEncoder.withIndent('  ').convert(value);
  }
}

class _ValidationHero extends StatelessWidget {
  const _ValidationHero({
    required this.caseCount,
    required this.latestResult,
  });

  final int caseCount;
  final String latestResult;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: const LinearGradient(
          colors: [Color(0xFFEBF1F8), Color(0xFFF8FBFA)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      padding: const EdgeInsets.all(24),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final wide = constraints.maxWidth >= 920;
          final intro = Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '点击验证台',
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                '本页用于核对平台入口、采集主链、结果模块和导出链路是否与当前 Flutter UI 主流程保持一致。它不是独立测试展示页，而是平台闭环的验证面板。',
                style: theme.textTheme.bodyLarge?.copyWith(height: 1.45),
              ),
            ],
          );

          final metrics = Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              _HeroMetric(label: '案例数', value: '$caseCount'),
              _HeroMetric(label: '最新结果', value: latestResult),
              const _HeroMetric(label: '数据模式', value: '模拟数据'),
            ],
          );

          if (!wide) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                intro,
                const SizedBox(height: 16),
                metrics,
              ],
            );
          }

          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(flex: 7, child: intro),
              const SizedBox(width: 20),
              Expanded(
                flex: 5,
                child: Align(alignment: Alignment.topRight, child: metrics),
              ),
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
      width: 180,
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

class _LogSection extends StatelessWidget {
  const _LogSection({
    required this.title,
    required this.value,
  });

  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
          ),
          const SizedBox(height: 8),
          SelectableText(value),
        ],
      ),
    );
  }
}
