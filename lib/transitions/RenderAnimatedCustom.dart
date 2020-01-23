import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

/// A custom renderer, based on RenderAnimatedOpacity: https://github.com/flutter/flutter/blob/27321ebbad/packages/flutter/lib/src/rendering/proxy_box.dart#L825
class RenderAnimatedCustom extends RenderProxyBox {
  double _lastUsedPhase;
  bool _currentlyNeedsCompositing;
  bool _alwaysIncludeSemantics;
  Animation<double> _animation;
  bool _hasPaintedOnce = false;
  static const MAX_MELT_OFFSET = 0.25; // variation between each melt, as screen height part
  static const MELT_SLICES_WIDTH = 2;
  static const NUM_MELT_WAVES_A = 10.5;
  static const NUM_MELT_WAVES_B = 4.5;

  @override
  bool get isRepaintBoundary => true;

  @override
  bool get alwaysNeedsCompositing => child != null && _currentlyNeedsCompositing;
  bool get alwaysIncludeSemantics => _alwaysIncludeSemantics;
  ui.Image image;
  Paint p = Paint();
  List offsets;
  Offset imageCaptureOffset = Offset(0, 0);

  RenderAnimatedCustom({
    @required Animation<double> animation,
    bool alwaysIncludeSemantics = false,
    RenderBox child,
  }) : assert(animation != null),
       assert(alwaysIncludeSemantics != null),
       _alwaysIncludeSemantics = alwaysIncludeSemantics,
       super(child) {
    this.animation = animation;
  }

  Animation<double> get animation => _animation;

  set animation(Animation<double> value) {
    assert(value != null);
    if (_animation == value) return;
    if (attached && _animation != null) _animation.removeListener(_updatePhase);
    _animation = value;
    if (attached) _animation.addListener(_updatePhase);
    _animation.addStatusListener(_statusListener);
    _updatePhase();
  }

  set alwaysIncludeSemantics(bool value) {
    if (value == _alwaysIncludeSemantics) return;
    _alwaysIncludeSemantics = value;
    markNeedsSemanticsUpdate();
  }

  @override
  void attach(PipelineOwner owner) {
    super.attach(owner);
    _animation.addListener(_updatePhase);
    _updatePhase(); // in case it changed while we weren't listening
  }

  @override
  void detach() {
    _animation.removeListener(_updatePhase);
    _animation.removeStatusListener(_statusListener);
    super.detach();
  }

  void _statusListener(AnimationStatus status) {
    _attemptToGetImage();
  }

  void _attemptToGetImage() async {
    if (layer != null && _hasPaintedOnce) {
      print("_attemptToGetImage() :: capturing " + imageCaptureOffset.toString() + " at " + DateTime.now().toString());
      OffsetLayer offsetLayer = layer;
      image = await offsetLayer.toImage(imageCaptureOffset & size);
      print("_attemptToGetImage() :: done at " + DateTime.now().toString());
    } else {
      print("_attemptToGetImage() :: can't do, layer is " + (layer == null ? "null" : "object") + ", has painted once = " + _hasPaintedOnce.toString());
    }
  }

  void _updatePhase() {
    final double newPhase = _animation.value;
    if (_lastUsedPhase != newPhase) {
      final bool didNeedCompositing = _currentlyNeedsCompositing;
      _currentlyNeedsCompositing = newPhase > 0 && newPhase < 1;
      if (child != null && didNeedCompositing != _currentlyNeedsCompositing) {
        markNeedsCompositingBitsUpdate();
      }
      markNeedsPaint();
      if (newPhase == 0 || _lastUsedPhase == 0) {
        markNeedsSemanticsUpdate();
      }
      _lastUsedPhase = newPhase;
    }
  }

  void _createOffsets() {
    if (offsets == null) {
      var random = math.Random();
      int numSlices = (size.width / MELT_SLICES_WIDTH).round();
      offsets = List.generate(numSlices, (int i) {
        var f = i.toDouble() / numSlices.toDouble();
        var h1 = (math.sin(f * math.pi * 2 * NUM_MELT_WAVES_A) * 0.5 + 0.5);
        var h2 = (math.sin(f * math.pi * 2 * NUM_MELT_WAVES_B) * 0.5 + 0.5);
        var h3 = random.nextDouble();
        var h4 = random.nextDouble();
        return (h1 + h2 + h3 + h4) / 4 * MAX_MELT_OFFSET;
      });
    }
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    _createOffsets();

    print("_paint() :: " + _animation.status.toString() + " @ " + _animation.value.toString());

    if (_animation.value == 0) {
      print("_paint() :: ...premature end, at 0");
      return;
    } else if (_animation.value == 1) {
      print("_paint() :: ...premature end, at 1");
      imageCaptureOffset = offset;
      _attemptToGetImage();
      context.paintChild(child, offset);
      return;
    }

    if (image == null && layer != null && _hasPaintedOnce) {
      print("_paint() :: ...WILL CAPTURE");
      _attemptToGetImage();
    }

    if (_animation.status == AnimationStatus.forward && _animation.value < 0.1) {
      if (image == null) {
        imageCaptureOffset = Offset(1000, 0);
        super.paint(context, imageCaptureOffset);
        print("_paint() :: ...LAST RESORT CAPTURE, has painted = " + _hasPaintedOnce.toString() + ", layer = " + (layer != null).toString() + ", image = " + (image != null).toString());
        _attemptToGetImage();
        _hasPaintedOnce = true;
        return;
      }
    }

    // var q = MediaQuery.of(child.get).
    // q.devicePixelRatio
    // TODO: need to calculate screen coordinates so we can distribute slices properly, cutting at round pixels.

    if (_animation.status == AnimationStatus.forward && image != null) {
      int i = 0;
      double sliceWidth = size.width / offsets.length;
      double meltPhase = 1 - _animation.value;
      meltPhase = meltPhase * meltPhase;
      offsets.forEach((offset) {
        double x1 = i * sliceWidth;
        double x2 = x1 + sliceWidth;
        var src = Rect.fromLTRB((x1 * 1.0).roundToDouble(), 0, x2.roundToDouble(), size.height);
        var dst = src;
        var effectiveOffset = meltPhase * (1 + MAX_MELT_OFFSET) - offset;
        if (effectiveOffset > 0) dst = src.translate(0, effectiveOffset * size.height);
        context.canvas.drawImageRect(image, src, dst, p);
        i++;
      });
    } else if (_animation.status == AnimationStatus.reverse && image != null) {
      int i = 0;
      double sliceWidth = size.width / offsets.length;
      double meltPhase = 1 - _animation.value;
      meltPhase = meltPhase * meltPhase;
      offsets.forEach((offset) {
        double x1 = i * sliceWidth;
        double x2 = x1 + sliceWidth;
        var src = Rect.fromLTRB(x1.roundToDouble(), 0, x2.roundToDouble(), size.height);
        var dst = src;
        var effectiveOffset = meltPhase * (1 + MAX_MELT_OFFSET) - offset;
        if (effectiveOffset > 0) dst = src.translate(0, effectiveOffset * size.height);
        context.canvas.drawImageRect(image, src, dst, p);
        i++;
      });
    } else if (_animation.status == AnimationStatus.completed) {
      imageCaptureOffset = offset;
      super.paint(context, imageCaptureOffset);
      _attemptToGetImage();
    } else {
      print("_paint() :: ...skip, image was " + (image == null ? "null" : "valid"));
    }
  }

  @override
  void visitChildrenForSemantics(RenderObjectVisitor visitor) {
    if (child != null && (_lastUsedPhase != 0 || alwaysIncludeSemantics)) {
      visitor(child);
    }
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty<Animation<double>>('phase', animation));
    properties.add(FlagProperty('alwaysIncludeSemantics', value: alwaysIncludeSemantics, ifTrue: 'alwaysIncludeSemantics'));
  }
}
