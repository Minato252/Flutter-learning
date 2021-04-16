import 'dart:convert';
import 'dart:math';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:rich_edit/rich_edit.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:weitong/Model/messageModel.dart';
import 'package:weitong/pages/group/GroupMessageService.dart';
import 'package:weitong/pages/group/SendShelterMessage.dart';
import 'package:weitong/pages/imageEditor/common_widget.dart';
import 'package:weitong/pages/tabs/Pre.dart';
import 'package:weitong/pages/tabs/chooseUser/contacts_list_page.dart';
import 'package:weitong/pages/tree/tree.dart';
import 'package:weitong/services/ScreenAdapter.dart';
import 'package:weitong/services/providerServices.dart';
import 'package:weitong/services/voiceprovider.dart';
import 'package:weitong/widget/JdButton.dart';
import 'package:weitong/pages/tabs/SimpleRichEditController.dart';
import 'package:crypto/crypto.dart';
import 'package:synchronized/synchronized.dart' as prefix;

class PretoRichEditGroup extends StatefulWidget {
  List<RichEditData> data;
  String title;
  String groupId;
  //String keyWords;

  PretoRichEditGroup(this.data, this.title, this.groupId);
  @override
  _PretoRichEditGroupState createState() =>
      _PretoRichEditGroupState(data, title, groupId);
}

class _PretoRichEditGroupState extends State<PretoRichEditGroup> {
  @override
  List<RichEditData> data;
  String title;
  String groupId;
  // List targetIdList;
  List<String> targetIdList = [];
  List<String> noteIdList = []; //要发短信的名单id
  List<String> noteNameList = []; //要发短信的名单name
  String content;
  //String keyWords;

  String id;
  SimpleRichEditController controller;
  _PretoRichEditGroupState(
      List<RichEditData> data, String title, String groupId) {
    this.data = new List<RichEditData>();
    this.data.addAll(data);
    this.title = title;
    this.groupId = groupId;
    //this.keyWords = keyWords;
    this.controller = SimpleRichEditController();

    List<RichEditData> l = _getList(data);

    controller.setDataFromList(l);
  }

  List<RichEditData> _getList(List<RichEditData> data) {
    List<RichEditData> copyList = [];
    for (var item in data) {
      RichEditData betContests = new RichEditData(item.type, item.data);
      copyList.add(betContests);
    }
    return copyList;
  }

  void initState() {
    super.initState();
    //setState(() {});
  }

  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomPadding: false,
      appBar: AppBar(
        //title: Text("编辑页面"),
        actions: [
          /*  FlatButton(
              onPressed: () {
                Navigator.of(context).pushNamedAndRemoveUntil(
                  '/',
                  (route) => route == null,
                );
              },
              child: Text(
                "返回首页",
                style: TextStyle(
                    fontSize: 15.0,
                    //fontWeight: FontWeight.w400,
                    color: Colors.white),
              )),*/
          FlatButton(
              onPressed: () {
                _sendMessage(controller);
              },
              child: Text(
                "预览",
                style: TextStyle(
                    fontSize: 15.0,
                    //fontWeight: FontWeight.w400,
                    color: Colors.white),
              )),
          FlatButton(
              onPressed: () {
                // _sendMessage(controller);
                _sendGroupMessage(controller, widget.groupId, widget.title);
              },
              child: Text(
                "发送",
                style: TextStyle(
                    fontSize: 15.0,
                    //fontWeight: FontWeight.w400,
                    color: Colors.white),
              )),
        ],
      ),
      body: Container(
        padding: EdgeInsets.all(5),
        child:
            Column(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
          Expanded(
              child:
                  /*Column(
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
                                Chip(label: Text(keyWords)),
                              ],
                            ),
                            Align(
                              alignment: new FractionalOffset(0.0, 0.0),
                              child: Text(
                                title,
                                style: TextStyle(fontSize: 20),
                              ),
                            )
                          ],
                        ),
                      ),
                    ],
                  ),
                  Divider(),*/
                  SafeArea(
            child: SizedBox(
              height: ScreenAdapter.height(900),
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
          )),
        ]),
      ),
    );
  }

  _sendMessage(SimpleRichEditController controller) async {
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
        messageId: groupId,
        //keyWord: keyWords,
        hadLook: prefs.get("id"));
    Navigator.push(context, MaterialPageRoute(builder: (c) {
      return SendShelterMessagePage(
        messageModel: messageModel,
        isSearchResult: false,
      );
    }));
    print("发送成功");
  }

//直接发送
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
    //SharedPreferences prefs = await SharedPreferences.getInstance();
    String id = prefs.getString("id");
    // for (int i = 0; i < users.length; i++) {
    //   if (users[i]["id"] == id) {
    //     users2.removeAt(i);
    //   }
    // }

    List targetAllList = await Navigator.of(context).push(MaterialPageRoute(
        builder: (BuildContext context) =>
            ContactListPage(users2, groupid: groupId, grouptitle: title)));

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

      await _sendShelterMessage(users2, messageModel); //往遮蔽表插入遮蔽消息
      // var uuid = Uuid();
      // var messageId = uuid.v1();
      // messageModel.messageId = messageId;
      messageModel.messageId = groupId;
      messageModel.fromuserid = prefs.getString("id");
      content = messageModel.toJsonString();
      if (isDirctionMessage) {
        //未全选群成员，即对部分人隐藏内容
        await GroupMessageService.sendDirectionMessage(
            targetIdList, groupId, content);
      } else {
        //全选群成员，发送群消息
        await GroupMessageService.sendGroupMessage(groupId, content);
      }
    }

    if (targetAllList[1] != null && !targetAllList[1].isEmpty) {
      targetAllList[1].forEach((element) {
        noteIdList.add(element["id"]);
        noteNameList.add(element["name"]);
      });
      _sendNoteMessage();
    }
    // _sendShelterMessage(users2); //往遮蔽表插入遮蔽消息
    sendMessageSuccess("发送成功");
  }

  _sendShelterMessage(List allIdInGroup, MessageModel messageModel) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    //把遮蔽消息存入遮蔽表中
    List allid = [];
    for (int i = 0; i < allIdInGroup.length; i++) {
      allid.add(allIdInGroup[i]['id']);
    }

    final ps = Provider.of<ProviderServices>(context);
    Map userInfo = ps.userInfo;

    String jsonTree = await Tree.getTreeFormSer(userInfo["id"], false, context);

//修改jsonTree字符串
    var parsedJson = json.decode(jsonTree);
    Map userInfoAll =
        await Tree.getUserInfo(userInfo["id"], userInfo["password"]);

    List rightList = userInfoAll["right"].split(",");

    List ll = Tree.getFathersRights(parsedJson, [], rightList[0]);
    List llstaff = Tree.getFathersRightStaffIds(parsedJson, [], rightList[0]);
    if (rightList.length > 1) {
      //多个权限情况
      for (int i = 1; i < rightList.length; i++) {
        List ll2 = Tree.getFathersRights(parsedJson, [], rightList[i]);
        List lls2taff =
            Tree.getFathersRightStaffIds(parsedJson, [], rightList[i]);
        for (int j = 0; j < lls2taff.length; j++) {
          if (!llstaff.contains(lls2taff[j])) {
            llstaff.add(lls2taff[j]);
          }
        }
      }
    }

    List superList = llstaff; //存储权限高的人
    // superList.add("11"); //假数据，假设11权限高
    // List needSendShelterMessageList = targetIdList; //需求发送遮蔽消息的人
    List needSendShelterMessageList = [];
    for (int i = 0; i < targetIdList.length; i++) {
      if (!needSendShelterMessageList.contains(targetIdList[i])) {
        needSendShelterMessageList.add(targetIdList[i]);
      }
    }
    for (int i = 0; i < superList.length; i++) {
      //把权限高的人加到发送遮蔽联系人列表中
      if (!needSendShelterMessageList.contains(superList[i])) {
        needSendShelterMessageList.add(superList[i]);
      }
    }
    // SharedPreferences prefs = await SharedPreferences.getInstance();
    String id = prefs.getString("id");

    if (!needSendShelterMessageList.contains(id)) {
      //把自己也加上，后期查询要用
      needSendShelterMessageList.add(id);
    }
    //发到普通表中一份，用来管理员查询
    String useid = prefs.get("id");
    var type = await Dio()
        .post("http://47.110.150.159:8080/gettype?id=$useid"); //获取用户所在的体系

    //发送给服务器
    var rel1 = await Dio()
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
      "Flag": "遮蔽的完整消息", //这里增加了flag
      "type": type.data,
    });

    for (int i = 0; i < needSendShelterMessageList.length; i++) {
      // if (allid.contains(needSendShelterMessageList)) {
      // if (needSendShelterMessageList.contains(allid[i])) {
      Dio dio = Dio();
      var rel =
          await dio.post("http://47.110.150.159:8080/shelter/insert", data: {
        "keywords": messageModel.keyWord,
        "messages": messageModel.htmlCode,
        "touserid": needSendShelterMessageList[i], //要发送的联系人
        "fromuserid": prefs.get("id"), //群id
        "title": messageModel.title,
        "hadLook": prefs.get("name") +
            "(" +
            new DateTime.now().toString().split('.')[0] +
            ")",
        "MesId": messageModel.messageId,
        "Flag": "普通", //这里增加了flag
        // "type": type.data,
      });
      // }
    }
    for (int i = 0; i < allid.length; i++) {
      // if (allid.contains(needSendShelterMessageList)) {
      if (!needSendShelterMessageList.contains(allid[i])) {
        Dio dio1 = Dio();
        String newHtml = "<p>遮蔽信息</p>";
        //"<p>这是一条遮蔽后的消息，您无法阅读</p>";
        // messageModel.htmlCode = newHtml;

        var rel =
            await dio1.post("http://47.110.150.159:8080/shelter/insert", data: {
          "keywords": messageModel.keyWord,
          "messages": newHtml,
          "touserid": allid[i],
          "fromuserid": prefs.get("id"),
          "title": messageModel.title,
          "hadLook": prefs.get("name") +
              "(" +
              new DateTime.now().toString().split('.')[0] +
              ")",
          "MesId": messageModel.messageId,
          "Flag": "普通", //这里增加了flag
          // "type": type.data,
        });
      }
    }
    sendMessageSuccess("发送成功");
    Navigator.pop(context);
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
