import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:weitong/pages/Admin/AddUser.dart';
import 'package:weitong/pages/SearchMessage/search_conversation_page.dart';
import 'package:weitong/pages/tabs/ChooseUser.dart';
import 'package:weitong/pages/tabs/Message.dart';
import 'package:weitong/pages/tabs/Setting.dart';
import 'package:weitong/pages/tabs/conversation_page.dart';
import 'package:weitong/pages/tags/TagChoiceChipDemo.dart';
import '../pages/tabs/Tabs.dart';
import '../pages/tags/TagChipDemo.dart';
import '../pages/tags/TagTextFieldDemo.dart';
import '../pages/Admin/AdminTabs.dart';
import '../pages/tabs/ReadMessage.dart';
import '../pages/tabs/MessageItem.dart';
import 'package:weitong/pages/Note/EditCreate.dart';
import 'package:weitong/pages/Note/CategoryPage.dart';
import 'package:weitong/pages/Note/NewCategory.dart';
import 'package:weitong/pages/Note/PreEdit.dart';
import 'package:weitong/pages/tabs/User.dart';

//配置路由
final routes = {
  '/': (context) => Tabs(),
  '/updateTags': (context, {arguments}) => TagChipDemo(arguments: arguments),
  '/inputNewTag': (context) => TextFieldDemo(),
  '/chooseTags': (context) => TagChoiceChipDemo(),
  '/admin': (context) => AdminTabs(),
  // '/addUser': (context) => AddUser(),
  '/chooseUser': (context) => ChooseUserPage(),
  // '/readMessage': (context, {argumets}) => ReadMessage(arguments: argumets),
  // '/readMessage': (context, {arguments}) => ReadMessage(arguments: arguments),

  '/messageItem': (context, {arguments}) =>
      MessageItemPage(arguments: arguments),

  '/conversation': (context, {arguments}) =>
      ConversationPage(arguments: arguments),
  '/searchConversation': (context, {arguments}) =>
      SearchConversationPage(arguments: arguments),
  // '/form': (context, {arguments}) => FormPage(arguments: arguments),
  // '/readMessage': (context) => ReadMessage(),
  '/category': (BuildContext context) => new CategoryPage(),
  '/edit': (BuildContext context) => new EditCreate(),
  '/newcategory': (context) => NewCategory(),
  '/preedit': (context) => PreEdit(),
  '/setting': (context) => SettingPage(),
  '/user': (context) => UserPage(),
};

//固定写法
// var onGenerateRoute = (RouteSettings settings) {
// // 统一处理
//   final String name = settings.name;
//   final Function pageContentBuilder = routes[name];
//   if (pageContentBuilder != null) {
//     if (settings.arguments != null) {
//       final Route route = MaterialPageRoute(
//           builder: (context) =>
//               pageContentBuilder(context, arguments: settings.arguments));
//       return route;
//     } else {
//       final Route route =
//           MaterialPageRoute(builder: (context) => pageContentBuilder(context));
//       return route;
//     }
//   }
// };

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
