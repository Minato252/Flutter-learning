import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_html/style.dart';
import 'package:fluttertoast/fluttertoast.dart';
// import 'package:path/path.dart';
import 'package:rich_edit/rich_edit.dart';
import 'package:rongcloud_im_plugin/rongcloud_im_plugin.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import 'package:weitong/Model/messageHistoryModel.dart';
import 'package:weitong/Model/messageModel.dart';
import 'package:weitong/Model/style.dart';
import 'package:weitong/pages/imageEditor/common_widget.dart';
import 'package:weitong/pages/tabs/PretoRichEdit.dart';
import 'package:weitong/pages/tree/tree.dart';
import 'package:weitong/services/DB/db_helper.dart';
import 'package:weitong/services/IM.dart';
import 'package:weitong/services/ScreenAdapter.dart';
import 'package:weitong/services/event_util.dart';
import 'package:weitong/services/providerServices.dart';
import 'package:weitong/widget/JdButton.dart';
import 'package:weitong/services/voiceprovider.dart';
import 'package:provider/provider.dart';
import 'package:weitong/widget/toast.dart';

import 'SimpleRichEditController.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';

import 'chooseUser/contacts_list_page.dart';

// import 'package:uuid/uuid.dart';
// import 'package:uuid/uuid_util.dart';

Scrollbar getPre(MessageModel messageModel, bool modify, double myFontSize,
    SimpleRichEditController controller, BuildContext context) {
  return Scrollbar(
    child: SingleChildScrollView(
        child: Container(
      padding: EdgeInsets.all(5),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Row(
            children: [
              // Icon(Icons.title),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            "标题",
                            style: TextStyle(
                              color: Theme.of(context).accentColor,
                            ),
                          ),
                        ),
                        Chip(label: Text(messageModel.keyWord)),
                      ],
                    ),
                    Align(
                      alignment: new FractionalOffset(0.0, 0.0),
                      child: Text(
                        "${messageModel.title}",
                        style: TextStyle(fontSize: 20),
                      ),
                    )
                  ],
                ),
              ),
            ],
          ),

          //   Wrap(
          //     crossAxisAlignment: WrapCrossAlignment.center,
          //     // alignment: WrapAlignment.start,
          //     spacing: 8.0,
          //     children: [
          //       // Text("标题："),
          //       Icon(Icons.title),
          //       Text(
          //         "${messageModel.title}",
          //         style: TextStyle(fontSize: 20),
          //       ),
          //       Chip(label: Text(messageModel.keyWord)),
          //     ],
          //   ),
          // ),

          Align(
            alignment: new FractionalOffset(0.0, 0.0),
            child: Text("已经浏览过该信息的人：${messageModel.hadLook.toString()}",
                style: TextStyle(
                  color: Theme.of(context).accentColor,
                )),
          ),
          // Html(
          //   data: messageModel.htmlCode,
          //   style: {
          //     'img': Style(width: 150, height: 150),
          //     'video': Style(width: 150, height: 150),
          //     // '#12': Style(width: 400, height: 400),
          //   },
          // ),
          Divider(),
          // Container(
          //   child: messageModel.htmlCode ==
          //           """<p><span style="font-size:15px;"></span></p>"""
          //       ? SizedBox(width: double.infinity)
          //       : HtmlWidget(
          //           messageModel.htmlCode,
          //           webView: true,
          //         ),
          // ),

          Container(
            child: messageModel.htmlCode ==
                    """<p><span style="font-size:15px;"></span></p>"""
                ? SizedBox(width: double.infinity)
                : Html(
                    data: messageModel.htmlCode,
                    style: {
                      'img': Style(width: 150, height: 150),
                      'video': Style(width: 150, height: 150),
                      // 'text': Style(fontSize: FontSize.large)
                      //  "p":Style(,FontSize(20.0)),
                      // "p": Style(FontSize(30.0))
                      "P": Style(fontSize: FontSize(myFontSize))
                    },
                  ),
          ),
          // Divider(),
          messageModel.modify
              ? SafeArea(
                  child: SizedBox(
                    height: ScreenAdapter.height(500),
                    child: MultiProvider(
                      providers: [
                        ChangeNotifierProvider(
                          builder: (_) => VoiceRecordProvider(),
                        )
                      ],
                      child: RichEdit(
                          controller), //需要指定height，才不会报错，之后可以用ScreenUtil包适配屏幕
                    ),
                    /*RichEdit(
                        controller), */ //需要指定height，才不会报错，之后可以用ScreenUtil包适配屏幕
                  ),
                )
              : Text(""),

          // Text("测试"),
        ],
      ),
    )),
  );
}

_sendMessage(SimpleRichEditController controller) async {}
//这个类在初始化时传入html代码就可以生成对应的页面了,还附带了确认发送的按钮

class PreAndSend extends StatefulWidget {
  MessageModel messageModel;
  String content;
  bool editable;
  List<RichEditData> data;
  double myFontSize = 15.0;
  PreAndSend(
      {MessageModel messageModel,
      bool editable = false,
      List<RichEditData> data}) {
    this.messageModel = messageModel;
    this.content = messageModel.toJsonString();
    this.editable = editable;
    this.data = data;
  }
  @override
  _PreAndSendState createState() => _PreAndSendState(
      messageModel: messageModel, editable: editable, data: data);
}

class _PreAndSendState extends State<PreAndSend> {
  MessageModel messageModel;
  String content;
  String targetId = "456";
  String notehtmlCode;
  double myFontSize = 15.0;

  bool editable;
  List<RichEditData> data;
  // List targetIdList;
  List<String> targetIdList = [];
  StreamSubscription<PageEvent> sss; //eventbus传值
  SimpleRichEditController controller;
  _PreAndSendState(
      {MessageModel messageModel,
      bool editable = false,
      List<RichEditData> data}) {
    this.messageModel = messageModel;
    this.content = messageModel.toJsonString();

    this.editable = editable;
    this.data = data;
    this.controller = SimpleRichEditController();
  }
  enlargeFontSize() {
    if (myFontSize <= 50) {
      myFontSize += 5.0;
      setState(() {});
    }
  }

  decreaseFontSize() {
    if (myFontSize > 5) {
      myFontSize -= 5.0;
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    notehtmlCode = messageModel.htmlCode;
    print("html:" + messageModel.htmlCode);
    ScreenAdapter.init(context);
    content = messageModel.toJsonString();
    return Scaffold(
      appBar: AppBar(
        title: Text("预览页面"),
        actions: [
          Row(
            mainAxisSize: MainAxisSize.max,
            children: [
              FlatButtonWithIcon(
                label: Text(
                  "发送",
                ),
                icon: Icon(
                  Icons.send,
                ),
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                onPressed: () async {
                  // if (targetIdList == null) {
                  //   sendMessageSuccess("请选择您要发送的联系人！");
                  // } else {
                  //   _sendMessage();
                  //   // Navigator.pop(context);
                  // }
                  //加载联系人列表
                  final ps = Provider.of<ProviderServices>(context);
                  Map userInfo = ps.userInfo;
                  String jsonTree =
                      await Tree.getTreeFormSer(userInfo["id"], false, context);
                  var parsedJson = json.decode(jsonTree);
                  List users = [];
                  Tree.getAllPeople(parsedJson, users);

                  List targetAllList = await Navigator.of(context).push(
                      MaterialPageRoute(
                          builder: (BuildContext context) =>
                              ContactListPage(users)));

                  if (targetAllList != null && !targetAllList.isEmpty) {
                    targetAllList.forEach((element) {
                      targetIdList.add(element["id"]);
                    });
                    _sendMessage();
                  }
                },
              ),
              FlatButtonWithIcon(
                label: Text("保存"),
                icon: Icon(
                  Icons.save,
                ),
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                onPressed: () {
                  postRequestFunction(notehtmlCode);
                },
              ),
              editable
                  ? FlatButtonWithIcon(
                      label: Text("遮蔽"),
                      icon: Icon(Icons.edit),
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      onPressed: () {
                        Navigator.of(context).push(new MaterialPageRoute(
                            builder: (context) => new PretoRichEdit(data,
                                messageModel.title, messageModel.keyWord)));
                      })
                  : SizedBox(
                      width: 0,
                      height: 0,
                    ),
              Container(
                height: 150.0,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      margin: EdgeInsets.all(0),
                      padding: EdgeInsets.all(0),
                      height: 25,
                      child: IconButton(
                        tooltip: "字体放大",
                        iconSize: 24.0,
                        padding: EdgeInsets.all(0),
                        icon: Icon(
                          Icons.add,

                          // size: 20,
                        ),
                        onPressed: () {
                          enlargeFontSize();
                        },
                      ),
                    ),
                    // Container(
                    //   child: Text(
                    //     "字体",
                    //     style: TextStyle(fontSize: 6.0),
                    //   ),
                    //   margin: EdgeInsets.all(0),
                    //   padding: EdgeInsets.all(0),
                    //   height: 6,
                    // ),
                    // Text("字体"),
                    Container(
                      margin: EdgeInsets.all(0),
                      padding: EdgeInsets.all(0),
                      height: 25,
                      child: IconButton(
                        tooltip: "字体放大",
                        iconSize: 24.0,

                        padding: EdgeInsets.all(0),
                        icon: Icon(
                          Icons.minimize_outlined,
                          // size: 20,
                        ),
                        // materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        onPressed: () {
                          decreaseFontSize();
                        },
                      ),
                    ),
                  ],
                ),
              )
            ],
          )
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Align(
          //   alignment: new FractionalOffset(0.0, 0.0),
          //   child: Text("已选择联系人：${targetIdList.toString()}"),
          // ),
          // Wrap(
          //   crossAxisAlignment: WrapCrossAlignment.center,
          //   // alignment: WrapAlignment.start,
          //   spacing: 8.0,
          //   children: [
          //     Text("已选择联系人："),
          //     Wrap(
          //       spacing: 8.0,
          //       children: _buildTarget(),
          //     ),
          //     ActionChip(
          //       backgroundColor: Theme.of(context).accentColor,
          //       label: Text(
          //         '选择联系人',
          //         style: TextStyle(color: Colors.white),
          //       ),
          //       // backgroundColor: Colors.grey[600],
          //       onPressed: () {
          //         sss =
          //             EventBusUtil.getInstance().on<PageEvent>().listen((data) {
          //           // print('${data.test}');
          //           targetIdList = data.userList;
          //           sss.cancel();
          //           setState(() {});
          //         });

          //         Navigator.pushNamed(context, '/chooseUser');
          //         // _awaitReturnChooseTargetIdList(context);

          //         //  targetIdList= a Navigator.pushNamed(context, '/chooseUser');
          //       },
          //       avatar: Icon(
          //         Icons.add,
          //         color: Colors.white,
          //       ),
          //     ),
          //   ],
          // ),
          // Divider(),
          // // Align(
          //   alignment: new FractionalOffset(0.0, 0.0),
          //   child: Text("已经浏览过该信息的人：${messageModel.hadLook.toString()}"),
          // ),
          Expanded(
            child: getPre(messageModel, false, myFontSize, controller, context),
          ),
        ],
      ),
      bottomNavigationBar: BottomAppBar(
        color: Theme.of(context).accentColor,
        shape: const CircularNotchedRectangle(),
        child: ButtonTheme(
          minWidth: 0.0,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            mainAxisSize: MainAxisSize.max,
            children: <Widget>[],
          ),
        ),
      ),
    );
  }

  List<Widget> _buildTarget() {
    var content;
    if (targetIdList != null && targetIdList.isNotEmpty) {
      //如果数据不为空，则显示Text
      content = targetIdList.map((tag) {
        return Chip(
          label: Text(tag),
        );
      }).toList();
    } else {
      //当数据为空我们需要隐藏这个Text
      //我们又不能返回一个null给当前的Widget Tree
      //只能返回一个长宽为0的widget占位
      content = [new Container(height: 0.0, width: 0.0)];
    }
    return content;
  }

  _sendMessage() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    // var db = DatabaseHelper();
    // db.initDb();

    //在这里写选择联系人，并将targetId改为联系人id
    print("****************这里打印targetIdList****");
    print(targetIdList);
    if (messageModel.modify) {
      var htmlCode = await controller.generateHtmlUrl();
      DateTime now = new DateTime.now();
      String cure =
          "<p><span style=\"font-size:15px;color: red\">以下是由${prefs.get("id")}修改，时间为：${now.toString().split('.')[0]}<\/span><\/p>";
      // content = content + cure + htmlCode;
      messageModel.htmlCode = messageModel.htmlCode + cure + htmlCode;
      content = messageModel.toJsonString();
    }
    var uuid = Uuid();
    var messageId = uuid.v1();
    messageModel.messageId = messageId;
    content = messageModel.toJsonString();
    for (String item in targetIdList) {
      Message message = await IM.sendMessage(content, item);
      // IM.sendMessage(content, item).whenComplete(() => null)

      print("*************该消息的id是" +
          messageModel.messageId +
          "**********************");

      var rel = await Dio()
          .post("http://47.110.150.159:8080/messages/insertMessage", data: {
        "keywords": messageModel.keyWord,
        "messages": messageModel.htmlCode,
        "touserid": item,
        "fromuserid": prefs.get("id"),
        "title": messageModel.title,
        "hadLook": prefs.get("id") +
            "(" +
            new DateTime.now().toString().split('.')[0] +
            ")",
        "MesId": messageModel.messageId
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

//将信息内容保存到我的部分类别为“默认类别”
  void postRequestFunction(String htmlCode) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    // var htmlCode = await controller.generateHtmlUrl();
    String url = "http://47.110.150.159:8080/insertNote";
    String id = prefs.get("id");

    ///发起post请求
    Response response = await Dio().post(url, data: {
      "nNotetitle": "${messageModel.title}",
      "nNote": "$htmlCode",
      "uId": "$id",
      "nCategory": "默认类别"
    });
    // print(response.data);

    MyToast.AlertMesaage("已将内容保存至草稿中！");
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
