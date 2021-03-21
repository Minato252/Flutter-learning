import 'dart:convert';
import 'dart:math';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rongcloud_im_plugin/rongcloud_im_plugin.dart';
import 'package:rongcloud_im_plugin/rongcloud_im_plugin.dart';
import 'package:rongcloud_im_plugin/rongcloud_im_plugin.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import 'package:weitong/Model/user_data.dart';
import 'package:weitong/pages/group/GroupMessageService.dart';
import 'package:weitong/pages/imageEditor/common_widget.dart';
import 'package:weitong/pages/tree/tree.dart';
import 'package:weitong/services/IM.dart';
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
            text: "创建群",
            cb: () async {
              // await _selectGruopMember();
              await _creatGruop();
            },
          ),
          FlatButtonWithIcon(
              onPressed: () async {
                await _searchGruopMember();
              },
              icon: Icon(Icons.send),
              label: Text("查询群成员")),
          FlatButtonWithIcon(
              onPressed: () async {
                await _reciveGroupMessage();
              },
              icon: Icon(Icons.send),
              label: Text("查询群消息")),
          FlatButtonWithIcon(
              onPressed: () async {
                // await _sendGroupMessage("18");
                List userList = ["222222"];
                String content = "群定向消息测试55555";
                await _sendDirectionMessage(userList, content);
              },
              icon: Icon(Icons.send),
              label: Text("发送群消息"))
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
  }

  _sendDirectionMessage(List userList, String messageContent) async {
    // List userList = ["18270015296"];
    TextMessage m = new TextMessage();
    m.content = messageContent;
    MessageContent content = m;
    var rel = await RongIMClient.sendDirectionalMessage(
        RCConversationType.Group, "19", userList, content);
    print(rel);
  }

  _creatGruop() async {
    String random = Random().nextInt(1000000).toString();

    String time = DateTime.now().microsecondsSinceEpoch.toString();
    // String signature = "zj8jV9ls6U" + random + time;
    String signature = RongAppSecret + random + time;
    var bytes = utf8.encode(signature);
    var uuid = Uuid();
    var groupId = uuid.v1();
    print("********************" + groupId);
    String menber = "18270015296,222222,55";

    var dio = Dio();
    dio.options.contentType = "application/x-www-form-urlencoded";
    // dio.options.headers["Content-Type"] = "application/x-www-form-urlencoded";
    // dio.options.headers["RC-App-Key"] = "pwe86ga5ps8o6";
    dio.options.headers["RC-App-Key"] = RongAppKey;
    dio.options.headers["RC-Nonce"] = random;
    // dio.options.headers["RC-Signature"] = signature.hashCode.toString();
    dio.options.headers["RC-Signature"] = sha1.convert(bytes).toString();
    dio.options.headers["RC-Timestamp"] = time;
    var rel = await dio.post("https://api-cn.ronghub.com/group/create.json",
        data: {"userId": menber, "groupId": "19", "groupName": "哈哈"});
    print(rel.data);
    await _sendGroupMessage("19");
  }

  _searchGruopMember() async {
    //2a2f7fd0-87d2-11eb-b427-c5e5521c8d73
    String random = Random().nextInt(1000000).toString();

    String time = DateTime.now().microsecondsSinceEpoch.toString();
    // String signature = "zj8jV9ls6U" + random + time;
    String signature = RongAppSecret + random + time;
    var bytes = utf8.encode(signature);
    // var uuid = Uuid();
    // var groupId = uuid.v1();

    //BOAF-OP9U-49KE-UAPH   messageUId
    //targetId 1ee17ce0-8a21-11eb-a0b1-115a42e92667

    var dio = Dio();
    dio.options.contentType = "application/x-www-form-urlencoded";
    // dio.options.headers["Content-Type"] = "application/x-www-form-urlencoded";
    // dio.options.headers["RC-App-Key"] = "pwe86ga5ps8o6";
    dio.options.headers["RC-App-Key"] = RongAppKey;
    dio.options.headers["RC-Nonce"] = random;
    // dio.options.headers["RC-Signature"] = signature.hashCode.toString();
    dio.options.headers["RC-Signature"] = sha1.convert(bytes).toString();
    dio.options.headers["RC-Timestamp"] = time;
    var rel = await dio.post("https://api-cn.ronghub.com/group/user/query.json",
        data: {"groupId": "BOAF-OP9U-49KE-UAPH"});
    print(rel.data);
  }

  _sendGroupMessage(String groupId) async {
    TextMessage txtMessage = new TextMessage();
    txtMessage.content = "这条消息来自 Flutter群消息，不要点击";
    Message msg = await RongIMClient.sendMessage(
        RCConversationType.Group, groupId, txtMessage);
    print(msg);

    // Message msg = await RongIMClient.sendMessage(
    //     RCConversationType.Private, "222222", txtMessage);
    // print("send message start senderUserId = " + msg.senderUserId);
  }

  _reciveGroupMessage() async {
    String groupId = "11";
// RongUserInfoManager.getInstance().getGroupInfo(groupId);
    var rel = await RongIMClient.getConversation(1, "11");
    // RongUserInfoManager.getInstance().getGroupInfo(groupId);
    print(rel);
  }
}
