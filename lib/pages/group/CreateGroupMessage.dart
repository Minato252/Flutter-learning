import 'dart:convert';
import 'dart:math';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/style.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:rich_edit/rich_edit.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import 'package:weitong/Model/messageModel.dart';
import 'package:weitong/Model/style.dart';
import 'package:weitong/pages/tabs/Pre.dart';
import 'package:weitong/pages/tabs/SimpleRichEditController.dart';
import 'package:weitong/pages/tabs/chooseUser/contacts_list_page.dart';
import 'package:weitong/pages/tree/tree.dart';
import 'package:weitong/services/IM.dart';
import 'package:weitong/services/ScreenAdapter.dart';
import 'package:weitong/services/providerServices.dart';
import 'package:weitong/widget/JdButton.dart';
import 'package:flutter_html/flutter_html.dart';

import 'package:rongcloud_im_plugin/rongcloud_im_plugin.dart';
import 'package:weitong/services/voiceprovider.dart';
import 'package:provider/provider.dart';
import 'package:weitong/pages/group/GroupPre.dart';
import 'package:rongcloud_im_plugin/rongcloud_im_plugin.dart';
import 'package:weitong/services/voiceprovider.dart';
import 'package:provider/provider.dart';

import 'package:crypto/crypto.dart';
import 'package:synchronized/synchronized.dart' as prefix;

import 'GroupMessageService.dart';

class GroupMessageCreate extends StatefulWidget {
  String targetGroupId;
  String title;
  /*GroupMessageCreate({String targetGroupId, String title}) {
    this.targetGroupId = targetGroupId;
    this.title = title;
  }*/
  GroupMessageCreate({Key key, this.targetGroupId, this.title})
      : super(key: key);

  @override
  _GroupMessageCreateState createState() =>
      _GroupMessageCreateState(targetGroupId = targetGroupId, title = title);
  /*targetGroupId = targetGroupId, title = title*/
}

class _GroupMessageCreateState extends State<GroupMessageCreate>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;
  final newTitleFormKey = GlobalKey<FormState>();
  String newTitle;
  String _curchosedTag = "";

  String _actionChipString = "选择关键词";
  IconData _actionChipIconData = Icons.add;
  List<Widget> _containerList;
  List<String> targetIdList = [];
  List<String> noteIdList = []; //要发短信的名单id
  List<String> noteNameList = []; //要发短信的名单name
  String content;

  SimpleRichEditController controller;
  String targetGroupId;
  String title;
  _GroupMessageCreateState(String targetGroupId, String title) {
    //富文本的controller
    controller = SimpleRichEditController();
  }
  @override
  Widget build(BuildContext context) {
    // ScreenUtil.instance = ScreenUtil(width: 750, height: 1334)..init(context);

    ScreenAdapter.init(context);

    return Scaffold(
        appBar: AppBar(
          //title: Text("创建消息"),
          //title: Text("发送"),
          actions: <Widget>[
            /* FlatButton(
                onPressed: () {
                  _clearMessage(controller);
                },
                child: Text(
                  "清空内容",
                  style: TextStyle(
                      fontSize: 20.0,
                      //fontWeight: FontWeight.w400,
                      color: Colors.white),
                )),*/
            SizedBox(
              width: ScreenAdapter.width(130),
              child: FlatButton(
                  onPressed: () {
                    //print(widget.targetGroupId);
                    _sendMessage(
                        controller, widget.targetGroupId, widget.title);
                  },
                  child: Text(
                    "预览",
                    style: TextStyle(
                        fontSize: ScreenAdapter.size(30),
                        //fontSize: 15.0,
                        //fontWeight: FontWeight.w400,
                        color: Colors.white),
                  )),
            ),
            SizedBox(
              width: ScreenAdapter.width(130),
              child: FlatButton(
                  onPressed: () {
                    //print(widget.targetGroupId);
                    //  _sendMessage(controller, widget.targetGroupId, widget.title);
                    _sendGroupMessage(
                        controller, widget.targetGroupId, widget.title);
                  },
                  child: Text(
                    "发送",
                    style: TextStyle(
                        fontSize: ScreenAdapter.size(30),
                        // fontSize: 15.0,
                        //fontWeight: FontWeight.w400,
                        color: Colors.white),
                  )),
            ),
          ],
        ),
        body: SafeArea(
          child: SingleChildScrollView(
              child: Container(
                  padding: EdgeInsets.all(20),
                  child:
                      /*Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: _containerList = [
                          Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                // Row(
                                //   children: [
                                //     Text("关键词:"),
                                //     SizedBox(
                                //       width: ScreenAdapter.width(20),
                                //     ),
                                //     Container(
                                //       width: ScreenAdapter.width(290),
                                //       child: ActionChip(
                                //         label: Text(
                                //           _actionChipString,
                                //           style: TextStyle(color: Colors.white),
                                //           maxLines: 2,
                                //           overflow: TextOverflow.ellipsis,
                                //         ),
                                //         backgroundColor: Colors.blue,
                                //         onPressed: () {
                                //           //_awaitReturnNewTag(context);
                                //           _awaitReturnChooseTag(context);
                                //         },
                                //         avatar: Icon(
                                //           _actionChipIconData,
                                //           color: Colors.white,
                                //         ),
                                //       ),
                                //     )
                                //   ],
                                // ),
                                // FlatButton(
                                //     onPressed: () {
                                //       Map args = {
                                //         "identify": "user",
                                //       }; //用于标识是用户维护关键词
                                //       Navigator.pushNamed(
                                //           context, '/updateTags',
                                //           arguments: args);
                                //     },
                                //     child: Text("管理关键词")),
                              ]),
                          Divider(),
                          // Form(
                          //   key: newTitleFormKey,
                          //   child: Column(
                          //     mainAxisAlignment: MainAxisAlignment.start,
                          //     crossAxisAlignment: CrossAxisAlignment.start,
                          //     children: [
                          //       TextFormField(
                          //         // controller: textFieldController,
                          //         style: TextStyle(
                          //           color: Colors.black,
                          //         ),
                          //         decoration: InputDecoration(
                          //             icon: Icon(Icons.title),
                          //             labelText: "标题",
                          //             // border: OutlineInputBorder(),
                          //             hintText: "标题需包含关键词"),
                          //         onSaved: (value) {
                          //           newTitle = value;
                          //         },
                          //         validator: _validateNewTitle,
                          //       ),
                          //     ],
                          //   ),
                          // ),
                          Divider(),*/
                      SafeArea(
                    child: SizedBox(
                      height: ScreenAdapter.height(1150),
                      // height: ScreenAdapter.height(1000),
                      child: MultiProvider(
                        providers: [
                          ChangeNotifierProvider(
                            builder: (_) => VoiceRecordProvider(),
                          )
                        ],
                        child: RichEdit(
                            controller), //需要指定height，才不会报错，之后可以用ScreenUtil包适配屏幕
                      ),
                      // Container(
                      //   child: TextField(
                      //     minLines: 18,
                      //     keyboardType: TextInputType.multiline,
                      //     maxLines: null,
                      //     decoration: InputDecoration(
                      //         border: OutlineInputBorder(), hintText: "输入内容"),
                      //   ),
                      // ),
                      // Divider(),
                      // Row(
                      //   mainAxisAlignment: MainAxisAlignment.spaceAround,
                      //   children: [
                      //     FlatButton(
                      //         onPressed: () {}, child: Icon(Icons.note_add)),
                      //     FlatButton(onPressed: () {}, child: Icon(Icons.mic)),
                      //     FlatButton(
                      //         onPressed: () {}, child: Icon(Icons.video_call)),
                      //   ],
                      // ),
                    ),
                    /*JdButton(
                text: "预览",
                cb: () {
                  _sendMessage(controller);
                },
              ),*/
                  )
                  // ]),
                  // ]
                  )),
        ));
  }

  String _validateNewTitle(value) {
    if (value.isEmpty) {
      return "新标题不能为空";
    } else if (_curchosedTag == "") {
      return "请先选择关键词";
    } else if (!value.contains(_curchosedTag)) {
      return "新标题未包含关键词";
    }
    return null;
  }

  _awaitReturnChooseTag(BuildContext context) async {
    print("open choose Tags");
    final chosedTag = await Navigator.pushNamed(context, '/chooseTags');
    if (chosedTag != null) {
      _curchosedTag = chosedTag;
      _updateChooseTagButton();
    }
  }

  _updateChooseTagButton() {
    if (_curchosedTag != '') {
      setState(() {
        _actionChipString = _curchosedTag;
        _actionChipIconData = Icons.turned_in_not;
      });
    } else {
      print("null");
      setState(() {
        _actionChipString = "选择关键词";
        _actionChipIconData = Icons.add;
      });
    }
  }

  _clearMessage(SimpleRichEditController controller) {
    controller.setData("");

    setState(() {
      // newTitle = "";
      // _curchosedTag = "";
      // _updateChooseTagButton();
    });
  }

  _sendMessage(SimpleRichEditController controller, String targetGroupId,
      String title) async {
    // newTitleFormKey.currentState.save(); //测试标题是否含有关键词
    // if (newTitleFormKey.currentState.validate()) {
//标题含有关键词
    //这个htmlCode就是所有消息的HTML代码了
    //或许我们可以加密了再传输？
    var htmlCode = await controller.generateHtmlUrl();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    print(htmlCode);

    // controller.generateHtml();
    //这里是用html初始化一个页面

    MessageModel messageModel = MessageModel(
        htmlCode: htmlCode,
        title: title,
        messageId: targetGroupId,
        // messageId:targetGroupId,

        // keyWord: _curchosedTag,
        hadLook: prefs.get("name") +
            "(" +
            new DateTime.now().toString().split('.')[0] +
            ")");
    List<RichEditData> l = new List<RichEditData>.from(controller.data);
    Navigator.push(context, MaterialPageRoute(builder: (c) {
      return GroupPre(
        messageModel: messageModel,
        editable: true,
        data: l,
        isSearchResult: false,
        targetGroupId: targetGroupId,
        // title:title,
      );
    }));
    print("发送成功");
    //print(targetGroupId);
  }

  //直接发送不需要预览

  _sendGroupMessage(
      SimpleRichEditController controller, String groupId, String title) async {
    var htmlCode = await controller.generateHtmlUrl();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    print(htmlCode);

    // controller.generateHtml();
    //这里是用html初始化一个页面

    MessageModel messageModel = MessageModel(
        htmlCode: htmlCode,
        title: title,
        messageId: groupId,
        // messageId:targetGroupId,

        // keyWord: _curchosedTag,
        hadLook: prefs.get("name") +
            "(" +
            new DateTime.now().toString().split('.')[0] +
            ")");
    List rel = await GroupMessageService.searchGruopMember(groupId);
    List<String> groupMember = [];
    for (int i = 0; i < rel.length; i++) {
      groupMember.add(rel[i]["id"]);
    }
    print(groupMember);
    final ps = Provider.of<ProviderServices>(context);
    Map userInfo = ps.userInfo;
    String jsonTree = await Tree.getTreeFormSer(userInfo["id"], false, context);
    var parsedJson = json.decode(jsonTree);
    List users = []; //树的总人数
    List users2 = []; //群成员
    Tree.getAllPeople(parsedJson, users);
    for (int i = 0; i < users.length; i++) {
      if (groupMember.contains(users[i]["id"])) {
        users2.add(users[i]);
      }
    }
    // SharedPreferences prefs = await SharedPreferences.getInstance();
    String id = prefs.getString("id");
    // for (int i = 0; i < users.length; i++) {
    //   if (users[i]["id"] == id) {
    //     users2.removeAt(i);
    //   }
    // }
    List targetAllList = await Navigator.of(context).push(MaterialPageRoute(
        builder: (BuildContext context) => ContactListPage(
              users2,
              groupid: groupId,
              grouptitle: title,
            )));

    targetIdList = [];
    if (targetAllList[0] != null && !targetAllList[0].isEmpty) {
      targetAllList[0].forEach((element) {
        targetIdList.add(element["id"]);
      });
      if (!targetIdList.contains(id)) {
        targetIdList.add(id); //不管什么情况，发消息发送人必须在群中
      }
      // await _sendMessage();
      bool isDirctionMessage = false;
      for (int i = 0; i < groupMember.length; i++) {
        if (!targetIdList.contains(groupMember[i])) {
          isDirctionMessage = true;
        }
      }
      // var uuid = Uuid();
      // var messageId = uuid.v1();
      // messageModel.messageId = messageId;
      messageModel.messageId = groupId;
      messageModel.fromuserid = prefs.getString("id");
      content = messageModel.toJsonString();
      String useid = prefs.get("id");
      var type = await Dio()
          .post("http://47.110.150.159:8080/gettype?id=$useid"); //获取用户所在的体系

      //发送给服务器
      var rel1 = await Dio()
          .post("http://47.110.150.159:8080/messages/insertMessage", data: {
        "keywords": "null",
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

      if (isDirctionMessage) {
        //未全选群成员，即对部分人隐藏内容
        await GroupMessageService.sendDirectionMessage(
            targetIdList, groupId, content);
      } else {
        //全选群成员，发送群消息
        await GroupMessageService.sendGroupMessage(groupId, content);
      }
    }

    // print(messageModel.title);

    // //发送给服务器
    // var rel1 = await Dio()
    //     .post("http://47.110.150.159:8080/messages/insertMessage", data: {
    //   "keywords": "null",
    //   "messages": messageModel.htmlCode,
    //   "touserid": messageModel.messageId,
    //   "fromuserid": prefs.get("id"),
    //   "title": messageModel.title,
    //   "hadLook": prefs.get("name") +
    //       "(" +
    //       new DateTime.now().toString().split('.')[0] +
    //       ")",
    //   "MesId": messageModel.messageId,
    //   "Flag": "普通", //这里增加了flag
    // });

    if (targetAllList[1] != null && !targetAllList[1].isEmpty) {
      targetAllList[1].forEach((element) {
        noteIdList.add(element["id"]);
        noteNameList.add(element["name"]);
      });
      _sendNoteMessage();
    }
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
