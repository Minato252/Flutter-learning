import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_html/style.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:rich_edit/rich_edit.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:weitong/Model/messageHistoryModel.dart';
import 'package:weitong/Model/messageModel.dart';
import 'package:weitong/Model/style.dart';
import 'package:weitong/services/DB/db_helper.dart';
import 'package:weitong/services/IM.dart';
import 'package:weitong/services/ScreenAdapter.dart';
import 'package:weitong/services/event_util.dart';
import 'package:weitong/widget/JdButton.dart';

import 'SimpleRichEditController.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';

Scrollbar getPre(MessageModel messageModel, bool modify,
    SimpleRichEditController controller) {
  return Scrollbar(
    child: SingleChildScrollView(
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("标题：${messageModel.title}"),
              Row(
                children: [
                  Text("关键词:"),
                  Chip(label: Text(messageModel.keyWord)),
                ],
              ),
            ],
          ),
          Align(
            alignment: new FractionalOffset(0.0, 0.0),
            child: Text("已经浏览过该信息的人：${messageModel.hadLook.toString()}"),
          ),
          // Html(
          //   data: messageModel.htmlCode,
          //   style: {
          //     'img': Style(width: 150, height: 150),
          //     'video': Style(width: 150, height: 150),
          //     // '#12': Style(width: 400, height: 400),
          //   },
          // ),

          HtmlWidget(
            messageModel.htmlCode,
            webView: true,
          ),

          messageModel.modify
              ? SafeArea(
                  child: SizedBox(
                    height: ScreenAdapter.height(500),
                    child: RichEdit(
                        controller), //需要指定height，才不会报错，之后可以用ScreenUtil包适配屏幕
                  ),
                )
              : Text(""),

          // Text("测试"),
        ],
      ),
    ),
  );
}

_sendMessage(SimpleRichEditController controller) async {}
//这个类在初始化时传入html代码就可以生成对应的页面了,还附带了确认发送的按钮

class PreAndSend extends StatefulWidget {
  MessageModel messageModel;
  String content;
  PreAndSend({MessageModel messageModel}) {
    this.messageModel = messageModel;
    this.content = messageModel.toJsonString();
  }
  @override
  _PreAndSendState createState() =>
      _PreAndSendState(messageModel: messageModel);
}

class _PreAndSendState extends State<PreAndSend> {
  MessageModel messageModel;
  String content;
  String targetId = "456";
  // List targetIdList;
  List<String> targetIdList;
  StreamSubscription<PageEvent> sss; //eventbus传值
  SimpleRichEditController controller = SimpleRichEditController();

  _PreAndSendState({MessageModel messageModel}) {
    this.messageModel = messageModel;
    this.content = messageModel.toJsonString();
  }
  @override
  @override
  Widget build(BuildContext context) {
    print("html:" + messageModel.htmlCode);
    ScreenAdapter.init(context);
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
                    sss = EventBusUtil.getInstance()
                        .on<PageEvent>()
                        .listen((data) {
                      // print('${data.test}');
                      targetIdList = data.userList;
                      sss.cancel();
                      setState(() {});
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
                      _sendMessage();
                      Navigator.pop(context);
                    }
                  },
                ),
              ],
            )
          ],
        ),
        body: Column(
          children: [
            Align(
              alignment: new FractionalOffset(0.0, 0.0),
              child: Text("已选择联系人：${targetIdList.toString()}"),
            ),
            // Align(
            //   alignment: new FractionalOffset(0.0, 0.0),
            //   child: Text("已经浏览过该信息的人：${messageModel.hadLook.toString()}"),
            // ),
            Expanded(
              child: getPre(messageModel, false, controller),
            ),
          ],
        ));
  }

  _sendMessage() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var db = DatabaseHelper();
    db.initDb();

    //在这里写选择联系人，并将targetId改为联系人id
    print("****************这里打印targetIdList****");
    print(targetIdList);
    if (messageModel.modify) {
      var htmlCode = await controller.generateHtmlUrl();
      DateTime now = new DateTime.now();
      String cure =
          "<p><span style=\"font-size:15px;color: red\">以下是由${prefs.get("id")}修改，时间为：${now.toString()}<\/span><\/p>";
      // content = content + cure + htmlCode;
      messageModel.htmlCode = messageModel.htmlCode + cure + htmlCode;
      content = messageModel.toJsonString();
    }

    for (String item in targetIdList) {
      IM.sendMessage(content, item);
      MessageHistoryModel m = new MessageHistoryModel();
      m.htmlCode = messageModel.htmlCode;
      m.keyWords = messageModel.keyWord;
      m.title = messageModel.title;
      m.userId = prefs.get("id");
      m.targetId = item;

      m.sendTime = DateTime.now().millisecondsSinceEpoch;
      db.insert(m, "message");

      await Dio()
          .post("http://47.110.150.159:8080/messages/insertMessage", data: {
        "keywords": messageModel.keyWord,
        "messages": messageModel.htmlCode,
        "touserid": prefs.get("id"),
        "fromuserid": item,
        "title": messageModel.title
      });
    }

    // IM.sendMessage(content, targetId);

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

// 这个类在初始化时传入html代码就可以生成对应的页面了
class Pre extends StatelessWidget {
  MessageModel messageModel;

  String content;
  String targetId = "456";
  // List targetIdList;
  List<String> targetIdList;
  StreamSubscription<PageEvent> sss; //eventbus传值

  Pre({Key key, MessageModel messageModel}) {
    this.messageModel = messageModel;
  }
  @override
  Widget build(BuildContext context) {
    ScreenAdapter.init(context);
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
                    // setState(() {});
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
                    _sendMessage();
                    Navigator.pop(context);
                  }
                },
              ),
            ],
          )
        ],
      ),
      // body: getPre(messageModel, true),
    );
  }

  _sendMessage() {
    //在这里写选择联系人，并将targetId改为联系人id
    print("****************这里打印targetIdList****");
    print(targetIdList);
    for (String item in targetIdList) {
      IM.sendMessage(content, item);
    }
    // IM.sendMessage(content, targetId);

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
