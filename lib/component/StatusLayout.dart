import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

class StatusLayout extends StatefulWidget {
  final Widget child;
  final StatusLayoutController controller;

  StatusLayout({Key key, this.child, @required this.controller}) :super(key: key);

  @override
  State<StatefulWidget> createState() => new _StatusLayoutState();
}

class _StatusLayoutState extends State<StatusLayout> {

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_handleChange);
  }

  @override
  void didUpdateWidget(StatusLayout oldWidget) {
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

  void _handleChange(Status status) {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return new Container(
      child: getContent(widget.controller.getStatus()),
    );
  }

  Widget getContent(Status status) {
    switch (status) {
      case Status.empty:
        return new Center(
          child: new FlutterLogo(size: 48.0),
        );
      case Status.loading:
        return new Center(
          child: new CircularProgressIndicator(backgroundColor: Theme
              .of(context)
              .primaryColor),
        );
      case Status.content:
        return widget.child;
      default:
        return null;
    }
  }
}

/// The status of an animation
enum Status {
  // display the empty placeholder
  empty,

  // display the circle progress indicator as a placeholder
  loading,

  // display the content
  content,
}

typedef void OnStatusChangedListener(Status status);

class StatusLayoutController {
  final ObserverList<OnStatusChangedListener> _listeners = new ObserverList<
      OnStatusChangedListener>();

  Status _status = Status.loading;

  void setStatus(Status newStatus) {
    assert(newStatus != null);
    _status = newStatus;
    notifyListeners(newStatus);
  }

  Status getStatus() {
    return _status;
  }

  void addListener(OnStatusChangedListener listener) {
    _listeners.add(listener);
  }

  void removeListener(OnStatusChangedListener listener) {
    _listeners.remove(listener);
  }

  void notifyListeners(Status status) {
    for (OnStatusChangedListener listener in new List<OnStatusChangedListener>.from(_listeners)) {
      try {
        if (_listeners.contains(listener))
          listener(status);
      } catch (exception, stack) {
        FlutterError.reportError(new FlutterErrorDetails(
            exception: exception,
            stack: stack,
            library: 'StatusLayout',
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