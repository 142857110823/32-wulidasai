import 'package:flutter/material.dart';

class ModeSelectionPage extends StatefulWidget {
  const ModeSelectionPage({
    super.key,
    required this.onEnterDemoWorkbench,
    required this.onEnterCaptureDemo,
    required this.onEnterValidationDemo,
  });

  final Future<void> Function() onEnterDemoWorkbench;
  final Future<void> Function() onEnterCaptureDemo;
  final Future<void> Function() onEnterValidationDemo;

  @override
  State<ModeSelectionPage> createState() => _ModeSelectionPageState();
}

class _ModeSelectionPageState extends State<ModeSelectionPage> {
  String? _loadingLabel;

  bool get _isLoading => _loadingLabel != null;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('FreshSalt Surface')),
      body: Stack(
        children: [
          SafeArea(
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                Text('模式选择与边界确认', style: theme.textTheme.headlineMedium),
                const SizedBox(height: 8),
                Text(
                  '首次进入先确认平台边界，再选择演示入口。当前默认加载模拟模型、模拟图像和模拟记录。',
                  style: theme.textTheme.bodyLarge,
                ),
                const SizedBox(height: 16),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('项目边界', style: theme.textTheme.titleMedium),
                        const SizedBox(height: 10),
                        Text(
                          '本应用仅用于大学物理实验、方法验证和平台演示，不作为食品安全、商品分级或执法性质结论输出。',
                          style: theme.textTheme.bodyMedium,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '当前结果均为模拟数据。后续仅替换真实暗箱实验图像和模型包，不重写主界面流程。',
                          style: theme.textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Text('演示入口', style: theme.textTheme.titleLarge),
                const SizedBox(height: 12),
                _ModeEntryCard(
                  title: '演示工作台',
                  subtitle:
                      '进入平台首页，查看模型状态、硬件状态、最近趋势和全部模块入口。',
                  actionLabel: '进入演示工作台',
                  icon: Icons.dashboard_outlined,
                  enabled: !_isLoading,
                  onPressed: () => _handleEntryTap(
                    label: '正在加载演示模式...',
                    action: widget.onEnterDemoWorkbench,
                  ),
                ),
                const SizedBox(height: 12),
                _ModeEntryCard(
                  title: '采集预测演示',
                  subtitle:
                      '直接进入采集主线，按“质控 -> I0 -> I1 -> ROI -> 预测 -> 保存”完成首条演示闭环。',
                  actionLabel: '进入采集预测',
                  icon: Icons.play_circle_outline,
                  enabled: !_isLoading,
                  onPressed: () => _handleEntryTap(
                    label: '正在加载采集演示...',
                    action: widget.onEnterCaptureDemo,
                  ),
                ),
                const SizedBox(height: 12),
                _ModeEntryCard(
                  title: '点击验证台',
                  subtitle: '进入 M01-M15 验证台，执行单条 case 或全链路模拟断言。',
                  actionLabel: '进入点击验证台',
                  icon: Icons.fact_check_outlined,
                  enabled: !_isLoading,
                  onPressed: () => _handleEntryTap(
                    label: '正在加载验证台...',
                    action: widget.onEnterValidationDemo,
                  ),
                ),
              ],
            ),
          ),
          if (_isLoading)
            ColoredBox(
              color: Colors.black.withOpacity(0.08),
              child: Center(
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 20,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const CircularProgressIndicator(),
                        const SizedBox(height: 16),
                        Text(_loadingLabel!),
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _handleEntryTap({
    required String label,
    required Future<void> Function() action,
  }) async {
    setState(() {
      _loadingLabel = label;
    });
    try {
      await action();
    } finally {
      if (mounted) {
        setState(() {
          _loadingLabel = null;
        });
      }
    }
  }
}

class _ModeEntryCard extends StatelessWidget {
  const _ModeEntryCard({
    required this.title,
    required this.subtitle,
    required this.actionLabel,
    required this.icon,
    required this.enabled,
    required this.onPressed,
  });

  final String title;
  final String subtitle;
  final String actionLabel;
  final IconData icon;
  final bool enabled;
  final Future<void> Function() onPressed;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon),
                const SizedBox(width: 10),
                Text(title, style: Theme.of(context).textTheme.titleMedium),
              ],
            ),
            const SizedBox(height: 10),
            Text(subtitle),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: enabled ? onPressed : null,
                child: Text(actionLabel),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
