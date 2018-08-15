import 'package:flutter/material.dart';
import 'package:flutter_meizi/component/my_tab_bar_view.dart' as MyTabBarView;
import 'package:flutter_meizi/component/my_page_view.dart' as MyPageView;

main() {
  runApp(MaterialApp(
    home: Test5(),
  ));
}

class Test extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    TabBarView(children: null);
    Size size = MediaQuery.of(context).size;
    print('size = $size');
    return Container(
      child: Text("hello world"),
    );
  }
}

class Test2 extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (BuildContext context, BoxConstraints constraints) {
      SingleChildScrollView(
        child: Container(
          child: SliverList(
              delegate: SliverChildListDelegate([
            Container(
              width: constraints.maxWidth,
              height: constraints.maxHeight,
              color: Colors.red,
              child: Center(child: Text("left")),
            ),
            Container(
              width: constraints.maxWidth,
              height: constraints.maxHeight,
              color: Colors.blue,
              child: Center(child: Text("right")),
            ),
          ])),
        ),
      );
    });
  }
}

class Test3 extends StatefulWidget {
  @override
  Test3State createState() {
    return new Test3State();
  }
}

class Test3State extends State<Test3> with TickerProviderStateMixin {
  TabController tabController;

  @override
  void initState() {
    super.initState();
    tabController = TabController(initialIndex: 0, length: 5, vsync: this);
  }

  @override
  void dispose() {
    super.dispose();
    tabController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    List<int> pages = [1, 2, 3, 4, 5];
    List<int> data = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16];
    return Scaffold(
      appBar: AppBar(
        title: TabBar(
          tabs: pages.map((i) {
            return Tab(
              text: "tab$i",
              icon: Icon(Icons.image),
            );
          }).toList(),
          controller: tabController,
        ),
      ),
      body: MyTabBarView.TabBarView(
        controller: tabController,
        children: pages.map((i) {
          return Container(
            height: double.infinity,
            color: Colors.red,
            child: ListView(
              children: data.map((i) {
                return ListTile(
                  title: Text("数据$i"),
                );
              }).toList(),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class Test4 extends StatefulWidget {
  @override
  Test4State createState() {
    return new Test4State();
  }
}

class Test4State extends State<Test4> with TickerProviderStateMixin {
  PageController pageController;

  @override
  void initState() {
    super.initState();
    pageController = PageController();
  }

  @override
  Widget build(BuildContext context) {
    List<int> pages = [1, 2, 3, 4, 5, 6, 7, 8];
    List<int> data = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16];
    return Scaffold(
      appBar: AppBar(),
      body: MyPageView.PageView(
        controller: pageController,
        children: pages.map((i) {
          return Container(
            height: double.infinity,
            color: Colors.red,
            child: ListView(
              children: data.map((i) {
                return ListTile(
                  title: Text("数据$i"),
                );
              }).toList(),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class Test5 extends StatefulWidget {
  @override
  Test5State createState() {
    return new Test5State();
  }
}

class Test5State extends State<Test5> {
  PageController _pageController;
  int _pageIndex = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController()
      ..addListener(() {
        if (_pageIndex != _pageController.page.round()) {
          print('onScorll');
          setState(() {
            _pageIndex = _pageController.page.round();
          });
        }
      });
  }

  @override
  Widget build(BuildContext context) {
    List<int> pages = [1, 2, 3, 4];
    List<int> data = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16];
    return Scaffold(
      appBar: AppBar(),
      body: MyPageView.PageView(
        children: pages.map((i) {
          return Container(
            height: double.infinity,
            color: Colors.red,
            child: ListView(
              children: data.map((n) {
                return ListTile(
                  title: Text("第$i页的第$n个条目"),
                );
              }).toList(),
            ),
          );
        }).toList(),
        controller: _pageController,
        cacheCount: 1,
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: pages.map((i) {
          return BottomNavigationBarItem(
            title: Text(
              "Item$i",
              style: Theme.of(context).textTheme.subhead.copyWith(color: Colors.red),
            ),
            icon: Icon(
              Icons.access_alarm,
              color: Colors.red,
            ),
          );
        }).toList(),
        currentIndex: _pageIndex,
        onTap: (int page) {
          _pageController.animateToPage(
            page,
            duration: Duration(milliseconds: 260),
            curve: Curves.fastOutSlowIn,
          );
        },
      ),
    );
  }
}

class Test6 extends StatefulWidget {
  @override
  Test6State createState() {
    return new Test6State();
  }
}

class Test6State extends State<Test6> {
  PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  Widget build(BuildContext context) {
    List<int> pages = [1, 2, 3, 4];
    List<int> data = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16];
    return Scaffold(
      appBar: AppBar(),
      body: PageView(
        children: pages.map((i) {
          return Container(
            height: double.infinity,
            color: Colors.red,
            child: Test6Page(i, data),
          );
        }).toList(),
        controller: _pageController,
      ),
    );
  }
}

class Test6Page extends StatefulWidget {
  final int pageIndex;
  final List<int> data;

  Test6Page(this.pageIndex, this.data);

  @override
  _Test6PageState createState() => _Test6PageState();
}

class _Test6PageState extends State<Test6Page> with AutomaticKeepAliveClientMixin {

  @override
  void initState() {
    super.initState();
    print('initState');
  }

  @override
  void dispose() {
    print('dispose');
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: widget.data.map((n) {
        return ListTile(
          title: Text("第${widget.pageIndex}页的第$n个条目"),
        );
      }).toList(),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
