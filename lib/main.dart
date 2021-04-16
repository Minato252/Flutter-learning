import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rongcloud_im_plugin/rongcloud_im_plugin.dart';
import 'package:weitong/pages/Admin/searchDemo.dart';
import 'package:weitong/services/ScreenAdapter.dart';
import 'package:weitong/services/providerServices.dart';
import 'Model/user_data.dart';
import 'pages/tabs/Tabs.dart';
import 'routers/router.dart';
import 'pages/Login.dart';

void main() {
  runApp(MyApp());
}

final GlobalKey<NavigatorState> navigatorKey = new GlobalKey<NavigatorState>();

class MyApp extends StatefulWidget {
  MyApp({Key key}) : super(key: key);



  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  @override
  void initState() {
    super.initState();
    // 1.初始化 im SDK
    RongIMClient.init(RongAppKey);
  }

  @override
  Widget build(BuildContext context) {
    // return MaterialApp(
    //   // home: SearchDemo(),
    //   initialRoute: '/',
    //   onGenerateRoute: onGenerateRoute,
    // );

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ProviderServices()),
      ],
      child: MaterialApp(
        navigatorKey: navigatorKey,
        // home: Tabs(),
        debugShowCheckedModeBanner: false,
        initialRoute: '/',
        onGenerateRoute: onGenerateRoute,
        // theme: ThemeData(
        //     // primaryColor: Colors.yellow
        //     primaryColor: Colors.white),
      ),
    );
  }
}
