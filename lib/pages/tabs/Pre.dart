import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:weitong/Model/messageModel.dart';
import 'package:weitong/Model/style.dart';
import 'package:weitong/services/IM.dart';

List friends = [];
Scrollbar getPre(MessageModel messageModel) {
  return Scrollbar(
    child: SingleChildScrollView(
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("标题：$messageModel.title"),
              Row(
                children: [
                  Text("关键词:"),
                  Chip(label: Text(messageModel.keyWord)),
                ],
              ),
            ],
          ),
          Html(data: messageModel.htmlCode),
          // Text("测试"),
        ],
      ),
    ),
  );
}

//这个类在初始化时传入html代码就可以生成对应的页面了,还附带了确认发送的按钮
class PreAndSend extends StatelessWidget {
  MessageModel messageModel;
  String content;
  String targetId = "456";

  PreAndSend({MessageModel messageModel}) {
    this.messageModel = messageModel;
    this.content = messageModel.toJsonString();
  }
  @override
  @override
  Widget build(BuildContext context) {
    print("html:" + messageModel.htmlCode);

    content = messageModel.toJsonString();
    return Scaffold(
      appBar: AppBar(
        title: Text("预览页面"),
        actions: [
          IconButton(
            icon: Icon(Icons.send),
            onPressed: () {
              _sendMessage(content);
            },
          )
        ],
      ),
      body: getPre(messageModel),
    );
  }

  _sendMessage(String content) {
    //在这里写选择联系人，并将targetId改为联系人id

    IM.sendMessage(content, targetId);
    print("content: " + content);
  }
}

//这个类在初始化时传入html代码就可以生成对应的页面了
class Pre extends StatelessWidget {
  MessageModel messageModel;

  Pre({Key key, MessageModel messageModel}) {
    this.messageModel = messageModel;
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("预览页面"),
      ),
      body: getPre(messageModel),
    );
  }
}
