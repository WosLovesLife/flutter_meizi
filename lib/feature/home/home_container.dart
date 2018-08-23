import 'package:flutter/material.dart';
import 'package:flutter_meizi/component/rebuild_layout.dart';

//import 'package:flutter_meizi/component/my_page_view.dart';
import 'package:flutter_meizi/feature/photo_list/photo_list_container.dart';
import 'package:flutter_meizi/feature/android_list/android_list_container.dart';

class HomeContainer extends StatefulWidget {
  @override
  _HomeContainerState createState() => new _HomeContainerState();
}

class _HomeContainerState extends State<HomeContainer> {
  PageController _pageController;
  RebuildLayoutController rebuildLayoutController;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();

    _pageController = new PageController();
    rebuildLayoutController = RebuildLayoutController();
  }

  @override
  Widget build(BuildContext context) {
    print('build');
    return new Scaffold(
      appBar: new AppBar(
        title: new Text('Mei Zi'),
      ),
      body: PageView(
        children: <Widget>[
          new Container(
            child: new PhotoList(),
          ),
          Container(
            child: new AndroidNewsList(),
          ),
        ],
        controller: _pageController,
        physics: NeverScrollableScrollPhysics(),
        onPageChanged: (int index) {
          _currentIndex = index;
          rebuildLayoutController.notification();
        },
      ),
      bottomNavigationBar: RebuildLayout(
          builder: (BuildContext context) {
            print('build');
            return BottomNavigationBar(
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
                _pageController.jumpToPage(index);
              },
              currentIndex: _currentIndex,
              type: BottomNavigationBarType.fixed,
            );
          },
          controller: rebuildLayoutController),
    );
  }
}
