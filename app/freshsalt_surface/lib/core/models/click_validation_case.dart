class ClickValidationCase {
  ClickValidationCase({
    required this.caseId,
    required this.module,
    required this.action,
    required this.mockInput,
    required this.expectedOutput,
    this.assertionRule,
  });

  final String caseId;
  final String module;
  final String action;
  final Map<String, dynamic> mockInput;
  final Map<String, dynamic> expectedOutput;
  final String? assertionRule;

  factory ClickValidationCase.fromJson(Map<String, dynamic> json) {
    return ClickValidationCase(
      caseId: json['case_id'] as String? ?? '',
      module: json['module'] as String? ?? '',
      action: json['action'] as String? ?? '',
      mockInput: Map<String, dynamic>.from(
        json['mock_input'] as Map? ?? const {},
      ),
      expectedOutput: Map<String, dynamic>.from(
        json['expected_output'] as Map? ?? const {},
      ),
      assertionRule: json['assertion_rule'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'case_id': caseId,
      'module': module,
      'action': action,
      'mock_input': mockInput,
      'expected_output': expectedOutput,
      'assertion_rule': assertionRule,
    };
  }
}

class ClickValidationLog {
  ClickValidationLog({
    required this.caseId,
    required this.module,
    required this.mockInput,
    required this.actualOutput,
    required this.expectedOutput,
    required this.result,
    required this.durationMs,
    this.errorMessage,
    this.screenshotPath,
    required this.createdAt,
  });

  final String caseId;
  final String module;
  final Map<String, dynamic> mockInput;
  final Map<String, dynamic> actualOutput;
  final Map<String, dynamic> expectedOutput;
  final String result;
  final int durationMs;
  final String? errorMessage;
  final String? screenshotPath;
  final DateTime createdAt;

  bool get isPassed => result == 'pass';

  factory ClickValidationLog.fromJson(Map<String, dynamic> json) {
    return ClickValidationLog(
      caseId: json['case_id'] as String? ?? '',
      module: json['module'] as String? ?? '',
      mockInput: Map<String, dynamic>.from(
        json['mock_input'] as Map? ?? const {},
      ),
      actualOutput: Map<String, dynamic>.from(
        json['actual_output'] as Map? ?? const {},
      ),
      expectedOutput: Map<String, dynamic>.from(
        json['expected_output'] as Map? ?? const {},
      ),
      result: json['result'] as String? ?? 'fail',
      durationMs: json['duration_ms'] as int? ?? 0,
      errorMessage: json['error_message'] as String?,
      screenshotPath: json['screenshot_path'] as String?,
      createdAt: DateTime.parse(
        json['created_at'] as String? ?? DateTime.now().toIso8601String(),
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'case_id': caseId,
      'module': module,
      'mock_input': mockInput,
      'actual_output': actualOutput,
      'expected_output': expectedOutput,
      'result': result,
      'duration_ms': durationMs,
      'error_message': errorMessage,
      'screenshot_path': screenshotPath,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
