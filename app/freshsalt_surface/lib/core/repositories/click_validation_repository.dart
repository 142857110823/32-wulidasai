import '../models/click_validation_case.dart';

abstract class ClickValidationRepository {
  Future<void> saveClickLog(ClickValidationLog log);

  Future<List<ClickValidationLog>> getAllClickLogs();

  Future<List<ClickValidationLog>> getClickLogsByModule(String module);

  Future<void> clearAll();
}

class InMemoryClickValidationRepository implements ClickValidationRepository {
  final List<ClickValidationLog> _logs = [];

  @override
  Future<void> saveClickLog(ClickValidationLog log) async {
    _logs.add(log);
  }

  @override
  Future<List<ClickValidationLog>> getAllClickLogs() async {
    return List<ClickValidationLog>.from(_logs);
  }

  @override
  Future<List<ClickValidationLog>> getClickLogsByModule(String module) async {
    return _logs.where((log) => log.module == module).toList();
  }

  @override
  Future<void> clearAll() async {
    _logs.clear();
  }

  Map<String, int> getPassFailSummary() {
    return {
      'total': _logs.length,
      'passed': _logs.where((log) => log.isPassed).length,
      'failed': _logs.where((log) => !log.isPassed).length,
    };
  }
}
