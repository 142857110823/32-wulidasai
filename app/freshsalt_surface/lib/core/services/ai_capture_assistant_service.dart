import '../models/ai_capture_assistant_advice.dart';
import '../models/quality_control_result.dart';

class AiCaptureAssistantService {
  const AiCaptureAssistantService();

  AiCaptureAssistantAdvice? build({
    required bool hasImportedRealImages,
    required QualityControlResult? qualityControlResult,
    required Map<String, dynamic>? roiPolygon,
  }) {
    if (!hasImportedRealImages) {
      return null;
    }

    final roiSuggestion = _buildRoiSuggestion(roiPolygon);
    if (qualityControlResult == null) {
      return AiCaptureAssistantAdvice(
        qualityStatus: '待分析',
        retakeRecommended: false,
        roiSuggestion: roiSuggestion,
        reasons: const [
          '已接收真实图片，等待完成图像质控分析。',
        ],
      );
    }

    final reasons = _buildReasons(qualityControlResult);
    return AiCaptureAssistantAdvice(
      qualityStatus: qualityControlResult.isPassed ? '可继续' : '建议补采',
      retakeRecommended: !qualityControlResult.isPassed,
      roiSuggestion: roiSuggestion,
      reasons: reasons,
    );
  }

  List<String> _buildReasons(QualityControlResult result) {
    final checks = result.checks;
    final reasons = <String>[];

    if (!(checks['exposure'] ?? true)) {
      reasons.add('高光过强或曝光异常，建议降低高光并保持补光均匀。');
    }
    if (!(checks['sharpness'] ?? true)) {
      reasons.add('画面偏虚或边缘不清晰，建议固定机位后重新采集。');
    }
    if (!(checks['gray_card_rsd'] ?? true)) {
      reasons.add('灰卡区域不稳定或不清晰，建议重新摆放并确保灰卡完整可见。');
    }
    if (!(checks['roi_integrity'] ?? true)) {
      reasons.add('样品区域偏移或 ROI 越界，建议重新调整选区。');
    }

    if (reasons.isEmpty) {
      reasons.add('曝光、清晰度和灰卡状态均可接受，可继续进入 ROI 与特征提取。');
    }

    return reasons;
  }

  String _buildRoiSuggestion(Map<String, dynamic>? roiPolygon) {
    if (roiPolygon == null || roiPolygon.isEmpty) {
      return '建议先使用中心 ROI，覆盖样品主体区域。';
    }

    final withinBounds = roiPolygon['within_bounds'] as bool? ?? true;
    final centerX = (roiPolygon['center_x'] as num?)?.toDouble() ?? 100.0;
    final centerY = (roiPolygon['center_y'] as num?)?.toDouble() ?? 100.0;
    final widthCm = (roiPolygon['width_cm'] as num?)?.toDouble() ?? 2.0;
    final heightCm = (roiPolygon['height_cm'] as num?)?.toDouble() ?? 2.0;

    if (!withinBounds) {
      return '建议将 ROI 拉回样品中央，避免越界，并保持约 ${widthCm.toStringAsFixed(1)} x ${heightCm.toStringAsFixed(1)} cm。';
    }

    final dx = centerX - 100.0;
    final dy = centerY - 100.0;
    if (dx.abs() <= 18 && dy.abs() <= 18) {
      return '当前 ROI 基本位于样品中央，可保持约 ${widthCm.toStringAsFixed(1)} x ${heightCm.toStringAsFixed(1)} cm。';
    }

    final horizontal = dx > 18
        ? '向左微调'
        : (dx < -18 ? '向右微调' : '保持水平位置');
    final vertical = dy > 18
        ? '向上微调'
        : (dy < -18 ? '向下微调' : '保持垂直位置');
    return 'AI 建议 ROI：$horizontal，$vertical，并继续覆盖样品主体区域。';
  }
}
