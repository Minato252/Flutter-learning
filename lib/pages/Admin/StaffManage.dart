import 'package:flutter/material.dart';
import 'package:flutter_simple_treeview/flutter_simple_treeview.dart';

// 在这里管理人员权限(方框,连线)
class StaffManagePage extends StatefulWidget {
  StaffManagePage({Key key}) : super(key: key);

  @override
  _StaffManagePageState createState() => _StaffManagePageState();
}

class _StaffManagePageState extends State<StaffManagePage> {
  String degreeName = "请输入权限名称";
  List<String> node = ["1", "2", "3"];

  Widget addNode() {
    Map<String, TreeNode> _remarkControllers = new Map();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("安全生产经营管理体系"),
      ),
      body: TreeView(nodes: [
        TreeNode(content: Text("权限1")),
        TreeNode(
            content: Row(
          children: [
            Text(degreeName),
            InkWell(
              child: Icon(Icons.add),
              onTap: () {},
            )
          ],
        )),
        TreeNode(
          content: Text("权限2"),
          children: [
            TreeNode(content: Text("权限3")),
            TreeNode(content: Text("权限4")),
            TreeNode(
              content: Text("权限5"),
              children: [
                TreeNode(content: Text("权限6")),
              ],
            ),
          ],
        ),
      ]),
    );
  }
}

class Task {
  String remark; //要给每个添加的controller绑定的值
  String key; //唯一键 与数据无关
  String json = "";
}
