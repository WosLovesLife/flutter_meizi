import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

class LoadMoreView extends StatefulWidget {
  final LoadMoreController controller;

  LoadMoreView({Key key, @required this.controller}) :super(key: key);

  @override
  State<StatefulWidget> createState() => new _LoadMoreViewState();
}

class _LoadMoreViewState extends State<LoadMoreView> {

  @override
  void initState() {
    super.initState();
    widget.controller.addOnStatusChangedListener(_handleChange);
  }

  @override
  void didUpdateWidget(LoadMoreView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.controller != oldWidget.controller) {
      oldWidget.controller.removeOnStatusChangedListener(_handleChange);
      widget.controller.addOnStatusChangedListener(_handleChange);
    }
  }

  @override
  void dispose() {
    super.dispose();
    widget.controller.removeOnStatusChangedListener(_handleChange);
  }

  void _handleChange(LoadMoreStatus status) {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    if (widget.controller._status == LoadMoreStatus.prepare) {
      widget.controller.notifyOnLoadMoreListeners();
    }
    return new Container(
      width: double.infinity,
      height: 56.0,
      child: getContent(widget.controller.getStatus()),
      alignment: AlignmentDirectional.center,
    );
  }

  Widget getContent(LoadMoreStatus status) {
    switch (status) {
      case LoadMoreStatus.idle:
        return new Center(
          child: new FlutterLogo(size: 48.0),
        );
      case LoadMoreStatus.prepare:
      case LoadMoreStatus.loading:
        Color color = Theme
            .of(context)
            .primaryColor;
        return new Center(
          child: new Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              new CircularProgressIndicator(backgroundColor: color),
              generateText("   Loading..."),
            ],
          ),
        );
      case LoadMoreStatus.noMore:
        return new Center(
          child: generateText("No More"),
        );
      default:
        return null;
    }
  }

  generateText(data) {
    return new Text(
      data,
      style: new TextStyle(
        fontSize: 18.0,
        letterSpacing: 5.0,
      ),
    );
  }
}

/// The status of an animation
enum LoadMoreStatus {
  // display the empty placeholder
  idle,

  // the UI is the same with loading, but it will trigger the notifyOnLoadMoreListeners
  prepare,

  // display the circle progress indicator as a placeholder
  loading,

  // display the content
  noMore,
}

typedef void OnStatusChangedListener(LoadMoreStatus status);

typedef void OnLoadMoreListener();

class LoadMoreController extends Listenable {
  final ObserverList<OnLoadMoreListener> _listeners = new ObserverList<
      OnLoadMoreListener>();

  final ObserverList<OnStatusChangedListener> _onStatusChangedListeners = new ObserverList<
      OnStatusChangedListener>();

  LoadMoreStatus _status = LoadMoreStatus.idle;

  void setStatus(LoadMoreStatus newStatus) {
    assert(newStatus != null);
    _status = newStatus;
    notifyOnStatusChangedListeners(newStatus);
  }

  LoadMoreStatus getStatus() {
    return _status;
  }

  @override
  void addListener(VoidCallback listener) {
    _listeners.add(listener);
  }

  @override
  void removeListener(VoidCallback listener) {
    _listeners.remove(listener);
  }

  void notifyOnLoadMoreListeners() {
    for (OnLoadMoreListener listener in new List<OnLoadMoreListener>.from(_listeners)) {
      try {
        if (_listeners.contains(listener))
          listener();
      } catch (exception, stack) {
        FlutterError.reportError(new FlutterErrorDetails(
            exception: exception,
            stack: stack,
            library: 'LoadMoreView',
            context: 'while notifying listeners for $runtimeType',
            informationCollector: (StringBuffer information) {
              information.writeln('The $runtimeType notifying listeners was:');
              information.write('  $this');
            }
        ));
      }
    }
  }

  // =============

  void addOnStatusChangedListener(OnStatusChangedListener listener) {
    _onStatusChangedListeners.add(listener);
  }

  void removeOnStatusChangedListener(OnStatusChangedListener listener) {
    _onStatusChangedListeners.remove(listener);
  }

  void notifyOnStatusChangedListeners(LoadMoreStatus status) {
    if (status == getStatus()) return;

    for (OnStatusChangedListener listener in new List<OnStatusChangedListener>.from(
        _onStatusChangedListeners)) {
      try {
        if (_onStatusChangedListeners.contains(listener))
          listener(status);
      } catch (exception, stack) {
        FlutterError.reportError(new FlutterErrorDetails(
            exception: exception,
            stack: stack,
            library: 'LoadMoreView',
            context: 'while notifying listeners for $runtimeType',
            informationCollector: (StringBuffer information) {
              information.writeln('The $runtimeType notifying listeners was:');
              information.write('  $this');
            }
        ));
      }
    }
  }
}