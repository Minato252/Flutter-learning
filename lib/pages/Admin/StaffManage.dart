import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_simple_treeview/flutter_simple_treeview.dart';
import 'package:weitong/pages/Admin/RightTextFieldDemo.dart';

String jsonTree = '''
{
  "employee": {
    "name": "sonoo",
    "level": 56,
    "married": true,
    "hobby": null
  },
  "week": [
    "Sunday",
    "Monday",
    "Tuesday",
    "Wednesday",
    "Thursday",
    "Friday",
    "Saturday"
  ]
}
''';

class RightWidget extends StatefulWidget {
  String rightName;
  Function refreshUI;
  RightWidget(String rightNam) {
    this.rightName = rightName;
  }

  @override
  _RightWidgetState createState() => _RightWidgetState(rightName);
}

class _RightWidgetState extends State<RightWidget> {
  _RightWidgetState(String rightName) {
    this.rightName = rightName;
  }
  String rightName;
  Widget build(BuildContext context) {
    return Container(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Text("$rightName"),
          Row(
            children: [
              IconButton(
                icon: Icon(Icons.add),
                onPressed: onTapPlus,
              )
            ],
          )
        ],
      ),
    );
  }

  onTapPlus() async {
    //这里写新增孩子的函数
    final newRight = await Navigator.push(
      context,
      new MaterialPageRoute(builder: (context) => new RightTextFieldDemo()),
    );
    if (newRight != null) {
      var parsedJson = json.decode(jsonTree);
      parsedJson = insertNode(parsedJson, rightName, newRight);
      jsonTree = json.encode(parsedJson);
      //这里应该刷新tree的UI
    }
  }
}

Map insertNode(parsedJson, parent, child) {
  if (parsedJson is Map<String, dynamic>) {
    parsedJson.forEach((key, value) {
      if (key == parent) {
        value[child] = {};
      } else {
        parsedJson[key] = insertNode(parsedJson[key], parent, child);
      }
    });
  }
  return parsedJson;
}

// 在这里管理人员权限(方框,连线)
class StaffManagePage extends StatefulWidget {
  StaffManagePage({Key key}) : super(key: key);

  @override
  _StaffManagePageState createState() => _StaffManagePageState();
}

class _StaffManagePageState extends State<StaffManagePage> {
  String degreeName = "请输入权限名称";
  List<String> node = ["1", "2", "3"];
  @override

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

      floatingActionButton: FloatingActionButton(
        onPressed: () {
          setState(() {
//             jsonTree = '''
//             {
//   "employee": {
//     "name": {},
//     "level": {},
//     "married": {},
//     "hobby": {}
//   }
//             }
// ''';
          });
        },
      ),
    );
  }

  /// Builds tree or error message out of the entered content.
  Widget buildTree() {
    try {
      var parsedJson = json.decode(jsonTree);
      return TreeView(
        nodes: toTreeNodes(parsedJson),
        // treeController: _treeController,
      );
    } on FormatException catch (e) {
      return Text(e.message);
    }
  }

  List<TreeNode> toTreeNodes(dynamic parsedJson) {
    if (parsedJson is Map<String, dynamic>) {
      return parsedJson.keys
          .map((k) => TreeNode(
              content: RightWidget('$k'), children: toTreeNodes(parsedJson[k])))
          .toList();
    }
    if (parsedJson is List<dynamic>) {
      return parsedJson
          .asMap()
          .map((i, element) => MapEntry(i,
              TreeNode(content: Text('[$i]:'), children: toTreeNodes(element))))
          .values
          .toList();
    }
    return [TreeNode(content: RightWidget(parsedJson.toString()))];
  }
}

class Task {
  String remark; //要给每个添加的controller绑定的值
  String key; //唯一键 与数据无关
  String json = "";
}
