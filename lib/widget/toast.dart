import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class MyToast {
  static AlertMesaage(String msg, {var color = Colors.red}) {
    Fluttertoast.showToast(
        msg: msg,
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM, // 消息框弹出的位置
        timeInSecForIosWeb: 1, // 消息框持续的时间（目前的版本只有ios有效）
        backgroundColor: color,
        textColor: Colors.white,
        fontSize: 16.0);
  }
}
