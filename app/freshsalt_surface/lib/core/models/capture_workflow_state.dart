class CaptureWorkflowState {
  const CaptureWorkflowState({
    this.qualityControlPassed = false,
    this.baselineReady = false,
    this.saltedReady = false,
    this.roiConfirmed = false,
    this.predictionReady = false,
    this.saved = false,
  });

  final bool qualityControlPassed;
  final bool baselineReady;
  final bool saltedReady;
  final bool roiConfirmed;
  final bool predictionReady;
  final bool saved;

  int get currentStage {
    if (saved) {
      return 6;
    }
    if (predictionReady) {
      return 5;
    }
    if (roiConfirmed) {
      return 5;
    }
    if (saltedReady) {
      return 4;
    }
    if (baselineReady) {
      return 3;
    }
    if (qualityControlPassed) {
      return 2;
    }
    return 1;
  }

  String get nextStageLabel {
    switch (currentStage) {
      case 1:
        return '开始质控';
      case 2:
        return '使用模拟 I0';
      case 3:
        return '使用模拟 I1';
      case 4:
        return '确认 ROI';
      case 5:
        return predictionReady ? '保存并查看结果' : '开始演示预测';
      case 6:
      default:
        return '保存并查看结果';
    }
  }

  bool get canUseBaseline => qualityControlPassed;
  bool get canUseSalted => baselineReady;
  bool get canConfirmRoi => saltedReady;
  bool get canRunPrediction => roiConfirmed;
  bool get canSave => predictionReady && !saved;
  bool get canOpenQualityDetail => qualityControlPassed;
  bool get canOpenFeatureDetail => predictionReady;
  bool get canOpenPredictionDetail => predictionReady;

  List<String> get lockedStages {
    final locked = <String>[];
    if (!canUseBaseline) {
      locked.add('I0 基线图');
    }
    if (!canUseSalted) {
      locked.add('I1 待测图');
    }
    if (!canConfirmRoi) {
      locked.add('ROI');
    }
    if (!canRunPrediction) {
      locked.add('特征与结果');
    }
    if (!canSave) {
      locked.add('保存');
    }
    return locked;
  }
}
