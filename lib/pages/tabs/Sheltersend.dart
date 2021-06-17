import 'dart:convert';
import 'dart:math';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:rich_edit/rich_edit.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
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
import 'package:weitong/widget/dialog_util.dart';

class ShelterSend extends StatefulWidget {
  List<RichEditData> data;
  String title;
  String groupId;
  //String keyWords;

  ShelterSend(this.data, this.title, this.groupId);
  @override
  _ShelterSendState createState() => _ShelterSendState(data, title, groupId);
}

class _ShelterSendState extends State<ShelterSend> {
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
  _ShelterSendState(List<RichEditData> data, String title, String groupId) {
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
    ScreenAdapter.init(context);
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

            SizedBox(
              width: ScreenAdapter.width(140),
              child: FlatButton(
                  onPressed: () {
                    // _sendMessage(controller);
                    _senddirectMessage(controller, widget.title);
                  },
                  child: Text(
                    "发送",
                    style: TextStyle(
                        fontSize: ScreenAdapter.size(35),
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
                  /* Column(
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
                  /*SafeArea(
                    child: SizedBox(
              height: ScreenAdapter.height(1150),
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
  }*/
                  SafeArea(
                child: SizedBox(
                  height: ScreenAdapter.height(1100),
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
              ),
        )));
  }

//判断标题在该体系中是否唯一
  Future<bool> checktitleonly(String title) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String useid = prefs.get("id");
    var type = await Dio().post("http://47.110.150.159:8080/gettype?id=$useid");
    var rel =
        await Dio().post("http://47.110.150.159:8080/group/select", data: {
      "groupname": title,
      "grouptype": type.data,
    });
    List r = rel.data;
    if (r.isEmpty) {
      return true;
    } else {
      return false;
    }
  }

  _senddirectMessage(SimpleRichEditController controller, String title) async {
    bool b = await checktitleonly(title);
    if (b) {
      //标题含有关键词
      //这个htmlCode就是所有消息的HTML代码了
      //或许我们可以加密了再传输？
      var htmlCode = await controller.generateHtmlUrl();
      SharedPreferences prefs = await SharedPreferences.getInstance();
      print(htmlCode);
      MessageModel messageModel = MessageModel(
          htmlCode: htmlCode,
          title: title,
          keyWord: "",
          hadLook: prefs.get("name") +
              "(" +
              new DateTime.now().toString().split('.')[0] +
              ")");

      final ps = Provider.of<ProviderServices>(context);
      Map userInfo = ps.userInfo;

//====从这里开始是多体系的更改===========
      ///===========获取list=========
      var isSingle = await Tree.isInSingleCom(userInfo["id"]);
      List users = [];
      List mulUserIds = []; //这个是将体系分开的idlist 形如[[1,2],[3,4]],只会在多体系用户用到
      if (isSingle == true) {
        //获取单体系user
        String jsonTree =
            await Tree.getTreeFromSer(userInfo["id"], false, context);
        var parsedJson = json.decode(jsonTree);
        Tree.getAllPeople(parsedJson, users);
      } else {
        List treeList = await Tree.getMulTreeFromSer(isSingle);

        treeList.forEach((element) {
          List l = [];
          var parsedJson = json.decode(element);
          Tree.getAllPeople(parsedJson, l);
          List idList = [];
          l.forEach((element) {
            idList.add(element["id"]);
          });
          mulUserIds.add(idList);
          users.addAll(l);
        });
      }

      // 处理users列表，消除重复的，且将多体系的人名字后添加“（多体系用户）”
      Set userIds = {};
      for (int i = 0; i < users.length; i++) {
        if (userIds.contains(users[i]["id"])) {
          //消除重复
          users.removeAt(i);
          i--;
        } else {
          userIds.add(users[i]["id"]);
          var isSingle = await Tree.isInSingleCom(users[i]["id"]); //多体系=》名字后面加
          if (isSingle != true) {
            users[i]["name"] += "(多体系用户)";
          }
        }
      }

      String id = userInfo["id"];
      for (int i = 0; i < users.length; i++) {
        if (users[i]["id"] == id) {
          users.removeAt(i);
        }
      }

      //=================================进行选择=========

      // List targetAllList = await Navigator.of(context).push(MaterialPageRoute(
      var result = await Navigator.of(context).push(MaterialPageRoute(
          builder: (BuildContext context) => ContactListPage(users)));
      if (result == null) {
        return;
      }
      List targetAllList = result;

      targetIdList = [];
      List alltargetIdList = [];
      if (targetAllList[0] != null && !targetAllList[0].isEmpty) {
        targetAllList[0].forEach((element) {
          alltargetIdList.add(element["id"]);
        });
//====开始发送===
        if (isSingle == true) {
          //如果当前创建人是单体系用户
          var temp =
              await Tree.getTypeFromUsers(alltargetIdList, maxNum: 1); //获取列表情况
          if (temp == null) {
            //列表为空
            return;
          } else if (temp is List) {
            //列表中存在了2个及以上的多体系用户
            await DialogUtil.showAlertDiaLog(
              context,
              "最多允许选择1个多体系用户。",
              title: "发送失败",
            );
          } else {
            //发送消息
            targetIdList = List.from(alltargetIdList);
            await _sendMessage2(messageModel, targetIdList);
            // sendMessageSuccess("发送成功");
          }
        } else {
          //如果是多体系用户
          var temp = await Tree.getTypeFromUsers(alltargetIdList); //获取列表情况
          if (temp == null) {
            //列表为空
            return;
          } else if (temp is List) {
            //列表中存在了1个及以上的多体系用户
            await DialogUtil.showAlertDiaLog(
              context,
              "不允许选择多体系用户。",
              title: "发送失败",
            );
          } else {
            //发送消息

//首先要用muluserids和targetIdList将各个体系的人分开
            //       for (int i = 0; i < mulUserIds.length; i++) {
            //         //对于每个体系的id
            //         targetIdList = List<String>.from(Set.from(mulUserIds[i])
            //             .intersection(Set.from(alltargetIdList))
            //             .toList());
            //         if (targetIdList != null) {
            //           String subtype = await Tree.getTypeFromUsers(targetIdList);
            //           await _sendMessageMul(messageModel, subtype);
            //         }
            //       }
            //     }
            //   }
            // }

            List typelist = [];
            for (int i = 0; i < mulUserIds.length; i++) {
              //对于每个体系的id
              List idList = List<String>.from(Set.from(mulUserIds[i])
                  .intersection(Set.from(alltargetIdList))
                  .toList());
              if (idList != null) {
                String type = await Tree.getTypeFromUsers(targetIdList);
                typelist.add(type);
              }
            }
            bool multitleonly =
                await checkmultitleonly(messageModel.title, typelist);
            if (!multitleonly) {
              await DialogUtil.showAlertDiaLog(
                context,
                "标题已创建",
                title: "发送失败",
              );
            } else {
//首先要用muluserids和targetIdList将各个体系的人分开
              for (int i = 0; i < mulUserIds.length; i++) {
                //对于每个体系的id
                targetIdList = List<String>.from(Set.from(mulUserIds[i])
                    .intersection(Set.from(alltargetIdList))
                    .toList());
                // if (targetIdList != null) {
                if (targetIdList != null && targetIdList.length != 0) {
                  String subtype = await Tree.getTypeFromUsers(targetIdList);
                  await _sendMessageMul(messageModel, subtype);
                }
              }
              sendMessageSuccess("发送成功");
            }
          }
        }
      }

      ///===这里是短信的 基本没改，改了个小bug====
      noteIdList = [];
      noteNameList = [];
      List allnoteIdList = [];
      List allnoteNameList = [];
      if (targetAllList[1] != null && !targetAllList[1].isEmpty) {
        targetAllList[1].forEach((element) {
          allnoteIdList.add(element["id"]);
          allnoteNameList.add(element["name"]);
        });
        noteIdList = List.from(allnoteIdList);
        noteNameList = List.from(allnoteNameList);
        _sendNoteMessage();
      }
    } else {
      sendMessageSuccess("该标题已创建");
    }
  }

  _sendMessage2(MessageModel messageModel, List targetIdList) async {
    //单体系用户调用，需要满足targetIdList中仅存在最多1个多体系用户
    SharedPreferences prefs = await SharedPreferences.getInstance();
    // var db = DatabaseHelper();
    // db.initDb();
    //在这里写选择联系人，并将targetId改为联系人id
    print("****************这里打印targetIdList****");
    // print(targetIdList.join(',').toString());
    var uuid = Uuid();
    var messageId = uuid.v1();
    messageModel.messageId = messageId;
    messageModel.fromuserid = prefs.getString("id");
    String content;
    content = messageModel.toJsonString();
    String useid = prefs.get("id");
    String totargetid = useid;
    for (int i = 0; i < targetIdList.length; i++) {
      if (targetIdList[i] != useid) {
        totargetid = totargetid + "+";
        totargetid = totargetid + targetIdList[i];
      }
    }

    var type = await Dio().post("http://47.110.150.159:8080/gettype?id=$useid");

    //发给服务器
    var rel = await Dio()
        .post("http://47.110.150.159:8080/messages/insertMessage", data: {
      "keywords": totargetid,
      "messages": messageModel.htmlCode,
      "touserid": messageModel.messageId,
      "fromuserid": prefs.get("id"),
      "title": messageModel.title,
      "hadLook": prefs.get("name") +
          "(" +
          new DateTime.now().toString().split('.')[0] +
          ")",
      "MesId": messageModel.messageId,
      "Flag": "遮蔽消息", //这里增加了flag
      "type": type.data,
    });

    // print(targetIdList.join(',').toString());
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
      "grouptype": type.data,
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

  _sendMessageMul(MessageModel messageModel, String type) async {
    //多体系用户建群调用，需要传入type，且要求targetIdList中不存在多体系用户
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
    String content;
    content = messageModel.toJsonString();
    // String useid = prefs.get("id");
    // var type = await Dio().post("http://47.110.150.159:8080/gettype?id=$useid");
    String useid = prefs.get("id");
    String totargetid = useid;
    for (int i = 0; i < targetIdList.length; i++) {
      if (targetIdList[i] != useid) {
        totargetid = totargetid + "+";
        totargetid = totargetid + targetIdList[i];
      }
    }

    //发给服务器
    var rel = await Dio()
        .post("http://47.110.150.159:8080/messages/insertMessage", data: {
      "keywords": totargetid,
      "messages": messageModel.htmlCode,
      "touserid": messageModel.messageId,
      "fromuserid": prefs.get("id"),
      "title": messageModel.title,
      "hadLook": prefs.get("name") +
          "(" +
          new DateTime.now().toString().split('.')[0] +
          ")",
      "MesId": messageModel.messageId,
      "Flag": "遮蔽消息", //这里增加了flag
      // "type": type.data,
      "type": type,
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
      // "grouptype": type.data,
      "grouptype": type,
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
    // sendMessageSuccess("发送成功");
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

  Future<bool> checkmultitleonly(String title, List typelist) async {
    for (int i = 0; i < typelist.length; i++) {
      var rel =
          await Dio().post("http://47.110.150.159:8080/group/select", data: {
        "groupname": title,
        "grouptype": typelist[i],
      });
      List r = rel.data;
      if (r.isNotEmpty) {
        return false;
      }
    }
    return true;
  }
}
