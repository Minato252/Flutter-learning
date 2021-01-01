import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:weitong/Model/messageModel.dart';
import 'package:weitong/Model/style.dart';
import 'package:weitong/services/IM.dart';
import 'package:weitong/services/event_util.dart';

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
  // List targetIdList;
  List<String> targetIdList;
  StreamSubscription<PageEvent> sss; //eventbus传值

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
          Row(
            children: [
              ActionChip(
                label: Text(
                  '选择联系人',
                  style: TextStyle(color: Colors.white),
                ),
                backgroundColor: Colors.grey[600],
                onPressed: () {
                  sss =
                      EventBusUtil.getInstance().on<PageEvent>().listen((data) {
                    // print('${data.test}');
                    targetIdList = data.userList;
                    sss.cancel();
                  });

                  Navigator.pushNamed(context, '/chooseUser');
                  // _awaitReturnChooseTargetIdList(context);

                  //  targetIdList= a Navigator.pushNamed(context, '/chooseUser');
                },
                avatar: Icon(
                  Icons.add,
                  color: Colors.white,
                ),
              ),
              IconButton(
                tooltip: "发送",
                icon: Icon(Icons.send),
                onPressed: () {
                  if (targetIdList == null) {
                    sendMessageSuccess("请选择您要发送的联系人！");
                  } else {
                    _sendMessage(content);
                    Navigator.pop(context);
                  }
                },
              ),
            ],
          )
        ],
      ),
      body: getPre(messageModel),
    );
  }

  _sendMessage(String content) {
    //在这里写选择联系人，并将targetId改为联系人id
    print("****************这里打印targetIdList****");
    print(targetIdList);
    for (String item in targetIdList) {
      IM.sendMessage(content, item);
    }
    // IM.sendMessage(content, targetId);
    print("content: " + content);
    sendMessageSuccess("发送成功");
  }

  sendMessageSuccess(String alrt) {
    Fluttertoast.showToast(
        msg: alrt,
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.CENTER, // 消息框弹出的位置
        timeInSecForIos: 1, // 消息框持续的时间（目前的版本只有ios有效）
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0);
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
