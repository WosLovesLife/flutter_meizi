import 'package:flutter/material.dart';

class DefaultRoute extends PageRouteBuilder {
  final Widget child;

  DefaultRoute({this.child}) : super(pageBuilder: (_, __, ___) {});

  @override
  Widget buildPage(
      BuildContext context, Animation<double> animation, Animation<double> secondaryAnimation) {
    return new SlideTransition(
      position: new Tween<Offset>(
        begin: const Offset(1.0, 0.0),
        end: const Offset(0.0, 0.0),
      ).animate(animation),
      child: new FadeTransition(
        opacity: new Tween<double>(
          begin: 0.0,
          end: 1.0,
        ).animate(animation),
        child: child, // child is the value returned by pageBuilder
      ),
    );
  }
}
