import '../models/feature_vector.dart';
import '../models/prediction_result.dart';

abstract class SessionRepository {
  Future<void> saveSession({
    required String sessionId,
    required String sampleId,
    required PredictionResult result,
    required FeatureVector featureVector,
    required String baselineImagePath,
    required String saltedImagePath,
    required Map<String, dynamic> roiPolygon,
  });

  Future<Map<String, dynamic>?> getSession(String sessionId);

  Future<List<Map<String, dynamic>>> getAllSessions({
    String? sampleId,
    String? modelId,
    bool? isSimulated,
    DateTime? startDate,
    DateTime? endDate,
  });

  Future<void> deleteSession(String sessionId);

  Future<void> clearAll();
}

class InMemorySessionRepository implements SessionRepository {
  final Map<String, Map<String, dynamic>> _sessionStore = {};

  @override
  Future<void> saveSession({
    required String sessionId,
    required String sampleId,
    required PredictionResult result,
    required FeatureVector featureVector,
    required String baselineImagePath,
    required String saltedImagePath,
    required Map<String, dynamic> roiPolygon,
  }) async {
    _sessionStore[sessionId] = {
      'session_id': sessionId,
      'sample_id': sampleId,
      'result': result.toJson(),
      'feature_vector': featureVector.toJson(),
      'baseline_image_path': baselineImagePath,
      'salted_image_path': saltedImagePath,
      'roi_polygon': roiPolygon,
      'created_at': DateTime.now().toIso8601String(),
      'is_simulated': result.sourceMode == 'simulated',
    };
  }

  @override
  Future<Map<String, dynamic>?> getSession(String sessionId) async {
    return _sessionStore[sessionId];
  }

  @override
  Future<List<Map<String, dynamic>>> getAllSessions({
    String? sampleId,
    String? modelId,
    bool? isSimulated,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final result = _sessionStore.values.where((session) {
      if (sampleId != null && session['sample_id'] != sampleId) {
        return false;
      }
      if (modelId != null &&
          (session['result'] as Map)['model_id'] != modelId) {
        return false;
      }
      if (isSimulated != null && session['is_simulated'] != isSimulated) {
        return false;
      }
      final createdAt = DateTime.parse(session['created_at'] as String);
      if (startDate != null && createdAt.isBefore(startDate)) {
        return false;
      }
      if (endDate != null && createdAt.isAfter(endDate)) {
        return false;
      }
      return true;
    }).toList();

    result.sort(
      (left, right) => DateTime.parse(right['created_at'] as String)
          .compareTo(DateTime.parse(left['created_at'] as String)),
    );
    return result;
  }

  @override
  Future<void> deleteSession(String sessionId) async {
    _sessionStore.remove(sessionId);
  }

  @override
  Future<void> clearAll() async {
    _sessionStore.clear();
  }

  int getSessionCount() => _sessionStore.length;
}
