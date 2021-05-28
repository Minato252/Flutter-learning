import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:weitong/pages/Admin/StaffManage.dart';
import 'package:weitong/pages/Admin/StaffManageChoose.dart';
import 'package:weitong/pages/tabs/Tabs.dart';
import 'package:weitong/pages/tree/tree.dart';
import 'package:weitong/widget/JdButton.dart';
import 'package:weitong/widget/dialog_util.dart';
import 'package:weitong/widget/toast.dart';

class AddUser extends StatefulWidget {
  List<String> illegalText; //非法字符列表
  AddUser(this.illegalText);
  @override
  _AddUserState createState() => _AddUserState(illegalText);
}

class _AddUserState extends State<AddUser> {
  @override
  final newUserFormKey = GlobalKey<FormState>();
  String id, password, name, job;
  List<String> rightList = [];
  List<String> illegalText; //非法字符列表
  _AddUserState(this.illegalText);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          actions: [],
          title: Text("新增人员"),
        ),
        body: SafeArea(
            child: SingleChildScrollView(
          child: Container(
              padding: EdgeInsets.all(26),
              child: Form(
                key: newUserFormKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "输入新增人员详情",
                      style: TextStyle(fontSize: 32.0),
                    ),
                    TextFormField(
                      // controller: textFieldController,

                      // style: TextStyle(
                      //   fontSize: 17,
                      //   color: Colors.black,
                      // ),

                      decoration: InputDecoration(
                          icon: Icon(Icons.subject),
                          labelText: "姓名",
                          hintText: "请输入姓名"),
                      onSaved: (value) {
                        name = value;
                      },
                      validator: _validateNewName,
                    ),

                    TextFormField(
                      // controller: textFieldController,
                      //只允许输入数字
                      keyboardType: TextInputType.phone,
                      // style: TextStyle(
                      //   fontSize: 17,
                      //   color: Colors.black,
                      // ),
                      decoration: InputDecoration(
                          icon: Icon(Icons.subject),
                          labelText: "手机号",
                          hintText: "请输入手机号"),
                      onSaved: (value) {
                        id = value;
                      },
                      validator: _validateNewId,
                    ),

                    // TextFormField(
                    //   // controller: textFieldController,
                    //   // style: TextStyle(
                    //   //   fontSize: 17,
                    //   //   color: Colors.black,
                    //   // ),
                    //   decoration: InputDecoration(
                    //       icon: Icon(Icons.subject),
                    //       labelText: "密码",
                    //       hintText: "请输入密码"),
                    //   onSaved: (value) {
                    //     id = value;
                    //   },
                    //   validator: _validateNewId,
                    // ),
                    // SizedBox(
                    //   height: 32.0,
                    // ),
                    TextFormField(
                      // controller: textFieldController,
                      // style: TextStyle(
                      //   fontSize: 17,
                      //   color: Colors.black,
                      // ),
                      decoration: InputDecoration(
                          icon: Icon(Icons.subject),
                          labelText: "密码",
                          hintText: "请输入密码"),
                      onSaved: (value) {
                        password = value;
                      },
                      validator: _validateNewPassword,
                    ),

                    TextFormField(
                      // controller: textFieldController,
                      //只允许输入数字
                      keyboardType: TextInputType.phone,
                      // style: TextStyle(
                      //   fontSize: 17,
                      //   color: Colors.black,
                      // ),
                      decoration: InputDecoration(
                          icon: Icon(Icons.subject),
                          labelText: "职务",
                          hintText: "请输入职务"),
                      onSaved: (value) {
                        job = value;
                      },
                      validator: _validateNewJob,
                    ),

                    Row(
                      children: [
                        Row(
                          children: [
                            Icon(Icons.subject),
                            Text("权限等级："),
                          ],
                        ),
                        Text(
                            "${Tree.rightListTextToPCRightText(rightList.toString())}"),
                        IconButton(
                          icon: Icon(Icons.edit),
                          onPressed: chooseRight,
                        )
                      ],
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    ),
                    Divider(
                      height: 30.0,
                    ),
                    JdButton(
                      text: '确定',
                      cb: () async {
                        await _sendDataBack(context);
                      },
                    ),
                  ],
                ),
              )),
        )));
  }

  Future<void> chooseRight() async {
    final choosedRight = await Navigator.push(
      context,
      new MaterialPageRoute(builder: (context) => new StaffManageChoose()),
    );
    if (choosedRight != null) {
      setState(() {
        rightList = choosedRight;
      });
    }
  }

  String _validateNewId(value) {
    if (value.isEmpty) {
      return "手机号不能为空";
    } else if (illegalText.contains(value)) {
      return "此手机号已被注册";
    }

    return null;
  }

  String _validateNewName(value) {
    if (value.isEmpty) {
      return "姓名不能为空";
    }
    return null;
  }

  String _validateNewJob(value) {
    if (value.isEmpty) {
      return "职务不能为空";
    }
    return null;
  }

  String _validateNewPassword(value) {
    if (value.isEmpty) {
      return "密码不能为空";
    }
    return null;
  }

  void alertDialog() {
    //==需要调用的提示框===============
    DialogUtil.showAlertDiaLog(
      context,
      "权限不能为空",
      title: "新增人员失败",
    );
  }

  Future<bool> registerUser(
      String id, String name, String password, String job, String right) async {
//  {
//      "id": "0988", 注册账号
//      "uPower":权限
//      "name": "xxx", 放入融云服务器的用户姓名
//      "password":"okkk",密码
//      "type":"1" 这里必须和creator一样（程序在查询其他成员的时候需要这个值，不然会失效）
//      "creator":"1"  区分成员属于哪个管理员创建
//      "authority":"部长"  权限
//     "who":"member"  此处区分注册人员；如果是注册管理员此处填写：adm
//                                       如果是注册用户成员此处填写：member
//  }

//获取自己的id
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String adminId = prefs.get("adminId");
    /*var type =
        await Dio().post("http://47.110.150.159:8080/gettype?id=$adminId");*/
    var rel1 = await Dio()
        .post("http://47.110.150.159:8080/getMInformation?id=$adminId");
    Map n = rel1.data;
    Map m = {
      "id": id,
      "uPower": right,
      "name": name,
      "password": password,
      "type": n['mType'],
      "creator": adminId,
      "authority": job,
      "who": "member",
      "company": n['mLocation'],
    };
    Response rel =
        await Dio().post("http://47.110.150.159:8080/register", data: m);

// 1 {fail:超出可创建最大人数}：表示超出购买的账号数，导致创建失败
// 2 {"Msg":"账号已存在","code":"202","id":"id"} 202：表示此ID已经被注册
// 3 注册成功，返回message：
// {"authority":"1",
// "id":"177",
// "password":"okkk",
// "token":"+N6PSEp6cPDMad7e68GxGrTxq47Jn+UhuuSKJ1cFdRA=@9s7f.cn.rongnav.com;9s7f.cn.rongcfg.com"}

    if (rel.data == "注册成功") {
      MyToast.AlertMesaage("注册成功");
      return true;
    } else {
      Map j = json.decode(rel.data);

      if (j.containsKey("fail")) {
        print("超出购买限额");

        // MyToast.AlertMesaage("超出可创建最大人数");
      } else if (j.containsKey("code")) {
        if (j["code"] == "202") {
          print("id已注册");
          MyToast.AlertMesaage(j["Msg"]);
        }
      } else if (j.containsKey("uToken")) {
        print("注册成功");

        MyToast.AlertMesaage("注册成功");
        return true;
      }
      return false;
    }
  }

  Future<void> _sendDataBack(BuildContext context) async {
    newUserFormKey.currentState.save();
    if (rightList.isEmpty) {
      alertDialog();
      return;
    }
    if (newUserFormKey.currentState.validate()) {
      bool regSuc = await registerUser(id, name, password, job,
          Tree.rightListTextToPCRightText(rightList.toString()));
      if (regSuc) {
        //这里返回的right改成了list
        Map mapToSendBack = {
          "name": name,
          "id": id,
          "password": password,
          "job": job,
          "right": rightList,
        };
        Navigator.pop(context, mapToSendBack);
        Navigator.pushNamed(context, '/admin');
      }
    }
  }
}
