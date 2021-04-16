import "package:flutter/material.dart";
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:weitong/pages/Admin/AdminLogRecord.dart';
import 'package:weitong/services/ScreenAdapter.dart';
import 'package:weitong/services/providerServices.dart';
import 'package:weitong/widget/JdButton.dart';

import '../Login.dart';

class Mine extends StatefulWidget {
  Mine({Key key}) : super(key: key);

  @override
  _MineState createState() => _MineState();
}

class _MineState extends State<Mine> {
  @override
  String id = "";
  void initState() {
    super.initState();
    _getAdminInfo();
  }

  _getAdminInfo() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    this.id = prefs.get("adminId");
    setState(() {
      id;
    });
  }

  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("我的"),
        ),
        body: ListView(
          children: [
            Container(
              height: ScreenAdapter.height(220),
              width: double.infinity,
              decoration: BoxDecoration(
                  image: DecorationImage(
                      image: AssetImage('images/user_bg.jpg'),
                      fit: BoxFit.cover)),
              child: Row(
                children: [
                  Container(
                    margin: EdgeInsets.fromLTRB(10, 0, 10, 0),
                    child: ClipOval(
                      child: Image.asset(
                        'images/user.png',
                        fit: BoxFit.cover,
                        width: ScreenAdapter.width(100),
                        height: ScreenAdapter.width(100),
                      ),
                    ),
                  ),
                  Expanded(
                      flex: 1,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("用户名：${id}",
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: ScreenAdapter.size(32))),
                          Text("用户管理员",
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: ScreenAdapter.size(24))),
                        ],
                      ))
                ],
              ),
            ),
            ListTile(
              leading: Icon(Icons.search),
              title: Text("记录"),
            ),
            ListTile(
              leading: Icon(Icons.search),
              title: Text("查询"),
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (c) {
                  return AdminLogRecordPage();
                  // title:title,
                }));
              },
            ),
            // ListTile(
            //   leading: Icon(Icons.settings),
            //   title: Text("设置"),
            // ),
            JdButton(
              text: "退出登录",
              cb: () {
                _logout();
              },
            )
          ],
        ));
  }

  void _logout() async {
    saveTree();
    clean();
    Navigator.of(context).pushAndRemoveUntil(
        new MaterialPageRoute(builder: (context) => new LoginPage()),
        (route) => route == null);
  }

  saveTree() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final tree = Provider.of<ProviderServices>(context);
    String jsonTree = tree.tree;
    prefs.setString("tree", jsonTree);
  }

  Future<void> clean() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString("adminId", null);
    prefs.setString("password", null);
  }
}
