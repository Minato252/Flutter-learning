import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_simple_treeview/flutter_simple_treeview.dart';
import 'package:provider/provider.dart';
import 'package:weitong/services/event_util.dart';
import 'package:weitong/services/providerServices.dart';

String staff = "人员";

// String jsonTree = '''
// {
//     "总经理": {
//         "$staff": [
//             {
//                 "name": "老总",
//                 "id": "这里是手机号",
//                 "password": "这里是密码",
//                 "job": "这里是职务",
//                 "right": "总经理"
//             }
//         ],
//         "美术部门": {
//             "$staff": [
//                 {
//                     "name": "张三",
//                     "id": "这里是手机号",
//                     "password": "这里是密码",
//                     "job": "这里是职务",
//                      "right": "美术部门"
//                 },
//                 {
//                     "name": "美术李四",
//                     "id": "这里是手机号",
//                     "password": "这里是密码",
//                     "job": "这里是职务",
//                 "right": "美术部门"
//                 }
//             ],
//             "美术小组": {
//                "$staff": [
//                     {
//                         "name": "美术王五",
//                         "id": "这里是手机号",
//                         "password": "这里是密码",
//                         "job": "这里是职务",
//                         "right": "美术小组"
//                     }
//                 ]
//             }
//         },
//         "软件部门": {
//            "$staff": [
//                 {
//                     "name": "软件李四",
//                     "id": "这里是手机号",
//                     "password": "这里是密码",
//                     "job": "这里是职务",
//                     "right": "软件部门"
//                 }
//             ],
//             "软件小组": {
//                 "$staff": [
//                     {
//                         "name": "软件王五",
//                         "id": "这里是手机号",
//                         "password": "这里是密码",
//                         "job": "这里是职务",
//                     "right": "软件小组"
//                     }
//                 ]
//             }
//         },
//         "人力部门": {
//            "$staff": [ ]
//         },
//         "销售部门": {
//             "$staff": [ ]
//         }
//     }
// }
// '''; //一直以来更改的jsonTree
class RightButton extends StatefulWidget {
  bool pressable;
  Color c;
  String rightName;

  RightButton(this.rightName, {this.pressable, this.c});
  @override
  _RightButtonState createState() => _RightButtonState(rightName, pressable, c);
}

List<String> targRightList = [];

class _RightButtonState extends State<RightButton> {
  @override
  String rightName;
  _RightButtonState(this.rightName, this.pressable, this.c);

  bool pressable;
  Color c;
  @override
  Widget build(BuildContext context) {
    return rightButtonNode(rightName);
  }

  rightButtonNode(dynamic rightName) {
    return Row(
      children: [
        Text(
          rightName,
          style: TextStyle(color: c),
        ),
        rightName == staff
            ? SizedBox()
            : Checkbox(
                value: targRightList.contains(rightName),
                activeColor: Colors.red,
                onChanged: (value) {
                  if (targRightList.contains(rightName)) {
                    targRightList.remove(rightName);

                    // EventBusUtil.getInstance().fire(UpdataNode("checkChange"));
                    if (mounted) {
                      setState(() {});
                    }
                    // value = false;
                  } else {
                    // targIdList.add(friends);
                    targRightList.add(rightName);

                    // value = true;
                    // EventBusUtil.getInstance().fire(UpdataNode("checkChange"));
                    if (mounted) {
                      setState(() {});
                    }
                  }
                }),
      ],
    );
  }
}

// 在这里管理人员权限(方框,连线)
class StaffManageChoose extends StatefulWidget {
  StaffManageChoose({Key key}) : super(key: key);

  @override
  _StaffManageChooseState createState() => _StaffManageChooseState();
}

class _StaffManageChooseState extends State<StaffManageChoose> {
  String degreeName = "请输入权限名称";
  List<String> node = ["1", "2", "3"];

  StreamSubscription<UpdataNode> sss; //eventbus传值

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    targRightList = [];
  }
  // Widget addNode() {
  //   Map<String, TreeNode> _remarkControllers = new Map();
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("安全生产经营管理体系"),
        actions: [
          IconButton(
            icon: Icon(Icons.done),
            onPressed: () {
              finishChoose();
            },
          )
        ],
      ),
      body: Scrollbar(
        child: SingleChildScrollView(
          child: buildTree(),
        ),
      ),
      //   TreeNode(content: Text("权限1")),
      //   TreeNode(
      //       content: Row(
      //     children: [
      //       Text(degreeName),
      //       InkWell(
      //         child: Icon(Icons.add),
      //         onTap: () {},
      //       )
      //     ],
      //   )),
      //   TreeNode(
      //     content: Text("权限2"),
      //     children: [
      //       TreeNode(content: Text("权限3")),
      //       TreeNode(content: Text("权限4")),
      //       TreeNode(
      //         content: Text("权限5"),
      //         children: [
      //           TreeNode(content: Text("权限6")),
      //         ],
      //       ),
      //     ],
      //   ),
      // tn,

      // floatingActionButton: FloatingActionButton(
      //   onPressed: () {
      //     refreshUI();
      //   },
      // ),
    );
  }

  /// Builds tree or error message out of the entered content.
  Widget buildTree() {
    try {
      final tree = Provider.of<ProviderServices>(context);
      String jsonTree = tree.tree;

      var parsedJson = json.decode(jsonTree);
      return TreeView(
        nodes: toTreeNodes(parsedJson, null, myColor.length - 1),
        // treeController: _treeController,
      );
    } on FormatException catch (e) {
      return Text(e.message);
    }
  }

  List<Color> myColor = [
    Colors.purple[700],
    Colors.blue[700],
    Colors.green[700],
    Colors.yellow[700],
    Colors.orange[700],
    Colors.red[700],
  ];

  List<TreeNode> toTreeNodes(
      dynamic parsedJson, var fatherName, int colorIndex) {
    if (parsedJson is Map<String, dynamic>) {
      return parsedJson.keys
          .map((k) => TreeNode(
              content: RightButton(
                k,
                pressable: k != staff,
                c: myColor[k == staff
                    ? (colorIndex + 1 < myColor.length ? colorIndex + 1 : 0)
                    : colorIndex],
              ),
              children: toTreeNodes(parsedJson[k], k,
                  (colorIndex - 1) > -1 ? colorIndex - 1 : myColor.length - 1)))
          .toList();
    }
    if (parsedJson is List<dynamic>) {
      return parsedJson
          .asMap()
          .map((i, element) => MapEntry(
              i,
              TreeNode(
                  content: Row(
                children: [
                  CircleAvatar(
                    backgroundColor: myColor[
                        colorIndex + 2 < myColor.length ? colorIndex + 2 : 1],
                    child: Text(
                      element["name"][0],
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                  SizedBox(
                    width: 10,
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${element["name"]}',
                        style: TextStyle(color: Colors.black, fontSize: 15),
                      ),
                      Text(
                        '${element["id"]}',
                        style: TextStyle(color: Colors.grey, fontSize: 12),
                      )
                    ],
                  ),
                ],
              ))))
          .values
          .toList();
    }
    return [
      TreeNode(
          content: RightButton(
        parsedJson.toString(),
      ))
    ];
  }

  // List<TreeNode> toTreeNodes(dynamic parsedJson, var fatherName) {
  //   if (parsedJson is Map<String, dynamic>) {
  //     return parsedJson.keys
  //         .map((k) => TreeNode(
  //             content: RightButton(k, onPressed, pressable: k != staff),
  //             children: toTreeNodes(parsedJson[k], k)))
  //         .toList();
  //   }
  //   if (parsedJson is List<dynamic>) {
  //     return parsedJson
  //         .asMap()
  //         .map((i, element) => MapEntry(
  //             i,
  //             TreeNode(
  //                 content: Row(
  //               children: [
  //                 CircleAvatar(
  //                   backgroundColor: Theme.of(context).accentColor,
  //                   child: Text(
  //                     element["name"][0],
  //                     style: TextStyle(color: Colors.white),
  //                   ),
  //                 ),
  //                 SizedBox(
  //                   width: 10,
  //                 ),
  //                 Column(
  //                   crossAxisAlignment: CrossAxisAlignment.start,
  //                   children: [
  //                     Text(
  //                       '${element["name"]}',
  //                       style: TextStyle(color: Colors.black, fontSize: 15),
  //                     ),
  //                     Text(
  //                       '${element["id"]}',
  //                       style: TextStyle(color: Colors.grey, fontSize: 12),
  //                     )
  //                   ],
  //                 ),
  //               ],
  //             ))))
  //         .values
  //         .toList();
  //   }
  //   return [TreeNode(content: RightButton(parsedJson.toString(), onPressed))];
  // }

  void finishChoose() {
    if (targRightList.isNotEmpty) {
      Navigator.pop(context, targRightList);
    }
  }
}
