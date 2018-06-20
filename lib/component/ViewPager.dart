import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:vector_math/vector_math_64.dart' as math64;

typedef void ValueChanged<T>(T value);

class ViewPager extends StatefulWidget {
  final List<Widget> children;
  final ViewPagerController controller;

  ViewPager({@required this.children, this.controller});

  @override
  _ViewPagerState createState() => new _ViewPagerState();
}

class _ViewPagerState extends State<ViewPager> with SingleTickerProviderStateMixin {
  double scrollPercent = 0.0;
  Offset startDrag;
  double startDragPercentScroll;
  double finishScrollStart;
  double finishScrollEnd;
  AnimationController finishScrollController;

  @override
  void initState() {
    super.initState();

    finishScrollController = new AnimationController(
      vsync: this,
      duration: new Duration(milliseconds: 280),
    )..addListener(() {
        setState(() {
          scrollPercent =
              lerpDouble(finishScrollStart, finishScrollEnd, finishScrollController.value);
          widget.controller.notifyListeners(_getIndex(), false);
        });
      });

    widget.controller.addListener(_handleChange);
  }

  @override
  void dispose() {
    super.dispose();

    finishScrollController.dispose();
  }

  @override
  void didUpdateWidget(ViewPager oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.controller != oldWidget.controller) {
      oldWidget.controller.removeListener(_handleChange);
      widget.controller.addListener(_handleChange);
    }
  }

  void _handleChange(int index, bool withAnim) {
    if (index == _getIndex()) return;

    if (withAnim) {
      finishScrollStart = scrollPercent;
      finishScrollEnd = index.toDouble() / widget.children.length;
      finishScrollController.forward(from: 0.0);
    } else {
      setState(() {
        scrollPercent = index.toDouble() / widget.children.length;
      });
    }
  }

  int _getIndex() {
    return (scrollPercent * widget.children.length).round();
  }

  @override
  Widget build(BuildContext context) {
    return new GestureDetector(
      onHorizontalDragStart: _onHorizontalDragStart,
      onHorizontalDragUpdate: _onHorizontalDragUpdate,
      onHorizontalDragEnd: _onHorizontalDragEnd,
      child: new Container(
        color: Colors.amber,
        child: Stack(children: _buildChildren()),
      ),
    );
  }

  List<Widget> _buildChildren() {
    final numCards = widget.children.length;
    int index = 0;
    return widget.children.map((child) {
      return _buildChild(index++, numCards, scrollPercent);
    }).toList();
  }

  Widget _buildChild(int cardIndex, int cardCount, double scrollPercent) {
    final cardScrollPercent = scrollPercent / (1 / cardCount);

    return FractionalTranslation(
      translation: new Offset(cardIndex - cardScrollPercent, 0.0),
      child: Transform(
        transform: _buildProjection(cardScrollPercent - cardIndex),
        child: widget.children[cardIndex],
      ),
    );
  }

  Matrix4 _buildProjection(double scrollPercent) {
    return Matrix4.translation(math64.Vector3(scrollPercent, 0.0, 0.0));
  }

  void _onHorizontalDragStart(DragStartDetails details) {
    startDrag = details.globalPosition;
    startDragPercentScroll = scrollPercent;
  }

  void _onHorizontalDragUpdate(DragUpdateDetails details) {
    final currDrag = details.globalPosition;
    final dragDistance = currDrag.dx - startDrag.dx;
    final singleCardDragPercent = dragDistance / context.size.width;

    final numCards = widget.children.length;
    setState(() {
      scrollPercent = (startDragPercentScroll + (-singleCardDragPercent / numCards))
          .clamp(0.0, 1.0 - (1 / numCards));
      widget.controller.notifyListeners(_getIndex(), false);
    });
  }

  void _onHorizontalDragEnd(DragEndDetails details) {
    final numCards = widget.children.length;
    finishScrollStart = scrollPercent;

    var velocity = details.velocity.pixelsPerSecond;
    if (velocity.dx > 1000) {
      finishScrollEnd = ((scrollPercent * numCards).floorToDouble()) / numCards;
    } else if (velocity.dx < -1000) {
      finishScrollEnd = ((scrollPercent * numCards).ceilToDouble() ) / numCards;
    } else {
      finishScrollEnd = (scrollPercent * numCards).roundToDouble() / numCards;
    }

    finishScrollController.forward(from: 0.0);

    setState(() {
      startDrag = null;
      startDragPercentScroll = null;
    });
  }
}

typedef void OnStatusChangedListener(int index, bool withAnim);

class ViewPagerController {
  final ObserverList<OnStatusChangedListener> _listeners =
      new ObserverList<OnStatusChangedListener>();

  int _index = 0;

  void setIndex(int newIndex, bool withAnim) {
    assert(newIndex >= 0);
    _index = newIndex;
    notifyListeners(newIndex, withAnim);
  }

  int getIndex() {
    return _index;
  }

  void addListener(OnStatusChangedListener listener) {
    _listeners.add(listener);
  }

  void removeListener(OnStatusChangedListener listener) {
    _listeners.remove(listener);
  }

  void notifyListeners(int newIndex, bool withAnim) {
    for (OnStatusChangedListener listener in new List<OnStatusChangedListener>.from(_listeners)) {
      try {
        if (_listeners.contains(listener)) listener(newIndex, withAnim);
      } catch (exception, stack) {
        FlutterError.reportError(new FlutterErrorDetails(
            exception: exception,
            stack: stack,
            library: 'StatusLayout',
            context: 'while notifying listeners for $runtimeType',
            informationCollector: (StringBuffer information) {
              information.writeln('The $runtimeType notifying listeners was:');
              information.write('  $this');
            }));
      }
    }
  }
}
