import '../models/prediction_result.dart';

class ExportService {
  static const List<String> csvHeaders = [
    'session_id',
    'sample_id',
    'model_id',
    'source_mode',
    'hardware_profile_id',
    'baseline_image_path',
    'salted_image_path',
    'roi_area_cm2',
    'dL',
    'da',
    'db',
    'dS',
    'whiteness_index',
    'specular_ratio',
    'glcm_contrast',
    'glcm_energy',
    'dL2',
    'specular_ratio2',
    'predicted_mg_cm2',
    'unit',
    'confidence_level',
    'result_status',
    'valid_range_min',
    'valid_range_max',
    'warnings',
    'created_at',
  ];

  String generateCsvRow({
    required String sessionId,
    required String sampleId,
    required PredictionResult result,
    required double roiAreaCm2,
    required String baselineImagePath,
    required String saltedImagePath,
  }) {
    final fields = [
      _escape(sessionId),
      _escape(sampleId),
      _escape(result.modelId),
      _escape(result.sourceMode),
      _escape(result.hardwareProfileId),
      _escape(baselineImagePath),
      _escape(saltedImagePath),
      roiAreaCm2.toStringAsFixed(2),
      (result.featureVector['dL'] ?? 0.0).toString(),
      (result.featureVector['da'] ?? 0.0).toString(),
      (result.featureVector['db'] ?? 0.0).toString(),
      (result.featureVector['dS'] ?? 0.0).toString(),
      (result.featureVector['whiteness_index'] ?? 0.0).toString(),
      (result.featureVector['specular_ratio'] ?? 0.0).toString(),
      (result.featureVector['glcm_contrast'] ?? 0.0).toString(),
      (result.featureVector['glcm_energy'] ?? 0.0).toString(),
      (result.featureVector['dL2'] ?? 0.0).toString(),
      (result.featureVector['specular_ratio2'] ?? 0.0).toString(),
      result.predictedValue.toStringAsFixed(4),
      _escape(result.unit),
      _escape(result.confidenceLevel),
      _escape(result.resultStatus),
      result.validRangeMin.toStringAsFixed(4),
      result.validRangeMax.toStringAsFixed(4),
      _escape(result.warnings.join('; ')),
      _escape(result.createdAt.toIso8601String()),
    ];
    return fields.join(',');
  }

  String generateCsv({
    required List<Map<String, dynamic>> sessions,
  }) {
    final buffer = StringBuffer();
    buffer.writeln(csvHeaders.map(_escape).join(','));

    for (final session in sessions) {
      final result = PredictionResult.fromJson(
        Map<String, dynamic>.from(session['result'] as Map? ?? const {}),
      );
      final roiArea = (session['roi_polygon'] as Map?)?['area'] as num? ?? 4.0;
      buffer.writeln(
        generateCsvRow(
          sessionId: session['session_id'] as String,
          sampleId: session['sample_id'] as String,
          result: result,
          roiAreaCm2: roiArea.toDouble(),
          baselineImagePath: session['baseline_image_path'] as String? ?? '',
          saltedImagePath: session['salted_image_path'] as String? ?? '',
        ),
      );
    }

    return buffer.toString();
  }

  String generateReportPreview({
    required String sampleId,
    required PredictionResult result,
    required double roiAreaCm2,
    required String baselineImagePath,
    required String saltedImagePath,
  }) {
    final buffer = StringBuffer()
      ..writeln('=== FreshSalt Surface 模拟报告预览 ===')
      ..writeln('生成时间: ${DateTime.now().toIso8601String()}')
      ..writeln()
      ..writeln('样品信息')
      ..writeln('  样品 ID: $sampleId')
      ..writeln('  ROI 面积: ${roiAreaCm2.toStringAsFixed(2)} cm2')
      ..writeln()
      ..writeln('图像路径')
      ..writeln('  基线图 I0: $baselineImagePath')
      ..writeln('  待测图 I1: $saltedImagePath')
      ..writeln()
      ..writeln('模型信息')
      ..writeln('  模型 ID: ${result.modelId}')
      ..writeln('  数据来源: ${result.sourceMode}')
      ..writeln('  硬件配置: ${result.hardwareProfileId}')
      ..writeln()
      ..writeln('结果信息')
      ..writeln(
        '  预测值: ${result.predictedValue.toStringAsFixed(4)} ${result.unit}',
      )
      ..writeln('  置信等级: ${result.confidenceLevel}')
      ..writeln('  结果状态: ${result.resultStatus}')
      ..writeln('  有效范围: [${result.validRangeMin}, ${result.validRangeMax}]')
      ..writeln()
      ..writeln('特征摘要');

    for (final entry in result.featureVector.entries) {
      buffer.writeln('  ${entry.key}: ${entry.value}');
    }

    if (result.warnings.isNotEmpty) {
      buffer
        ..writeln()
        ..writeln('警告信息');
      for (final warning in result.warnings) {
        buffer.writeln('  - $warning');
      }
    }

    buffer
      ..writeln()
      ..writeln('边界提示')
      ..writeln('  本结果仅用于大学物理实验与方法验证。')
      ..writeln('  不作为食品安全、商品分级或执法检测依据。');

    return buffer.toString();
  }

  String _escape(Object? value) {
    final raw = '$value'.replaceAll('"', '""');
    return '"$raw"';
  }
}
