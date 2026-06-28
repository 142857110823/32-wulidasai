import 'dart:math' as math;
import 'dart:typed_data';

import 'package:flutter/material.dart';

import '../../core/models/capture_step_bundle.dart';
import '../../routing/app_router.dart';
import '../../shared/widgets/capture_stage_navigation.dart';
import '../../shared/widgets/capture_stage_shell.dart';

class RoiPage extends StatefulWidget {
  const RoiPage({
    super.key,
    this.bundle,
  });

  final CaptureStepBundle? bundle;

  @override
  State<RoiPage> createState() => _RoiPageState();
}

class _RoiPageState extends State<RoiPage> {
  static const double _sceneCm = 4.0;
  late _NormalizedRect _roiRect;
  bool _dirty = false;
  MemoryImage? _roiMemoryImage;

  @override
  void initState() {
    super.initState();
    _roiRect = _roiFromPolygon(
      widget.bundle?.controller?.roiPolygon ?? widget.bundle?.roiPolygon,
    );
    final roiImageBytes = _resolveRoiImageBytes();
    if (roiImageBytes != null && roiImageBytes.isNotEmpty) {
      _roiMemoryImage = MemoryImage(roiImageBytes);
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = widget.bundle?.controller;
    final workflowState =
        controller?.workflowState ?? widget.bundle?.workflowState;
    final confirmed = controller?.roiConfirmed ?? false;
    final roiPolygon = _polygonFromRect(_roiRect);
    final hasRealImage = _roiMemoryImage != null;

    return CaptureStageShell(
      appBarTitle: 'ROI 圈定',
      title: 'ROI 手动圈定',
      subtitle: '拖动选框移动区域，拖动四角调整大小。确认后再进入特征提取。',
      stageLabel: '4 / 7',
      stageTitle: 'ROI',
      tags: [
        '人工交互',
        if (workflowState != null) '阶段 ${workflowState.currentStage}',
      ],
      metrics: [
        CaptureStageMetric(
          label: '状态',
          value: _dirty ? '待确认' : (confirmed ? '已确认' : '未确认'),
          note: _dirty ? 'ROI 已修改，请重新确认。' : '确认后可进入下一步。',
        ),
        CaptureStageMetric(
          label: '边界',
          value: (roiPolygon['within_bounds'] as bool) ? '有效' : '越界',
          note: '建议让 ROI 完整落在图像有效区域内。',
        ),
        CaptureStageMetric(
          label: '图像',
          value: hasRealImage ? '真实图片' : '示例画布',
          note: hasRealImage ? 'ROI 当前直接基于导入图片。' : '尚未检测到可渲染的导入图片。',
        ),
      ],
      children: [
        CaptureStageSectionCard(
          title: '交互画布',
          trailing: Chip(
            label: Text(_dirty ? '已修改' : (confirmed ? '已确认' : '未确认')),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Text(
                  '系统会先给出一个默认 ROI，避免首屏空白，用户可以直接微调。',
                ),
              ),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Text(hasRealImage ? '当前底图：真实图片' : '当前底图：未检测到真实图片'),
              ),
              AspectRatio(
                aspectRatio: 1,
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final size = math.min(
                      constraints.maxWidth,
                      constraints.maxHeight,
                    );
                    final rect = _roiRect.toRect(size, size);

                    return Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFFF4F7F6),
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(
                          color: Theme.of(context).colorScheme.outlineVariant,
                        ),
                      ),
                      child: Stack(
                        children: [
                          Positioned.fill(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(18),
                              child: DecoratedBox(
                                decoration: BoxDecoration(
                                  image: _roiMemoryImage == null
                                      ? null
                                      : DecorationImage(
                                          image: _roiMemoryImage!,
                                          fit: BoxFit.cover,
                                        ),
                                ),
                                child: SizedBox.expand(
                                  key: ValueKey(
                                    hasRealImage
                                        ? 'roi-real-image'
                                        : 'roi-empty-image',
                                  ),
                                ),
                              ),
                            ),
                          ),
                          if (hasRealImage)
                            Positioned.fill(
                              child: DecoratedBox(
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.06),
                                ),
                              ),
                            ),
                          const Positioned.fill(child: _RoiGridBackground()),
                          Positioned(
                            left: rect.left,
                            top: rect.top,
                            child: _MoveRegion(
                              width: rect.width,
                              height: rect.height,
                              onPanUpdate: (details) {
                                setState(() {
                                  _roiRect = _roiRect.translate(
                                    details.delta.dx / size,
                                    details.delta.dy / size,
                                  );
                                  _dirty = true;
                                });
                              },
                            ),
                          ),
                          ..._buildHandleWidgets(size),
                          Positioned(
                            left: 14,
                            right: 14,
                            bottom: 12,
                            child: Text(
                              '拖动选框移动 ROI，拖动四角手柄调整大小。',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  _RoiStatChip(
                    label: '面积',
                    value: '${(roiPolygon['area'] as double).toStringAsFixed(2)} cm2',
                  ),
                  _RoiStatChip(
                    label: '宽度',
                    value:
                        '${(roiPolygon['width_cm'] as double).toStringAsFixed(2)} cm',
                  ),
                  _RoiStatChip(
                    label: '高度',
                    value:
                        '${(roiPolygon['height_cm'] as double).toStringAsFixed(2)} cm',
                  ),
                  _RoiStatChip(
                    label: '中心',
                    value:
                        '${(roiPolygon['center_x'] as double).toStringAsFixed(0)}, ${(roiPolygon['center_y'] as double).toStringAsFixed(0)}',
                  ),
                ],
              ),
            ],
          ),
        ),
        CaptureStageSectionCard(
          title: '当前操作',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _dirty
                    ? '你已经修改了 ROI，请先确认，再进入特征提取。'
                    : (confirmed
                        ? '当前 ROI 已确认，可以直接进入特征提取。'
                        : '先调整 ROI，再点击确认。'),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: _confirmRoi,
                  child: const Text('确认 ROI'),
                ),
              ),
            ],
          ),
        ),
        CaptureStageSectionCard(
          title: 'ROI 摘要',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('边界状态：${(roiPolygon['within_bounds'] as bool) ? '有效' : '越界'}'),
              const SizedBox(height: 6),
              Text(
                '场景尺寸：${_sceneCm.toStringAsFixed(1)} cm × ${_sceneCm.toStringAsFixed(1)} cm',
              ),
              const SizedBox(height: 6),
              const Text('当前版本已支持人工拖拽和确认 ROI，可直接服务采集主链路。'),
            ],
          ),
        ),
        CaptureStageSectionCard(
          title: '阶段导航',
          child: CaptureStageNavigation(
            previousLabel: '返回待测图',
            previousAction: () => Navigator.of(context).pop(),
            nextLabel: '下一步：特征提取',
            nextAction: (controller?.roiConfirmed ?? false) && !_dirty
                ? () => Navigator.of(context).pushNamed(
                      AppRouter.featurePreview,
                      arguments: widget.bundle,
                    )
                : null,
          ),
        ),
      ],
    );
  }

  List<Widget> _buildHandleWidgets(double size) {
    final rect = _roiRect.toRect(size, size);
    final handles = <_HandleSpec>[
      _HandleSpec(
        left: rect.left,
        top: rect.top,
        onDrag: (dx, dy) => _roiRect = _roiRect.resizeFromTopLeft(dx / size, dy / size),
      ),
      _HandleSpec(
        left: rect.right,
        top: rect.top,
        onDrag: (dx, dy) => _roiRect = _roiRect.resizeFromTopRight(dx / size, dy / size),
      ),
      _HandleSpec(
        left: rect.left,
        top: rect.bottom,
        onDrag: (dx, dy) =>
            _roiRect = _roiRect.resizeFromBottomLeft(dx / size, dy / size),
      ),
      _HandleSpec(
        left: rect.right,
        top: rect.bottom,
        onDrag: (dx, dy) =>
            _roiRect = _roiRect.resizeFromBottomRight(dx / size, dy / size),
      ),
    ];

    return handles
        .map(
          (handle) => Positioned(
            left: handle.left - 12,
            top: handle.top - 12,
            child: GestureDetector(
              onPanUpdate: (details) {
                setState(() {
                  handle.onDrag(details.delta.dx, details.delta.dy);
                  _dirty = true;
                });
              },
              child: Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: const Color(0xFF0F766E),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                ),
              ),
            ),
          ),
        )
        .toList(growable: false);
  }

  void _confirmRoi() {
    final roiPolygon = _polygonFromRect(_roiRect);
    widget.bundle?.updateRoiPolygon?.call(roiPolygon);
    widget.bundle?.confirmRoi?.call();
    if (!mounted) {
      return;
    }
    setState(() {
      _dirty = false;
    });
  }

  Uint8List? _resolveRoiImageBytes() {
    final controller = widget.bundle?.controller;
    return controller?.saltedImageBytes ?? controller?.baselineImageBytes;
  }

  _NormalizedRect _roiFromPolygon(Map<String, dynamic>? roiPolygon) {
    final widthCm = ((roiPolygon?['width_cm'] as num?) ?? 2.0).toDouble();
    final heightCm = ((roiPolygon?['height_cm'] as num?) ?? 2.0).toDouble();
    final centerX = ((roiPolygon?['center_x'] as num?) ?? 100.0).toDouble() / 200.0;
    final centerY = ((roiPolygon?['center_y'] as num?) ?? 100.0).toDouble() / 200.0;

    final widthNorm = (widthCm / _sceneCm).clamp(0.18, 0.9);
    final heightNorm = (heightCm / _sceneCm).clamp(0.18, 0.9);

    return _NormalizedRect.fromCenter(
      centerX: centerX.clamp(0.1, 0.9),
      centerY: centerY.clamp(0.1, 0.9),
      width: widthNorm,
      height: heightNorm,
    );
  }

  Map<String, dynamic> _polygonFromRect(_NormalizedRect rect) {
    final widthCm = rect.width * _sceneCm;
    final heightCm = rect.height * _sceneCm;
    final center = rect.center;

    return {
      'area': widthCm * heightCm,
      'width_cm': widthCm,
      'height_cm': heightCm,
      'center_x': center.dx * 200.0,
      'center_y': center.dy * 200.0,
      'within_bounds': rect.left >= 0 &&
          rect.top >= 0 &&
          rect.right <= 1 &&
          rect.bottom <= 1,
    };
  }
}

class _MoveRegion extends StatelessWidget {
  const _MoveRegion({
    required this.width,
    required this.height,
    required this.onPanUpdate,
  });

  final double width;
  final double height;
  final GestureDragUpdateCallback onPanUpdate;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      key: const ValueKey('roi-move-region'),
      onPanUpdate: onPanUpdate,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: const Color(0x220F766E),
          border: Border.all(
            color: const Color(0xFF0F766E),
            width: 2.5,
          ),
          borderRadius: BorderRadius.circular(14),
        ),
      ),
    );
  }
}

class _RoiGridBackground extends StatelessWidget {
  const _RoiGridBackground();

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _GridPainter(
        lineColor: Theme.of(context).colorScheme.outlineVariant,
      ),
      child: const SizedBox.expand(),
    );
  }
}

class _RoiStatChip extends StatelessWidget {
  const _RoiStatChip({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: Theme.of(context).textTheme.bodySmall),
          const SizedBox(height: 4),
          Text(
            value,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
          ),
        ],
      ),
    );
  }
}

class _GridPainter extends CustomPainter {
  const _GridPainter({required this.lineColor});

  final Color lineColor;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = lineColor.withOpacity(0.35)
      ..strokeWidth = 1;

    for (var i = 1; i < 4; i++) {
      final dx = size.width * i / 4;
      final dy = size.height * i / 4;
      canvas.drawLine(Offset(dx, 0), Offset(dx, size.height), paint);
      canvas.drawLine(Offset(0, dy), Offset(size.width, dy), paint);
    }
  }

  @override
  bool shouldRepaint(covariant _GridPainter oldDelegate) {
    return oldDelegate.lineColor != lineColor;
  }
}

class _HandleSpec {
  const _HandleSpec({
    required this.left,
    required this.top,
    required this.onDrag,
  });

  final double left;
  final double top;
  final void Function(double dx, double dy) onDrag;
}

class _NormalizedRect {
  const _NormalizedRect({
    required this.left,
    required this.top,
    required this.right,
    required this.bottom,
  });

  factory _NormalizedRect.fromCenter({
    required double centerX,
    required double centerY,
    required double width,
    required double height,
  }) {
    return _NormalizedRect(
      left: centerX - width / 2,
      top: centerY - height / 2,
      right: centerX + width / 2,
      bottom: centerY + height / 2,
    )._clamp();
  }

  final double left;
  final double top;
  final double right;
  final double bottom;

  double get width => right - left;
  double get height => bottom - top;
  Offset get center => Offset((left + right) / 2, (top + bottom) / 2);

  Rect toRect(double widthPx, double heightPx) {
    return Rect.fromLTRB(
      left * widthPx,
      top * heightPx,
      right * widthPx,
      bottom * heightPx,
    );
  }

  _NormalizedRect translate(double dx, double dy) {
    return _NormalizedRect(
      left: left + dx,
      top: top + dy,
      right: right + dx,
      bottom: bottom + dy,
    )._clamp();
  }

  _NormalizedRect resizeFromTopLeft(double dx, double dy) {
    return _NormalizedRect(
      left: left + dx,
      top: top + dy,
      right: right,
      bottom: bottom,
    )._clamp(minSize: 0.18);
  }

  _NormalizedRect resizeFromTopRight(double dx, double dy) {
    return _NormalizedRect(
      left: left,
      top: top + dy,
      right: right + dx,
      bottom: bottom,
    )._clamp(minSize: 0.18);
  }

  _NormalizedRect resizeFromBottomLeft(double dx, double dy) {
    return _NormalizedRect(
      left: left + dx,
      top: top,
      right: right,
      bottom: bottom + dy,
    )._clamp(minSize: 0.18);
  }

  _NormalizedRect resizeFromBottomRight(double dx, double dy) {
    return _NormalizedRect(
      left: left,
      top: top,
      right: right + dx,
      bottom: bottom + dy,
    )._clamp(minSize: 0.18);
  }

  _NormalizedRect _clamp({double minSize = 0.18}) {
    var newLeft = left.clamp(0.0, 1.0);
    var newTop = top.clamp(0.0, 1.0);
    var newRight = right.clamp(0.0, 1.0);
    var newBottom = bottom.clamp(0.0, 1.0);

    if (newRight - newLeft < minSize) {
      if (newLeft + minSize <= 1.0) {
        newRight = newLeft + minSize;
      } else {
        newLeft = 1.0 - minSize;
        newRight = 1.0;
      }
    }
    if (newBottom - newTop < minSize) {
      if (newTop + minSize <= 1.0) {
        newBottom = newTop + minSize;
      } else {
        newTop = 1.0 - minSize;
        newBottom = 1.0;
      }
    }

    return _NormalizedRect(
      left: newLeft,
      top: newTop,
      right: newRight,
      bottom: newBottom,
    );
  }
}
