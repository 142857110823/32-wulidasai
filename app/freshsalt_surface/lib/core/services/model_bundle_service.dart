import '../models/model_bundle.dart';

class ModelBundleService {
  ModelBundle? _activeModelBundle;
  final Map<String, ModelBundle> _modelCache = {};

  ModelBundle? get activeModel => _activeModelBundle;

  Future<List<String>> loadModelBundle(ModelBundle bundle) async {
    final validationErrors = bundle.validate();
    if (validationErrors.isNotEmpty) {
      return validationErrors;
    }

    _modelCache[bundle.modelId] = bundle;
    return <String>[];
  }

  Future<List<String>> activateModelBundle(String modelId) async {
    if (!_modelCache.containsKey(modelId)) {
      return <String>['未找到模型包: $modelId'];
    }

    _activeModelBundle = _modelCache[modelId];
    return <String>[];
  }

  void deactivateModelBundle() {
    _activeModelBundle = null;
  }

  List<ModelBundle> getCachedModelBundles() {
    return _modelCache.values.toList();
  }

  bool validateHardwareCompatibility(
    String currentHardwareProfileId,
    ModelBundle bundle,
  ) {
    final requiredProfile = bundle.metadata['hardware_profile_id'] as String?;
    if (requiredProfile == null) {
      return true;
    }
    return currentHardwareProfileId == requiredProfile;
  }

  bool isResultInValidRange(double value, ModelBundle bundle) {
    return value >= bundle.validRange[0] && value <= bundle.validRange[1];
  }
}
