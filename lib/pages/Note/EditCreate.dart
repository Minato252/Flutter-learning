import 'package:flutter/material.dart';
//import 'dart:convert';
import 'package:rich_edit/rich_edit.dart';
import 'package:weitong/pages/tabs/SimpleRichEditController.dart';
//import 'package:webview_flutter/webview_flutter.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_html/flutter_html.dart';
//import 'package:weitong/pages/tabs/SimpleRichEditController.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

class EditCreate extends StatelessWidget {
  SimpleRichEditController controller = SimpleRichEditController();
  String newTitle;
  String category;
  String id;
  final _formKey = GlobalKey<FormState>();
  EditCreate({Key key, this.category, this.id}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
        home: new Scaffold(
            appBar: AppBar(
              leading: IconButton(
                  icon: Icon(Icons.arrow_back),
                  onPressed: () {
                    Navigator.pop(context);
                  }),
              title: Text("编辑页面"),
              //backgroundColor: Colors.yellow,
              actions: <Widget>[
                IconButton(
                  icon: Icon(Icons.save),
                  onPressed: () {
                    var _state = _formKey.currentState;
                    if (_state.validate()) {
                      _state.save();
                      _sendMessage(controller, id, context);
                    }
                  },
                )
              ],
            ),
            body: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Form(
                    key: _formKey,
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
                              hintText: "请输入标题"),
                          onSaved: (value) {
                            newTitle = value;
                          },
                          validator: (String value) {
                            return value.length > 0 ? null : '标题不能为空';
                          },
                        ),
                      ],
                    ),
                  ),
                  Divider(),
                  SafeArea(
                    child: SizedBox(
                      height: ScreenUtil.getInstance().setHeight(1100),
                      child: RichEdit(
                          controller), //需要指定height，才不会报错，之后可以用ScreenUtil包适配屏幕
                    ),
                  ),
                ])));
  }

  _sendMessage(SimpleRichEditController controller, String id,
      BuildContext context) async {
    var htmlCode = await controller.generateHtmlUrl();
    print(htmlCode);
    postRequestFunction(htmlCode, newTitle, id);
    // controller.generateHtml();
    //这里是用html初始化一个页面

    /*Navigator.push(context, MaterialPageRoute(builder: (c) {
      return Pre(
        htmlCode: htmlCode,
      );
    }));*/
    print("发送成功");
    Navigator.pop(context, "$htmlCode");

    // }
  }

  void postRequestFunction(String htmlCode, String title, String id) async {
    String url = "http://47.110.150.159:8080/insertNote";

    ///发起post请求
    Response response = await Dio().post(url, data: {
      "nNotetitle": "$title",
      "nNote": "$htmlCode",
      "uId": "$id",
      "nCategory": "$category"
    });
    print(response.data);
    print(id);
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
      appBar: AppBar(),
      body: Html(data: htmlCode),
    );
  }
}
