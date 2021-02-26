import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:rich_edit/rich_edit.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:weitong/Model/messageModel.dart';
import 'package:weitong/pages/tabs/Pre.dart';
import 'package:weitong/widget/JdButton.dart';

import 'SimpleRichEditController.dart';

class PretoRichEdit extends StatefulWidget {
  List<RichEditData> data;
  String title;
  String keyWords;

  PretoRichEdit(this.data, this.title, this.keyWords);
  @override
  _PretoRichEditState createState() =>
      _PretoRichEditState(data, title, keyWords);
}

class _PretoRichEditState extends State<PretoRichEdit> {
  @override
  List<RichEditData> data;
  String title;
  String keyWords;

  String id;
  SimpleRichEditController controller;
  _PretoRichEditState(List<RichEditData> data, String title, String keyWords) {
    this.data = new List<RichEditData>();
    this.data.addAll(data);
    this.title = title;
    this.keyWords = keyWords;
    this.controller = SimpleRichEditController(context);

    List<RichEditData> l = _getList(data);

    controller.setDataFromList(l);
  }

  List<RichEditData> _getList(List<RichEditData> data) {
    List<RichEditData> copyList = [];
    for (var item in data) {
      RichEditData betContests = new RichEditData(item.type, item.data);
      copyList.add(betContests);
    }
    return copyList;
  }

  void initState() {
    super.initState();
    //setState(() {});
  }

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("编辑页面"),
      ),
      body: Container(
        padding: EdgeInsets.all(5),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Expanded(
              child: Column(
                children: [
                  Row(
                    children: [
                      // Icon(Icons.title),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    "标题",
                                    style: TextStyle(
                                      color: Theme.of(context).accentColor,
                                    ),
                                  ),
                                ),
                                Chip(label: Text(keyWords)),
                              ],
                            ),
                            Align(
                              alignment: new FractionalOffset(0.0, 0.0),
                              child: Text(
                                title,
                                style: TextStyle(fontSize: 20),
                              ),
                            )
                          ],
                        ),
                      ),
                    ],
                  ),
                  SafeArea(
                    child: SizedBox(
                      height: ScreenUtil.getInstance().setHeight(800),
                      child: RichEdit(
                          controller), //需要指定height，才不会报错，之后可以用ScreenUtil包适配屏幕
                    ),
                  ),
                ],
              ),
            ),
            JdButton(
              text: "发送",
              cb: () {
                _sendMessage(controller);
              },
            ),
          ],
        ),
      ),
    );
  }

  _sendMessage(SimpleRichEditController controller) async {
    //标题含有关键词
    //这个htmlCode就是所有消息的HTML代码了
    //或许我们可以加密了再传输？
    var htmlCode = await controller.generateHtmlUrl();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    print(htmlCode);

    // controller.generateHtml();
    //这里是用html初始化一个页面

    MessageModel messageModel = MessageModel(
        htmlCode: htmlCode,
        title: title,
        keyWord: keyWords,
        hadLook: prefs.get("id"));
    Navigator.push(context, MaterialPageRoute(builder: (c) {
      return PreAndSend(
        messageModel: messageModel,
      );
    }));
    print("发送成功");
  }
}
