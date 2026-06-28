import 'package:flutter/material.dart';

import '../../features/history/history_page.dart';
import '../../features/home/home_page.dart';
import '../../features/report/report_page.dart';
import '../../features/result/result_page.dart';
import '../../routing/app_router.dart';

class PlatformBottomNavShell extends StatelessWidget {
  const PlatformBottomNavShell({
    super.key,
    required this.currentRoute,
    this.resultSessionId,
  });

  final String currentRoute;
  final String? resultSessionId;

  static const List<String> tabRoutes = <String>[
    AppRouter.home,
    AppRouter.result,
    AppRouter.history,
    AppRouter.report,
  ];

  int get _currentIndex {
    final index = tabRoutes.indexOf(currentRoute);
    return index >= 0 ? index : 0;
  }

  Widget _buildPage() {
    switch (currentRoute) {
      case AppRouter.result:
        return ResultPage(
          key: const ValueKey('tab-result'),
          sessionId: resultSessionId,
          embedInShell: true,
        );
      case AppRouter.history:
        return const HistoryPage(
          key: ValueKey('tab-history'),
          embedInShell: true,
        );
      case AppRouter.report:
        return const ReportPage(
          key: ValueKey('tab-report'),
          embedInShell: true,
        );
      case AppRouter.home:
      default:
        return const HomePage(
          key: ValueKey('tab-home'),
          embedInShell: true,
        );
    }
  }

  void _onTap(BuildContext context, int index) {
    final targetRoute = tabRoutes[index];
    if (targetRoute == currentRoute) {
      return;
    }
    Navigator.of(context).pushReplacementNamed(targetRoute);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: _buildPage(),
      bottomNavigationBar: _PlatformBottomNavBar(
        currentIndex: _currentIndex,
        onTap: (index) => _onTap(context, index),
      ),
    );
  }
}

class _PlatformBottomNavBar extends StatelessWidget {
  const _PlatformBottomNavBar({
    required this.currentIndex,
    required this.onTap,
  });

  final int currentIndex;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    const items = [
      ('首页', Icons.home_outlined),
      ('结果', Icons.show_chart_outlined),
      ('历史', Icons.history),
      ('报告', Icons.description_outlined),
    ];

    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(18, 0, 18, 8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: const [
              BoxShadow(
                color: Color(0x12000000),
                blurRadius: 18,
                offset: Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            children: List.generate(items.length, (index) {
              final selected = index == currentIndex;
              return Expanded(
                child: InkWell(
                  borderRadius: BorderRadius.circular(18),
                  onTap: () => onTap(index),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 180),
                          width: 40,
                          height: 30,
                          decoration: BoxDecoration(
                            color: selected
                                ? const Color(0xFFDFF3EC)
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Icon(
                            items[index].$2,
                            color: selected
                                ? theme.colorScheme.primary
                                : theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          items[index].$1,
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: selected
                                ? theme.colorScheme.primary
                                : theme.colorScheme.onSurfaceVariant,
                            fontWeight:
                                selected ? FontWeight.w700 : FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}
