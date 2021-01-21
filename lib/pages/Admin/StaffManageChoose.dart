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

class RightButton extends StatelessWidget {
  String rightName;
  RightButton(this.rightName, this.onPressed, {this.pressable});
  Function onPressed;
  bool pressable;

  @override
  Widget build(BuildContext context) {
    return FlatButton(
      child: Text(rightName),
      onPressed: () {
        if (pressable) {
          onPressed(this.rightName);
        }
      },
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
  }
  // Widget addNode() {
  //   Map<String, TreeNode> _remarkControllers = new Map();
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("安全生产经营管理体系"),
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
        nodes: toTreeNodes(parsedJson, null),
        // treeController: _treeController,
      );
    } on FormatException catch (e) {
      return Text(e.message);
    }
  }

  List<TreeNode> toTreeNodes(dynamic parsedJson, var fatherName) {
    if (parsedJson is Map<String, dynamic>) {
      return parsedJson.keys
          .map((k) => TreeNode(
              content: RightButton(k, onPressed, pressable: k != staff),
              children: toTreeNodes(parsedJson[k], k)))
          .toList();
    }
    if (parsedJson is List<dynamic>) {
      return parsedJson
          .asMap()
          .map((i, element) =>
              MapEntry(i, TreeNode(content: Text('[${element["name"]}]'))))
          .values
          .toList();
    }
    return [TreeNode(content: RightButton(parsedJson.toString(), onPressed))];
  }

  void onPressed(String rightName) {
    if (rightName != null) {
      Navigator.pop(context, rightName);
    }
  }
}
