import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

/// A custom renderer.
/// This is a copy of RenderAnimatedOpacity: https://github.com/flutter/flutter/blob/27321ebbad/packages/flutter/lib/src/rendering/proxy_box.dart#L825
class RenderAnimatedCustom extends RenderProxyBox {
  RenderAnimatedCustom({
    @required Animation<double> phase,
    bool alwaysIncludeSemantics = false,
    RenderBox child,
  }) : assert(phase != null),
       assert(alwaysIncludeSemantics != null),
       _alwaysIncludeSemantics = alwaysIncludeSemantics,
       super(child) {
    this.phase = phase;
  }

  double _lastUsedPhase;

  @override
  bool get alwaysNeedsCompositing => child != null && _currentlyNeedsCompositing;
  bool _currentlyNeedsCompositing;

  /// The animation that drives this render object's opacity.
  ///
  /// An opacity of 1.0 is fully opaque. An opacity of 0.0 is fully transparent
  /// (i.e., invisible).
  ///
  /// To change the opacity of a child in a static manner, not animated,
  /// consider [RenderOpacity] instead.
  Animation<double> get phase => _phase;
  Animation<double> _phase;
  set phase(Animation<double> value) {
    assert(value != null);
    if (_phase == value) return;
    if (attached && _phase != null) _phase.removeListener(_updatePhase);
    _phase = value;
    if (attached) _phase.addListener(_updatePhase);
    _updatePhase();
  }

  /// Whether child semantics are included regardless of the opacity.
  ///
  /// If false, semantics are excluded when [opacity] is 0.0.
  ///
  /// Defaults to false.
  bool get alwaysIncludeSemantics => _alwaysIncludeSemantics;
  bool _alwaysIncludeSemantics;
  set alwaysIncludeSemantics(bool value) {
    if (value == _alwaysIncludeSemantics) return;
    _alwaysIncludeSemantics = value;
    markNeedsSemanticsUpdate();
  }

  @override
  void attach(PipelineOwner owner) {
    super.attach(owner);
    _phase.addListener(_updatePhase);
    _updatePhase(); // in case it changed while we weren't listening
  }

  @override
  void detach() {
    _phase.removeListener(_updatePhase);
    super.detach();
  }

  void _updatePhase() {
    final double newPhase = _phase.value;
    if (_lastUsedPhase != newPhase) {
      _lastUsedPhase = newPhase;
      final bool didNeedCompositing = _currentlyNeedsCompositing;
      _currentlyNeedsCompositing = _lastUsedPhase > 0 && _lastUsedPhase < 1;
      if (child != null && didNeedCompositing != _currentlyNeedsCompositing) {
        markNeedsCompositingBitsUpdate();
      }
      markNeedsPaint();
      if (newPhase == 0 || _lastUsedPhase == 0) {
        markNeedsSemanticsUpdate();
      }
    }
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    if (child != null) {
      if (_lastUsedPhase == 0) {
        // No need to keep the layer. We'll create a new one if necessary.
        layer = null;
        return;
      }
      if (_lastUsedPhase == 1) {
        // No need to keep the layer. We'll create a new one if necessary.
        layer = null;
        context.paintChild(child, offset);
        return;
      }
      assert(needsCompositing);
      layer = context.pushOpacity(offset, (_lastUsedPhase * 255).round(), super.paint, oldLayer: layer);
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
    properties.add(DiagnosticsProperty<Animation<double>>('phase', phase));
    properties.add(FlagProperty('alwaysIncludeSemantics', value: alwaysIncludeSemantics, ifTrue: 'alwaysIncludeSemantics'));
  }
}
