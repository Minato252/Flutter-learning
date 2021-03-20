import 'dart:convert';
import 'dart:math';

import 'package:dio/dio.dart';
import 'package:rongcloud_im_plugin/rongcloud_im_plugin.dart';
import 'package:uuid/uuid.dart';
import 'package:weitong/Model/user_data.dart';
import 'package:crypto/crypto.dart';

class GroupMessageService {
  static Future<void> creatGruop(String groupId, String groupName,
      String member, String messageContent) async {
    String random = Random().nextInt(1000000).toString();

    String time = DateTime.now().microsecondsSinceEpoch.toString();
    // String signature = "zj8jV9ls6U" + random + time;
    String signature = RongAppSecret + random + time;
    var bytes = utf8.encode(signature);
    // var uuid = Uuid();
    // var groupId = uuid.v1();
    // print("********************" + groupId);

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
        data: {"userId": member, "groupId": groupId, "groupName": groupName});
    print(rel.data);

    if (rel.data["code"] == 200) {
      var r = await sendGroupMessage(groupId, messageContent);
      print(r);
    }
    return rel.data;
  }

  static Future<String> searchGruopMember(String gropuId) async {
    //2a2f7fd0-87d2-11eb-b427-c5e5521c8d73
    String random = Random().nextInt(1000000).toString();

    String time = DateTime.now().microsecondsSinceEpoch.toString();
    // String signature = "zj8jV9ls6U" + random + time;
    String signature = RongAppSecret + random + time;
    var bytes = utf8.encode(signature);
    // var uuid = Uuid();
    // var groupId = uuid.v1();

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
        data: {"groupId": gropuId});
    print(rel.data);
    return rel.data;
  }

  static Future sendGroupMessage(String groupId, String messageContent) async {
    TextMessage txtMessage = new TextMessage();
    txtMessage.content = messageContent;
    Message msg = await RongIMClient.sendMessage(
        RCConversationType.Group, groupId, txtMessage);
    return msg;
  }

  static creatGruop2(String groupId, String groupName, String member,
      String messageContent) async {
    String random = Random().nextInt(1000000).toString();

    String time = DateTime.now().microsecondsSinceEpoch.toString();
    // String signature = "zj8jV9ls6U" + random + time;
    String signature = RongAppSecret + random + time;
    var bytes = utf8.encode(signature);
    // var uuid = Uuid();
    // var groupId = uuid.v1();
    print("********************" + groupId);
    // String menber = "18270015296,222222";

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
        data: {"userId": member, "groupId": groupId, "groupName": groupName});
    print(rel);
    print(rel.data);
    await sendGroupMessage2(groupId);
  }

  static sendGroupMessage2(String groupId) async {
    TextMessage txtMessage = new TextMessage();
    txtMessage.content = "这条消息来自 Flutter";
    Message msg = await RongIMClient.sendMessage(
        RCConversationType.Group, groupId, txtMessage);
    print(msg);

    // Message msg = await RongIMClient.sendMessage(
    //     RCConversationType.Private, "222222", txtMessage);
    // print("send message start senderUserId = " + msg.senderUserId);
  }
}
