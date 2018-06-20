import 'package:flutter/material.dart';
import 'package:flutter_meizi/component/ViewPager.dart';
import 'package:flutter_meizi/feature/photo_list/PhotoListContainer.dart';
import 'package:flutter_meizi/feature/android_list/AndroidListContainer.dart';

class HomeContainer extends StatefulWidget {
  @override
  _HomeContainerState createState() => new _HomeContainerState();
}

class _HomeContainerState extends State<HomeContainer> {
  ViewPagerController _pageController;
  int _currentIndex = 0;
  PageStorageKey _photoListKey;
  PageStorageKey _androidNewsListKey;

  @override
  void initState() {
    super.initState();

    _pageController = new ViewPagerController()
      ..addListener((int index, bool withAnim) {
        setState(() {
          _currentIndex = index;
        });
      });

    _photoListKey = new PageStorageKey('_photoListKey');
    _androidNewsListKey = new PageStorageKey('_androidNewsListKey');
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text('Mei Zi'),
      ),
      body: ViewPager(
        children: <Widget>[
          new Container(
            key: _photoListKey,
            child: new PhotoList(),
          ),
          Container(
            key: _androidNewsListKey,
            child: new AndroidNewsList(),
          ),
        ],
        controller: _pageController,
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: [
          BottomNavigationBarItem(
            icon: Icon(
              Icons.home,
            ),
            title: Text('MeiZi'),
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.android,
            ),
            title: Text('Android'),
          ),
        ],
        onTap: (int index) {
          _currentIndex = index;
          _pageController.setIndex(index, false);
        },
        currentIndex: _currentIndex,
      ),
    );
  }
}
