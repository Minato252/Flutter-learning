import 'package:flutter/material.dart';
import 'package:weitong/widget/JdButton.dart';

class Input extends StatefulWidget {
  int maxLength; //最大长度
  String title; //"新建权限"
  String subtitle; //"输入您要新建的权限名称"
  String name; //"权限名称"（不能为空）
  List<String> illegalText; //非法字符列表
  Input(String title, String subtitle, int maxLength, String name,
      {List<String> illegalText = const []}) {
    this.title = title;
    this.subtitle = subtitle;
    this.maxLength = maxLength;
    this.name = name;
    this.illegalText = illegalText;
  }
  @override
  _InputState createState() => _InputState(
      this.title, this.subtitle, this.maxLength, this.name, this.illegalText);
}

class _InputState extends State<Input> {
  // TextEditingController textFieldController = TextEditingController();

  final newTagFormKey = GlobalKey<FormState>();
  int maxLength; //最大长度
  String title; //"新建权限"
  String subtitle; //"输入您要新建的权限名称"
  String name; //"权限名称"（不能为空）
  List<String> illegalText; //非法字符列表
  _InputState(String title, String subtitle, int maxLength, String name,
      List<String> illegalText) {
    this.title = title;
    this.subtitle = subtitle;
    this.maxLength = maxLength;
    this.name = name;
    this.illegalText = illegalText;
  }

  String newTag;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text('$title')),
        body: Container(
            padding: EdgeInsets.all(20),
            child: Form(
              key: newTagFormKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    height: 32.0,
                  ),
                  Text(
                    "$subtitle",
                    style: TextStyle(fontSize: 32.0),
                  ),
                  SizedBox(
                    height: 32.0,
                  ),
                  TextFormField(
                    // controller: textFieldController,
                    style: TextStyle(
                      fontSize: 17,
                      color: Colors.black,
                    ),
                    decoration: InputDecoration(
                        icon: Icon(Icons.subject),
                        labelText: "$title",
                        border: OutlineInputBorder(),
                        hintText: "最多输入 ${maxLength.toString()} 个字"),
                    onSaved: (value) {
                      newTag = value;
                    },
                    validator: _validateNewTag,
                  ),
                  SizedBox(
                    height: 32.0,
                  ),
                  JdButton(
                    text: '确定',
                    cb: () {
                      _sendDataBack(context);
                    },
                  ),
                ],
              ),
            )));
  }

  void _sendDataBack(BuildContext context) {
    newTagFormKey.currentState.save();
    if (newTagFormKey.currentState.validate()) {
      String textToSendBack = newTag;
      Navigator.pop(context, textToSendBack);
    }
  }

  String _validateNewTag(value) {
    if (value.isEmpty) {
      return "$name不能为空";
    } else if (value.length > maxLength) {
      return "$name不能超过 ${maxLength.toString()}个字";
    } else if (illegalText.contains(value)) {
      return "“$value”已存在，不能使用，请更换";
    }
    return null;
  }
}
