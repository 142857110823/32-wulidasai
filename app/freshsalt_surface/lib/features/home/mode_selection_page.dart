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
                Text('选择进入方式', style: theme.textTheme.headlineMedium),
                const SizedBox(height: 8),
                Text(
                  '先进入一个可操作入口，再继续图像采集、质控分析和结果查看。',
                  style: theme.textTheme.bodyLarge,
                ),
                const SizedBox(height: 16),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('当前说明', style: theme.textTheme.titleMedium),
                        const SizedBox(height: 10),
                        Text(
                          '本应用面向图像采集与分析流程演示，可用于导入图片、查看质控提示、完成 ROI 选区与结果复核。',
                          style: theme.textTheme.bodyMedium,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '当前版本默认提供内置示例数据，便于快速体验完整流程。',
                          style: theme.textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Text('可用入口', style: theme.textTheme.titleLarge),
                const SizedBox(height: 12),
                _ModeEntryCard(
                  title: '平台首页',
                  subtitle: '查看平台总览、最近结果和主要模块入口。',
                  actionLabel: '进入平台首页',
                  icon: Icons.dashboard_outlined,
                  enabled: !_isLoading,
                  onPressed: () => _handleEntryTap(
                    label: '正在进入平台首页...',
                    action: widget.onEnterDemoWorkbench,
                  ),
                ),
                const SizedBox(height: 12),
                _ModeEntryCard(
                  title: '采集流程',
                  subtitle: '直接进入导入图片、质控提示、ROI 选区和结果生成流程。',
                  actionLabel: '进入采集流程',
                  icon: Icons.play_circle_outline,
                  enabled: !_isLoading,
                  onPressed: () => _handleEntryTap(
                    label: '正在加载采集流程...',
                    action: widget.onEnterCaptureDemo,
                  ),
                ),
                const SizedBox(height: 12),
                _ModeEntryCard(
                  title: '流程验证',
                  subtitle: '查看当前流程节点与交互链路的验证记录。',
                  actionLabel: '进入流程验证',
                  icon: Icons.fact_check_outlined,
                  enabled: !_isLoading,
                  onPressed: () => _handleEntryTap(
                    label: '正在加载流程验证...',
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
