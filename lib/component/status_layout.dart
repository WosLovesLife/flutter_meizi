import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

typedef Widget StatusLayoutBuilder(BuildContext context);

class StatusLayout extends StatefulWidget {
  final StatusLayoutBuilder builder;
  final StatusLayoutController controller;

  StatusLayout({Key key, this.builder, @required this.controller}) : super(key: key);

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
    switch (widget.controller._status) {
      case Status.empty:
        return new Center(
          child: new FlutterLogo(size: 48.0),
        );
      case Status.loading:
        return new Center(
          child: new CircularProgressIndicator(backgroundColor: Theme.of(context).primaryColor),
        );
      case Status.content:
        return widget.builder == null ? Wrap() : widget.builder(context);
      case Status.error:
        return Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text("出现了错误"),
              Padding(padding: EdgeInsets.only(top: 12.0)),
            ],
          ),
        );
      default:
        return Wrap();
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

  // display the error page and retry button
  error,
}

typedef void OnStatusChangedListener(Status status);

class StatusLayoutController {
  final ObserverList<OnStatusChangedListener> _listeners =
      new ObserverList<OnStatusChangedListener>();

  StatusLayoutController({Status status}) : _status = status;

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
        if (_listeners.contains(listener)) listener(status);
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
