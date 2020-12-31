import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:weitong/pages/tabs/Tabs.dart';
import 'package:weitong/services/ScreenAdapter.dart';
import '../widget/JdText.dart';
import '../widget/JdButton.dart';
import 'package:dio/dio.dart';
import '../Model/UserModel.dart';
import 'dart:convert' as convert;
import 'package:weitong/Model/user_data.dart';
import 'package:fluttertoast/fluttertoast.dart';

import 'Admin/AdminTabs.dart';

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

  void _saveUserInfo(String id, String token) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString("id", id);
    prefs.setString("token", token);
    // prefs.setString("phone", _assount.text);
    // prefs.setString("password", _password.text);
  }

  void _loginAction() async {
    var rel = await Dio().post("http://47.110.150.159:8080/login",
        data: {"id": id, "password": password});
    var rel2 = convert.jsonDecode(rel.data);
    var result = new UserItemModel.fromJson(rel2);

    //===debug
    if (id == "123") {
      result = new UserItemModel.fromJson(demo[0]);
    } else {
      result = new UserItemModel.fromJson(demo[1]);
    }

    if (this.role == "user" && result.code == "200") {
      _saveUserInfo(id, result.token);
      Navigator.of(context).pushAndRemoveUntil(
          new MaterialPageRoute(builder: (context) => new Tabs()),
          (route) => route == null);
    } else if (this.role == "admin" && result.code == "200") {
      Navigator.of(context).pushAndRemoveUntil(
          new MaterialPageRoute(builder: (context) => new AdminTabs()),
          (route) => route == null);
    } else {
      AlertMesaage();
    }

    //post
  }

  AlertMesaage() {
    Fluttertoast.showToast(
        msg: "用户名或密码错误",
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM, // 消息框弹出的位置
        timeInSecForIos: 1, // 消息框持续的时间（目前的版本只有ios有效）
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0);
  }
}
