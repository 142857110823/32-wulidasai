import 'package:flutter/widgets.dart';

import 'app.dart';

Object? _semanticsHandle;

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  _semanticsHandle ??= WidgetsBinding.instance.ensureSemantics();
  runApp(const FreshSaltApp());
}
