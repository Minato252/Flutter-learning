import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:locally/locally.dart';
import 'package:provider/provider.dart';
import 'package:rongcloud_im_plugin/rongcloud_im_plugin.dart';
import 'package:weitong/main.dart';
import 'package:weitong/services/providerServices.dart';
import 'package:flutter_local_notifications/src/platform_specifics/android/enums.dart';
import 'package:flutter_local_notifications/src/platform_specifics/android/notification_details.dart';
import 'package:flutter_local_notifications/src/platform_specifics/ios/notification_details.dart';
import 'package:flutter_local_notifications/src/notification_details.dart';

class MyLocally extends Locally {
  int index = 0;
  MyLocally({
    @required BuildContext context,
    @required MaterialPageRoute pageRoute,
    @required String appIcon,
    @required String payload,
    iosRequestSoundPermission = false,
    iosRequestBadgePermission = false,
    iosRequestAlertPermission = false,
  }) : super(
            context: context,
            pageRoute: pageRoute,
            appIcon: appIcon,
            payload: payload,
            iosRequestSoundPermission: iosRequestSoundPermission,
            iosRequestBadgePermission: iosRequestBadgePermission,
            iosRequestAlertPermission: iosRequestAlertPermission);
  @override
  Future<void> onSelectNotification(String payload) async {
    if (payload != null) {
      debugPrint('notification payload: ' + payload);
    }
    // await Navigator.pushAndRemoveUntil(
    //     context, super.pageRoute, (route) => route == null);
  }

  @override
  Future<void> onDidReceiveNotification(id, title, body, payload) async {
    await showDialog(
        context: context,
        child: CupertinoAlertDialog(
          title: title,
          content: Text(body),
          actions: <Widget>[
            CupertinoDialogAction(
              isDefaultAction: true,
              child: Text('Ok'),
              onPressed: () async {
                // await Navigator.pushAndRemoveUntil(
                //     context, super.pageRoute, (route) => route == null);
              },
            )
          ],
        ));
  }

  Future show(
      {@required title,
      @required message,
      channelName = 'channel Name',
      channelID = 'channelID',
      channelDescription = 'channel Description',
      importance = Importance.High,
      priority = Priority.High,
      ticker = 'test ticker'}) async {
    if (title == null && message == null) {
      throw "Missing parameters, title: message";
    } else {
      this.title = title;
      this.message = message;

      var androidPlatformChannelSpecifics = AndroidNotificationDetails(
          channelID, channelName, channelDescription,
          importance: importance, priority: priority, ticker: ticker);

      var iosPlatformChannelSpecifics = IOSNotificationDetails();

      var platformChannelSpecifics = NotificationDetails(
          androidPlatformChannelSpecifics, iosPlatformChannelSpecifics);

      await localNotificationsPlugin.show(
          index++, title, message, platformChannelSpecifics,
          payload: payload);
    }
    print(index);
  }

  Future cancelAll() async {
    index = 0;
    localNotificationsPlugin.cancelAll();
  }
}

MyLocally locally = null;
// Locally locally2 = null;

class EasyNotification {
  // MyLocally locally;
  // var p;
  // bool isActive;
  EasyNotification() {
    BuildContext context = navigatorKey.currentState.overlay.context;
    // p = Provider.of<ProviderServices>(context);
    // locally = p.locally;
    // isActive = p.isActive;

    if (locally == null) {
      locally = MyLocally(
        context: context,
        payload: 'test',
        pageRoute: MaterialPageRoute(builder: (context) => Tab()),
        appIcon: 'mipmap/ic_launcher',
      );
    }

    // locally2 = MyLocally(
    //   context: context,
    //   payload: 'test',
    //   pageRoute: MaterialPageRoute(builder: (context) => Tab()),
    //   appIcon: 'mipmap/ic_launcher',
    // );
    // p.upDatalocally(locally);

    // }
  }
  // void locallyInit() {

  // }

  Future<void> show(
      {String title = "亘管", String message = "新信息", String id = ""}) async {
    //如果不在前台就通知
    // locally.show(title: "亘管", message: "您有$num条新消息");
    String unreadString = "";
    RongIMClient.getTotalUnreadCount((int count, int code) {
      if (0 == code) {
        print("未读数为" + count.toString());
        unreadString = "(共${count.toString()}条未读信息)";
      }
    });
    //获取用户名
    if (id != "") {
      var relname = await Dio()
          .post("http://47.110.150.159:8080/getinformation?id=" + id);
      String name = relname.data["uName"].toString();
      message = "$name发来一条新信息";
    }
    message += unreadString;

    // locally.cancelAll();
    if (currentState != AppLifecycleState.resumed) {
      // locally.show(title: "亘管", message: "新消息");
      locally.show(title: title, message: message);
      // locally2.show(title: "weitong", message: "weitong");
    } else {
      locally.cancelAll();
      locally.show(title: title, message: message);
      locally.cancelAll();
    }
  }

  void cancle() {
    //进入app时调用，取消所有通知
    locally.cancelAll();
  }
}
