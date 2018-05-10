import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:cached_network_image/cached_network_image.dart';

class PhotoView extends StatefulWidget {
  final String imageUrl;
  final AnimationController opacityController;

  PhotoView({Key key, @required this.imageUrl, @required this.opacityController})
      :super(key: key);

  @override
  State<StatefulWidget> createState() => new _LoadMoreViewState();
}

class _LoadMoreViewState extends State<PhotoView> with SingleTickerProviderStateMixin {
  AnimationController controller;
  CurvedAnimation curvedAnimation;
  Tween<double> _scaleTween;

  // 放大/和放大的基点的值. 在动画/手势中会实时变化
  double scaleValue = 1.0;
  Alignment alignment = Alignment.center;

  // ==== 辅助动画/手势的计算
  Offset _downPoint;

  /// 上次放大的比例, 用于帮助下次放大操作时放大的速度保持一致.
  double _lastScaleValue = 1.0;

  @override
  void initState() {
    super.initState();

    controller = new AnimationController(duration: new Duration(milliseconds: 300), vsync: this)
      ..addListener(_handleScaleAnim);

    curvedAnimation = new CurvedAnimation(parent: controller, curve: Curves.fastOutSlowIn);
  }

  generateScaleAnim(double begin, double end) {
    _scaleTween = new Tween<double>(begin: begin, end: end);
  }

  _handleScaleAnim() {
    var newScale = _scaleTween.evaluate(curvedAnimation);
    setState(() {
      if (newScale < scaleValue) { // zoom out
        var alignTween = new Tween<Alignment>(begin: alignment, end: new Alignment(0.0, 0.0));
        alignment = alignTween.evaluate(curvedAnimation);
      } else { // zoom in
        var size = context
            .findRenderObject()
            .paintBounds
            .size;

        var centerX = size.width / 2;
        var centerY = size.height / 2;

        var x = (_downPoint.dx - centerX) / centerX;
        var y = (_downPoint.dy - centerY) / centerY;

        var alignTween = new Tween<Alignment>(
            begin: alignment,
            end: new Alignment(x, y));

        alignment = alignTween.evaluate(curvedAnimation);
      }

      scaleValue = newScale;
    });
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Matrix4 transform = new Matrix4.identity()
      ..scale(scaleValue, scaleValue, 1.0);

    return new GestureDetector(
      onPanDown: (DragDownDetails details) {
        _downPoint = details.globalPosition;
        controller.stop();
      },
      onPanCancel: () {
        if (scaleValue > 3.0) {
          generateScaleAnim(scaleValue, 3.0);
          controller.reset();
          controller.forward();
        } else if (scaleValue < 1.0) {
          generateScaleAnim(scaleValue, 1.0);
          controller.reset();
          controller.forward();
        }
      },
      child: new GestureDetector(
        onTap: () {
          Navigator.of(context).pop();
        },
        onDoubleTap: () {
          if (scaleValue > 1.0) {
            generateScaleAnim(scaleValue, 1.0);
          } else {
            generateScaleAnim(scaleValue, 3.0);
          }

          controller.reset();
          controller.forward();
        },
        onScaleStart: (ScaleStartDetails details) {
          _downPoint = details.focalPoint;
          _lastScaleValue = scaleValue;
        },
        onScaleUpdate: (ScaleUpdateDetails details) {
          double newScale = (_lastScaleValue * details.scale);

          if (newScale < 0.7) {
            newScale = 0.7;
          } else if (newScale > 5.0) {
            newScale = 5.0;
          }

          setState(() {
            scaleValue = newScale;
          });
        },
        onScaleEnd: (ScaleEndDetails details) {
          if (scaleValue > 3.0) {
            generateScaleAnim(scaleValue, 3.0);
            controller.reset();
            controller.forward();
          } else if (scaleValue < 1.0) {
            generateScaleAnim(scaleValue, 1.0);
            controller.reset();
            controller.forward();
          }
        },
        child: new Container(
          width: double.INFINITY,
          height: double.INFINITY,
          color: Colors.black,
          alignment: Alignment.center,
          child: new Wrap(
            children: <Widget>[
              new Transform(
                transform: transform,
                alignment: alignment,
                child: new CachedNetworkImage(
                  fit: BoxFit.scaleDown,
                  imageUrl: widget.imageUrl,
                  placeholder: new Icon(Icons.photo, size: 56.0),
                  errorWidget: new Icon(Icons.warning, size: 56.0),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class TestPhotoView extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return new _TestPhotoViewState();
  }
}

class _TestPhotoViewState extends State<TestPhotoView> with SingleTickerProviderStateMixin {
  AnimationController controller;

  @override
  void initState() {
    super.initState();
    controller = new AnimationController(vsync: this);
  }

  @override
  void dispose() {
    controller.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return new PhotoView(
      imageUrl: 'http://ww2.sinaimg.cn/large/610dc034jw1f3rbikc83dj20dw0kuadt.jpg',
      opacityController: controller,
    );
  }

}

void main() =>
    runApp(new MaterialApp(
      title: 'Mei Zi',
      theme: new ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: new TestPhotoView(),
    ));