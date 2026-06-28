import 'dart:math' as math;
import 'dart:typed_data';

import 'package:image/image.dart' as img;

import '../models/feature_vector.dart';
import '../models/quality_control_result.dart';

class RealImageAnalysisService {
  Future<QualityControlResult> performQualityControl({
    required Uint8List imageBytes,
    double roiAreaCm2 = 4.0,
    bool roiWithinBounds = true,
  }) async {
    final decoded = _decodeImage(imageBytes);
    final grayPatch = _extractGrayCardPatch(decoded);
    final grayValues = _collectGrayValues(grayPatch);
    final saturationRatio = _computeSaturationRatio(decoded);
    final laplacianVariance = _computeSharpness(decoded);
    final grayCardRsd = _computeRelativeStd(grayValues);

    final checks = <String, bool>{
      'exposure': saturationRatio < 0.005,
      'sharpness': laplacianVariance >= 100.0,
      'gray_card_rsd': grayCardRsd <= 0.02,
      'roi_integrity': roiAreaCm2 > 0 && roiWithinBounds,
    };

    final failureReasons = <String>[];
    if (!(checks['exposure'] ?? false)) {
      failureReasons.add(
        '曝光异常：饱和像素比例 ${(saturationRatio * 100).toStringAsFixed(2)}%，高于 0.50% 阈值。',
      );
    }
    if (!(checks['sharpness'] ?? false)) {
      failureReasons.add(
        '清晰度不足：Laplacian variance ${laplacianVariance.toStringAsFixed(2)}，低于 100.00 阈值。',
      );
    }
    if (!(checks['gray_card_rsd'] ?? false)) {
      failureReasons.add(
        '灰卡稳定性不足：RSD ${(grayCardRsd * 100).toStringAsFixed(2)}%，高于 2.00% 阈值。',
      );
    }
    if (!(checks['roi_integrity'] ?? false)) {
      failureReasons.add('ROI 超出有效范围或面积无效，请重新圈定样品区域。');
    }

    return QualityControlResult(
      status: checks.values.every((value) => value) ? 'passed' : 'failed',
      checks: checks,
      metrics: {
        'exposure_saturation_ratio': saturationRatio,
        'laplacian_variance': laplacianVariance,
        'gray_card_rsd': grayCardRsd,
        'roi_area_cm2': roiAreaCm2,
        'roi_within_bounds': roiWithinBounds,
        'source_mode': 'real_image_pixels',
      },
      failureReasons: failureReasons,
      checkedAt: DateTime.now(),
    );
  }

  Future<FeatureVector> extractFeatures({
    required String sessionId,
    required Uint8List baselineImageBytes,
    required Uint8List saltedImageBytes,
  }) async {
    final baseline = _extractCentralStats(_decodeImage(baselineImageBytes));
    final salted = _extractCentralStats(_decodeImage(saltedImageBytes));
    final luminanceDelta = salted.luminance - baseline.luminance;
    final saturationDelta = salted.saturation - baseline.saturation;
    final specularDelta = salted.specularRatio - baseline.specularRatio;

    final features = <String, double>{
      'dL': luminanceDelta,
      'da': salted.meanR - baseline.meanR,
      'db': salted.meanB - baseline.meanB,
      'dS': saturationDelta,
      'whiteness_index': salted.whitenessIndex,
      'specular_ratio': salted.specularRatio,
      'glcm_contrast': salted.textureContrast,
      'glcm_energy': salted.histogramEnergy,
      'dL2': luminanceDelta * luminanceDelta,
      'specular_ratio2': specularDelta * specularDelta,
    };

    return FeatureVector(
      sessionId: sessionId,
      features: features,
      metadata: {
        'extraction_method': 'real_image_pixels',
        'roi_source': 'center_crop',
      },
      extractedAt: DateTime.now(),
    );
  }

  img.Image _decodeImage(Uint8List bytes) {
    final decoded = img.decodeImage(bytes);
    if (decoded == null) {
      throw Exception('无法解码所选图片，请使用 PNG 或 JPG 文件。');
    }
    return decoded;
  }

  img.Image _extractGrayCardPatch(img.Image image) {
    final width = math.max(8, image.width ~/ 6);
    final height = math.max(8, image.height ~/ 6);
    final x = math.max(0, image.width - width - 4);
    const y = 4;
    return img.copyCrop(image, x: x, y: y, width: width, height: height);
  }

  _RegionStats _extractCentralStats(img.Image image) {
    final cropWidth = math.max(16, image.width ~/ 2);
    final cropHeight = math.max(16, image.height ~/ 2);
    final x = math.max(0, (image.width - cropWidth) ~/ 2);
    final y = math.max(0, (image.height - cropHeight) ~/ 2);
    final roi = img.copyCrop(image, x: x, y: y, width: cropWidth, height: cropHeight);

    var count = 0;
    var sumR = 0.0;
    var sumG = 0.0;
    var sumB = 0.0;
    var sumL = 0.0;
    var sumS = 0.0;
    var brightPixels = 0;
    final histogram = List<double>.filled(16, 0);
    var textureContrastAcc = 0.0;

    for (var yIndex = 0; yIndex < roi.height; yIndex++) {
      for (var xIndex = 0; xIndex < roi.width; xIndex++) {
        final pixel = roi.getPixel(xIndex, yIndex);
        final r = pixel.r.toDouble();
        final g = pixel.g.toDouble();
        final b = pixel.b.toDouble();
        final maxRgb = math.max(r, math.max(g, b));
        final minRgb = math.min(r, math.min(g, b));
        final luminance = 0.2126 * r + 0.7152 * g + 0.0722 * b;
        final saturation = maxRgb <= 0 ? 0.0 : (maxRgb - minRgb) / maxRgb;
        final whiteness = (r + g + b) / (3 * 255.0);

        sumR += r / 255.0;
        sumG += g / 255.0;
        sumB += b / 255.0;
        sumL += luminance / 255.0;
        sumS += saturation;
        if (maxRgb >= 245) {
          brightPixels++;
        }

        final bin = math.min(15, (whiteness * 15).floor());
        histogram[bin] += 1;

        if (xIndex + 1 < roi.width) {
          final next = roi.getPixel(xIndex + 1, yIndex);
          final nextLum =
              (0.2126 * next.r + 0.7152 * next.g + 0.0722 * next.b) / 255.0;
          final delta = (luminance / 255.0) - nextLum;
          textureContrastAcc += delta * delta;
        }
        count++;
      }
    }

    final normalizedHistogram = histogram.map((item) => item / count).toList();
    final histogramEnergy = normalizedHistogram.fold<double>(
      0,
      (sum, value) => sum + value * value,
    );

    return _RegionStats(
      meanR: sumR / count,
      meanG: sumG / count,
      meanB: sumB / count,
      luminance: sumL / count,
      saturation: sumS / count,
      whitenessIndex: (sumR + sumG + sumB) / (3 * count),
      specularRatio: brightPixels / count,
      textureContrast: textureContrastAcc / count,
      histogramEnergy: histogramEnergy,
    );
  }

  double _computeSaturationRatio(img.Image image) {
    var saturated = 0;
    final total = image.width * image.height;
    for (var y = 0; y < image.height; y++) {
      for (var x = 0; x < image.width; x++) {
        final pixel = image.getPixel(x, y);
        if (pixel.r >= 250 || pixel.g >= 250 || pixel.b >= 250) {
          saturated++;
        }
      }
    }
    return total == 0 ? 0.0 : saturated / total;
  }

  double _computeSharpness(img.Image image) {
    final gray = List<double>.filled(image.width * image.height, 0.0);
    for (var y = 0; y < image.height; y++) {
      for (var x = 0; x < image.width; x++) {
        final pixel = image.getPixel(x, y);
        gray[y * image.width + x] =
            0.2126 * pixel.r + 0.7152 * pixel.g + 0.0722 * pixel.b;
      }
    }

    final laplacian = <double>[];
    for (var y = 1; y < image.height - 1; y++) {
      for (var x = 1; x < image.width - 1; x++) {
        final center = gray[y * image.width + x];
        final up = gray[(y - 1) * image.width + x];
        final down = gray[(y + 1) * image.width + x];
        final left = gray[y * image.width + x - 1];
        final right = gray[y * image.width + x + 1];
        laplacian.add((4 * center) - up - down - left - right);
      }
    }

    if (laplacian.isEmpty) {
      return 0.0;
    }
    final mean = laplacian.reduce((a, b) => a + b) / laplacian.length;
    final variance = laplacian.fold<double>(
          0.0,
          (sum, value) => sum + math.pow(value - mean, 2),
        ) /
        laplacian.length;
    return variance;
  }

  List<double> _collectGrayValues(img.Image patch) {
    final values = <double>[];
    for (var y = 0; y < patch.height; y++) {
      for (var x = 0; x < patch.width; x++) {
        final pixel = patch.getPixel(x, y);
        values.add((0.2126 * pixel.r + 0.7152 * pixel.g + 0.0722 * pixel.b) / 255.0);
      }
    }
    return values;
  }

  double _computeRelativeStd(List<double> values) {
    if (values.isEmpty) {
      return 1.0;
    }
    final mean = values.reduce((a, b) => a + b) / values.length;
    if (mean == 0) {
      return 1.0;
    }
    final variance = values.fold<double>(
          0.0,
          (sum, value) => sum + math.pow(value - mean, 2),
        ) /
        values.length;
    return math.sqrt(variance) / mean;
  }
}

class _RegionStats {
  const _RegionStats({
    required this.meanR,
    required this.meanG,
    required this.meanB,
    required this.luminance,
    required this.saturation,
    required this.whitenessIndex,
    required this.specularRatio,
    required this.textureContrast,
    required this.histogramEnergy,
  });

  final double meanR;
  final double meanG;
  final double meanB;
  final double luminance;
  final double saturation;
  final double whitenessIndex;
  final double specularRatio;
  final double textureContrast;
  final double histogramEnergy;
}
