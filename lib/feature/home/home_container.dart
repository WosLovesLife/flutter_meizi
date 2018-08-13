import 'package:flutter/material.dart' hide PageController, PageView;
import 'package:flutter_meizi/component/view_pager.dart';
import 'package:flutter_meizi/feature/photo_list/photo_list_container.dart';
import 'package:flutter_meizi/feature/android_list/android_list_container.dart';

class HomeContainer extends StatefulWidget {
  @override
  _HomeContainerState createState() => new _HomeContainerState();
}

class _HomeContainerState extends State<HomeContainer> {
  ViewPagerController _pageController;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();

    _pageController = new ViewPagerController()
      ..addListener((int index, bool withAnim) {
        setState(() {
          _currentIndex = index;
        });
      });

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
            child: new PhotoList(),
          ),
          Container(
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
          _pageController.setIndex(index, true);
        },
        currentIndex: _currentIndex,
      ),
    );
  }
}
