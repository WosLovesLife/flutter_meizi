import 'package:flutter/material.dart';
import 'package:flutter_meizi/component/load_more_view.dart';
import 'package:flutter_meizi/component/photo_view.dart';
import 'package:flutter_meizi/component/status_layout.dart';
import 'package:flutter_meizi/feature/android_list/android_item_view.dart';
import 'dart:async';

import 'package:flutter_meizi/model/bean/android_news.dart';
import 'package:flutter_meizi/model/net/gan_huo_api.dart';

class AndroidNewsContainer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text('Android news'),
      ),
      body: new AndroidNewsList(),
    );
  }
}

class AndroidNewsList extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => new _AndroidNewsListState();
}

class _AndroidNewsListState extends State<AndroidNewsList> with TickerProviderStateMixin {
  List<AndroidNews> dataSet = <AndroidNews>[];
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

    if (dataSet.length <= 0) {
      _loadData(1, false);
    }
  }

  _loadData(int page, bool isLoadMore) async {
//    final Completer<Null> completer = new Completer<Null>();
//    new Timer(const Duration(seconds: 2), () async {
//      completer.complete();
//    });
//    await completer.future;

    try {
      // fetch data from server
      List<AndroidNews> result = await FuLiApi.androidNews(page);

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
        if (isLoadMore) {
          // add more data
          dataSet.addAll(result);
        } else {
          // reset data
          dataSet.clear();
          dataSet.addAll(result);
          // clear the animations which in the current AndroidItemView
          for (var anim in photoItemAnimations) {
            anim.dispose();
          }
          photoItemAnimations.clear();
        }

        // make animations for AndroidItemView
        for (int i = 0; i < result.length; i++) {
          AnimationController controller =
              new AnimationController(vsync: this, duration: new Duration(milliseconds: 800));
          photoItemAnimations.add(controller);
          new Timer(new Duration(milliseconds: i * 150), () {
            controller.forward();
          });
        }

        statusLayoutController.setStatus(Status.content);

        if (dataSet.length >= 10) {
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

  /// 创建一个平移变换
  /// 跳转过去查看源代码，可以看到有各种各样定义好的变换
  static SlideTransition createTransition(Animation<double> animation, Widget child) {
    return new SlideTransition(
      position: new Tween<Offset>(
        begin: const Offset(1.0, 0.0),
        end: const Offset(0.0, 0.0),
      ).animate(animation),
      child: new FadeTransition(
        opacity: new Tween<double>(
          begin: 0.0,
          end: 1.0,
        ).animate(animation),
        child: child, // child is the value returned by pageBuilder
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return new Container(
      child: new StatusLayout(
          controller: statusLayoutController,
          child: new RefreshIndicator(
              child: new ListView.builder(
                physics: const AlwaysScrollableScrollPhysics(),
                itemBuilder: _buildItem,
                itemCount: dataSet.length + 1,
                padding: const EdgeInsets.symmetric(vertical: 2.0),
              ),
              onRefresh: _handleRefresh)),
    );
  }

  Widget _buildItem(BuildContext context, int index) {
    if (index == dataSet.length) {
      return new LoadMoreView(controller: loadMoreController);
    }
    return new GestureDetector(
        onTap: () {
          Navigator.of(context).push(new PageRouteBuilder(pageBuilder: (BuildContext context,
                  Animation<double> animation, Animation<double> secondaryAnimation) {
                return new PhotoView(
                  imageUrl: dataSet[index].url,
                  opacityController: photoItemAnimations[index],
                );
              }, transitionsBuilder: (
                BuildContext context,
                Animation<double> animation,
                Animation<double> secondaryAnimation,
                Widget child,
              ) {
                // 添加一个平移动画
                return createTransition(animation, child);
              }));
        },
        child: new AndroidItemView(dataSet[index], photoItemAnimations[index]));
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
