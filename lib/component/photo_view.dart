import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_advanced_networkimage/flutter_advanced_networkimage.dart';
import 'package:flutter_advanced_networkimage/transition_to_image.dart';

class PhotoView extends StatefulWidget {
  final String imageUrl;

  PhotoView({Key key, @required this.imageUrl}) : super(key: key);

  @override
  State<StatefulWidget> createState() => new _LoadMoreViewState();
}

class _LoadMoreViewState extends State<PhotoView> with TickerProviderStateMixin {
  GlobalKey _imageKey = new GlobalKey();

  AnimationController _controller;
  CurvedAnimation _curvedAnimation;
  Tween<double> _scaleTween;
  Tween<Offset> _positionTween;

  // 放大/和放大的基点的值. 在动画/手势中会实时变化
  double _scale = 1.0;
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

  _forwardAnimations() {
    _scaleTween = new Tween<double>(begin: _scale, end: 3.0);

    var containerSize = MediaQuery.of(context).size;
    var center = new Offset(containerSize.width, containerSize.height) / 2.0;
    var delta = center - _downPoint;
    var positionDelta = (delta * 3.0);
    _positionTween = new Tween<Offset>(begin: _position, end: _clampPosition(positionDelta, 3.0));
  }

  _resetAnimations() {
    _scaleTween = new Tween<double>(begin: _scale, end: 1.0);
    _positionTween = new Tween<Offset>(begin: _position, end: Offset.zero);
  }

  _handleScaleAnim() {
    var newScale = _scaleTween.evaluate(_curvedAnimation);
    setState(() {
      _scale = newScale;
      _position = _clampPosition(_positionTween.evaluate(_curvedAnimation), newScale);
    });
  }

  Offset _clampPosition(Offset offset, double scale) {
    var imageSize = _imageKey.currentContext.findRenderObject().paintBounds.size;

    final x = offset.dx;
    final y = offset.dy;
    final computedWidth = imageSize.width * scale;
    final computedHeight = imageSize.height * scale;
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final screenHalfX = screenWidth / 2;
    final screenHalfY = screenHeight / 2;

    final double computedX = screenWidth < computedWidth
        ? x.clamp(0 - (computedWidth / 2) + screenHalfX, computedWidth / 2 - screenHalfX)
        : 0.0;

    final double computedY = screenHeight < computedHeight
        ? y.clamp(0 - (computedHeight / 2) + screenHalfY, computedHeight / 2 - screenHalfY)
        : 0.0;

    return new Offset(computedX, computedY);
  }

  Offset _lastImageSize = Offset.zero;

  _handleScaleStart(ScaleStartDetails details) {
    _downPoint = details.focalPoint;
    _lastScaleValue = _scale;
    _lastPosition = details.focalPoint - _position;

    Size s = _imageKey.currentContext.findRenderObject().paintBounds.size;
    _lastImageSize = Offset(s.width * _scale, s.height * _scale);
  }

  _handleScaleUpdate(ScaleUpdateDetails details) {
    double newScale = (_lastScaleValue * details.scale);

    if (newScale < 0.7) {
      newScale = 0.7;
    } else if (newScale > 5.0) {
      newScale = 5.0;
    }

    // 拖拽带来的变化
    Offset positionDelta = (details.focalPoint - _lastPosition);

    // 缩放焦点带来的变化
    Size s = _imageKey.currentContext.findRenderObject().paintBounds.size;
    Offset newSize = Offset(s.width * newScale, s.height * newScale);
    Offset deltaSize = newSize - _lastImageSize;
    Offset halfDeltaSize = deltaSize / 2.0;

    Size half = context.size / 2.0;
    double ratioX = (half.width - _downPoint.dx) / half.width;
    double ratioY = (half.height - _downPoint.dy) / half.height;

    Offset extraOffset = Offset(halfDeltaSize.dx * ratioX, halfDeltaSize.dy * ratioY);
    positionDelta = Offset(positionDelta.dx + extraOffset.dx, positionDelta.dy + extraOffset.dy);

    setState(() {
      _scale = newScale;
      _position = _clampPosition(positionDelta, _scale);
    });
  }

  _checkAndReset() {
    if (_scale > 3.0) {
      _scaleTween = new Tween<double>(begin: _scale, end: 3.0);
//      _positionTween = new Tween<Offset>(begin: _position, end: _position);
//      _controller.reset();
//      _controller.forward();

      double delta = _scale - 3.0;
      Offset remove = _position / _scale * delta;
      print('_scale = $_scale; _position = $_position; remove = $remove');
      _positionTween = new Tween<Offset>(begin: _position, end: _position - remove);
      _controller.forward(from: 0.0);
    } else if (_scale < 1.0) {
      _resetAnimations();
      _controller.forward(from: 0.0);
    }
  }

  _handleScaleEnd(ScaleEndDetails details) {
    _checkAndReset();
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
        _checkAndReset();
      },
      child: new GestureDetector(
        onTap: () {
          Navigator.of(context).pop();
        },
        onDoubleTap: () {
          if (_scale > 1.0) {
            _resetAnimations();
          } else {
            _forwardAnimations();
          }

          _controller.reset();
          _controller.forward();
        },
        onScaleStart: _handleScaleStart,
        onScaleUpdate: _handleScaleUpdate,
        onScaleEnd: _handleScaleEnd,
        child: new Container(
          width: double.infinity,
          height: double.infinity,
          color: Colors.black,
          alignment: Alignment.center,
          child: new Wrap(
            children: <Widget>[
              new Transform(
                transform: transform,
                alignment: Alignment.center,
                child: IgnorePointer(
                  ignoringSemantics: true,
                  child: new TransitionToImage(
                    AdvancedNetworkImage(widget.imageUrl),
                    key: _imageKey,
                    placeholder: new Icon(Icons.image, size: 56.0),
                  ),
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
//      imageUrl: 'http://ww2.sinaimg.cn/large/610dc034jw1f3rbikc83dj20dw0kuadt.jpg',
      imageUrl: 'http://pic.58pic.com/58pic/12/22/98/77v58PICHMR.jpg',
//      imageUrl: 'http://img.soogif.com/YpEcZKVZvshJEC2dSrWAXQkhFDjBSyqR.gif',
    );
  }
}

void main() => runApp(
      new MaterialApp(
        title: 'Mei Zi',
        theme: new ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: new TestPhotoView(),
      ),
    );
