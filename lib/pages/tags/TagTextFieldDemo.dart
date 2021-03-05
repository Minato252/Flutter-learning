import 'package:flutter/material.dart';
import 'package:weitong/widget/JdButton.dart';
import 'package:weitong/services/ScreenAdapter.dart';

class TextFieldDemo extends StatefulWidget {
  @override
  _TextFieldDemoState createState() => _TextFieldDemoState();
}

class _TextFieldDemoState extends State<TextFieldDemo> {
  // TextEditingController textFieldController = TextEditingController();
  final int _maxLength = 12;
  final newTagFormKey = GlobalKey<FormState>();
  String newTag;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text('新建关键词')),
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
                  /* Container(
                    width: ScreenAdapter.getScreenWidth(),
                    child: Text(
                      "输入您要新建的关键词",
                      style: TextStyle(fontSize: 1.0),
                      textAlign: TextAlign.center,
                    ),
                  ),*/
                  Text(
                    "输入您要新建的关键词",
                    style: TextStyle(fontSize: 22.0),
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
                        labelText: "新建关键词",
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
      return "关键词不能为空";
    } else if (value.length > _maxLength) {
      return "关键词不能超过 ${_maxLength.toString()}个字";
    }
    return null;
  }
}
