import 'package:rongcloud_im_plugin/rongcloud_im_plugin.dart';

class IM {
  static Future<Message> sendMessage(String content, String targetId) async {
    //发送单聊消息
    TextMessage txtMessage = new TextMessage();

    txtMessage.content = content;
    Message msg = await RongIMClient.sendMessage(
        RCConversationType.Private, targetId, txtMessage);
    // print("send message start senderUserId = " + msg.senderUserId);
    print("msg" + msg.toString());
    return msg;
  }

  static Future<Message> sendGroupMessage(
      String content, String targetId) async {
    //发送单聊消息
    TextMessage txtMessage = new TextMessage();

    txtMessage.content = content;
    Message msg = await RongIMClient.sendMessage(
        RCConversationType.Group, targetId, txtMessage);
    // print("send message start senderUserId = " + msg.senderUserId);
    print("msg" + msg.toString());
    return msg;
  }
}
