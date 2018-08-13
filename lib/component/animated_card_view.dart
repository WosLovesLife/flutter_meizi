import 'package:flutter/material.dart';

class AnimatedCardView extends StatelessWidget {
  AnimatedCardView({this.child, AnimationController controller})
      : curvedAnimation = new CurvedAnimation(parent: controller, curve: Curves.fastOutSlowIn);

  final Widget child;
  final CurvedAnimation curvedAnimation;

  @override
  Widget build(BuildContext context) {
    Animation<Offset> slideAnimation =
        new Tween<Offset>(begin: new Offset(0.0, 0.5), end: new Offset(0.0, 0.0))
            .animate(curvedAnimation);

    Animation<double> fadeAnimation =
        new Tween<double>(begin: 0.0, end: 1.0).animate(curvedAnimation);

    return new SlideTransition(
      position: slideAnimation,
      child: new FadeTransition(
        opacity: fadeAnimation,
        child: new Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.zero,
          ),
          elevation: 4.0,
          child: child,
        ),
      ),
    );
  }
}
