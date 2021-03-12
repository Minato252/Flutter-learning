import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_simple_treeview/flutter_simple_treeview.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:weitong/pages/Admin/UserDetails.dart';
import 'package:weitong/pages/tree/tree.dart';
import 'package:weitong/services/event_util.dart';
import 'package:weitong/services/providerServices.dart';
import 'package:weitong/widget/Input.dart';
import 'package:weitong/widget/dialog_util.dart';

String staff = "人员";
// String jsonTreeNet = '''
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

class RightWidget extends StatefulWidget {
  String parentName;
  String rightName;
  bool deleteable;
  bool editable;
  bool addable;
  Color c;
  RightWidget(String rightName, String parentName,
      {bool deleteable = true,
      bool editable = true,
      bool addable = true,
      Color c = Colors.black}) {
    this.rightName = rightName;
    this.parentName = parentName;
    this.deleteable = deleteable;
    this.editable = editable;
    this.addable = addable;
    this.c = c;
  }

  @override
  _RightWidgetState createState() => _RightWidgetState(
      rightName, parentName, deleteable, editable, addable, c);
}

class _RightWidgetState extends State<RightWidget> {
  String parentName;
  String rightName;
  bool deleteable;
  bool editable;
  bool addable;
  Color c;
  _RightWidgetState(String rightName, String parentName, bool deleteable,
      bool editable, bool addable, Color c) {
    this.rightName = rightName;
    this.parentName = parentName;
    this.deleteable = deleteable;
    this.editable = editable;
    this.addable = addable;
    this.c = c;
  }

  StreamSubscription<UpdataNode> sss; //eventbus传值

  Widget build(BuildContext context) {
    var addButton = addable
        ? IconButton(
            icon: Icon(
              Icons.add,
              color: c,
            ),
            onPressed: onTapAdd,
          )
        : Container(height: 0.0, width: 0.0);
    var editButton = addable
        ? IconButton(
            icon: Icon(Icons.edit, color: c),
            onPressed: onTapEdit,
          )
        : Container(height: 0.0, width: 0.0);
    var deleteButton = addable
        ? IconButton(
            icon: Icon(Icons.delete, color: c),
            onPressed: onTapDelete,
          )
        : Container(height: 0.0, width: 0.0);
    return Container(
      child: Row(
        // mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Text(
                "$rightName",
                style: TextStyle(color: c),
              ),
              addButton,
              editButton,
              deleteButton
            ],
          )
        ],
      ),
    );
  }

  onTapAdd() async {
    final tree = Provider.of<ProviderServices>(context);
    String jsonTree = tree.tree;
    var parsedJson = json.decode(jsonTree);
    List<String> illegalText = [];
    Tree.getAllKeyName(parsedJson, illegalText);
    //这里写新增孩子的函数
    final newRight = await Navigator.push(
      context,
      new MaterialPageRoute(
          builder: (context) => new Input("新建权限", "输入您要新建的权限名称", 12, "权限名称",
              illegalText: illegalText)),
    );
    if (newRight != null) {
      parsedJson = Tree.insertNode(parsedJson, rightName, newRight);
      jsonTree = json.encode(parsedJson);
      //这里应该刷新tree的UI,目前只能用按钮实现
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String id = prefs.getString("adminId");
      await Tree.setTreeInSer(id, jsonTree, context);

      EventBusUtil.getInstance().fire(UpdataNode("updataNode"));
    }
  }

  onTapEdit() async {
    final tree = Provider.of<ProviderServices>(context);
    String jsonTree = tree.tree;

    var parsedJson = json.decode(jsonTree);
    List<String> illegalText = [];
    Tree.getAllKeyName(parsedJson, illegalText);
    final newRight = await Navigator.push(
      context,
      new MaterialPageRoute(
          builder: (context) => new Input("修改权限", "输入您要修改的权限名称", 12, "权限名称",
              illegalText: illegalText)),
    );
    if (newRight != null) {
      parsedJson = Tree.editNode(parsedJson, parentName, rightName, newRight);
      jsonTree = json.encode(parsedJson);
      //这里应该刷新tree的UI,目前只能用按钮实现
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String id = prefs.getString("adminId");
      await Tree.setTreeInSer(id, jsonTree, context);

      setState(() {
        rightName = newRight;
      });
      EventBusUtil.getInstance().fire(UpdataNode("updataNode"));
      // setState(() {});

    }
  }

  onTapDelete() async {
    final tree = Provider.of<ProviderServices>(context);
    String jsonTree = tree.tree;
    var parsedJson = json.decode(jsonTree);
    var result = Tree.deleteNode(parsedJson, parentName, rightName);
    if (result == null) {
      //非空删除失败
      EventBusUtil.getInstance().fire(UpdataNode("rejectDeleteNode"));
    } else {
      parsedJson = result;
      jsonTree = json.encode(parsedJson);

      SharedPreferences prefs = await SharedPreferences.getInstance();
      String id = prefs.getString("adminId");
      await Tree.setTreeInSer(id, jsonTree, context);

      EventBusUtil.getInstance().fire(UpdataNode("updataNode"));
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
    // print("***************打印provider************");
    // print(tree.tree.toString());

    sss = EventBusUtil.getInstance().on<UpdataNode>().listen((data) {
      if (data.type == "rejectDeleteNode") {
        alertDialog();
      } else if (mounted) {
        setState(() {});
      }
      sss.cancel();
      if (mounted) {
        setState(() {});
      }
    });
    return Scaffold(
      appBar: AppBar(
        title: Text("安全生产经营管理体系"),
        actions: [
          // IconButton(
          //   icon: Icon(Icons.add),
          //   onPressed: () async {
          //     final newRight = await Navigator.push(
          //       context,
          //       new MaterialPageRoute(
          //           builder: (context) => new Input(
          //                 "新建最高权限",
          //                 "输入您要新建的权限名称",
          //                 12,
          //                 "权限名称",
          //               )),
          //     );
          //     if (newRight != null) {
          //       final tree = Provider.of<ProviderServices>(context);
          //       String jsonTree = tree.tree;
          //       var parsedJson = json.decode(jsonTree);
          //       parsedJson = Tree.insertNode(parsedJson, null, newRight);
          //       jsonTree = json.encode(parsedJson);
          //       //这里应该刷新tree的UI,目前只能用按钮实现
          //       SharedPreferences prefs = await SharedPreferences.getInstance();
          //       String id = prefs.getString("adminId");
          //       await Tree.setTreeInSer(id, jsonTree, context);

          //       EventBusUtil.getInstance().fire(UpdataNode("updataNode"));
          //     }
          //   },
          // ),
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: () async {
              SharedPreferences prefs = await SharedPreferences.getInstance();
              String id = prefs.getString("adminId");
              await Tree.getTreeFormSer(id, true, context);

              EventBusUtil.getInstance().fire(UpdataNode("updataNode"));
            },
          ),
        ],
      ),
      body: Scrollbar(
        child: SingleChildScrollView(
          child: SingleChildScrollView(
              scrollDirection: Axis.horizontal, child: buildTree()),
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
      final tree = Provider.of<ProviderServices>(context);
      String jsonTree = tree.tree;
      var parsedJson = json.decode(jsonTree);

      Color cc = Theme.of(context).accentColor;
      return TreeView(
        // nodes: toTreeNodes(parsedJson, null),
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
              content: RightWidget(
                '$k',
                fatherName,
                deleteable: "$k" != "$staff",
                editable: "$k" != "$staff",
                addable: "$k" != "$staff",
                c: myColor[k == staff
                    ? (colorIndex + 1 < myColor.length ? colorIndex + 1 : 0)
                    : colorIndex],
              ),
              children: toTreeNodes(parsedJson[k], k,
                  (colorIndex - 1) > -1 ? colorIndex - 1 : myColor.length - 1)))
          .toList();
    }
    if (parsedJson is List<dynamic>) {
      // colorIndex = colorIndex + 1 < myColor.length ? colorIndex + 1 : 0;
      return parsedJson
          .asMap()
          .map((i, element) => MapEntry(
              i,
              TreeNode(
                  content: FlatButton(
                      onPressed: () {
                        Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) => UserDetails(element)));
                      },
                      child: Row(
                        children: [
                          CircleAvatar(
                            backgroundColor: myColor[
                                colorIndex + 2 < myColor.length
                                    ? colorIndex + 2
                                    : 1],
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
                                style: TextStyle(
                                    color: Colors.black, fontSize: 15),
                              ),
                              Text(
                                '${element["id"]}',
                                style:
                                    TextStyle(color: Colors.grey, fontSize: 12),
                              )
                            ],
                          ),
                        ],
                      )))))
          .values
          .toList();
    }
    return [
      TreeNode(
          content: RightWidget(
        parsedJson.toString(),
        fatherName,
        // c: myColor[colorIndex + 1 < myColor.length ? colorIndex + 1 : 0],
      ))
    ];
  }

  //  List<TreeNode> toTreeNodes(dynamic parsedJson, var fatherName) {
  //   if (parsedJson is Map<String, dynamic>) {
  //     return parsedJson.keys
  //         .map((k) => TreeNode(
  //             content: RightWidget(
  //               '$k',
  //               fatherName,
  //               deleteable: "$k" != "$staff",
  //               editable: "$k" != "$staff",
  //               addable: "$k" != "$staff",
  //             ),
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
  //   return [TreeNode(content: RightWidget(parsedJson.toString(), fatherName))];
  // }

}

class Task {
  String remark; //要给每个添加的controller绑定的值
  String key; //唯一键 与数据无关
  String json = "";
}
