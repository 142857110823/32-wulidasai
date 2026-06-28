class AiCaptureAssistantAdvice {
  const AiCaptureAssistantAdvice({
    required this.qualityStatus,
    required this.retakeRecommended,
    required this.roiSuggestion,
    required this.reasons,
  });

  final String qualityStatus;
  final bool retakeRecommended;
  final String roiSuggestion;
  final List<String> reasons;
}
