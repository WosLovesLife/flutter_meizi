import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

typedef void ValueChanged<T>(T value);

class ViewPager extends StatefulWidget {
  final List<Widget> children;
  final ViewPagerController controller;

  ViewPager({@required this.children, this.controller});

  @override
  _ViewPagerState createState() => new _ViewPagerState();
}

class _ViewPagerState extends State<ViewPager> with SingleTickerProviderStateMixin {
  ScrollController scrollController;
  double pageWidth = 0.0;

  @override
  void initState() {
    super.initState();

    scrollController = ScrollController();
    scrollController.addListener(() {
      int index = (scrollController.offset / pageWidth).round();
      if (index != widget.controller._index) {
        widget.controller._setIndex(index, false);
      }
    });

    widget.controller._addListener(_handleChange);
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  void didUpdateWidget(ViewPager oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.controller != oldWidget.controller) {
      oldWidget.controller._removeListener(_handleChange);
      widget.controller._addListener(_handleChange);
    }
  }

  void _handleChange(int index, bool withAnim) {
    if (withAnim) {
      scrollController.animateTo(
        pageWidth * index,
        duration: Duration(milliseconds: 260),
        curve: Curves.fastOutSlowIn,
      );
    } else {
      scrollController.jumpTo(pageWidth * index);
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (BuildContext context, BoxConstraints constraints) {
      pageWidth = constraints.maxWidth;
      return new Scrollable(
        axisDirection: AxisDirection.left,
//        controller: scrollController,
        physics: AlwaysScrollableScrollPhysics(),
        viewportBuilder: (BuildContext context, ViewportOffset position) {
          return new ListView(
            controller: scrollController,
            scrollDirection: Axis.horizontal,
            physics: PageScrollPhysics(),
            children: widget.children.map((w) {
              return Container(
                width: constraints.maxWidth,
                height: constraints.maxHeight,
                child: w,
              );
            }).toList(),
          );
        },
      );
    });
  }
}

typedef void OnStatusChangedListener(int index, bool withAnim);

class ViewPagerController {
  final ObserverList<OnStatusChangedListener> _listeners =
      new ObserverList<OnStatusChangedListener>();
  final ObserverList<OnStatusChangedListener> _outerListeners =
      new ObserverList<OnStatusChangedListener>();

  int _index = 0;

  int getIndex() {
    return _index;
  }

  void setIndex(int newIndex, bool withAnim) {
    assert(newIndex >= 0);
    if (_index != newIndex) {
      _index = newIndex;
      _notifyListeners(newIndex, withAnim, List<OnStatusChangedListener>.from(_listeners));
    }
  }

  void _setIndex(int newIndex, bool withAnim) {
    assert(newIndex >= 0);
    if (_index != newIndex) {
      _index = newIndex;
      _notifyListeners(newIndex, withAnim, List<OnStatusChangedListener>.from(_outerListeners));
    }
  }

  void _addListener(OnStatusChangedListener listener) {
    _listeners.add(listener);
  }

  void _removeListener(OnStatusChangedListener listener) {
    _listeners.remove(listener);
  }

  void addListener(OnStatusChangedListener listener) {
    _outerListeners.add(listener);
  }

  void removeListener(OnStatusChangedListener listener) {
    _outerListeners.remove(listener);
  }

  void _notifyListeners(int newIndex, bool withAnim, List<OnStatusChangedListener> listeners) {
    for (OnStatusChangedListener listener in listeners) {
      try {
        listener(newIndex, withAnim);
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
