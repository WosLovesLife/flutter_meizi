import 'dart:ui';

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

class _LoadMoreViewState extends State<PhotoView> with TickerProviderStateMixin {
  GlobalKey _imageKey = new GlobalKey();

  AnimationController _controller;
  CurvedAnimation _curvedAnimation;
  Tween<double> _scaleTween;

  // 放大/和放大的基点的值. 在动画/手势中会实时变化
  double _scale = 1.0;
  Alignment _alignment = Alignment.center;
  Offset _position = Offset.zero;

  // ==== 辅助动画/手势的计算
  Offset _downPoint;

  /// 上次放大的比例, 用于帮助下次放大操作时放大的速度保持一致.
  double _lastScaleValue = 1.0;
  Offset _lastPosition = Offset.zero;

  @override
  void initState() {
    super.initState();

    _controller = new AnimationController(duration: new Duration(milliseconds: 300), vsync: this)
      ..addListener(_handleScaleAnim);

    _curvedAnimation = new CurvedAnimation(parent: _controller, curve: Curves.fastOutSlowIn);
  }

  generateScaleAnim(double begin, double end) {
    _scaleTween = new Tween<double>(begin: begin, end: end);
  }

  _handleScaleAnim() {
    var newScale = _scaleTween.evaluate(_curvedAnimation);
    setState(() {
      if (newScale < _scale) { // zoom out
        var alignTween = new Tween<Alignment>(begin: _alignment, end: new Alignment(0.0, 0.0));
        _alignment = alignTween.evaluate(_curvedAnimation);

        var positionTween = new Tween<Offset>(begin: _position, end: Offset.zero);
        _position = positionTween.evaluate(_curvedAnimation);
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
            begin: _alignment,
            end: new Alignment(x, y));

        _alignment = alignTween.evaluate(_curvedAnimation);
      }

      _scale = newScale;
    });
  }

  Offset _clampPosition(Offset offset) {
    var imageSize = _imageKey.currentContext
        .findRenderObject()
        .paintBounds
        .size;

    final x = offset.dx;
    final y = offset.dy;
    final computedWidth = imageSize.width * _scale;
    final computedHeight = imageSize.height * _scale;
    final screenWidth = MediaQuery
        .of(context)
        .size
        .width;
    final screenHeight = MediaQuery
        .of(context)
        .size
        .height;
    final screenHalfX = screenWidth / 2;
    final screenHalfY = screenHeight / 2;

    final double computedX = screenWidth < computedWidth ? x.clamp(
        0 - (computedWidth / 2) + screenHalfX,
        computedWidth / 2 - screenHalfX
    ) : 0.0;

    final double computedY = screenHeight < computedHeight ? y.clamp(
        0 - (computedHeight / 2) + screenHalfY,
        computedHeight / 2 - screenHalfY
    ) : 0.0;

    return new Offset(
        computedX,
        computedY
    );
  }

  _handleScaleStart(ScaleStartDetails details) {
    _downPoint = details.focalPoint;
    _lastScaleValue = _scale;
    _lastPosition = details.focalPoint - _position;
  }

  _handleScaleUpdate(ScaleUpdateDetails details) {
    double newScale = (_lastScaleValue * details.scale);

    if (newScale < 0.7) {
      newScale = 0.7;
    } else if (newScale > 5.0) {
      newScale = 5.0;
    }

    final Offset positionDelta = (details.focalPoint - _lastPosition);

    setState(() {
      _scale = newScale;

      if (_lastScaleValue == _scale) {
        _position = _clampPosition(positionDelta * (newScale / _lastScaleValue));
      }
    });
  }

  _handleScaleEnd(ScaleEndDetails details) {
    if (_scale > 3.0) {
      generateScaleAnim(_scale, 3.0);
      _controller.reset();
      _controller.forward();
    } else if (_scale < 1.0) {
      generateScaleAnim(_scale, 1.0);
      _controller.reset();
      _controller.forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Matrix4 transform = new Matrix4.identity()
      ..translate(_position.dx, _position.dy)
      ..scale(_scale, _scale, 1.0);

    return new GestureDetector(
      onPanDown: (DragDownDetails details) {
        _downPoint = details.globalPosition;
        _controller.stop();
      },
      onPanCancel: () {
        if (_scale > 3.0) {
          generateScaleAnim(_scale, 3.0);
          _controller.reset();
          _controller.forward();
        } else if (_scale < 1.0) {
          generateScaleAnim(_scale, 1.0);
          _controller.reset();
          _controller.forward();
        }
      },
      child: new GestureDetector(
        onTap: () {
          Navigator.of(context).pop();
        },
        onDoubleTap: () {
          if (_scale > 1.0) {
            generateScaleAnim(_scale, 1.0);
          } else {
            generateScaleAnim(_scale, 3.0);
          }

          _controller.reset();
          _controller.forward();
        },
        onScaleStart: _handleScaleStart,
        onScaleUpdate: _handleScaleUpdate,
        onScaleEnd: _handleScaleEnd,
        child: new Container(
          width: double.INFINITY,
          height: double.INFINITY,
          color: Colors.black,
          alignment: Alignment.center,
          child: new Wrap(
            children: <Widget>[
              new Transform(
                transform: transform,
//                alignment: alignment,
                alignment: Alignment.center,
                child: new CachedNetworkImage(
                  key: _imageKey,
                  fit: BoxFit.scaleDown,
                  imageUrl: widget.imageUrl,
                  placeholder: new CircularProgressIndicator(),
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
//      imageUrl: 'http://img.soogif.com/YpEcZKVZvshJEC2dSrWAXQkhFDjBSyqR.gif',
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