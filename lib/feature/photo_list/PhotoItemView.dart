import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../model/bean/Photo.dart';

class PhotoItemView extends StatelessWidget {
  PhotoItemView(this.photo, this.controller);

  final Photo photo;

  final AnimationController controller;

  @override
  Widget build(BuildContext context) {
    var curvedAnimation = new CurvedAnimation(parent: controller, curve: Curves.fastOutSlowIn);

    Animation<Offset> slideAnimation = new Tween<Offset>(
        begin: new Offset(0.0, 0.5), end: new Offset(0.0, 0.0))
        .animate(curvedAnimation);

    Animation<double> fadeAnimation = new Tween<double>(begin: 0.0, end: 1.0)
        .animate(curvedAnimation);

    return new SlideTransition(
        position: slideAnimation,
        child: new FadeTransition(
          opacity: fadeAnimation,
          child: new Card(
            elevation: 4.0,
            child: new Container(
              width: double.INFINITY,
              height: 300.0,
              child: new CachedNetworkImage(
                fit: BoxFit.cover,
                imageUrl: photo.smallUrl,
                placeholder: new Icon(Icons.photo, size: 56.0),
                errorWidget: new Icon(Icons.warning, size: 56.0),
              ),
            ),
          ),
        )
    );
  }
}