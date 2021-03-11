import 'dart:convert';
import 'dart:math';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:weitong/pages/imageEditor/common_widget.dart';
import 'package:weitong/pages/tree/tree.dart';
import 'package:weitong/services/providerServices.dart';
import 'package:weitong/widget/JdButton.dart';

import 'package:crypto/crypto.dart';

class SettingPage extends StatefulWidget {
  SettingPage({Key key}) : super(key: key);

  @override
  _SettingPageState createState() => _SettingPageState();
}

class _SettingPageState extends State<SettingPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("设置界面"),
      ),
      body: ListView(
        children: [
          Text("设置界面"),
          JdButton(
            text: "测试",
            cb: () async {
              await myText();
            },
          ),
          FlatButtonWithIcon(
              onPressed: () {}, icon: Icon(Icons.send), label: Text("发送"))
        ],
      ),
    );
  }

  myText() async {
    // SharedPreferences prefs = await SharedPreferences.getInstance();
    // print("***************************" +
    //     prefs.getString("name") +
    //     "*************************");
    String random = Random().nextInt(1000000).toString();

    String time = DateTime.now().microsecondsSinceEpoch.toString();
    String signature = "zj8jV9ls6U" + random + time;
    var bytes = utf8.encode(signature);
    // var rel =
    //     await Dio().post("http://api.sms.ronghub.com/sendNotify.json", data: {
    //   "RC-App-Key": "pwe86ga5ps8o6",
    //   "RC-Nonce": random,
    //   "RC-Timestamp": time,
    //   "RC-Signature": signature.hashCode.toString(),
    //   "Content-Type": "application/x-www-form-urlencoded",
    //   "region": "86",
    //   "templateId": "3LcaaXRMAIsbHzMoUvRBp_",
    //   "p1": "123",
    //   "p2": "456",
    //   "mobile": "18270015296"
    // });

    var dio = Dio();
    dio.options.contentType = "application/x-www-form-urlencoded";
    // dio.options.headers["Content-Type"] = "application/x-www-form-urlencoded";
    dio.options.headers["RC-App-Key"] = "pwe86ga5ps8o6";
    dio.options.headers["RC-Nonce"] = random;
    // dio.options.headers["RC-Signature"] = signature.hashCode.toString();
    dio.options.headers["RC-Signature"] = sha1.convert(bytes).toString();
    dio.options.headers["RC-Timestamp"] = time;
    var rel =
        await dio.post("http://api.sms.ronghub.com/sendNotify.json", data: {
      "region": "86",
      "templateId": "7LTilw6ik8Fb3UgkWKmYgi",
      "p1": "123", //接收人
      "p2": "456", //发送人
      "mobile": "18270015296"
    });

    // var rel =
    //     await Dio().post("http://api.sms.ronghub.com/sendNotify.json", data: {
    //   "headers": {
    //     "RC-App-Key": "pwe86ga5ps8o6",
    //     "RC-Nonce": random,
    //     "RC-Timestamp": time,
    //     "RC-Signature": signature.hashCode.toString(),
    //     "Content-Type": "application/x-www-form-urlencoded",
    //   },
    //   "data": {
    //     "region": "86",
    //     "templateId": "3LcaaXRMAIsbHzMoUvRBp_",
    //     "p1": "123",
    //     "p2": "456",
    //     "mobile": "18270015296"
    //   }
    // });
    print(rel.data);
  }
}

/**
 * 内容遮蔽
 * 遮蔽效果：对所有人展示、只对上级展示（目前不想具体到特定上级，只要是上级即可）、只对下级展示
 * 
 */
