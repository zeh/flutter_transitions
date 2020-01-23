import 'package:flutter/material.dart';

import 'package:flutter_transitions/transitions/CustomTransition.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Transitions',
      initialRoute: FirstScreen.routeName,
      routes: {
        FirstScreen.routeName: (context) => FirstScreen(),
        SecondScreen.routeName: (context) => SecondScreen(),
        ThirdScreen.routeName: (context) => ThirdScreen(),
      },
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
    );
  }
}

Route createRouteWithTransitionTween() {
  return PageRouteBuilder(
    pageBuilder: (context, animation, secondaryAnimation) => ThirdScreen(),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      var begin = Offset(0.0, 1.0);
      var end = Offset.zero;
      var curve = Curves.ease;
      var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
      var offsetAnimation = animation.drive(tween);
      return SlideTransition(
        position: offsetAnimation,
        child: child,
      );
    },
  );
}

Route createRouteWithTransitionFade() {
  return PageRouteBuilder(
    pageBuilder: (context, animation, secondaryAnimation) => ThirdScreen(),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      return FadeTransition(
        opacity: animation,
        child: child,
      );
    },
  );
}

Route createRouteWithTransitionCustom() {
  return PageRouteBuilder(
    pageBuilder: (context, animation, secondaryAnimation) => ThirdScreen(),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      return CustomTransition(
        animation: animation,
        child: child,
      );
    },
  );
}

class FirstScreen extends StatelessWidget {
  static const routeName = '/first';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('First Screen'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            RaisedButton(
              child: Text('Open Second screen (default transition)'),
              onPressed: () {
                Navigator.pushNamed(context, SecondScreen.routeName);
              },
            ),
            RaisedButton(
              child: Text('Open Third screen (custom transition, tweens)'),
              onPressed: () {
                Navigator.push(context, createRouteWithTransitionTween());
              },
            ),
            RaisedButton(
              child: Text('Open Third screen (custom transition, fade)'),
              onPressed: () {
                Navigator.push(context, createRouteWithTransitionFade());
              },
            ),
            RaisedButton(
              child: Text('Open Third screen (custom transition, custom code)'),
              onPressed: () {
                Navigator.push(context, createRouteWithTransitionCustom());
              },
            ),
          ],
        ),
      ),
    );
  }
}

class SecondScreen extends StatelessWidget {
  static const routeName = '/second';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Second Screen"),
      ),
      body: Center(
        child: RaisedButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: Text('Go back!'),
        ),
      ),
    );
  }
}

class ThirdScreen extends StatelessWidget {
  static const routeName = '/third';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Third Screen"),
      ),
      body: Center(
        child: RaisedButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: Text('Go back!'),
        ),
      ),
    );
  }
}

