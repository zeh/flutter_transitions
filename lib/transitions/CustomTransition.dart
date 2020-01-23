import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

/// A custom transition to animate a widget.
/// This is a copy of FadeTransition: https://github.com/flutter/flutter/blob/27321ebbad/packages/flutter/lib/src/widgets/transitions.dart#L530
class CustomTransition extends SingleChildRenderObjectWidget {
  /// Creates an opacity transition.
  ///
  /// The [opacity] argument must not be null.
  const CustomTransition({
    Key key,
    @required this.animation,
    this.alwaysIncludeSemantics = false,
    Widget child,
  }) : assert(animation != null),
       super(key: key, child: child);

  /// The animation that controls the opacity of the child.
  ///
  /// If the current value of the opacity animation is v, the child will be
  /// painted with an opacity of v. For example, if v is 0.5, the child will be
  /// blended 50% with its background. Similarly, if v is 0.0, the child will be
  /// completely transparent.
  final Animation<double> animation;

  /// Whether the semantic information of the children is always included.
  ///
  /// Defaults to false.
  ///
  /// When true, regardless of the opacity settings the child semantic
  /// information is exposed as if the widget were fully visible. This is
  /// useful in cases where labels may be hidden during animations that
  /// would otherwise contribute relevant semantics.
  final bool alwaysIncludeSemantics;

  @override
  RenderAnimatedOpacity createRenderObject(BuildContext context) {
    return RenderAnimatedOpacity(
      opacity: animation,
      alwaysIncludeSemantics: alwaysIncludeSemantics,
    );
  }

  @override
  void updateRenderObject(BuildContext context, RenderAnimatedOpacity renderObject) {
    renderObject
      ..opacity = animation
      ..alwaysIncludeSemantics = alwaysIncludeSemantics;
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty<Animation<double>>('animation', animation));
    properties.add(FlagProperty('alwaysIncludeSemantics', value: alwaysIncludeSemantics, ifTrue: 'alwaysIncludeSemantics'));
  }
}
