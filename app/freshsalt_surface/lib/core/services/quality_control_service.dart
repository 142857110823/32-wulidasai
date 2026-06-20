import '../models/quality_control_result.dart';

class QualityControlService {
  static const double _exposureThreshold = 0.005;
  static const double _sharpnessThreshold = 100.0;
  static const double _grayCardRsdThreshold = 0.02;

  Future<QualityControlResult> performQualityControl({
    required Map<String, dynamic> imageMetadata,
  }) async {
    final checks = <String, bool>{};
    final metrics = <String, dynamic>{};
    final failureReasons = <String>[];

    final exposurePass = _checkExposure(imageMetadata);
    checks['exposure'] = exposurePass;
    metrics['exposure_saturation_ratio'] =
        imageMetadata['saturation_ratio'] ?? 0.0;
    if (!exposurePass) {
      failureReasons.add(
        '过曝：饱和像素比例 ${((imageMetadata['saturation_ratio'] as num? ?? 0.0) * 100).toStringAsFixed(2)}% 超过阈值 ${(100 * _exposureThreshold).toStringAsFixed(2)}%',
      );
    }

    final sharpnessPass = _checkSharpness(imageMetadata);
    checks['sharpness'] = sharpnessPass;
    metrics['laplacian_variance'] = imageMetadata['laplacian_variance'] ?? 0.0;
    if (!sharpnessPass) {
      failureReasons.add(
        '清晰度不足：Laplacian variance ${((imageMetadata['laplacian_variance'] as num?) ?? 0.0).toStringAsFixed(2)} 低于阈值 ${_sharpnessThreshold.toStringAsFixed(2)}',
      );
    }

    final grayCardPass = _checkGrayCardRsd(imageMetadata);
    checks['gray_card_rsd'] = grayCardPass;
    metrics['gray_card_rsd'] = imageMetadata['gray_card_rsd'] ?? 0.0;
    if (!grayCardPass) {
      failureReasons.add(
        '灰卡稳定性不足：RSD ${((imageMetadata['gray_card_rsd'] as num? ?? 0.0) * 100).toStringAsFixed(2)}% 超过阈值 ${(100 * _grayCardRsdThreshold).toStringAsFixed(2)}%',
      );
    }

    final roiPass = _checkRoiIntegrity(imageMetadata);
    checks['roi_integrity'] = roiPass;
    metrics['roi_area_cm2'] = imageMetadata['roi_area_cm2'] ?? 0.0;
    metrics['roi_within_bounds'] = imageMetadata['roi_within_bounds'] ?? false;
    if (!roiPass) {
      if ((imageMetadata['roi_area_cm2'] as num? ?? 0.0) <= 0) {
        failureReasons.add('ROI 面积必须大于 0');
      }
      if ((imageMetadata['roi_within_bounds'] as bool? ?? false) == false) {
        failureReasons.add('ROI 超出图像边界');
      }
    }

    return QualityControlResult(
      status: checks.values.every((value) => value) ? 'passed' : 'failed',
      checks: checks,
      metrics: metrics,
      failureReasons: failureReasons,
      checkedAt: DateTime.now(),
    );
  }

  bool _checkExposure(Map<String, dynamic> metadata) {
    return (metadata['saturation_ratio'] as num? ?? 0.0) < _exposureThreshold;
  }

  bool _checkSharpness(Map<String, dynamic> metadata) {
    return (metadata['laplacian_variance'] as num? ?? 0.0) >=
        _sharpnessThreshold;
  }

  bool _checkGrayCardRsd(Map<String, dynamic> metadata) {
    return (metadata['gray_card_rsd'] as num? ?? 0.0) <= _grayCardRsdThreshold;
  }

  bool _checkRoiIntegrity(Map<String, dynamic> metadata) {
    return (metadata['roi_area_cm2'] as num? ?? 0.0) > 0 &&
        (metadata['roi_within_bounds'] as bool? ?? false);
  }
}
