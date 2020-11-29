import 'package:flutter/material.dart';
import 'package:weitong/pages/tabs/Message.dart';
import 'package:weitong/pages/tags/TagChoiceChipDemo.dart';
import '../pages/tabs/Tabs.dart';
import '../pages/tags/TagChipDemo.dart';
import '../pages/tags/TagTextFieldDemo.dart';
import '../pages/Admin/AdminTabs.dart';

//配置路由
final routes = {
  '/': (context) => Tabs(),
  '/updateTags': (context) => TagChipDemo(),
  '/inputNewTag': (context) => TextFieldDemo(),
  '/chooseTags': (context) => TagChoiceChipDemo(),
  '/admin': (context) => AdminTabs()
};

//固定写法
var onGenerateRoute = (RouteSettings settings) {
// 统一处理
  final String name = settings.name;
  final Function pageContentBuilder = routes[name];
  if (pageContentBuilder != null) {
    if (settings.arguments != null) {
      final Route route = MaterialPageRoute(
          builder: (context) =>
              pageContentBuilder(context, arguments: settings.arguments));
      return route;
    } else {
      final Route route =
          MaterialPageRoute(builder: (context) => pageContentBuilder(context));
      return route;
    }
  }
};
