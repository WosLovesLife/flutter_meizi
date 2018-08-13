import 'package:flutter/material.dart';
import 'package:flutter_advanced_networkimage/flutter_advanced_networkimage.dart';
import 'package:flutter_advanced_networkimage/transition_to_image.dart';
import 'package:flutter_meizi/model/bean/photo.dart';

class PhotoItemView extends StatelessWidget {
  PhotoItemView(this.photo, this.controller);

  final Photo photo;

  final AnimationController controller;

  @override
  Widget build(BuildContext context) {
    var curvedAnimation = new CurvedAnimation(parent: controller, curve: Curves.fastOutSlowIn);

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
            elevation: 4.0,
            child: new Container(
              width: double.infinity,
              height: 300.0,
              child: TransitionToImage(
                AdvancedNetworkImage(photo.smallUrl),
                fit: BoxFit.cover,
                placeholder: new Icon(Icons.image, size: 56.0),
                width: double.infinity,
                height: double.infinity,
              ),
            ),
          ),
        ));
  }
}
