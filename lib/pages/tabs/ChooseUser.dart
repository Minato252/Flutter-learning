import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_simple_treeview/flutter_simple_treeview.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:weitong/pages/tree/tree.dart';
import 'package:weitong/services/event_util.dart';
import 'package:weitong/services/providerServices.dart';
import 'package:weitong/widget/JdButton.dart';

String staff = "人员";
// String jsonTreeNet = '''
// {
//     "总经理": {

//         "$staff": [
//             {
//                 "name": "老总",
//                 "id": "123",
//                 "password": "这里是密码",
//                 "job": "这里是职务",
//                 "right": "总经理"
//             }
//         ],
//         "美术部门": {
//             "$staff": [
//                 {
//                     "name": "张三",
//                     "id": "456",
//                     "password": "这里是密码",
//                     "job": "这里是职务",
//                      "right": "美术部门"
//                 },
//                 {
//                     "name": "美术李四",
//                     "id": "789",
//                     "password": "这里是密码",
//                     "job": "这里是职务",
//                 "right": "美术部门"
//                 }
//             ],
//             "美术小组": {
//                "$staff": [
//                     {
//                         "name": "美术王五",
//                         "id": "4",
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
//                     "id": "5",
//                     "password": "这里是密码",
//                     "job": "这里是职务",
//                     "right": "软件部门"
//                 }
//             ],
//             "软件小组": {
//                 "$staff": [
//                     {
//                         "name": "软件王五",
//                         "id": "6",
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

List<String> targIdList = [];

class ChooseUserPage extends StatefulWidget {
  ChooseUserPage({Key key}) : super(key: key);

  @override
  _ChooseUserPageState createState() => _ChooseUserPageState();
}

class _ChooseUserPageState extends State<ChooseUserPage> {
  StreamSubscription<PageEvent> sss; //eventbus传值
  StreamSubscription<UpdataNode> sss2; //eventbus传值
  @override

  // List<String> targIdList = [];

  // String jsonFriends =
  //     "{'123':{'name':'张三','分支':'同事'},'456':{'name':'李四','分支':'同学'},'789':{'name':'小明','分支':'同事'}}";
  // List<String> friends = ['123', '456', '789', '001'];
  @override
  Widget build(BuildContext context) {
    sss2 = EventBusUtil.getInstance().on<UpdataNode>().listen((data) {
      if (data.type == "checkChange") {
        sss2.cancel();
        if (mounted) {
          setState(() {});
        }
      }
    });
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: () async {
              SharedPreferences prefs = await SharedPreferences.getInstance();
              String id = prefs.getString("id");
              await Tree.getTreeFormSer(id, false, context);

              if (mounted) {
                setState(() {});
              }
            },
          ),
          FlatButton(
              onPressed: () {
                EventBusUtil.getInstance().fire(PageEvent(targIdList));
                Navigator.pop(context);
              },
              child: Text("完成")),
        ],
      ),
      // body: new ListView.builder(
      //   scrollDirection: Axis.vertical,
      //   itemCount: friends.length,
      //   // controller: _scrollController,
      //   itemBuilder: (BuildContext context, int index) {
      //     if (friends.length <= 0) {
      //       // return WidgetUtil.buildEmptyWidget();
      //       return Container(
      //         height: 1,
      //         width: 1,
      //       );
      //     }
      //     return Container(
      //       child: Row(
      //         children: [
      //           Checkbox(
      //             value: targIdList.contains(friends[index]),
      //             activeColor: Colors.red,
      //             onChanged: (value) {
      //               if (targIdList.contains(friends[index])) {
      //                 targIdList.remove(friends[index]);
      //                 // value = false;
      //               } else {
      //                 targIdList.add(friends[index]);
      //                 // value = true;
      //               }

      //               setState(() {});
      //             },
      //           ),
      //           Text(friends[index])
      //         ],
      //       ),
      //     );
      //   },
      // ),

      body: Scrollbar(
        child: SingleChildScrollView(
          child: buildTree(),
        ),
      ),
    );
  }

  Widget buildTree() {
    try {
      final tree = Provider.of<ProviderServices>(context, listen: false);
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
              content: RightButton2(
                k,
                pressable: k == staff,
                authority: fatherName,
              ),
              children: toTreeNodes(parsedJson[k], k)))
          .toList();
    }
    if (parsedJson is List<dynamic>) {
      return parsedJson.asMap().map((i, element) =>
          // MapEntry(i, TreeNode(content: Text('[${element["name"]}]'))))
          MapEntry(i, TreeNode(content: staffNode(element)))).values.toList();
    }
    return [TreeNode(content: RightButton2(parsedJson.toString()))];
  }

  void onPressed(String rightName) {
    if (rightName != null) {
      Navigator.pop(context, rightName);
    }
  }

  staffNode(dynamic staff) {
    return Row(
      children: [
        Checkbox(
          value: targIdList.contains(staff['id']),
          // value: true,
          activeColor: Colors.red,
          onChanged: (value) {
            if (targIdList.contains(staff['id'])) {
              targIdList.remove(staff['id']);

              EventBusUtil.getInstance().fire(UpdataNode("checkChange"));
              if (mounted) {
                setState(() {});
              }
              // value = false;
            } else {
              // targIdList.add(friends);
              targIdList.add(staff['id']);

              // value = true;
              EventBusUtil.getInstance().fire(UpdataNode("checkChange"));
              if (mounted) {
                setState(() {});
              }
            }
          },
        ),
        Text(staff['name']),
      ],
    );
  }
}

class RightButton2 extends StatefulWidget {
  String rightName;
  // RightButton(this.rightName, {this.pressable, this.authority});
  String authority;
  bool pressable;
  bool isCheck;
  RightButton2(this.rightName, {Key key, this.pressable, this.authority})
      : super(key: key);

  @override
  _RightButton2State createState() =>
      _RightButton2State(rightName, pressable: pressable, authority: authority);
}

class _RightButton2State extends State<RightButton2> {
  @override
  _RightButton2State(this.rightName, {this.pressable, this.authority});
  String rightName;
  // RightButton(this.rightName, {this.pressable, this.authority});
  String authority;
  bool pressable;
  bool isCheck;
  List<String> friends = [];

  @override
  Widget build(BuildContext context) {
    return FlatButton(
      child: Row(
        children: [
          pressable
              ? Checkbox(
                  value: isContains(authority, context),
                  // value: true,
                  activeColor: Colors.red,
                  onChanged: (value) {
                    if (isContains(authority, context)) {
                      for (int i = 0; i < friends.length; i++) {
                        targIdList.remove(friends[i]);
                      }
                      EventBusUtil.getInstance()
                          .fire(UpdataNode("checkChange"));
                      if (mounted) {
                        setState(() {});
                      }
                      // value = false;
                    } else {
                      // targIdList.add(friends);
                      for (int i = 0; i < friends.length; i++) {
                        targIdList.add(friends[i]);
                      }
                      // value = true;
                      EventBusUtil.getInstance()
                          .fire(UpdataNode("checkChange"));
                      if (mounted) {
                        setState(() {});
                      }
                    }
                  },
                )
              : Text(""),
          Text(rightName),
        ],
      ),
      onPressed: () {},
    );
  }

  bool isContains(String rightName, BuildContext context) {
    friends.clear();
    final tree = Provider.of<ProviderServices>(context, listen: false);
    String jsonTree = tree.tree;
    var parsedJson = json.decode(jsonTree);
    getStaff(parsedJson, rightName, friends);
    for (int i = 0; i < friends.length; i++) {
      if (!targIdList.contains(friends[i])) {
        return false;
      }
    }
    return true;
  }

  dynamic getStaff(parsedJson, String rightName, List<String> friends) {
    if (parsedJson is Map<String, dynamic>) {
      parsedJson.forEach((key, value) {
        getStaff(parsedJson[key], rightName, friends);
      });
    } else if (parsedJson is List) {
      for (int i = 0;
          i < parsedJson.length && parsedJson[i]["right"] == rightName;
          i++) {
        if (!friends.contains(parsedJson[i]["id"])) {
          friends.add(parsedJson[i]["id"]);
        }
      }
    }
  }
}
