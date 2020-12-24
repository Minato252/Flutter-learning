import 'dart:async';
import 'dart:convert' as convert;
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/widgets.dart';

class Base64Convert {
  // static String base64Encode(String data) {
  //   var content = convert.utf8.encode(data);
  //   var digest = convert.base64Encode(content);
  //   return digest;
  // }
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
  // static image2Base64(String path) async {
  //   File file = new File(path);

  //   List<int> imageBytes = await file.readAsBytes();
  //   print("萨芬的拉开附近拉水电费");
  //   print("文件长度是：  " + imageBytes.length.toString());
  //   return convert.base64Encode(imageBytes);
  // }

  static Future image2Base64(String path) async {
    File file = new File(path);

    List<int> imageBytes = await file.readAsBytes();

    print("=======imageBytes=====");
    print(imageBytes);

    var r = base64Encode(imageBytes);

//debug===
    // r = "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";
//debug===

    return r;
  }

  /*
  * 将图片文件转换成Base64字符串
  */
  static Future imageFile2Base64(File file) async {
    List<int> imageBytes = await file.readAsBytes();

    return convert.base64Encode(imageBytes);
  }

  /*
  * 将Base64字符串的图片转换成图片
  */
  static Widget base642Image(String base64Txt) {
    Uint8List decodeTxt = convert.base64.decode(base64Txt);
    // Uint8List decodeTxt = convert
    //     .base64Decode(base64Txt.replaceAll('\r', '').replaceAll('\n', ''));
    print("***************这是base64解码后的字符串*************");
    print(decodeTxt);

//debug======
//debug======

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
