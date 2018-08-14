import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

class LoadMoreView extends StatefulWidget {
  final LoadMoreController controller;

  LoadMoreView({Key key, @required this.controller}) : super(key: key);

  @override
  State<StatefulWidget> createState() => new _LoadMoreViewState();
}

class _LoadMoreViewState extends State<LoadMoreView> {
  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_handleChange);
  }

  @override
  void didUpdateWidget(LoadMoreView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.controller != oldWidget.controller) {
      oldWidget.controller.removeListener(_handleChange);
      widget.controller.addListener(_handleChange);
    }
  }

  @override
  void dispose() {
    super.dispose();
    widget.controller.removeListener(_handleChange);
  }

  void _handleChange() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    if (widget.controller._status == LoadMoreStatus.prepare) {
      widget.controller._status = LoadMoreStatus.loading;
    }
    return ListTile(
      title: getContent(widget.controller.getStatus()),
      onTap: widget.controller._status == LoadMoreStatus.error ? () {} : null,
    );
  }

  Widget getContent(LoadMoreStatus status) {
    switch (status) {
      case LoadMoreStatus.prepare:
      case LoadMoreStatus.loading:
        return new Center(
          child: new Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              new CircularProgressIndicator(backgroundColor: Theme.of(context).primaryColor),
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

  // display the error tile and tap to retry
  error,
}

class LoadMoreController extends Listenable {
  final ObserverList<VoidCallback> _listeners = new ObserverList<VoidCallback>();

  LoadMoreStatus _status = LoadMoreStatus.idle;

  void setStatus(LoadMoreStatus newStatus) {
    assert(newStatus != null);
    if (newStatus == getStatus()) return;

    _status = newStatus;
    notifyOnStatusChangedListeners(newStatus);
  }

  LoadMoreStatus getStatus() {
    return _status;
  }

  // =============

  @override
  void addListener(listener) {
    _listeners.add(listener);
  }

  @override
  void removeListener(listener) {
    _listeners.remove(listener);
  }

  void notifyOnStatusChangedListeners(LoadMoreStatus status) {
    for (VoidCallback listener in new List<VoidCallback>.from(_listeners)) {
      try {
        if (_listeners.contains(listener)) listener();
      } catch (exception, stack) {
        FlutterError.reportError(
          new FlutterErrorDetails(
            exception: exception,
            stack: stack,
            library: 'LoadMoreView',
            context: 'while notifying listeners for $runtimeType',
            informationCollector: (StringBuffer information) {
              information.writeln('The $runtimeType notifying listeners was:');
              information.write('  $this');
            },
          ),
        );
      }
    }
  }
}
