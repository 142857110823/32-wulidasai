import '../models/click_validation_case.dart';
import '../repositories/click_validation_repository.dart';

class ClickValidationService {
  ClickValidationService({required this.repository});

  final ClickValidationRepository repository;

  Future<ClickValidationLog> executeClickCase({
    required ClickValidationCase testCase,
    required Future<Map<String, dynamic>> Function(Map<String, dynamic>)
        mockServiceCall,
  }) async {
    final startTime = DateTime.now();

    try {
      final actualOutput = await mockServiceCall(testCase.mockInput);
      final passed = _performAssertion(
        expectedOutput: testCase.expectedOutput,
        actualOutput: actualOutput,
      );

      final log = ClickValidationLog(
        caseId: testCase.caseId,
        module: testCase.module,
        mockInput: testCase.mockInput,
        actualOutput: actualOutput,
        expectedOutput: testCase.expectedOutput,
        result: passed ? 'pass' : 'fail',
        durationMs: DateTime.now().difference(startTime).inMilliseconds,
        errorMessage: passed
            ? null
            : _generateErrorMessage(
                expected: testCase.expectedOutput,
                actual: actualOutput,
              ),
        createdAt: DateTime.now(),
      );

      await repository.saveClickLog(log);
      return log;
    } catch (error) {
      final log = ClickValidationLog(
        caseId: testCase.caseId,
        module: testCase.module,
        mockInput: testCase.mockInput,
        actualOutput: const {},
        expectedOutput: testCase.expectedOutput,
        result: 'fail',
        durationMs: DateTime.now().difference(startTime).inMilliseconds,
        errorMessage: '执行异常: $error',
        createdAt: DateTime.now(),
      );
      await repository.saveClickLog(log);
      return log;
    }
  }

  Future<Map<String, dynamic>> executeFullChain(
    List<ClickValidationCase> testCases,
    Future<Map<String, dynamic>> Function(String, Map<String, dynamic>)
        moduleServiceCall,
  ) async {
    final logs = <ClickValidationLog>[];
    final startTime = DateTime.now();

    for (final testCase in testCases) {
      try {
        final actualOutput = await moduleServiceCall(
          testCase.module,
          testCase.mockInput,
        );
        final passed = _performAssertion(
          expectedOutput: testCase.expectedOutput,
          actualOutput: actualOutput,
        );
        logs.add(
          ClickValidationLog(
            caseId: testCase.caseId,
            module: testCase.module,
            mockInput: testCase.mockInput,
            actualOutput: actualOutput,
            expectedOutput: testCase.expectedOutput,
            result: passed ? 'pass' : 'fail',
            durationMs: 0,
            errorMessage: passed
                ? null
                : _generateErrorMessage(
                    expected: testCase.expectedOutput,
                    actual: actualOutput,
                  ),
            createdAt: DateTime.now(),
          ),
        );
      } catch (error) {
        logs.add(
          ClickValidationLog(
            caseId: testCase.caseId,
            module: testCase.module,
            mockInput: testCase.mockInput,
            actualOutput: const {},
            expectedOutput: testCase.expectedOutput,
            result: 'fail',
            durationMs: 0,
            errorMessage: '执行异常: $error',
            createdAt: DateTime.now(),
          ),
        );
      }
    }

    for (final log in logs) {
      await repository.saveClickLog(log);
    }

    return {
      'total': logs.length,
      'passed': logs.where((log) => log.isPassed).length,
      'failed': logs.where((log) => !log.isPassed).length,
      'total_duration_ms': DateTime.now().difference(startTime).inMilliseconds,
      'logs': logs
          .map(
            (log) => {
              'case_id': log.caseId,
              'module': log.module,
              'actual_output': log.actualOutput,
              'result': log.result,
              'error_message': log.errorMessage,
            },
          )
          .toList(),
    };
  }

  bool _performAssertion({
    required Map<String, dynamic> expectedOutput,
    required Map<String, dynamic> actualOutput,
  }) {
    for (final key in expectedOutput.keys) {
      if (!actualOutput.containsKey(key)) {
        return false;
      }
      if (actualOutput[key] != expectedOutput[key]) {
        return false;
      }
    }
    return true;
  }

  String _generateErrorMessage({
    required Map<String, dynamic> expected,
    required Map<String, dynamic> actual,
  }) {
    final diffs = <String>[];
    for (final key in expected.keys) {
      if (!actual.containsKey(key)) {
        diffs.add('缺少字段: $key');
      } else if (actual[key] != expected[key]) {
        diffs.add('$key 期望 ${expected[key]}，实际 ${actual[key]}');
      }
    }
    return diffs.isEmpty ? '断言失败' : diffs.join('; ');
  }
}
