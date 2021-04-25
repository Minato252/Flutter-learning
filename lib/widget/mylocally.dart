import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:locally/locally.dart';
import 'package:provider/provider.dart';
import 'package:rongcloud_im_plugin/rongcloud_im_plugin.dart';
import 'package:weitong/main.dart';
import 'package:weitong/services/providerServices.dart';

class MyLocally extends Locally {
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
}

MyLocally locally = null;

class easyNotification {
  // MyLocally locally;
  // var p;
  // bool isActive;
  easyNotification() {
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
      // p.upDatalocally(locally);

    }
  }
  // void locallyInit() {

  // }

  void show() {
    if (currentState != AppLifecycleState.resumed) {
      //如果不在前台就通知
      // locally.show(title: "微通", message: "您有$num条新消息");
      RongIMClient.getTotalUnreadCount((int count, int code) {
        if (0 == code) {
          print("未读数为" + count.toString());
        }
      });
      locally.cancelAll();
      locally.show(title: "微通", message: "新消息");
    } else {
      locally.cancelAll();
      locally.show(title: "微通", message: "新消息");
      locally.cancelAll();
    }
  }

  void cancle() {
    //进入app时调用，取消所有通知
    locally.cancelAll();
  }
}
