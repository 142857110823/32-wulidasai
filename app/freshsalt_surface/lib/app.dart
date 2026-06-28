import 'package:flutter/material.dart';

import 'core/demo/demo_app_scope.dart';
import 'core/demo/demo_app_scope_provider.dart';
import 'core/demo/demo_catalog.dart';
import 'routing/app_router.dart';
import 'theme/app_theme.dart';

class FreshSaltApp extends StatefulWidget {
  const FreshSaltApp({
    super.key,
    this.scopeFuture,
  });

  final Future<AppScope>? scopeFuture;

  @override
  State<FreshSaltApp> createState() => _FreshSaltAppState();
}

class _FreshSaltAppState extends State<FreshSaltApp> {
  late final Future<AppScope> _scopeFuture;
  final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();
  AppScope? _scopeOverride;
  String? _lastBootstrappedRoute;

  @override
  void initState() {
    super.initState();
    _scopeFuture = widget.scopeFuture ?? buildRuntimeScope();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<AppScope>(
      future: _scopeOverride == null
          ? _scopeFuture
          : Future<AppScope>.value(_scopeOverride),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Theme(
            data: AppTheme.light(),
            child: Directionality(
              textDirection: TextDirection.ltr,
              child: ColoredBox(
                color: const Color(0xFFF6F9F7),
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 520),
                      child: DecoratedBox(
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
                        child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '应用初始化失败',
                                style: AppTheme.light().textTheme.headlineSmall
                                    ?.copyWith(fontWeight: FontWeight.w800),
                              ),
                              const SizedBox(height: 12),
                              const Text(
                                '当前应用未能完成启动。下面是本次初始化报错，可据此继续修复主流程。',
                              ),
                              const SizedBox(height: 16),
                              SelectableText(
                                '${snapshot.error}',
                                style: AppTheme.light().textTheme.bodyMedium,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        }

        if (!snapshot.hasData) {
          return Theme(
            data: AppTheme.light(),
            child: const Directionality(
              textDirection: TextDirection.ltr,
              child: ColoredBox(
                color: Color(0xFFF6F9F7),
                child: Center(
                  child: CircularProgressIndicator(),
                ),
              ),
            ),
          );
        }

        final scope = snapshot.data!;
        final resolvedRoute = _resolveInitialRoute();
        _bootstrapInitialRouteIfNeeded(resolvedRoute);

        return DemoAppScopeProvider(
          scope: scope,
          child: MaterialApp(
            navigatorKey: _navigatorKey,
            title: 'FreshSalt Surface',
            theme: AppTheme.light(),
            onGenerateInitialRoutes: (initialRoute) => buildFreshSaltInitialRoutes(
              initialRoute: resolvedRoute,
              onGenerateRoute: AppRouter.onGenerateRoute,
            ),
            onGenerateRoute: AppRouter.onGenerateRoute,
          ),
        );
      },
    );
  }

  String _resolveInitialRoute() {
    final fragment = Uri.base.fragment.trim();
    if (fragment.isEmpty) {
      return AppRouter.home;
    }

    final fragmentPath = fragment.split('?').first.split('#').first.trim();
    final normalized = fragmentPath.startsWith('/')
        ? fragmentPath
        : '/$fragmentPath';

    const supportedRoutes = {
      AppRouter.home,
      AppRouter.capture,
      AppRouter.result,
      AppRouter.history,
      AppRouter.report,
      AppRouter.demoValidation,
      AppRouter.modelBundle,
      AppRouter.analysis,
      AppRouter.sample,
      AppRouter.settingsRoute,
      AppRouter.qualityControl,
      AppRouter.roi,
      AppRouter.featurePreview,
      AppRouter.prediction,
      AppRouter.hardwareConfig,
      AppRouter.baselineStage,
      AppRouter.saltedStage,
    };

    return supportedRoutes.contains(normalized)
        ? normalized
        : AppRouter.home;
  }

  void _bootstrapInitialRouteIfNeeded(String resolvedRoute) {
    if (resolvedRoute == AppRouter.home || _lastBootstrappedRoute == resolvedRoute) {
      return;
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final navigator = _navigatorKey.currentState;
      if (!mounted || navigator == null) {
        return;
      }

      final currentRoute =
          ModalRoute.of(navigator.context)?.settings.name;
      if (currentRoute == resolvedRoute) {
        _lastBootstrappedRoute = resolvedRoute;
        return;
      }

      navigator.pushNamedAndRemoveUntil(
        resolvedRoute,
        (route) => route.settings.name == AppRouter.home,
      );
      _lastBootstrappedRoute = resolvedRoute;
    });
  }
}

List<Route<dynamic>> buildFreshSaltInitialRoutes({
  required String initialRoute,
  required RouteFactory onGenerateRoute,
}) {
  final homeRoute = onGenerateRoute(
    const RouteSettings(name: AppRouter.home),
  );
  if (homeRoute == null) {
    return const <Route<dynamic>>[];
  }

  if (initialRoute == AppRouter.home) {
    return <Route<dynamic>>[homeRoute];
  }

  final targetRoute = onGenerateRoute(
    RouteSettings(name: initialRoute),
  );
  if (targetRoute == null) {
    return <Route<dynamic>>[homeRoute];
  }

  return <Route<dynamic>>[homeRoute, targetRoute];
}
