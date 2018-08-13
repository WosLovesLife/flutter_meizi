import 'package:flutter/material.dart';
import 'package:flutter_meizi/component/animated_card_view.dart';
import '../../model/bean/android_news.dart';
import 'package:flutter_advanced_networkimage/flutter_advanced_networkimage.dart';
import 'package:flutter_advanced_networkimage/transition_to_image.dart';

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
        child: new TransitionToImage(
          AdvancedNetworkImage(androidNews.smallImage, useDiskCache: true),
          fit: BoxFit.cover,
          placeholder: new Icon(Icons.image, size: 56.0),
          width: double.infinity,
          height: double.infinity,
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
