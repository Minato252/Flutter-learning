import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:weitong/pages/Admin/StaffManageChoose.dart';
import 'package:weitong/pages/tree/tree.dart';
import 'package:weitong/widget/JdButton.dart';
import 'package:weitong/widget/dialog_util.dart';
import 'package:weitong/widget/toast.dart';
import 'package:dio/dio.dart';

Map name = {
  "name": "姓名",
  "id": "手机号",
  "password": "密码",
  "job": "职务",
  "right": "权限",
};

class Edituserdetails extends StatefulWidget {
  Map details;
  Edituserdetails(this.details);
  @override
  //Edituserdetails({Key key}) : super(key: key);
  _EdituserdetailsState createState() => _EdituserdetailsState(details);
}

class _EdituserdetailsState extends State<Edituserdetails> {
  final newUserFormKey = GlobalKey<FormState>();
  Map details;
  Map oldDetails;
  String id, password, name, job;
  List<String> rightList = [];
  int rightValue;

  _EdituserdetailsState(Map details) {
    this.details = details;
    this.oldDetails = details;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          actions: [],
          title: Text("修改人员信息"),
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
                    TextFormField(
                      initialValue: details["name"],
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
                      //keyboardType: TextInputType.phone,
                      // style: TextStyle(
                      //   fontSize: 17,
                      //   color: Colors.black,
                      // ),
                      initialValue: details["id"],
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
                      initialValue: details["password"],
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

                      // style: TextStyle(
                      //   fontSize: 17,
                      //   color: Colors.black,
                      // ),
                      //keyboardType: TextInputType.phone,
                      initialValue: details["job"],
                      decoration: InputDecoration(
                          icon: Icon(Icons.subject),
                          labelText: "职务",
                          hintText: "请输入职务"),
                      onSaved: (value) {
                        job = value;
                      },
                      validator: _validateNewJob,
                    ),
                    // DropdownButton(
                    //     value: rightValue,
                    //     isExpanded: true,
                    //     hint: Text("请选择权限等级"),
                    //     items: [
                    //       DropdownMenuItem(
                    //         child: Text('权限1'),
                    //         value: 1,
                    //       ),
                    //       DropdownMenuItem(
                    //         child: Text('权限2'),
                    //         value: 2,
                    //       ),
                    //       DropdownMenuItem(
                    //         child: Text('权限3'),
                    //         value: 3,
                    //       ),
                    //       DropdownMenuItem(
                    //         child: Text('权限4'),
                    //         value: 4,
                    //       ),
                    //       DropdownMenuItem(
                    //         child: Text('权限5'),
                    //         value: 5,
                    //       ),
                    //       DropdownMenuItem(
                    //         child: Text('权限6'),
                    //         value: 6,
                    //       ),
                    //     ],
                    //     onChanged: (value) => setState(() {
                    //           rightValue = value;
                    //         })),
                    Row(
                      children: [
                        Row(
                          children: [
                            Icon(Icons.subject),
                            Text("权限等级："),
                          ],
                        ),
                        //right = details["right"].toString(),
                        Text("${details["right"]}"),
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
                      text: '保存',
                      cb: () async {
                        var _state = newUserFormKey.currentState;
                        if (_state.validate()) {
                          _state.save();
                          await _alterUser(id, name, password, job, details);
                        }
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
        details["right"] =
            Tree.rightListTextToPCRightText(rightList.toString());
      });
    }
  }

  String _validateNewId(value) {
    if (value.isEmpty) {
      return "手机号不能为空";
    } else if (value != details["id"]) {
      return "手机号不可更改";
    } else {
      return null;
    }
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

  Future<bool> _alterUser(
      String id, String name, String password, String job, Map details) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    String adminId = prefs.get("adminId");
    /*var type =
        await Dio().post("http://47.110.150.159:8080/gettype?id=$adminId");
*/
    /* "uLoginid":"44444444",
       "id":"1234",
       "uPassword":"1234",
       "uToken":"",
       "uAuthority":"",
       "uName":"",
       "uPower":"888"*/
    Response response =
        await Dio().post("http://47.110.150.159:8080/updataUser", data: {
      "uLoginid": details["id"],
      "id": details["id"],
      "uPassword": password,
      "uAuthority": job,
      "uName": name,
      "uPower": details["right"],
    });
    var data = response.data;
    if (data == 1) {
      MyToast.AlertMesaage("修改成功");

      //从这里开始更新树

      Map newDetails = {
        "name": name,
        "id": details["id"],
        "password": password,
        "job": job,
        "right": details["right"],
      };
      //从服务器获得最新的树
      String jsonTree = await Tree.getTreeFromSer(adminId, true, context);

      var parsedJson = json.decode(jsonTree);

      Tree.deletePeopleIntoTree(parsedJson, oldDetails);
      Tree.insertPeopleIntoTree(parsedJson, newDetails);

      Tree.setTreeInSer(adminId, json.encode(parsedJson), context);

//===更新树结束

      Navigator.pop(context, true); //这里返回个true代表成功
    }

    // print(data);
  }
}
