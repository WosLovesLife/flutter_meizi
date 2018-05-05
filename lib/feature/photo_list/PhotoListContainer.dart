import 'package:flutter/material.dart';
import '../../model/bean/Photo.dart';
import '../../model/net/GanHuoApi.dart';
import '../../component/StatusLayout.dart';
import '../../component/LoadMoreView.dart';
import './PhotoItemView.dart';
import 'dart:async';

class PhotoListContainer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text('Mei Zi'),
      ),
      body: new PhotoList(),
    );
  }
}

class PhotoList extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => new _PhotoListState();
}

class _PhotoListState extends State<PhotoList> with TickerProviderStateMixin {
  List<Photo> photos = <Photo>[];
  List<AnimationController> photoItemAnimations = <AnimationController>[];
  StatusLayoutController statusLayoutController;
  LoadMoreController loadMoreController;
  int currentPage = 1;


  @override
  void initState() {
    super.initState();

    statusLayoutController = new StatusLayoutController();
    loadMoreController = new LoadMoreController();
    loadMoreController.addListener(_handleLoadMore);

    if (photos.length <= 0) {
      _loadData(1, false);
    }
  }

  _loadData(int page, bool isLoadMore) async {
    final Completer<Null> completer = new Completer<Null>();
    new Timer(const Duration(seconds: 2), () async {
      completer.complete();
    });
    await completer.future;

    try {
      // fetch data from server
      List<Photo> result = await FuLiApi.request(page);

      // display empty-content placeholder and reset load more status
      if (result.isEmpty) {
        setState(() {
          statusLayoutController.setStatus(Status.empty);
          if (isLoadMore) {
            loadMoreController.setStatus(LoadMoreStatus.noMore);
          } else {
            loadMoreController.setStatus(LoadMoreStatus.idle);
          }
        });
        return;
      }

      // display content and reset load more status
      setState(() {
        if (isLoadMore) { // add more data
          photos.addAll(result);
        } else { // reset data
          photos.clear();
          photos.addAll(result);
          // clear the animations which in the current PhotoItemView
          for (var anim in photoItemAnimations) {
            anim.dispose();
          }
          photoItemAnimations.clear();
        }

        // make animations for PhotoItemView
        for (int i = 0; i < result.length; i++) {
          AnimationController controller = new AnimationController(
              vsync: this, duration: new Duration(milliseconds: 800));
          photoItemAnimations.add(controller);
          new Timer(new Duration(milliseconds: i * 150), () {
            controller.forward();
          });
        }

        statusLayoutController.setStatus(Status.content);

        if (photos.length >= 10) {
          loadMoreController.setStatus(LoadMoreStatus.prepare);
        } else {
          loadMoreController.setStatus(LoadMoreStatus.noMore);
        }
      });
    } catch (e, s) {
      FlutterError.reportError(new FlutterErrorDetails(
        exception: e,
        stack: s,
        library: 'Photo List',
        context: 'while fetch photos from servers',
      ));
    }
  }

  @override
  void dispose() {
    for (var anim in photoItemAnimations) {
      anim.dispose();
    }
    loadMoreController.removeListener(_handleLoadMore);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return new Container(
      child: new StatusLayout(
          controller: statusLayoutController,
          child: new RefreshIndicator(
              child: new ListView.builder(
                physics: const AlwaysScrollableScrollPhysics(),
                itemBuilder: (BuildContext context, int index) {
                  if (index == photos.length) {
                    return new LoadMoreView(controller: loadMoreController,);
                  }
                  return new PhotoItemView(photos[index], photoItemAnimations[index]);
                },
                itemCount: photos.length + 1,
                padding: const EdgeInsets.symmetric(vertical: 2.0),
              ),
              onRefresh: _handleRefresh
          )
      ),
    );
  }

  Future<Null> _handleRefresh() async {
    final Completer<Null> completer = new Completer<Null>();
    await _loadData(currentPage = 1, false);
    completer.complete(null);
    return completer.future;
  }

  void _handleLoadMore() {
    loadMoreController.setStatus(LoadMoreStatus.loading);
    _loadData(++currentPage, true);
  }
}
