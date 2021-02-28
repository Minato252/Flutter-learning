import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:weitong/pages/imageEditor/common_widget.dart';
import 'package:weitong/services/providerServices.dart';
import 'package:weitong/widget/JdButton.dart';

class SettingPage extends StatefulWidget {
  SettingPage({Key key}) : super(key: key);

  @override
  _SettingPageState createState() => _SettingPageState();
}

class _SettingPageState extends State<SettingPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("设置界面"),
      ),
      body: ListView(
        children: [
          Text("设置界面"),
          JdButton(
            text: "测试",
            cb: myText(),
          ),
          FlatButtonWithIcon(
              onPressed: () {}, icon: Icon(Icons.send), label: Text("发送"))
        ],
      ),
    );
  }

  myText() {
    final tree = Provider.of<ProviderServices>(context);
    String jsonTree = tree.tree;

    var parsedJson = json.decode(jsonTree);
  }
}

/**
 * 内容遮蔽
 * 遮蔽效果：对所有人展示、只对上级展示（目前不想具体到特定上级，只要是上级即可）、只对下级展示
 * 
 */
