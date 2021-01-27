import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:weitong/pages/tabs/Tabs.dart';
import 'package:weitong/services/ScreenAdapter.dart';
import 'package:weitong/services/providerServices.dart';
import 'package:weitong/widget/toast.dart';
import '../widget/JdText.dart';
import '../widget/JdButton.dart';
import 'package:dio/dio.dart';
import '../Model/UserModel.dart';
import 'dart:convert' as convert;
import 'package:weitong/Model/user_data.dart';
import 'package:fluttertoast/fluttertoast.dart';

import 'Admin/AdminTabs.dart';

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

class LoginPage extends StatefulWidget {
  String role;
  LoginPage({Key key, this.role = "user"}) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  String role = "users";
  String id;
  String password;
  @override
  Widget build(BuildContext context) {
    ScreenAdapter.init(context);
    return Container(
        child: Scaffold(
            appBar: AppBar(
              // leading: IconButton(
              //   icon: Icon(Icons.close),
              //   onPressed: () {
              //     Navigator.pop(context);
              //   },
              // ),
              title: Text("登录页面"),
              actions: <Widget>[
                FlatButton(
                  child: Text("客服"),
                  onPressed: () {},
                )
              ],
            ),
            body: Container(
              // padding: EdgeInsets.all(ScreenAdapter.width(20)),

              padding: EdgeInsets.all(ScreenAdapter.width(20)),
              child: ListView(
                children: [
                  Center(
                    child: Container(
                      margin: EdgeInsets.only(top: 30),
                      height: ScreenAdapter.width(160),
                      width: ScreenAdapter.width(160),
                      // child: Image.asset('images/login.png'),
                      child: Image.network(
                          'https://www.itying.com/images/flutter/list5.jpg',
                          fit: BoxFit.cover),
                    ),
                  ),
                  SizedBox(height: 30),
                  JdText(
                    text: "请输入用户名",
                    onChanged: (value) {
                      this.id = value;
                    },
                  ),
                  SizedBox(height: 10),
                  JdText(
                    text: "请输入密码",
                    password: true,
                    onChanged: (value) {
                      this.password = value;
                    },
                  ),
                  SizedBox(height: 10),
                  // Container(
                  //   padding: EdgeInsets.all(ScreenAdapter.width(20)),
                  //   child: Stack(
                  //     children: [
                  //       Align(
                  //         alignment: Alignment.centerLeft,
                  //         child: Text('忘记密码'),
                  //       ),
                  //       Align(
                  //         alignment: Alignment.centerRight,
                  //         child: InkWell(
                  //           onTap: () {
                  //             Navigator.pushNamed(context, '/registerFirst');
                  //           },
                  //           child: Text('新用户注册'),
                  //         ),
                  //       )
                  //     ],
                  //   ),
                  // ),

                  Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                    Text("用户:"),
                    Radio(
                      value: "user",
                      groupValue: this.role,
                      onChanged: (value) {
                        setState(() {
                          this.role = value;
                        });
                      },
                    ),
                    Text("管理员:"),
                    Radio(
                      value: "admin",
                      groupValue: this.role,
                      onChanged: (value) {
                        setState(() {
                          this.role = value;
                        });
                      },
                    ),
                  ]),

                  SizedBox(height: 20),
                  JdButton(
                    text: "登录",
                    color: Color.fromRGBO(111, 111, 111, 0.9),
                    cb: () {
                      _loginAction();
                      // Navigator.pushNamed(context, '/initTags');
                    },
                  )
                ],
              ),
            )));
  }

  void _saveUserInfo(Map userInfo, String token) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString("id", userInfo["id"]);
    prefs.setString("right", userInfo["right"]);

    prefs.setString("token", token);
    // prefs.setString("phone", _assount.text);
    // prefs.setString("password", _password.text);
  }

  void _saveAdminInfo(String id, String password) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString("adminId", id);
    prefs.setString("password", password);
    // prefs.setString("phone", _assount.text);
    // prefs.setString("password", _password.text);
  }

  Future<String> getTree() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String tree = prefs.get("tree");
    print("tree: " + tree);
    if (tree == null) {
      tree = "{}";
    }
    return tree;
  }

  Future<List<String>> getKeyWords() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> keyWords = prefs.get("keyWords").split(",");
    if (keyWords == null) {
      keyWords = [];
    }
    return keyWords;
  }

  void getUserInfo(parsedJson, String id) {
    if (parsedJson is Map<String, dynamic>) {
      parsedJson.forEach((key, value) {
        getUserInfo(parsedJson[key], id);
      });
    } else if (parsedJson is List) {
      for (int i = 0; i < parsedJson.length; i++) {
        if (parsedJson[i]["id"] == id) {
          Map user = parsedJson[i];
          final ps = Provider.of<ProviderServices>(context);
          ps.upDatauserInfo(user);
        }
      }
    }
    return null;
  }

  void _loginAction() async {
    var rel = await Dio().post("http://47.110.150.159:8080/login",
        data: {"id": id, "password": password});
    // var rel;

    Map rel2 = json.decode(rel.data);

    // //===debug
    // if (id == "123") {
    //   result = new UserItemModel.fromJson(demo[0]);
    // } else if (id == '456') {
    //   result = new UserItemModel.fromJson(demo[1]);
    // } else if (id == '789') {
    //   result = new UserItemModel.fromJson(demo[2]);
    // }

    if (this.role == "user" && rel2["code"] == "200") {
      //把树从内存里取出 这个之后变成网络请求
      final ps = Provider.of<ProviderServices>(context);
      String jsonTreeNet = await getTree();
      ps.upDataTree(jsonTreeNet);

      //把关键词从内存里取出
      List<String> keyWords = await getKeyWords();
      ps.upDataKeyWords(keyWords);

      //在树里读取user的information,放provider里
      var parsedJson = json.decode(jsonTreeNet);
      getUserInfo(parsedJson, id);
      Map userInfo = ps.userInfo;
      _saveUserInfo(userInfo, rel2["token"]);

      Navigator.of(context).pushAndRemoveUntil(
          new MaterialPageRoute(builder: (context) => new Tabs()),
          (route) => route == null);
    } else if (this.role == "admin" && rel2["管理员登录成功"] == "successful") {
      _saveAdminInfo(id, password);

      //把树从内存里取出 这个之后变成网络请求
      final tree = Provider.of<ProviderServices>(context);
      String jsonTreeNet = await getTree();
      tree.upDataTree(jsonTreeNet);

      Navigator.of(context).pushAndRemoveUntil(
          new MaterialPageRoute(builder: (context) => new AdminTabs()),
          (route) => route == null);
    } else {
      MyToast.AlertMesaage("用户名或密码错误");
    }

    //post
  }

  // AlertMesaage() {
  //   Fluttertoast.showToast(
  //       msg: "用户名或密码错误",
  //       toastLength: Toast.LENGTH_LONG,
  //       gravity: ToastGravity.BOTTOM, // 消息框弹出的位置
  //       timeInSecForIos: 1, // 消息框持续的时间（目前的版本只有ios有效）
  //       backgroundColor: Colors.red,
  //       textColor: Colors.white,
  //       fontSize: 16.0);
  // }
}
