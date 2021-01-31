import 'dart:convert';
import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rongcloud_im_plugin/rongcloud_im_plugin.dart';
import 'package:weitong/Model/user_data.dart';
import 'package:weitong/pages/tree/tree.dart';
import 'package:weitong/services/event_bus.dart';
import 'package:weitong/services/providerServices.dart';
import '../Login.dart';
import 'LogRecord.dart';
import 'MessageCreate.dart';
import 'User.dart';
import 'Message.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Tabs extends StatefulWidget {
  Tabs({Key key}) : super(key: key);

  @override
  _TabsState createState() => _TabsState();
}

class _TabsState extends State<Tabs> {
  int _currentIndex = 0;
  List _pagelist = [
    MessagePage(),
    MessageCreate(),
    LogRecordPage(),
    UserPage()
  ];

  AppLifecycleState currentState = AppLifecycleState.resumed;
  // List _pagelist = [Message(), MessageCreate(), LogRecord(), User()];
  @override
  void initState() {
    super.initState();

    print("init");
    initPlatformState();

    initTreeAndUserInfo();

    initKeyWords();
  }

  initPlatformState() async {
    //2.连接 im SDK
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String token = prefs.get("token");
    if (token != null && token.length > 0) {
      // int rc = await RongIMClient.connect(token);
      RongIMClient.connect(token, (int code, String userId) {
        // developer.log("connect result " + code.toString(), name: pageName);

        // EventBus.instance.commit(EventKeys.UpdateNotificationQuietStatus, {});
        if (code == 31004 || code == 12) {
          //登陆失败
          // developer.log("connect result " + code.toString(), name: pageName);
          Navigator.of(context).pushAndRemoveUntil(
              new MaterialPageRoute(builder: (context) => new LoginPage()),
              (route) => route == null);
        } else if (code == 0 || code == 34001) {
          print("登陆成功");
          //登陆成功
          // developer.log("connect userId" + userId, name: pageName);
          // 连接成功后打开数据库
          // _initUserInfoCache();

        }
      });
    } else {
      print("jump into login");
      Navigator.of(context).pushAndRemoveUntil(
          new MaterialPageRoute(builder: (context) => new LoginPage()),
          (route) => route == null);
    }

//绑定接收消息
    RongIMClient.onMessageReceivedWrapper =
        (Message msg, int left, bool hasPackage, bool offline) {
      String hasP = hasPackage ? "true" : "false";
      String off = offline ? "true" : "false";
      if (msg.content != null) {
        print(
          "object onMessageReceivedWrapper objName:" +
              msg.content.getObjectName() +
              " msgContent:" +
              msg.content.encode() +
              " left:" +
              left.toString() +
              " hasPackage:" +
              hasP +
              " offline:" +
              off,
        );
      } else {
        print(
          "object onMessageReceivedWrapper objName: ${msg.objectName} content is null left:${left.toString()} hasPackage:$hasP offline:$off",
        );
      }
      // if (currentState == AppLifecycleState.paused // 应用程序当前对用户不可见，不响应用户输入，并在后台运行。
      //     // && !checkNoficationQuietStatus()   //检查通知静止时间？
      //     ) {
      //   EventBus.instance.commit(EventKeys.ReceiveMessage,
      //       {"message": msg, "left": left, "hasPackage": hasPackage});
      //   RongIMClient.getConversationNotificationStatus(
      //       msg.conversationType, msg.targetId, (int status, int code) {
      //     if (status == 1) {
      //       _postLocalNotification(msg, left);
      //     }
      //   });
      // } else {
      //   //如果应用在后台的话
      //通知其他页面收到消息

      EventBus.instance.commit(EventKeys.ReceiveMessage,
          {"message": msg, "left": left, "hasPackage": hasPackage});
      // }
    };
  }

  initTreeAndUserInfo() async {
    // var rel = await Dio().post("http://47.110.150.159:8080/tree/selectMem");
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String id = prefs.getString("id");
    String jsonTree = await Tree.getTreeFormSer(id, false, context);

    var parsedJson = json.decode(jsonTree);
    Map userInfo = Tree.getUserInfoAndSave(parsedJson, id, context);
    print(userInfo.toString());
  }

  initKeyWords() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String k = prefs.getString("keyWords");
    List<String> keyWords;
    if (k == null || k == "null") {
      keyWords = [];
    } else {
      keyWords = k.split(",");
    }

    final ps = Provider.of<ProviderServices>(context);
    ps.upDataKeyWords(keyWords);
  }

  Future<void> cleanToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString("token", null);
  }

  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(
      //   title: Text("微通"),
      // ),
      // floatingActionButton: FloatingActionButton(
      //   child: Icon(Icons.delete),
      //   onPressed: () {
      //     cleanToken();
      //   },
      // ),
      body: this._pagelist[this._currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: this._currentIndex,
        onTap: (index) {
          setState(() {
            this._currentIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        fixedColor: Colors.red,
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.textsms), title: Text("消息")),
          BottomNavigationBarItem(icon: Icon(Icons.create), title: Text("创建")),
          BottomNavigationBarItem(icon: Icon(Icons.search), title: Text("查询")),
          BottomNavigationBarItem(icon: Icon(Icons.people), title: Text("我的"))
        ],
      ),
    );
  }
}
