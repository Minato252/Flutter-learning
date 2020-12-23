import 'package:flutter/material.dart';
import 'package:rongcloud_im_plugin/rongcloud_im_plugin.dart';
import 'package:weitong/Model/user_data.dart';
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
  // List _pagelist = [Message(), MessageCreate(), LogRecord(), User()];
  @override
  void initState() {
    super.initState();

    print("init");
    initPlatformState();
  }

  initPlatformState() async {
    // 1.初始化 im SDK
    RongIMClient.init(RongAppKey);

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
    };
  }

  Future<void> cleanToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString("token", null);
  }

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("微通"),
      ),
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
          BottomNavigationBarItem(
              icon: Icon(Icons.account_circle), title: Text("联系人")),
          BottomNavigationBarItem(icon: Icon(Icons.people), title: Text("我的"))
        ],
      ),
    );
  }
}
