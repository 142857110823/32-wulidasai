class QualityControlResult {
  QualityControlResult({
    required this.status,
    required this.checks,
    required this.metrics,
    required this.failureReasons,
    required this.checkedAt,
  });

  final String status;
  final Map<String, bool> checks;
  final Map<String, dynamic> metrics;
  final List<String> failureReasons;
  final DateTime checkedAt;

  bool get isPassed => status == 'passed';

  factory QualityControlResult.fromJson(Map<String, dynamic> json) {
    return QualityControlResult(
      status: json['status'] as String? ?? 'failed',
      checks: Map<String, bool>.from(json['checks'] as Map? ?? const {}),
      metrics: Map<String, dynamic>.from(json['metrics'] as Map? ?? const {}),
      failureReasons: List<String>.from(
        json['failure_reasons'] as List? ?? const [],
      ),
      checkedAt: DateTime.parse(
        json['checked_at'] as String? ?? DateTime.now().toIso8601String(),
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'checks': checks,
      'metrics': metrics,
      'failure_reasons': failureReasons,
      'checked_at': checkedAt.toIso8601String(),
    };
  }
}
