import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

final PageController _defaultPageController = new PageController();
const PageScrollPhysics _kPagePhysics = PageScrollPhysics();

class PageView extends StatefulWidget {
  /// Creates a scrollable list that works page by page from an explicit [List]
  /// of widgets.
  ///
  /// This constructor is appropriate for page views with a small number of
  /// children because constructing the [List] requires doing work for every
  /// child that could possibly be displayed in the page view, instead of just
  /// those children that are actually visible.
  PageView({
    Key key,
    this.scrollDirection = Axis.horizontal,
    this.reverse = false,
    PageController controller,
    this.physics,
    this.pageSnapping = true,
    this.onPageChanged,
    List<Widget> children = const <Widget>[],
    this.cacheCount = 0,
  })  : controller = controller ?? _defaultPageController,
        childrenDelegate = new SliverChildListDelegate(children),
        super(key: key);

  /// Creates a scrollable list that works page by page using widgets that are
  /// created on demand.
  ///
  /// This constructor is appropriate for page views with a large (or infinite)
  /// number of children because the builder is called only for those children
  /// that are actually visible.
  ///
  /// Providing a non-null [itemCount] lets the [PageView] compute the maximum
  /// scroll extent.
  ///
  /// [itemBuilder] will be called only with indices greater than or equal to
  /// zero and less than [itemCount].
  PageView.builder({
    Key key,
    this.scrollDirection = Axis.horizontal,
    this.reverse = false,
    PageController controller,
    this.physics,
    this.pageSnapping = true,
    this.onPageChanged,
    @required IndexedWidgetBuilder itemBuilder,
    int itemCount,
    this.cacheCount = 0,
  })  : controller = controller ?? _defaultPageController,
        childrenDelegate = new SliverChildBuilderDelegate(itemBuilder, childCount: itemCount),
        super(key: key);

  /// Creates a scrollable list that works page by page with a custom child
  /// model.
  PageView.custom({
    Key key,
    this.scrollDirection = Axis.horizontal,
    this.reverse = false,
    PageController controller,
    this.physics,
    this.pageSnapping = true,
    this.onPageChanged,
    @required this.childrenDelegate,
    this.cacheCount = 0,
  })  : assert(childrenDelegate != null),
        controller = controller ?? _defaultPageController,
        super(key: key);

  /// The axis along which the page view scrolls.
  ///
  /// Defaults to [Axis.horizontal].
  final Axis scrollDirection;

  /// Whether the page view scrolls in the reading direction.
  ///
  /// For example, if the reading direction is left-to-right and
  /// [scrollDirection] is [Axis.horizontal], then the page view scrolls from
  /// left to right when [reverse] is false and from right to left when
  /// [reverse] is true.
  ///
  /// Similarly, if [scrollDirection] is [Axis.vertical], then the page view
  /// scrolls from top to bottom when [reverse] is false and from bottom to top
  /// when [reverse] is true.
  ///
  /// Defaults to false.
  final bool reverse;

  /// An object that can be used to control the position to which this page
  /// view is scrolled.
  final PageController controller;

  /// How the page view should respond to user input.
  ///
  /// For example, determines how the page view continues to animate after the
  /// user stops dragging the page view.
  ///
  /// The physics are modified to snap to page boundaries using
  /// [PageScrollPhysics] prior to being used.
  ///
  /// Defaults to matching platform conventions.
  final ScrollPhysics physics;

  /// Set to false to disable page snapping, useful for custom scroll behavior.
  final bool pageSnapping;

  /// Called whenever the page in the center of the viewport changes.
  final ValueChanged<int> onPageChanged;

  /// A delegate that provides the children for the [PageView].
  ///
  /// The [PageView.custom] constructor lets you specify this delegate
  /// explicitly. The [PageView] and [PageView.builder] constructors create a
  /// [childrenDelegate] that wraps the given [List] and [IndexedWidgetBuilder],
  /// respectively.
  final SliverChildDelegate childrenDelegate;

  final int cacheCount;

  @override
  _PageViewState createState() => new _PageViewState();
}

class _PageViewState extends State<PageView> {
  int _lastReportedPage = 0;

  @override
  void initState() {
    super.initState();

    _lastReportedPage = widget.controller.initialPage;
  }

  AxisDirection _getDirection(BuildContext context) {
    switch (widget.scrollDirection) {
      case Axis.horizontal:
        assert(debugCheckHasDirectionality(context));
        final TextDirection textDirection = Directionality.of(context);
        final AxisDirection axisDirection = textDirectionToAxisDirection(textDirection);
        return widget.reverse ? flipAxisDirection(axisDirection) : axisDirection;
      case Axis.vertical:
        return widget.reverse ? AxisDirection.up : AxisDirection.down;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final AxisDirection axisDirection = _getDirection(context);
    final ScrollPhysics physics =
        widget.pageSnapping ? _kPagePhysics.applyTo(widget.physics) : widget.physics;

    return LayoutBuilder(builder: (BuildContext context, BoxConstraints constraints) {
      return new NotificationListener<ScrollNotification>(
        onNotification: (ScrollNotification notification) {
          if (notification.depth == 0 &&
              widget.onPageChanged != null &&
              notification is ScrollUpdateNotification) {
            final PageMetrics metrics = notification.metrics;
            final int currentPage = metrics.page.round();
            if (currentPage != _lastReportedPage) {
              _lastReportedPage = currentPage;
              widget.onPageChanged(currentPage);
            }
          }
          return false;
        },
        child: new Scrollable(
          axisDirection: axisDirection,
          controller: widget.controller,
          physics: physics,
          viewportBuilder: (BuildContext context, ViewportOffset position) {
            return new Viewport(
              cacheExtent: widget.cacheCount * constraints.maxWidth - 1,
              axisDirection: axisDirection,
              offset: position,
              slivers: <Widget>[
                new SliverFillViewport(
                    viewportFraction: widget.controller.viewportFraction,
                    delegate: widget.childrenDelegate),
              ],
            );
          },
        ),
      );
    });
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder description) {
    super.debugFillProperties(description);
    description.add(new EnumProperty<Axis>('scrollDirection', widget.scrollDirection));
    description.add(new FlagProperty('reverse', value: widget.reverse, ifTrue: 'reversed'));
    description.add(
        new DiagnosticsProperty<PageController>('controller', widget.controller, showName: false));
    description
        .add(new DiagnosticsProperty<ScrollPhysics>('physics', widget.physics, showName: false));
    description.add(
        new FlagProperty('pageSnapping', value: widget.pageSnapping, ifFalse: 'snapping disabled'));
  }
}
