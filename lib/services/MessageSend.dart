import 'dart:async';
import 'dart:convert' as convert;
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/widgets.dart';

//发送图片消息方法
class ImageMessageSend {
  static String base64Encode(List<int> data) {
    // var content = convert.utf8.encode(data);
    var digest = convert.base64Encode(data);
    return digest;
  }

  /*
  * Base64解密
  */
  static String base64Decode(String data) {
    List<int> bytes = convert.base64Decode(data);
    // 网上找的很多都是String.fromCharCodes，这个中文会乱码
    //String txt1 = String.fromCharCodes(bytes);
    String result = convert.utf8.decode(bytes);
    return result;
  }

  /*
  * 通过图片路径将图片转换成Base64字符串
  */
  static Future image2Base64(String path) async {
    File file = new File(path);

    List<int> imageBytes = await file.readAsBytes();

    var r = base64Encode(imageBytes);

    return r;
  }

  /*
  * 将Base64字符串的图片转换成图片
  */
  static Widget base642Image(String base64Txt) {
    Uint8List decodeTxt = convert.base64.decode(base64Txt);

    return Image.memory(
      decodeTxt,

      width: 100, fit: BoxFit.fitWidth,
      gaplessPlayback: true, //防止重绘
      repeat: ImageRepeat.noRepeat,
      scale: 1.0,
    );

    // return decodeTxt;
  }
}
