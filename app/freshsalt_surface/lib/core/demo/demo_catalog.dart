import '../models/model_bundle.dart';
import 'demo_app_scope.dart';
import 'demo_capture_case.dart';

const demoHardwareProfileId = 'darkbox_v1';

final demoModelBundleJson = <String, dynamic>{
  'model_id': 'freshsalt_rgb_cucumber_darkbox_v1',
  'source': 'simulated',
  'sample_type': 'cucumber',
  'target': 'surface_NaCl_load_mg_cm2',
  'unit': 'mg/cm2 NaCl eq.',
  'valid_range_mg_cm2': [0.0, 0.75],
  'feature_order': [
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
  ],
  'coefficients': [
    0.018,
    -0.003,
    0.002,
    -0.011,
    0.21,
    0.15,
    0.006,
    -0.004,
    -0.0002,
    -0.03,
  ],
  'intercept': 0.01,
  'warnings': ['模拟模型仅用于交互验证，不代表真实性能'],
  'metadata': {'hardware_profile_id': demoHardwareProfileId},
};

final demoImageMetadataLow = <String, dynamic>{
  'saturation_ratio': 0.002,
  'laplacian_variance': 150.0,
  'gray_card_rsd': 0.01,
  'roi_area_cm2': 4.0,
  'roi_within_bounds': true,
  'color_dL': -2.5,
  'color_da': 1.2,
  'color_db': 0.8,
  'color_dS': -0.5,
  'whiteness_index': 0.08,
  'specular_ratio': 0.05,
  'glcm_contrast': 0.12,
  'glcm_energy': 0.85,
  'dL2': 6.25,
  'specular_ratio2': 0.0025,
  'roi_source': 'demo_case_low',
};

final demoImageMetadataMedium = <String, dynamic>{
  'saturation_ratio': 0.003,
  'laplacian_variance': 155.0,
  'gray_card_rsd': 0.012,
  'roi_area_cm2': 4.0,
  'roi_within_bounds': true,
  'color_dL': -8.5,
  'color_da': 3.5,
  'color_db': 2.1,
  'color_dS': -1.8,
  'whiteness_index': 0.24,
  'specular_ratio': 0.18,
  'glcm_contrast': 0.28,
  'glcm_energy': 0.78,
  'dL2': 72.25,
  'specular_ratio2': 0.0324,
  'roi_source': 'demo_case_medium',
};

final demoImageMetadataHigh = <String, dynamic>{
  'saturation_ratio': 0.004,
  'laplacian_variance': 160.0,
  'gray_card_rsd': 0.015,
  'roi_area_cm2': 4.0,
  'roi_within_bounds': true,
  'color_dL': -15.2,
  'color_da': 6.8,
  'color_db': 4.5,
  'color_dS': -3.5,
  'whiteness_index': 0.45,
  'specular_ratio': 0.32,
  'glcm_contrast': 0.48,
  'glcm_energy': 0.68,
  'dL2': 231.04,
  'specular_ratio2': 0.1024,
  'roi_source': 'demo_case_high',
};

final demoImageMetadataOverexposed = <String, dynamic>{
  'saturation_ratio': 0.008,
  'laplacian_variance': 150.0,
  'gray_card_rsd': 0.01,
  'roi_area_cm2': 4.0,
  'roi_within_bounds': true,
  'color_dL': -5.0,
  'color_da': 2.0,
  'color_db': 1.5,
  'color_dS': -1.0,
  'whiteness_index': 0.12,
  'specular_ratio': 0.08,
  'glcm_contrast': 0.15,
  'glcm_energy': 0.82,
  'dL2': 25.0,
  'specular_ratio2': 0.0064,
  'roi_source': 'demo_case_overexposed',
};

final demoRoiPolygon = <String, dynamic>{
  'area': 4.0,
  'width_cm': 2.0,
  'height_cm': 2.0,
  'center_x': 100.0,
  'center_y': 100.0,
  'within_bounds': true,
};

final demoCaptureCases = <DemoCaptureCase>[
  DemoCaptureCase(
    id: 'low',
    title: '低负载 0.05',
    subtitle: '低盐覆盖，用于验证基础链路。',
    sampleId: 'sample_demo_low',
    baselineImagePath: '/mock/baseline_low.png',
    saltedImagePath: '/mock/salted_low.png',
    imageMetadata: demoImageMetadataLow,
  ),
  DemoCaptureCase(
    id: 'medium',
    title: '中负载 0.35',
    subtitle: '标准演示案例，预期稳定通过。',
    sampleId: 'sample_demo_medium',
    baselineImagePath: '/mock/baseline_medium.png',
    saltedImagePath: '/mock/salted_medium.png',
    imageMetadata: demoImageMetadataMedium,
  ),
  DemoCaptureCase(
    id: 'high',
    title: '高负载 0.70',
    subtitle: '接近模型上限，结果应显示预警。',
    sampleId: 'sample_demo_high',
    baselineImagePath: '/mock/baseline_high.png',
    saltedImagePath: '/mock/salted_high.png',
    imageMetadata: demoImageMetadataHigh,
  ),
  DemoCaptureCase(
    id: 'overexposed',
    title: '过曝异常',
    subtitle: '质控失败案例，必须阻断结果生成。',
    sampleId: 'sample_demo_overexposed',
    baselineImagePath: '/mock/baseline_overexposed.png',
    saltedImagePath: '/mock/salted_overexposed.png',
    imageMetadata: demoImageMetadataOverexposed,
  ),
];

ModelBundle buildDemoModelBundle() {
  return ModelBundle.fromJson(demoModelBundleJson);
}

Future<AppScope> buildRuntimeDemoScope() {
  return AppScope.demo(
    bundle: buildDemoModelBundle(),
    hardwareProfileId: demoHardwareProfileId,
    captureCases: demoCaptureCases,
    roiPolygon: demoRoiPolygon,
  );
}
