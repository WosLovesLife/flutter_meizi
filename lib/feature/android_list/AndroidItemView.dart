import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_meizi/component/AnimatedCardView.dart';
import '../../model/bean/AndroidNews.dart';

class AndroidItemView extends StatelessWidget {
  AndroidItemView(this.androidNews, this.controller);

  final AndroidNews androidNews;

  final AnimationController controller;

  @override
  Widget build(BuildContext context) {
    var image = androidNews.smallImage;
    var imageView;
    if (image != null) {
      imageView = Container(
        width: double.infinity,
        height: 300.0,
        child: new CachedNetworkImage(
          fit: BoxFit.cover,
          imageUrl: androidNews.smallImage,
          placeholder: new Icon(Icons.photo, size: 56.0),
          errorWidget: new Icon(Icons.warning, size: 56.0),
        ),
      );
    } else {
      imageView = new Container();
    }

    return new AnimatedCardView(
      child: Container(
        constraints: new BoxConstraints(
          minHeight: 150.0,
        ),
        alignment: Alignment.centerLeft,
        child: new Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            imageView,
            new Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: new Text(
                androidNews.desc,
                style: Theme.of(context).accentTextTheme.subhead.copyWith(color: Colors.black),
              ),
            )
          ],
        ),
      ),
      controller: controller,
    );
  }
}
