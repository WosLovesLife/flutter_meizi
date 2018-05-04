import 'dart:io';
import 'dart:convert';
import 'dart:async';
import '../Constants.dart';
import '../bean/Photo.dart';

class Fuli {

  static Future<List<Photo>> request(int page) async {
    var httpClient = new HttpClient();

    try {
      var uri = new Uri.http(
        GAN_HUO_URL_BASE,
        GAN_HUO_PATH_FULI + '/10/' + page.toString(),
      );
      var request = await httpClient.getUrl(uri);
      var response = await request.close();
      if (response.statusCode != HttpStatus.OK) {
        throw new HttpException('网络错误');
      }

      var responseBody = await response.transform(UTF8.decoder).join();
      var map = JSON.decode(responseBody);

      if (map['error']) {
        throw new HttpException('数据错误');
      }

      var results = map['results'];
      assert(results is List);
      return (results as List).map((res) {
        return new Photo(
            res['_id'],
            res['createAt'],
            res['desc'],
            res['publishedAt'],
            res['source'],
            res['type'],
            res['url'],
            res['used'],
            res['who']);
      }).toList(growable: false);
    } catch (exception) {
      throw new HttpException('网络错误');
    }
  }
}