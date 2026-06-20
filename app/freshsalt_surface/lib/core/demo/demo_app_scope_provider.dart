import 'package:flutter/widgets.dart';

import 'demo_app_scope.dart';

class DemoAppScopeProvider extends InheritedWidget {
  const DemoAppScopeProvider({
    super.key,
    required this.scope,
    required super.child,
  });

  final AppScope scope;

  static AppScope of(BuildContext context) {
    final provider =
        context.dependOnInheritedWidgetOfExactType<DemoAppScopeProvider>();
    assert(provider != null, 'DemoAppScopeProvider not found in context');
    return provider!.scope;
  }

  @override
  bool updateShouldNotify(DemoAppScopeProvider oldWidget) {
    return oldWidget.scope != scope;
  }
}
