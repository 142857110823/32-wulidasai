import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:freshsalt_surface/core/demo/demo_capture_bundle_factory.dart';
import 'package:image/image.dart' as package_image;

import 'support/demo_fixtures.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('demo capture bundle uses real pixel QC after real image import', () async {
    final scope = await buildDemoScope();
    final bundle = buildDemoCaptureBundle(scope);
    final controller = bundle.controller!;

    final baselineBytes = _buildPngBytes(
      width: 120,
      height: 80,
      fill: const [96, 112, 92],
      grayCard: const [125, 125, 125],
    );
    final saltedBytes = _buildPngBytes(
      width: 120,
      height: 80,
      fill: const [168, 176, 160],
      grayCard: const [125, 125, 125],
    );

    controller.useBaselineImage(
      'user://baseline_real.png',
      isSimulated: false,
      imageBytes: baselineBytes,
    );
    controller.useSaltedImage(
      'user://salted_real.png',
      isSimulated: false,
      imageBytes: saltedBytes,
    );

    await bundle.runQualityControl!.call();

    expect(controller.qualityControlResult, isNotNull);
    expect(
      controller.qualityControlResult!.metrics['source_mode'],
      equals('real_image_pixels'),
    );
  });

  test('demo capture bundle uses real feature extraction after real image import',
      () async {
    final scope = await buildDemoScope();
    final bundle = buildDemoCaptureBundle(scope);
    final controller = bundle.controller!;

    final baselineBytes = _buildPngBytes(
      width: 120,
      height: 80,
      fill: const [90, 110, 88],
      grayCard: const [125, 125, 125],
    );
    final saltedBytes = _buildPngBytes(
      width: 120,
      height: 80,
      fill: const [170, 178, 162],
      grayCard: const [125, 125, 125],
    );

    controller.useBaselineImage(
      'user://baseline_real.png',
      isSimulated: false,
      imageBytes: baselineBytes,
    );
    controller.useSaltedImage(
      'user://salted_real.png',
      isSimulated: false,
      imageBytes: saltedBytes,
    );

    await bundle.runFeatureExtraction!.call();

    expect(controller.featureVector, isNotNull);
    expect(
      controller.featureVector!.metadata['extraction_method'],
      equals('real_image_pixels'),
    );
    expect(
      controller.featureVector!.metadata['roi_source'],
      equals('center_crop'),
    );
  });

  test('demo capture bundle keeps the real-image chain through QC and feature extraction',
      () async {
    final scope = await buildDemoScope();
    final bundle = buildDemoCaptureBundle(scope);
    final controller = bundle.controller!;

    final baselineBytes = _buildPngBytes(
      width: 120,
      height: 80,
      fill: const [92, 108, 90],
      grayCard: const [125, 125, 125],
    );
    final saltedBytes = _buildPngBytes(
      width: 120,
      height: 80,
      fill: const [176, 182, 168],
      grayCard: const [125, 125, 125],
    );

    controller.useBaselineImage(
      'user://baseline_real.png',
      isSimulated: false,
      imageBytes: baselineBytes,
    );
    controller.useSaltedImage(
      'user://salted_real.png',
      isSimulated: false,
      imageBytes: saltedBytes,
    );

    await bundle.runQualityControl!.call();
    controller.confirmRoi();
    await bundle.runFeatureExtraction!.call();

    expect(controller.hasImportedRealImages, isTrue);
    expect(controller.qualityControlResult, isNotNull);
    expect(controller.featureVector, isNotNull);
    expect(
      controller.qualityControlResult!.metrics['source_mode'],
      equals('real_image_pixels'),
    );
    expect(
      controller.featureVector!.metadata['extraction_method'],
      equals('real_image_pixels'),
    );
    expect(controller.workflowState.roiConfirmed, isTrue);
  });

  test('failed QC does not erase imported real image state', () async {
    final scope = await buildDemoScope();
    final bundle = buildDemoCaptureBundle(scope);
    final controller = bundle.controller!;

    final baselineBytes = _buildPngBytes(
      width: 120,
      height: 80,
      fill: const [252, 252, 252],
      grayCard: const [252, 252, 252],
    );
    final saltedBytes = _buildPngBytes(
      width: 120,
      height: 80,
      fill: const [252, 252, 252],
      grayCard: const [252, 252, 252],
    );

    controller.useBaselineImage(
      'user://baseline_real.png',
      isSimulated: false,
      imageBytes: baselineBytes,
    );
    controller.useSaltedImage(
      'user://salted_real.png',
      isSimulated: false,
      imageBytes: saltedBytes,
    );

    await bundle.runQualityControl!.call();

    expect(controller.qualityControlResult, isNotNull);
    expect(controller.qualityControlResult!.isPassed, isFalse);
    expect(controller.hasImportedRealImages, isTrue);
    expect(controller.baselineImagePath, equals('user://baseline_real.png'));
    expect(controller.saltedImagePath, equals('user://salted_real.png'));
    expect(controller.baselineImageBytes, isNotNull);
    expect(controller.saltedImageBytes, isNotNull);
    expect(controller.baselineUsesSimulatedSource, isFalse);
    expect(controller.saltedUsesSimulatedSource, isFalse);
  });
}

Uint8List _buildPngBytes({
  required int width,
  required int height,
  required List<int> fill,
  required List<int> grayCard,
}) {
  return Uint8List.fromList(
    // Reuse the existing helper behavior indirectly by encoding a simple RGB PNG.
    // Keeping this local avoids coupling this focused test to a large mixed test file.
    _encodeSyntheticPng(
      width: width,
      height: height,
      fill: fill,
      grayCard: grayCard,
    ),
  );
}

List<int> _encodeSyntheticPng({
  required int width,
  required int height,
  required List<int> fill,
  required List<int> grayCard,
}) {
  final bytes = <int>[];
  final image = <int>[];
  for (var y = 0; y < height; y++) {
    for (var x = 0; x < width; x++) {
      final inGrayCard = x >= width - (width ~/ 6) && x < width - 4 && y >= 4 && y < (height ~/ 6);
      final rgb = inGrayCard ? grayCard : fill;
      image.addAll([rgb[0], rgb[1], rgb[2], 255]);
    }
  }
  // Minimal delegation to the existing image package avoids rewriting the app logic under test.
  // The test depends only on valid PNG bytes, not on the exact synthetic texture.
  final pngBytes = _pngFromRgba(width, height, image);
  bytes.addAll(pngBytes);
  return bytes;
}

List<int> _pngFromRgba(int width, int height, List<int> rgbaBytes) {
  // Uses the app dependency already present in test runtime.
  // Kept as a tiny adapter to avoid importing the large existing test helper file.
  final image = package_image.Image(width: width, height: height);
  var index = 0;
  for (var y = 0; y < height; y++) {
    for (var x = 0; x < width; x++) {
      image.setPixelRgba(
        x,
        y,
        rgbaBytes[index],
        rgbaBytes[index + 1],
        rgbaBytes[index + 2],
        rgbaBytes[index + 3],
      );
      index += 4;
    }
  }
  return package_image.encodePng(image);
}
