import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

import 'RenderAnimatedCustom.dart';

class CustomTransition extends SingleChildRenderObjectWidget {
  final Animation<double> animation;
  final bool alwaysIncludeSemantics;

  const CustomTransition({
    Key key,
    @required this.animation,
    this.alwaysIncludeSemantics = false,
    Widget child,
  }) : assert(animation != null),
       super(key: key, child: child);

  @override
  RenderAnimatedCustom createRenderObject(BuildContext context) {
    return RenderAnimatedCustom(
      animation: animation,
      alwaysIncludeSemantics: alwaysIncludeSemantics,
    );
  }

  @override
  void updateRenderObject(BuildContext context, RenderAnimatedCustom renderObject) {
    renderObject
      ..animation = animation
      ..alwaysIncludeSemantics = alwaysIncludeSemantics;
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty<Animation<double>>('animation', animation));
    properties.add(FlagProperty('alwaysIncludeSemantics', value: alwaysIncludeSemantics, ifTrue: 'alwaysIncludeSemantics'));
  }
}
