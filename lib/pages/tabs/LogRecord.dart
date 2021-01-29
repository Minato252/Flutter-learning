// import 'dart:convert';

// import 'package:flutter/material.dart';
// import 'package:flutter_simple_treeview/flutter_simple_treeview.dart';
// import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
// import 'package:provider/provider.dart';
// import 'package:weitong/services/event_util.dart';
// import 'package:weitong/services/providerServices.dart';

// String staff = "人员";
// // String jsonTreeNet = '''
// // {
// //     "总经理": {

// //         "$staff": [
// //             {
// //                 "name": "老总",
// //                 "id": "123",
// //                 "password": "这里是密码",
// //                 "job": "这里是职务",
// //                 "right": "总经理"
// //             }
// //         ],
// //         "美术部门": {
// //             "$staff": [
// //                 {
// //                     "name": "张三",
// //                     "id": "456",
// //                     "password": "这里是密码",
// //                     "job": "这里是职务",
// //                      "right": "美术部门"
// //                 },
// //                 {
// //                     "name": "美术李四",
// //                     "id": "789",
// //                     "password": "这里是密码",
// //                     "job": "这里是职务",
// //                 "right": "美术部门"
// //                 }
// //             ],
// //             "美术小组": {
// //                "$staff": [
// //                     {
// //                         "name": "美术王五",
// //                         "id": "4",
// //                         "password": "这里是密码",
// //                         "job": "这里是职务",
// //                         "right": "美术小组"
// //                     }
// //                 ]
// //             }
// //         },
// //         "软件部门": {
// //            "$staff": [
// //                 {
// //                     "name": "软件李四",
// //                     "id": "5",
// //                     "password": "这里是密码",
// //                     "job": "这里是职务",
// //                     "right": "软件部门"
// //                 }
// //             ],
// //             "软件小组": {
// //                 "$staff": [
// //                     {
// //                         "name": "软件王五",
// //                         "id": "6",
// //                         "password": "这里是密码",
// //                         "job": "这里是职务",
// //                     "right": "软件小组"
// //                     }
// //                 ]
// //             }
// //         },
// //         "人力部门": {
// //            "$staff": [ ]
// //         },
// //         "销售部门": {
// //             "$staff": [ ]
// //         }
// //     }
// // }
// // '''; //一直以来更改的jsonTree

// List<String> targIdList = [];

// class LogRecordPage extends StatefulWidget {
//   LogRecordPage({Key key}) : super(key: key);

//   @override
//   _LogRecordPageState createState() => _LogRecordPageState();
// }

// class _LogRecordPageState extends State<LogRecordPage> {
//   StreamSubscription<UpdataNode> sss2; //eventbus传值

//   @override
//   Widget build(BuildContext context) {
//     sss2 = EventBusUtil.getInstance().on<UpdataNode>().listen((data) {
//       if (data.type == "checkChange") {
//         sss2.cancel();
//         setState(() {});
//       }
//     });

//     return Scaffold(
//       appBar: AppBar(
//         title: Text("联系人"),
//         actions: [
//           IconButton(
//               onPressed: () {
//                 print("***************打印选择的联系人************");
//                 print(targIdList.toString());
//               },
//               icon: Icon(Icons.ac_unit)),
//         ],
//       ),
//       body: Scrollbar(
//         child: SingleChildScrollView(
//           child: buildTree(),
//         ),
//       ),
//     );
//   }

//   Widget buildTree() {
//     try {
//       final tree = Provider.of<ProviderServices>(context);
//       String jsonTree = tree.tree;

//       var parsedJson = json.decode(jsonTree);
//       return TreeView(
//         nodes: toTreeNodes(parsedJson, null),
//         // treeController: _treeController,
//       );
//     } on FormatException catch (e) {
//       return Text(e.message);
//     }
//   }

//   List<TreeNode> toTreeNodes(dynamic parsedJson, var fatherName) {
//     if (parsedJson is Map<String, dynamic>) {
//       return parsedJson.keys
//           .map((k) => TreeNode(
//               content: RightButton2(
//                 k,
//                 pressable: k == staff,
//                 authority: fatherName,
//               ),
//               children: toTreeNodes(parsedJson[k], k)))
//           .toList();
//     }
//     if (parsedJson is List<dynamic>) {
//       return parsedJson.asMap().map((i, element) =>
//           // MapEntry(i, TreeNode(content: Text('[${element["name"]}]'))))
//           MapEntry(i, TreeNode(content: staffNode(element)))).values.toList();
//     }
//     return [TreeNode(content: RightButton2(parsedJson.toString()))];
//   }

//   void onPressed(String rightName) {
//     if (rightName != null) {
//       Navigator.pop(context, rightName);
//     }
//   }

//   staffNode(dynamic staff) {
//     return Row(
//       children: [
//         Checkbox(
//           value: targIdList.contains(staff['id']),
//           // value: true,
//           activeColor: Colors.red,
//           onChanged: (value) {
//             if (targIdList.contains(staff['id'])) {
//               targIdList.remove(staff['id']);

//               EventBusUtil.getInstance().fire(UpdataNode("checkChange"));
//               setState(() {});
//               // value = false;
//             } else {
//               // targIdList.add(friends);
//               targIdList.add(staff['id']);

//               // value = true;
//               EventBusUtil.getInstance().fire(UpdataNode("checkChange"));
//               setState(() {});
//             }
//           },
//         ),
//         Text(staff['name']),
//       ],
//     );
//   }
// }

// class RightButton extends StatelessWidget {
//   String rightName;
//   RightButton(this.rightName, {this.pressable, this.authority});
//   String authority;
//   bool pressable;
//   bool isCheck;
//   List<String> friends = [];
//   @override
//   Widget build(BuildContext context) {
//     return FlatButton(
//       child: Row(
//         children: [
//           pressable
//               ? Checkbox(
//                   value: isContains(authority, context),
//                   activeColor: Colors.red,
//                   onChanged: (value) {
//                     if (isContains(authority, context)) {
//                       for (int i = 0; i < friends.length; i++) {
//                         targIdList.remove(friends[i]);
//                       }
//                       // value = false;
//                     } else {
//                       // targIdList.add(friends);
//                       for (int i = 0; i < friends.length; i++) {
//                         targIdList.add(friends[i]);
//                       }
//                       // value = true;
//                     }
//                   },
//                 )
//               : Text(""),
//           Text(rightName),
//         ],
//       ),
//       onPressed: () {},
//     );
//   }

//   bool isContains(String rightName, BuildContext context) {
//     friends = [];
//     final tree = Provider.of<ProviderServices>(context);
//     String jsonTree = tree.tree;
//     var parsedJson = json.decode(jsonTree);
//     getStaff(parsedJson, rightName, friends);
//     if (targIdList.contains(friends)) {
//       return true;
//     } else {
//       return false;
//     }
//   }

//   dynamic getStaff(parsedJson, String rightName, List<String> friends) {
//     if (parsedJson is Map<String, dynamic>) {
//       parsedJson.forEach((key, value) {
//         getStaff(parsedJson[key], rightName, friends);
//       });
//     } else if (parsedJson is List) {
//       for (int i = 0;
//           i < parsedJson.length && parsedJson[i]["right"] == rightName;
//           i++) {
//         if (!friends.contains(parsedJson[i]["id"])) {
//           friends.add(parsedJson[i]["id"]);
//         }
//       }
//     }
//   }
// }

// class RightButton2 extends StatefulWidget {
//   String rightName;
//   // RightButton(this.rightName, {this.pressable, this.authority});
//   String authority;
//   bool pressable;
//   bool isCheck;
//   RightButton2(this.rightName, {Key key, this.pressable, this.authority})
//       : super(key: key);

//   @override
//   _RightButton2State createState() =>
//       _RightButton2State(rightName, pressable: pressable, authority: authority);
// }

// class _RightButton2State extends State<RightButton2> {
//   @override
//   _RightButton2State(this.rightName, {this.pressable, this.authority});
//   String rightName;
//   // RightButton(this.rightName, {this.pressable, this.authority});
//   String authority;
//   bool pressable;
//   bool isCheck;
//   List<String> friends = [];

//   @override
//   Widget build(BuildContext context) {
//     return FlatButton(
//       child: Row(
//         children: [
//           pressable
//               ? Checkbox(
//                   value: isContains(authority, context),
//                   // value: true,
//                   activeColor: Colors.red,
//                   onChanged: (value) {
//                     if (isContains(authority, context)) {
//                       for (int i = 0; i < friends.length; i++) {
//                         targIdList.remove(friends[i]);
//                       }
//                       EventBusUtil.getInstance()
//                           .fire(UpdataNode("checkChange"));
//                       setState(() {});
//                       // value = false;
//                     } else {
//                       // targIdList.add(friends);
//                       for (int i = 0; i < friends.length; i++) {
//                         targIdList.add(friends[i]);
//                       }
//                       // value = true;
//                       EventBusUtil.getInstance()
//                           .fire(UpdataNode("checkChange"));
//                       setState(() {});
//                     }
//                   },
//                 )
//               : Text(""),
//           Text(rightName),
//         ],
//       ),
//       onPressed: () {},
//     );
//   }

//   bool isContains(String rightName, BuildContext context) {
//     friends.clear();
//     final tree = Provider.of<ProviderServices>(context);
//     String jsonTree = tree.tree;
//     var parsedJson = json.decode(jsonTree);
//     getStaff(parsedJson, rightName, friends);
//     for (int i = 0; i < friends.length; i++) {
//       if (!targIdList.contains(friends[i])) {
//         return false;
//       }
//     }
//     return true;
//   }

//   dynamic getStaff(parsedJson, String rightName, List<String> friends) {
//     if (parsedJson is Map<String, dynamic>) {
//       parsedJson.forEach((key, value) {
//         getStaff(parsedJson[key], rightName, friends);
//       });
//     } else if (parsedJson is List) {
//       for (int i = 0;
//           i < parsedJson.length && parsedJson[i]["right"] == rightName;
//           i++) {
//         if (!friends.contains(parsedJson[i]["id"])) {
//           friends.add(parsedJson[i]["id"]);
//         }
//       }
//     }
//   }
// }

import 'package:flutter/material.dart';
import 'package:weitong/Model/messageHistoryModel.dart';
import 'package:weitong/services/DB/db_helper.dart';
import 'package:weitong/services/DB/provider.dart';
// import 'package:flutter_plugin_record/index.dart';

class LogRecordPage extends StatefulWidget {
  LogRecordPage({Key key}) : super(key: key);

  @override
  _LogRecordPageState createState() => _LogRecordPageState();
}

class _LogRecordPageState extends State<LogRecordPage> {
  var db = DatabaseHelper();
  List<MessageHistoryModel> list = new List();
  List<MessageHistoryModel> list2 = new List();

  MessageHistoryModel m = new MessageHistoryModel();

  _getDataFromDb() async {
    // List datas = await db.getTotalList("select * from message");
    List datas = await db.getItem('66666', '77777');
    // Future<int> c = db.getCount();
    // print(c);
    if (datas.length > 0) {
      print("***************************打印长度**********");
      print(datas.length);
      datas.forEach((element) {
        MessageHistoryModel message = MessageHistoryModel.fromMap(element);
        list.add(message);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    db.initDb();
    // db.insert(m, "message");
    // List data =db.getTotalList("select * from message");
    // if(data.length>0){
    //   data.forEach((element) {

    //   })
    // }
    // list2 = db.getItem('1', '1');
    // var c = db.getCount();
    _getDataFromDb();
    return Scaffold(
        appBar: AppBar(
          title: Text("仿微信发送语音"),
        ),
        body: Container(
          child: IconButton(
            icon: Icon(Icons.ac_unit),
            onPressed: () {
              print("**********时间****************");
              print(DateTime.now().millisecondsSinceEpoch);
              print("**********时间****************");
              list.forEach((element) {
                print(element.htmlCode);
              });
            },
          ),
        ));
  }
}
