import 'package:flutter/material.dart';
import 'model/bean/Photo.dart';
import 'model/net/GanHuoApi.dart';
import 'package:cached_network_image/cached_network_image.dart';

class PhotoListFragment extends StatelessWidget {
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

class _PhotoListState extends State<PhotoList> {
  List<Photo> photos = <Photo>[];

  @override
  void initState() {
    super.initState();

    if (photos.length <= 0) {
      _loadData();
    }
  }

  _loadData() async {
    try {
      List<Photo> result = await Fuli.request(1);
      setState(() {
        photos.addAll(result);
      });

      setState(() {});
    } catch (e) {
      print('加载图片错误 = ' + e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return new Container(
      child: new ListView.builder(
        itemBuilder: (BuildContext context, int index) {
          return new PhotoItem(photos[index]);
        },
        itemCount: photos.length,
        padding: const EdgeInsets.symmetric(vertical: 2.0),
      ),
    );
  }
}

class PhotoItem extends StatelessWidget {
  PhotoItem(this.photo);

  final Photo photo;

  @override
  Widget build(BuildContext context) {
    return new Center(
        child: new Card(
          elevation: 2.0,
          child: new Container(
            width: double.INFINITY,
            height: 300.0,
            color: Colors.purple,
            child: new CachedNetworkImage(
              fit: BoxFit.cover,
              imageUrl: photo.smallUrl,
              placeholder: new Icon(Icons.photo, size: 56.0),
              errorWidget: new Icon(Icons.warning, size: 56.0),
            ),
          ),
        )
    );
  }
}