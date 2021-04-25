import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rongcloud_im_plugin/rongcloud_im_plugin.dart';
import 'package:weitong/pages/Admin/searchDemo.dart';
import 'package:weitong/services/ScreenAdapter.dart';
import 'package:weitong/services/providerServices.dart';
import 'package:weitong/widget/mylocally.dart';
import 'Model/user_data.dart';
import 'pages/tabs/Tabs.dart';
import 'routers/router.dart';
import 'pages/Login.dart';

void main() {
  runApp(MyApp());
}

AppLifecycleState currentState = AppLifecycleState.resumed;

final GlobalKey<NavigatorState> navigatorKey = new GlobalKey<NavigatorState>();

class MyApp extends StatefulWidget {
  MyApp({Key key}) : super(key: key);

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    // 1.初始化 im SDK
    RongIMClient.init(RongAppKey);
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    print("--" + state.toString());
    // final p = Provider.of<ProviderServices>(context);
    currentState = state;
    switch (state) {
      case AppLifecycleState.inactive: // 处于这种状态的应用程序应该假设它们可能在任何时候暂停。
        print("inactive");
        break;
      case AppLifecycleState.resumed: //从后台切换前台，界面可见
        print("resumed");
        // final p = Provider.of<ProviderServices>(context);
        if (locally != null) {
          locally.cancelAll();
        }
        break;
      case AppLifecycleState.paused: // 界面不可见，后台
        print("paused");
        break;
      case AppLifecycleState.detached: // APP结束时调用
        print("detached");
        break;
    }
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
