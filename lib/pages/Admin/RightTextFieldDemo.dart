import 'package:flutter/material.dart';
import 'package:weitong/widget/JdButton.dart';

class RightTextFieldDemo extends StatefulWidget {
  @override
  _RightTextFieldDemoState createState() => _RightTextFieldDemoState();
}

class _RightTextFieldDemoState extends State<RightTextFieldDemo> {
  // TextEditingController textFieldController = TextEditingController();
  final int _maxLength = 12;
  final newTagFormKey = GlobalKey<FormState>();
  String newTag;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text('新建权限')),
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
                    "输入您要新建的权限名称",
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
                        labelText: "新建权限",
                        border: OutlineInputBorder(),
                        hintText: "最多输入 ${_maxLength.toString()} 个字"),
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
      return "权限名称不能为空";
    } else if (value.length > _maxLength) {
      return "权限名称不能超过 ${_maxLength.toString()}个字";
    }
    return null;
  }
}
