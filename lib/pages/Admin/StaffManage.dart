import 'package:flutter/material.dart';
import 'package:flutter_simple_treeview/flutter_simple_treeview.dart';
import 'package:weitong/pages/Admin/RightTextFieldDemo.dart';

class TreeNodePlus extends TreeNode {
  List<TreeNode> children;
  Widget content;
  TreeNodePlus(RightWidget rw) {
    content = rw;
    children = rw.children;
  }
}

class RightWidget extends StatefulWidget {
  String rightName;
  List<TreeNodePlus> children;
  RightWidget(String rightName, List<TreeNodePlus> children) {
    this.rightName = rightName;
    this.children = children;
  }

  @override
  _RightWidgetState createState() => _RightWidgetState(rightName, children);
}

class _RightWidgetState extends State<RightWidget> {
  _RightWidgetState(String rightName, List<TreeNodePlus> children) {
    this.rightName = rightName;
    this.children = children;
  }
  String rightName;
  List<TreeNodePlus> children;
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
      List<TreeNodePlus> children = [];
      RightWidget rw = RightWidget(newRight, children);
      TreeNodePlus tn = new TreeNodePlus(rw);
      setState(() {
        this.children.add(tn);
      });
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
  List<TreeNodePlus> children = [];

  TreeNodePlus tn;
  // Widget addNode() {
  //   Map<String, TreeNode> _remarkControllers = new Map();
  // }

  @override
  Widget build(BuildContext context) {
    RightWidget rw = RightWidget("头", children);
    this.tn = TreeNodePlus(rw);
    return Scaffold(
      appBar: AppBar(
        title: Text("安全生产经营管理体系"),
      ),
      body: TreeView(nodes: [
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
        tn,
      ]),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          RightWidget rw = tn.content;
          rw.rightName = '123';
          setState(() {});
          print(rw.rightName);
        },
      ),
    );
  }
}

class Task {
  String remark; //要给每个添加的controller绑定的值
  String key; //唯一键 与数据无关
  String json = "";
}
