//{
//"_id": "5b17f772421aa910a82cf51a",
//"createdAt": "2018-06-07T11:41:31.949Z",
//"desc": "\u8584\u8377\u5065\u5eb7\u4f53\u91cd\u9009\u62e9\u63a7\u4ef6\u3002",
//"images": [
//"http://img.gank.io/731d1a9b-04ea-4d2f-b4c7-7418d87aa8fe"
//],
//"publishedAt": "2018-06-07T00:00:00.0Z",
//"source": "chrome",
//"type": "Android",
//"url": "https://github.com/totond/BooheeRuler",
//"used": true,
//"who": "\u827e\u7c73"
//}

const String SMALL_URL_SUFFIX = '?imageView2/0/w/600';

class AndroidNews {
  String _id;
  String createAt;
  String desc;
  List<String> images;
  String publishedAt;
  String source;
  String type;
  String url;
  bool used;
  String who;

  AndroidNews(this._id, this.createAt, this.desc, this.images, this.publishedAt, this.source,
      this.type, this.url, this.used, this.who);

  String get id => _id;

  String get image => images != null ? images[0] : null;

  String get smallImage =>
      (images != null && images.isNotEmpty) ? images[0] + SMALL_URL_SUFFIX : null;
}
