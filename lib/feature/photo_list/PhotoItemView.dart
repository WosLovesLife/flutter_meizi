import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../model/bean/Photo.dart';

class PhotoItemView extends StatelessWidget {
  PhotoItemView(this.photo);

  final Photo photo;

  @override
  Widget build(BuildContext context) {
    return new Center(
        child: new Card(
          elevation: 2.0,
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
        )
    );
  }
}