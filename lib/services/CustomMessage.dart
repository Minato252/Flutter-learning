import 'dart:convert' show json;
import 'dart:developer' as developer;
import 'package:rongcloud_im_plugin/rongcloud_im_plugin.dart';

class CustomMessage extends MessageContent {
  static const String objectName = "message";

  String content;
  String extra;

  /// [content] 文本内容
  static CustomMessage obtain(String content) {
    CustomMessage msg = new CustomMessage();
    msg.content = content;
    return msg;
  }

  @override
  void decode(String jsonStr) {
    if (jsonStr == null) {
      developer.log("Flutter CustomMessage deocde error: no content",
          name: "RongIMClient.CustomMessage");
      return;
    }
    Map map = json.decode(jsonStr.toString());
    this.content = map["content"];
    this.extra = map["extra"];
    Map userMap = map["user"];
    super.decodeUserInfo(userMap);
    Map menthionedMap = map["mentionedInfo"];
    super.decodeMentionedInfo(menthionedMap);
    this.destructDuration = map["burnDuration"];
  }

  @override
  String encode() {
    Map map = {"content": this.content, "extra": this.extra};
    if (this.sendUserInfo != null) {
      Map userMap = super.encodeUserInfo(this.sendUserInfo);
      map["user"] = userMap;
    }
    if (this.mentionedInfo != null) {
      Map mentionedMap = super.encodeMentionedInfo(this.mentionedInfo);
      map["mentionedInfo"] = mentionedMap;
    }
    if (this.destructDuration != null && this.destructDuration > 0) {
      map["burnDuration"] = this.destructDuration;
    }
    return json.encode(map);
  }

  @override
  String conversationDigest() {
    return content;
  }

  @override
  String getObjectName() {
    return objectName;
  }
}
