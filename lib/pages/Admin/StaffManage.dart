import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_simple_treeview/flutter_simple_treeview.dart';
import 'package:weitong/services/event_util.dart';
import 'package:weitong/widget/Input.dart';
import 'package:weitong/widget/dialog_util.dart';

String staff = "人员";
String jsonTree = '''
{
    "总经理": {
        "$staff": [
            {
                "name": "老总", 
                "id": "这里是手机号", 
                "password": "这里是密码", 
                "job": "这里是职务"
            }
        ], 
        "美术部门": {
            "$staff": [
                {
                    "name": "张三", 
                    "id": "这里是手机号", 
                    "password": "这里是密码", 
                    "job": "这里是职务"
                }, 
                {
                    "name": "美术李四", 
                    "id": "这里是手机号", 
                    "password": "这里是密码", 
                    "job": "这里是职务"
                }
            ], 
            "美术小组": {
               "$staff": [
                    {
                        "name": "美术王五", 
                        "id": "这里是手机号", 
                        "password": "这里是密码", 
                        "job": "这里是职务"
                    }
                ]
            }
        }, 
        "软件部门": {
           "$staff": [
                {
                    "name": "软件李四", 
                    "id": "这里是手机号", 
                    "password": "这里是密码", 
                    "job": "这里是职务"
                }
            ], 
            "软件小组": {
                "$staff": [
                    {
                        "name": "软件王五", 
                        "id": "这里是手机号", 
                        "password": "这里是密码", 
                        "job": "这里是职务"
                    }
                ]
            }
        }, 
        "人力部门": {
           "$staff": [ ]
        }, 
        "销售部门": {
            "$staff": [ ]
        }
    }
}
'''; //一直以来更改的jsonTree

class RightWidget extends StatefulWidget {
  String parentName;
  String rightName;
  bool deleteable;
  bool editable;
  bool addable;
  RightWidget(String rightName, String parentName,
      {bool deleteable = true, bool editable = true, bool addable = true}) {
    this.rightName = rightName;
    this.parentName = parentName;
    this.deleteable = deleteable;
    this.editable = editable;
    this.addable = addable;
  }

  @override
  _RightWidgetState createState() =>
      _RightWidgetState(rightName, parentName, deleteable, editable, addable);
}

class _RightWidgetState extends State<RightWidget> {
  String parentName;
  String rightName;
  bool deleteable;
  bool editable;
  bool addable;
  _RightWidgetState(String rightName, String parentName, bool deleteable,
      bool editable, bool addable) {
    this.rightName = rightName;
    this.parentName = parentName;
    this.deleteable = deleteable;
    this.editable = editable;
    this.addable = addable;
  }

  StreamSubscription<UpdataNode> sss; //eventbus传值

  Widget build(BuildContext context) {
    var addButton = addable
        ? IconButton(
            icon: Icon(Icons.add),
            onPressed: onTapAdd,
          )
        : Container(height: 0.0, width: 0.0);
    var editButton = addable
        ? IconButton(
            icon: Icon(Icons.edit),
            onPressed: onTapEdit,
          )
        : Container(height: 0.0, width: 0.0);
    var deleteButton = addable
        ? IconButton(
            icon: Icon(Icons.delete),
            onPressed: onTapDelete,
          )
        : Container(height: 0.0, width: 0.0);
    return Container(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Text("$rightName"),
          Row(
            children: [addButton, editButton, deleteButton],
          )
        ],
      ),
    );
  }

  onTapAdd() async {
    var parsedJson = json.decode(jsonTree);
    List<String> illegalText = [];
    getAllKeyName(parsedJson, illegalText);
    //这里写新增孩子的函数
    final newRight = await Navigator.push(
      context,
      new MaterialPageRoute(
          builder: (context) => new Input("新建权限", "输入您要新建的权限名称", 12, "权限名称",
              illegalText: illegalText)),
    );
    if (newRight != null) {
      parsedJson = insertNode(parsedJson, rightName, newRight);
      jsonTree = json.encode(parsedJson);
      //这里应该刷新tree的UI,目前只能用按钮实现

      EventBusUtil.getInstance().fire(UpdataNode("updataNode"));
    }
  }

  onTapEdit() async {
    var parsedJson = json.decode(jsonTree);
    List<String> illegalText = [];
    getAllKeyName(parsedJson, illegalText);
    final newRight = await Navigator.push(
      context,
      new MaterialPageRoute(
          builder: (context) => new Input("修改权限", "输入您要修改的权限名称", 12, "权限名称",
              illegalText: illegalText)),
    );
    if (newRight != null) {
      parsedJson = editNode(parsedJson, parentName, rightName, newRight);
      jsonTree = json.encode(parsedJson);
      //这里应该刷新tree的UI,目前只能用按钮实现

      EventBusUtil.getInstance().fire(UpdataNode("updataNode"));
      setState(() {});
    }
  }

  onTapDelete() {
    var parsedJson = json.decode(jsonTree);
    parsedJson = deleteNode(parsedJson, parentName, rightName);
    jsonTree = json.encode(parsedJson);

    EventBusUtil.getInstance().fire(UpdataNode("updataNode"));
  }

  void getAllKeyName(parsedJson, List<String> result) {
    if (parsedJson is Map<String, dynamic>) {
      parsedJson.forEach((key, value) {
        if (!result.contains(key)) {
          result.add(key);
        }
        getAllKeyName(parsedJson[key], result);
        return;
      });
    } else {
      return;
    }
  }

  dynamic insertNode(parsedJson, parent, child) {
    if (parsedJson is Map<String, dynamic>) {
      parsedJson.forEach((key, value) {
        if (key == parent) {
          value[child] = {
            "$staff": [],
          };
        } else {
          parsedJson[key] = insertNode(parsedJson[key], parent, child);
        }
      });
    }
    return parsedJson;
  }

  dynamic editNode(parsedJson, parentName, String oldName, String newName) {
    if (parsedJson is Map<String, dynamic>) {
      if (parentName == null) {
        //在第一级一定会有
        parsedJson[newName] = Map.from(parsedJson[oldName]);
        parsedJson.remove(oldName);
        return parsedJson;
      } else {
        parsedJson.forEach((key, value) {
          if (key == parentName) {
            //一定在这一级
            Map<String, dynamic> m = Map.from(value);
            m[newName] = m[oldName];
            m.remove(oldName);
            parsedJson[key] = m;
          } else {
            parsedJson[key] =
                editNode(parsedJson[key], parentName, oldName, newName);
          }
        });
        return parsedJson;
      }
    } else {
      return parsedJson;
    }
  }

  bool mapIsEmpty(Map<String, dynamic> m) {
    bool isEmpty = true;
    if (m["$staff"].length != 0) {
      isEmpty = false;
      return isEmpty;
    }
    if (m.keys.length > 1) {
      isEmpty = false;
      return isEmpty;
    }
    return isEmpty;
  }

  dynamic deleteNode(parsedJson, parentName, deleteName) {
    if (parsedJson is Map<String, dynamic>) {
      if (parentName == null) {
        //在第一级一定会有待删除结点
        if (mapIsEmpty(parsedJson[deleteName])) {
          //待删除结点里面为空
          parsedJson.remove(deleteName);
        } else {
          //这里需要调用另一个类的函数
          print("非空");
          //在这里eventBus====================

//==========================================
        }
      } else {
        parsedJson.forEach((key, value) {
          if (key == parentName) {
            //一定在这一级
            Map<String, dynamic> m = Map.from(value);
            if (mapIsEmpty(m[deleteName])) {
              //待删除结点里面为空
              m.remove(deleteName);
              parsedJson[key] = m;
            } else {
              //这里需要调用另一个类的函数
              print("非空");
            }
          } else {
            parsedJson[key] =
                deleteNode(parsedJson[key], parentName, deleteName);
          }
        });
      }

      return parsedJson;
    } else {
      return parsedJson;
    }
  }
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
    sss = EventBusUtil.getInstance().on<UpdataNode>().listen((data) {
      sss.cancel();
      setState(() {});
    });
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

  void refreshUI() {
    setState(() {});
  }

  void alertDialog() {
    //==需要调用的提示框===============
    DialogUtil.showAlertDiaLog(
      context,
      "无法删除非空的权限，请将其包含的人员与权限均清空。",
      title: "删除失败",
    );
  }

  /// Builds tree or error message out of the entered content.
  Widget buildTree() {
    try {
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
              content: RightWidget(
                '$k',
                fatherName,
                deleteable: "$k" != "$staff",
                editable: "$k" != "$staff",
                addable: "$k" != "$staff",
              ),
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
    return [TreeNode(content: RightWidget(parsedJson.toString(), fatherName))];
  }
}

class Task {
  String remark; //要给每个添加的controller绑定的值
  String key; //唯一键 与数据无关
  String json = "";
}
