/*
example:
{
"_id": "5aa5cc6a421aa9103ed33c7c",
"createdAt": "2018-03-12T08:40:10.360Z",
"desc": "3-12",
"publishedAt": "2018-03-12T08:44:50.326Z",
"source": "chrome",
"type": "\u798f\u5229",
"url": "https://ws1.sinaimg.cn/large/610dc034ly1fp9qm6nv50j20u00miacg.jpg",
"used": true,
"who": "daimajia"
}
*/

class Photo {
  String _id;
  String createAt;
  String desc;
  String publishedAt;
  String source;
  String type;
  String url;
  bool used;
  String who;

  Photo(this._id, this.createAt, this.desc, this.publishedAt, this.source, this.type, this.url,
      this.used, this.who);

  String get id => _id;

  String get smallUrl => url + '?imageView2/0/w/300';
}