//https://material.io/tools/icons/?icon=favorite&style=baseline

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rongcloud_im_plugin/rongcloud_im_plugin.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:weitong/services/providerServices.dart';
import 'package:weitong/widget/JdButton.dart';
import '../../services/ScreenAdapter.dart';
import '../Login.dart';
import 'Tabs.dart';

class UserPage extends StatefulWidget {
  UserPage({Key key}) : super(key: key);

  @override
  _UserPageState createState() => _UserPageState();
}

class _UserPageState extends State<UserPage> {
  @override
  String id;

  void initState() {
    super.initState();
    // 1.初始化 im SDK
    _getUserInfo();
  }

  @override
  Widget build(BuildContext context) {
    ScreenAdapter.init(context);
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
                        Text("普通员工",
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: ScreenAdapter.size(24))),
                      ],
                    ))
              ],
            ),
          ),
          ListTile(
            leading: Icon(Icons.history),
            title: Text("记录"),
          ),
          ListTile(
              leading: Icon(Icons.settings),
              title: Text("我的资料"),
              onTap: () {
                Navigator.of(context).pushNamed('/category');
              }),
          ListTile(
              leading: Icon(Icons.settings),
              title: Text("设置"),
              onTap: () {
                Navigator.of(context).pushNamed('/setting');
              }),
          JdButton(
            text: "退出登录",
            cb: () {
              _logout();
            },
          )
        ],
      ),
    );
  }

  void _logout() async {
    RongIMClient.disconnect(false);

    cleanToken();
    saveKeyWords();
    Navigator.of(context).pushAndRemoveUntil(
        new MaterialPageRoute(builder: (context) => new LoginPage()),
        (route) => route == null);
  }

  Future<void> cleanToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString("token", null);
  }

  String listToString(List<String> list) {
    if (list == null) {
      return null;
    }
    String result;
    list.forEach((string) =>
        {if (result == null) result = string else result = '$result,$string'});
    return result.toString();
  }

  Future<void> saveKeyWords() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final ps = Provider.of<ProviderServices>(context);
    List<String> tags = ps.keyWords;
    prefs.setString("keyWords", listToString(tags));
  }

  _getUserInfo() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    this.id = prefs.get("id");
    setState(() {
      id;
    });
  }
}
