import 'dart:convert';
import 'dart:isolate';
import 'dart:math';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
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
import 'package:weitong/pages/group/GroupMessageService.dart';
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

import 'package:crypto/crypto.dart';
import 'package:synchronized/synchronized.dart' as prefix;

// import 'package:uuid/uuid.dart';
// import 'package:uuid/uuid_util.dart';

Scrollbar getPre(
    MessageModel messageModel,
    bool modify,
    double myFontSize,
    bool isSearchResult,
    SimpleRichEditController controller,
    BuildContext context) {
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
                        //  Chip(label: Text(messageModel.keyWord)),
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

          isSearchResult
              ? Align(
                  alignment: new FractionalOffset(0.0, 0.0),
                  child: Text("已经浏览过该信息的人：${messageModel.hadLook.toString()}",
                      style: TextStyle(
                        color: Theme.of(context).accentColor,
                      )),
                )
              : Text(""),
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
                      'img': Style(width: 200, height: 300),
                      'video': Style(width: 150, height: 150),
                      // 'text': Style(fontSize: FontSize.large)
                      //  "p":Style(,FontSize(20.0)),
                      // "p": Style(FontSize(30.0))
                      "P": Style(fontSize: FontSize(myFontSize))
                    },
                  ),
          ),
          // Divider(),
          /*  messageModel.modify
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
              : Text(""),*/

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
  bool isSearchResult = false;
  PreAndSend(
      {MessageModel messageModel,
      bool editable = false,
      bool isSearchResult,
      List<RichEditData> data}) {
    this.messageModel = messageModel;
    this.content = messageModel.toJsonString();
    this.editable = editable;
    this.data = data;
    this.isSearchResult = isSearchResult;
  }
  @override
  _PreAndSendState createState() => _PreAndSendState(
      messageModel: messageModel,
      editable: editable,
      data: data,
      isSearchResult: isSearchResult);
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
  List<String> noteIdList = []; //要发短信的名单id
  List<String> noteNameList = []; //要发短信的名单name
  StreamSubscription<PageEvent> sss; //eventbus传值
  SimpleRichEditController controller;

  bool isSearchResult = false;
  _PreAndSendState(
      {MessageModel messageModel,
      bool editable = false,
      bool isSearchResult,
      List<RichEditData> data}) {
    this.messageModel = messageModel;
    this.content = messageModel.toJsonString();

    this.isSearchResult = isSearchResult;

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

//获取群成员
  _sendGroupMessage() async {
    List rel = await GroupMessageService.searchGruopMember("11");
    List<String> groupMember = [];
    for (int i = 0; i < rel.length; i++) {
      groupMember.add(rel[i]["id"]);
    }
    print(groupMember);
    final ps = Provider.of<ProviderServices>(context);
    Map userInfo = ps.userInfo;
    String jsonTree = await Tree.getTreeFormSer(userInfo["id"], false, context);
    var parsedJson = json.decode(jsonTree);
    List users = [];
    List users2 = [];
    Tree.getAllPeople(parsedJson, users);
    for (int i = 0; i < users.length; i++) {
      if (groupMember.contains(users[i]["id"])) {
        users2.add(users[i]);
      }
    }
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String id = prefs.getString("id");
    for (int i = 0; i < users.length; i++) {
      if (users[i]["id"] == id) {
        users.removeAt(i);
      }
    }
    // List targetAllList = await Navigator.of(context).push(MaterialPageRoute(
    var result = await Navigator.of(context).push(MaterialPageRoute(
        builder: (BuildContext context) => ContactListPage(users2)));
    if (result == null) {
      return;
    }
    List targetAllList = result;
    targetIdList = [];
    if (targetAllList[0] != null && !targetAllList[0].isEmpty) {
      targetAllList[0].forEach((element) {
        targetIdList.add(element["id"]);
      });
      await _sendMessage();
    }

    if (targetAllList[1] != null && !targetAllList[1].isEmpty) {
      targetAllList[1].forEach((element) {
        noteIdList.add(element["id"]);
        noteNameList.add(element["name"]);
      });
      _sendNoteMessage();
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
                  style: TextStyle(color: Colors.white),
                ),
                icon: Icon(
                  Icons.send,
                  color: Colors.white,
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

                  // await _sendGroupMessage();
                  final ps = Provider.of<ProviderServices>(context);
                  Map userInfo = ps.userInfo;
                  String jsonTree =
                      await Tree.getTreeFormSer(userInfo["id"], false, context);
                  var parsedJson = json.decode(jsonTree);
                  List users = [];
                  Tree.getAllPeople(parsedJson, users);
                  SharedPreferences prefs =
                      await SharedPreferences.getInstance();
                  String id = prefs.getString("id");
                  for (int i = 0; i < users.length; i++) {
                    if (users[i]["id"] == id) {
                      users.removeAt(i);
                    }
                  }
                  // List targetAllList = await Navigator.of(context).push(
                  var result = await Navigator.of(context).push(
                      MaterialPageRoute(
                          builder: (BuildContext context) =>
                              ContactListPage(users)));
                  if (result == null) {
                    return;
                  }
                  List targetAllList = result;
                  targetIdList = [];
                  if (targetAllList[0] != null && !targetAllList[0].isEmpty) {
                    targetAllList[0].forEach((element) {
                      targetIdList.add(element["id"]);
                    });
                    await _sendMessage();
                  }

                  if (targetAllList[1] != null && !targetAllList[1].isEmpty) {
                    targetAllList[1].forEach((element) {
                      noteIdList.add(element["id"]);
                      noteNameList.add(element["name"]);
                    });
                    _sendNoteMessage();
                  }
                },
              ),
              /* FlatButtonWithIcon(
                label: Text("保存"),
                icon: Icon(
                  Icons.save,
                ),
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                onPressed: () {
                  postRequestFunction(notehtmlCode);
                },
              ),*/
              // editable
              //     ? FlatButtonWithIcon(
              //         label: Text("遮蔽"),
              //         icon: Icon(Icons.edit),
              //         materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              //         onPressed: () {
              //           Navigator.of(context).push(new MaterialPageRoute(
              //               builder: (context) => new PretoRichEdit(data,
              //                   messageModel.title, messageModel.keyWord)));
              //         })
              //     : SizedBox(
              //         width: 0,
              //         height: 0,
              //       ),
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
              ),
              IconButton(
                  onPressed: () {
                    Navigator.of(context).pushNamedAndRemoveUntil(
                      '/',
                      (route) => route == null,
                    );
                  },
                  icon: Icon(Icons.account_balance)),
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
            child: getPre(messageModel, false, myFontSize, isSearchResult,
                controller, context),
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
    print(targetIdList.join(',').toString());
    var uuid = Uuid();
    var messageId = uuid.v1();
    messageModel.messageId = messageId;
    messageModel.fromuserid = prefs.getString("id");
    content = messageModel.toJsonString();
    String useid = prefs.get("id");
    var type = await Dio()
        .post("http://47.110.150.159:8080/gettype?id=$useid"); //获取用户所在的体系

    //发给服务器
    var rel = await Dio()
        .post("http://47.110.150.159:8080/messages/insertMessage", data: {
      "keywords": messageModel.keyWord,
      "messages": messageModel.htmlCode,
      "touserid": messageModel.messageId,
      "fromuserid": prefs.get("id"),
      "title": messageModel.title,
      "hadLook": prefs.get("name") +
          "(" +
          new DateTime.now().toString().split('.')[0] +
          ")",
      "MesId": messageModel.messageId,
      "Flag": "普通", //这里增加了flag
      "type": type.data,
    });

    print(targetIdList.join(',').toString());
    print("title:" + messageModel.title);
    print("**************在创建群之前的messageId是：" + messageModel.messageId);
    await GroupMessageService.creatGruop(messageModel.messageId,
        messageModel.title, targetIdList.join(',').toString(), content);

    //print("1111111111111111111111");
    //print(rel);

    //存储群组关系

    var rel1 =
        await Dio().post("http://47.110.150.159:8080/group/insert", data: {
      "groupid": messageModel.messageId,
      "groupname": messageModel.title,
      "groupcreatorid": prefs.get("id"),
      "groupcreatorname": prefs.get("name"),
      "grouptime": new DateTime.now().toString().split('.')[0],
    });
    //print("222222222222222222222222");
    //print(rel1);
    // print("*********");
    // Future.delayed(Duration(seconds: 3), () {
    // GroupMessageService.sendGroupMessage("11", content);
    // });
    // var rel = await GroupMessageService.creatGruop(
    //     messageId, messageModel.title, targetIdList.join(',').toString());
    // print("****建群*****");
    // print(rel["code"]);

    // while (rel["code"] != 200) {
    //   print("*********");
    // }
    // print("****发信息*****");
    // GroupMessageService.sendGroupMessage(messageId, content);
    // print("最后了");

    // var lock = prefix.Lock();
    // bool _bCounting = false;
    // lock.synchronized(() async {
    //   // _bCounting = !_bCounting;

    //   GroupMessageService.creatGruop(
    //       messageId, messageModel.title, targetIdList.join(',').toString());
    //   print("****建群*****");
    // });
    // lock.synchronized(() async {
    //   // _bCounting = !_bCounting;
    //   GroupMessageService.sendGroupMessage(messageId, content);
    //   print("****发信息*****");
    // });
    // }
    print(messageId);
    sendMessageSuccess("发送成功");
  }

  _sendNoteMessage() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    for (int i = 0; i < noteIdList.length; i++) {
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
        "p1": noteNameList[i], //接收人
        "p2": prefs.get("name"), //发送人
        "mobile": noteIdList[i]
      });
    }
//发给服务器
    /*var rel = await Dio()
        .post("http://47.110.150.159:8080/messages/insertMessage", data: {
      "keywords": messageModel.keyWord,
      "messages": messageModel.htmlCode,
      "touserid": messageModel.messageId,
      "fromuserid": prefs.get("id"),
      "title": messageModel.title,
      "hadLook": prefs.get("name") +
          "(" +
          new DateTime.now().toString().split('.')[0] +
          ")",
      "MesId": messageModel.messageId
    });
    print("1111111111111111111111");
    print(rel);

    //存储群组关系

    var rel1 =
        await Dio().post("http://47.110.150.159:8080/group/insert", data: {
      "groupid": messageModel.messageId,
      "groupname": messageModel.title,
      "groupcreatorid": prefs.get("id"),
      "groupcreatorname": prefs.get("name"),
      "grouptime": new DateTime.now().toString().split('.')[0],
    });
    print("222222222222222222222222");
    print(rel1);*/

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

//将信息内容保存到服务器
  void postRequestFunction(String htmlCode) async {
    //   SharedPreferences prefs = await SharedPreferences.getInstance();
    //   // var htmlCode = await controller.generateHtmlUrl();
    //   String url = "http://47.110.150.159:8080/insertNote";
    //   String id = prefs.get("id");
    //   DateTime now = new DateTime.now();
    //   String html = htmlCode +
    //       "<p><span style=\"font-size:15px;color: blue\">以下是由${prefs.get("name")}保持，时间为：${now.toString().split('.')[0]}<\/span><\/p>";

    //   ///发起post请求
    //   Response response = await Dio().post(url, data: {
    //     "nNotetitle": "${messageModel.title}",
    //     "nNote": "$html",
    //     "uId": "$id",
    //     "nCategory": "默认类别"
    //   });
    //   // print(response.data);

    //   MyToast.AlertMesaage("已将内容保存至草稿中！");
    // }

    SharedPreferences prefs = await SharedPreferences.getInstance();
    // var htmlCode = await controller.generateHtmlUrl();

    String id = prefs.get("id");
    DateTime now = new DateTime.now();
    String html = htmlCode +
        "<p><span style=\"font-size:15px;color: blue\">以上是由${prefs.get("name")}保存，时间为：${now.toString().split('.')[0]}<\/span><\/p>";
    /*String url = "http://47.110.150.159:8080/insertNote";
    ///发起post请求
    Response response = await Dio().post(url, data: {
      "nNotetitle": "${messageModel.title}",
      "nNote": "$htmlCode",
      "uId": "$id",
      "nCategory": "默认类别"
    });
    // print(response.data);
    String fromid;
    if (messageModel.fromuserid == null) {
      fromid = id;
    } else {
      fromid = messageModel.fromuserid;
    }*/
    String useid = prefs.get("id");
    var type = await Dio()
        .post("http://47.110.150.159:8080/gettype?id=$useid"); //获取用户所在的体系

    print(messageModel.messageId);
    var rel = await Dio()
        .post("http://47.110.150.159:8080/messages/insertMessage", data: {
      "keywords": messageModel.keyWord,
      "messages": html,
      "touserid": messageModel.messageId,
      "fromuserid": prefs.get("id"),
      "title": messageModel.title,
      "hadLook": prefs.get("name") +
          "(" +
          new DateTime.now().toString().split('.')[0] +
          ")",
      "MesId": messageModel.messageId,
      "Flag": "草稿",
      "type": type.data,
    });

    MyToast.AlertMesaage("已将内容保存！");
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
