import 'package:flutter/material.dart';
import 'package:rongcloud_im_plugin/rongcloud_im_plugin.dart';
import 'package:weitong/pages/Admin/searchDemo.dart';
import 'package:weitong/services/ScreenAdapter.dart';
import 'Model/user_data.dart';
import 'pages/tabs/Tabs.dart';
import 'routers/router.dart';
import 'pages/Login.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  MyApp({Key key}) : super(key: key);

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    // 1.初始化 im SDK
    RongIMClient.init(RongAppKey);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // home: SearchDemo(),
      initialRoute: '/',
      onGenerateRoute: onGenerateRoute,
    );
  }
}
