import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:rich_edit/rich_edit.dart';
import 'package:weitong/services/IM.dart';
import 'package:weitong/widget/JdButton.dart';
import 'package:flutter_html/flutter_html.dart';
import 'SimpleRichEditController.dart';
import 'package:rongcloud_im_plugin/rongcloud_im_plugin.dart';

class MessageCreate extends StatefulWidget {
  MessageCreate({Key key}) : super(key: key);

  @override
  _MessageCreateState createState() => _MessageCreateState();
}

class _MessageCreateState extends State<MessageCreate> {
  final newTitleFormKey = GlobalKey<FormState>();
  String newTitle;
  String _curchosedTag = "";

  String _actionChipString = "选择关键词";
  IconData _actionChipIconData = Icons.add;
  List<Widget> _containerList;

  @override
  Widget build(BuildContext context) {
    ScreenUtil.instance = ScreenUtil(width: 750, height: 1334)..init(context);

    //富文本的controller
    SimpleRichEditController controller = SimpleRichEditController();

    return SafeArea(
        child: Container(
      padding: EdgeInsets.all(20),
      child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: _containerList = [
                  Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Row(
                          children: [
                            Text("关键词:"),
                            SizedBox(
                              width: 15,
                            ),
                            ActionChip(
                              label: Text(
                                _actionChipString,
                                style: TextStyle(color: Colors.white),
                              ),
                              backgroundColor: Colors.blue,
                              onPressed: () {
                                //_awaitReturnNewTag(context);
                                _awaitReturnChooseTag(context);
                              },
                              avatar: Icon(
                                _actionChipIconData,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                        FlatButton(
                            onPressed: () {
                              Navigator.pushNamed(context, '/updateTags');
                            },
                            child: Text("管理关键词")),
                      ]),
                  Divider(),
                  Form(
                    key: newTitleFormKey,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TextFormField(
                          // controller: textFieldController,
                          style: TextStyle(
                            color: Colors.black,
                          ),
                          decoration: InputDecoration(
                              icon: Icon(Icons.title),
                              labelText: "标题",
                              // border: OutlineInputBorder(),
                              hintText: "标题需包含关键词"),
                          onSaved: (value) {
                            newTitle = value;
                          },
                          validator: _validateNewTitle,
                        ),
                      ],
                    ),
                  ),
                  Divider(),
                  SafeArea(
                    child: SizedBox(
                      height: ScreenUtil.getInstance().setHeight(600),
                      child: RichEdit(
                          controller), //需要指定height，才不会报错，之后可以用ScreenUtil包适配屏幕
                    ),
                  ),
                  // Container(
                  //   child: TextField(
                  //     minLines: 18,
                  //     keyboardType: TextInputType.multiline,
                  //     maxLines: null,
                  //     decoration: InputDecoration(
                  //         border: OutlineInputBorder(), hintText: "输入内容"),
                  //   ),
                  // ),
                  // Divider(),
                  // Row(
                  //   mainAxisAlignment: MainAxisAlignment.spaceAround,
                  //   children: [
                  //     FlatButton(
                  //         onPressed: () {}, child: Icon(Icons.note_add)),
                  //     FlatButton(onPressed: () {}, child: Icon(Icons.mic)),
                  //     FlatButton(
                  //         onPressed: () {}, child: Icon(Icons.video_call)),
                  //   ],
                  // ),
                ]),
            JdButton(
              text: "发送",
              cb: () {
                _sendMessage(controller);
              },
            ),
          ]),
    ));
  }

  String _validateNewTitle(value) {
    if (value.isEmpty) {
      return "新标题不能为空";
    } else if (_curchosedTag == "") {
      return "请先选择关键词";
    } else if (!value.contains(_curchosedTag)) {
      return "新标题未包含关键词";
    }
    return null;
  }

  _awaitReturnChooseTag(BuildContext context) async {
    print("open choose Tags");
    final chosedTag = await Navigator.pushNamed(context, '/chooseTags');
    if (chosedTag != null) {
      _curchosedTag = chosedTag;
      _updateChooseTagButton();
    }
  }

  _updateChooseTagButton() {
    if (_curchosedTag != '') {
      setState(() {
        _actionChipString = _curchosedTag;
        _actionChipIconData = Icons.turned_in_not;
      });
    } else {
      print("null");
      setState(() {
        _actionChipString = "选择关键词";
        _actionChipIconData = Icons.add;
      });
    }
  }

  _sendMessage(SimpleRichEditController controller) async {
    newTitleFormKey.currentState.save(); //测试标题是否含有关键词
    if (newTitleFormKey.currentState.validate()) {
//标题含有关键词
      //这个htmlCode就是所有消息的HTML代码了
      //或许我们可以加密了再传输？
      var htmlCode = await controller.generateHtmlUrl();
      print(htmlCode);
      // controller.generateHtml();
      //这里是用html初始化一个页面
      Navigator.push(context, MaterialPageRoute(builder: (c) {
        return Pre(
          htmlCode: htmlCode,
        );
      }));
      print("发送成功");
    }
  }
}

//这个类在初始化时传入html代码就可以生成对应的页面了
class Pre extends StatelessWidget {
  final htmlCode;

  Pre({Key key, this.htmlCode}) : super(key: key);
  @override
  @override
  Widget build(BuildContext context) {
    print("html:" + htmlCode);
    return Scaffold(
        appBar: AppBar(
          title: Text("预览页面"),
        ),
        body: Scrollbar(
          child: SingleChildScrollView(
            child: Column(
              children: [
                Html(data: htmlCode),
                // Text("测试"),
                JdButton(
                    text: "确定发送",
                    cb: () {
                      IM.sendMessage(htmlCode, "456");
                    }),
              ],
            ),
          ),
        ));
  }
}
