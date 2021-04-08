import 'dart:io';
import 'dart:typed_data';
import 'dart:ui';
import 'package:crypto/crypto.dart';
import 'dart:convert' as convert;

import 'package:http/http.dart' as http;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

class MyNetworkImage extends ImageProvider<MyNetworkImage> {
  /// Creates an object that fetches the image at the given URL.
  ///
  /// The arguments must not be null.
  const MyNetworkImage(this.url, {this.scale = 1.0, this.headers, this.sdCache})
      : assert(url != null),
        assert(scale != null);

  /// The URL from which the image will be fetched.
  final String url;

  final bool sdCache; //加一个标志为  是否需要缓存到sd卡

  /// The scale to place in the [ImageInfo] object of the image.
  final double scale;

  /// The HTTP headers that will be used with [HttpClient.get] to fetch image from network.
  final Map<String, String> headers;

  @override
  Future<MyNetworkImage> obtainKey(ImageConfiguration configuration) {
    return SynchronousFuture<MyNetworkImage>(this);
  }

  @override
  ImageStreamCompleter load(MyNetworkImage key, DecoderCallback decode) {
    return MultiFrameImageStreamCompleter(
      codec: _loadAsync(key),
      scale: key.scale,
      informationCollector: () {},
      chunkEvents: null,

      // informationCollector: (StringBuffer information) {
      //   information.writeln('Image provider: $this');
      //   information.write('Image key: $key');
      // }
    );
  }

  @override
  Future<Codec> _loadAsync(MyNetworkImage key) async {
    assert(key == this);
    //本地已经缓存过就直接返回图片
    if (sdCache != null) {
      final Uint8List bytes = await _getFromSdcard(key.url);
      if (bytes != null &&
          bytes.lengthInBytes != null &&
          bytes.lengthInBytes != 0) {
        print("success");
        return await PaintingBinding.instance.instantiateImageCodec(bytes);
      }
    }
    final Uri resolved = Uri.base.resolve(key.url);
    http.Response response = await http.get(resolved);

    if (response.statusCode != HttpStatus.ok)
      throw Exception(
          'HTTP request failed, statusCode: ${response?.statusCode}, $resolved');

    final Uint8List bytes = await response.bodyBytes;
//网络请求结束后缓存图片到本地
    if (sdCache != null && bytes.lengthInBytes != 0) {
      _saveToImage(bytes, key.url);
    }
    if (bytes.lengthInBytes == 0)
      throw Exception('MyNetworkImage is an empty file: $resolved');

    return await PaintingBinding.instance.instantiateImageCodec(bytes);
  }

  @override
  bool operator ==(dynamic other) {
    if (other.runtimeType != runtimeType) return false;
    final MyNetworkImage typedOther = other;
    return url == typedOther.url && scale == typedOther.scale;
  }

  @override
  int get hashCode => hashValues(url, scale);

  @override
  String toString() => '$runtimeType("$url", scale: $scale)';

// 图片路径MD5一下 缓存到本地
  void _saveToImage(Uint8List mUint8List, String name) async {
    name = md5.convert(convert.utf8.encode(name)).toString();
    Directory dir = await getTemporaryDirectory();
    String path = dir.path + "/" + name;
    var file = File(path);
    bool exist = await file.exists();
    print("**********************path =${path}");
    if (!exist) File(path).writeAsBytesSync(mUint8List);
  }

  _getFromSdcard(String name) async {
    name = md5.convert(convert.utf8.encode(name)).toString();
    Directory dir = await getTemporaryDirectory();
    String path = dir.path + "/" + name;
    var file = File(path);
    bool exist = await file.exists();
    if (exist) {
      final Uint8List bytes = await file.readAsBytes();
      return bytes;
    }
    return null;
  }
}

class CacheFileImage {
  /// 获取url字符串的MD5值
  static String getUrlMd5(String url) {
    var content = new convert.Utf8Encoder().convert(url);
    var digest = md5.convert(content);
    return digest.toString();
  }

  /// 获取图片缓存路径
  Future<String> getCachePath() async {
    Directory dir = await getApplicationDocumentsDirectory();
    Directory cachePath = Directory("${dir.path}/imagecache/");
    if (!cachePath.existsSync()) {
      cachePath.createSync();
    }
    return cachePath.path;
  }

  /// 判断是否有对应图片缓存文件存在
  Future<Uint8List> getFileBytes(String url) async {
    String cacheDirPath = await getCachePath();
    String urlMd5 = getUrlMd5(url);
    File file = File("$cacheDirPath/$urlMd5");
    print("读取文件:${file.path}");
    if (file.existsSync()) {
      return await file.readAsBytes();
    }

    return null;
  }

  /// 将下载的图片数据缓存到指定文件
  Future saveBytesToFile(String url, Uint8List bytes) async {
    String cacheDirPath = await getCachePath();
    String urlMd5 = getUrlMd5(url);
    File file = File("$cacheDirPath/$urlMd5");
    if (!file.existsSync()) {
      file.createSync();
      await file.writeAsBytes(bytes);
    }
  }
}
//博客地址 https://blog.csdn.net/weixin_43499085/article/details/88842438
