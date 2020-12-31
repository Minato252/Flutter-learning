import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:weitong/Model/style.dart';
import 'package:weitong/services/IM.dart';

Scrollbar getPre(String title, String keyWord, String htmlCode) {
  return Scrollbar(
    child: SingleChildScrollView(
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("标题：$title"),
              Row(
                children: [
                  Text("关键词:"),
                  Chip(label: Text(keyWord)),
                ],
              ),
            ],
          ),
          Html(data: htmlCode),
          // Text("测试"),
        ],
      ),
    ),
  );
}

//这个类在初始化时传入html代码就可以生成对应的页面了,还附带了确认发送的按钮
class PreAndSend extends StatelessWidget {
  final htmlCode;
  final title;
  final keyWord;
  String content;
  String targetId = "456";

  PreAndSend({Key key, this.htmlCode, this.title, this.keyWord})
      : super(key: key);
  @override
  @override
  Widget build(BuildContext context) {
    print("html:" + htmlCode);

    content = jsonEncode({
      'htmlCode': htmlCode,
      'title': title,
      'keyWord': keyWord,
    });
    return Scaffold(
      appBar: AppBar(
        title: Text("预览页面"),
        actions: [
          IconButton(
            icon: Icon(Icons.send),
            onPressed: () {
              IM.sendMessage(content, targetId);
            },
          )
        ],
      ),
      body: getPre(title, keyWord, htmlCode),
    );
  }
}

//这个类在初始化时传入html代码就可以生成对应的页面了
class Pre extends StatelessWidget {
  final htmlCode;
  final title;
  final keyWord;

  Pre({Key key, this.htmlCode, this.title, this.keyWord}) : super(key: key);
  @override
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("预览页面"),
      ),
      body: getPre(title, keyWord, htmlCode),
    );
  }
}
