import 'package:flutter/material.dart';
import 'package:weitong/widget/JdButton.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class NewCategory extends StatefulWidget {
  NewCategory({Key key}) : super(key: key);

  @override
  _NewCategory createState() => _NewCategory();
}

class _NewCategory extends State<NewCategory> {
  @override
  final int _maxLength = 10;
  final _formKey = GlobalKey<FormState>();
  String text = '';
  String id;

  void initState() {
    super.initState();
    // 1.初始化 im SDK
    _getUserInfo();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: (AppBar(
          title: Text('新建类别'),
          centerTitle: true,
          backgroundColor: Colors.deepOrangeAccent,
        )),
        body: Container(
            padding: EdgeInsets.all(20),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(
                    height: 32.0,
                  ),
                  Text(
                    "请输入类别名称",
                    style: TextStyle(fontSize: 22.0),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(
                    height: 32.0,
                  ),
                  TextFormField(
                    style: TextStyle(
                      fontSize: 17,
                      color: Colors.black,
                    ),
                    decoration: InputDecoration(
                        icon: Icon(Icons.subject),
                        labelText: "新建类别",
                        border: OutlineInputBorder(),
                        hintText: "最多输入 ${_maxLength.toString()} 个字"),
                    onSaved: (value) {
                      text = value;
                    },
                    validator: (String value) {
                      return value.length > 0 ? null : '标题不能为空';
                    },
                  ),
                  SizedBox(
                    height: 32.0,
                  ),
                  RaisedButton(
                      child: Text('新建'),
                      onPressed: () {
                        var _state = _formKey.currentState;
                        if (_state.validate()) {
                          _state.save();
                          postRequestFunction(text);
                        }
                      }),
                ],
              ),
            )));
  }

  _getUserInfo() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    this.id = prefs.get("id");
    setState(() {
      id;
    });
  }

  void postRequestFunction(String text) async {
    String url = "http://47.110.150.159:8080/insertCategory";

    ///创建Dio
    //Dio dio = new Dio();

    ///创建Map 封装参数
    /* Map<String, dynamic> map = Map();
    map['userid']:"123",
    map['category']:textToSendBack;
*/
    ///发起post请求
    Response response =
        await Dio().post(url, data: {"userid": "$id", "category": "$text"});
    var data = response.data;
    print(data);
    Navigator.pop(context, "$text");
  }
}
