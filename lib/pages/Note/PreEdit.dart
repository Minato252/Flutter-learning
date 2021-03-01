import 'package:html/dom.dart';
import 'package:flutter/material.dart';
import 'package:weitong/pages/tabs/SimpleRichEditController.dart';
import 'package:rich_edit/rich_edit.dart';
import 'package:html/parser.dart' show parse;
import 'package:html/dom.dart' as dom;
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dio/dio.dart';
import 'package:weitong/services/voiceprovider.dart';
import 'package:provider/provider.dart';

class PreEdit extends StatefulWidget {
  final htmlCode;
  String ntitle;
  String nCategory;

  PreEdit({Key key, this.htmlCode, this.nCategory, this.ntitle})
      : super(key: key);
  @override
  _PreEditState createState() => _PreEditState();
}

class _PreEditState extends State<PreEdit> {
  @override
  SimpleRichEditController controller;
  String id;
  void initState() {
    super.initState();
    _getUserInfo();
    getContext('${widget.htmlCode}');
    print(resultList);
    controller.setData(resultList.toString());
    //setState(() {});
  }

  _PreEditState() {
    controller = SimpleRichEditController();
  }
  _getUserInfo() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    this.id = prefs.get("id");
    setState(() {
      id;
    });
  }

  List resultList = [];
  void getContext(String htmlCode) {
    var str = htmlCode;
    var document = parse(str);
    List<dom.Element> children = document.children;
    Function fn;
    fn = (children) {
      for (int i = 0; i < children.length; i++) {
        dom.Element ele = children[i];
        String localName = ele.localName;
        if (localName == 'html' || localName == 'head' || localName == 'body') {
          if (ele.children.length > 0) {
            fn(ele.children);
          }
          continue;
        }

        /*print(
            '===============================标签名: <$localName>=================================\n');
        print(ele);
        print('toString: ' + ele.toString());
        print('innerHTML: ' + ele.innerHtml);
        print('outerHTML: ' + ele.outerHtml);
        print('localName: ' + ele.localName);
        print('text: ' + ele.text);
        print('attributes: ' + ele.attributes.toString());*/

        if (ele.children.length > 0) {
          dom.Element firstChildEle = ele.children.first;
          String preTag = '<${ele.localName}>';
          String firstChildTag = '<${firstChildEle.localName}';
          // print('preTag: $preTag, fistChildTag: $firstChildTag');

          String outerHtml = ele.outerHtml;
          String regStr = "<${ele.localName}\.*>(.*)$firstChildTag";
          List<RegExpMatch> matches =
              RegExp(regStr).allMatches(outerHtml).toList();
          matches.forEach((RegExpMatch match) {
            String text = match.group(1);
            // print('~~~提取出文本: $text');
            if (text != null && text.length > 0) {
              resultList.add(text);
            }
          });

          // print(
          //     '==============================================================================\n\n');
          fn(ele.children);

          dom.Element lastChildEle = ele.children.last;
          String lastChildTag = '</${lastChildEle.localName}>';
          preTag = '</${ele.localName}';
          // print('lastChildTag: $lastChildTag, preTag: $preTag');

          regStr = "$lastChildTag(.*)$preTag";
          matches = RegExp(regStr).allMatches(outerHtml).toList();
          matches.forEach((RegExpMatch match) {
            String text = match.group(1);
            //print('~~~提取出文本: $text');
            if (text != null && text.length > 0) {
              resultList.add(text);
            }
          });
        } else {
          String text = ele.innerHtml;
          //print('~~~提取出文本: $text');
          if (text != null && text.length > 0) {
            resultList.add(text);
          }

          if (localName == 'img') {
            String src = ele.attributes['src'];
            //print('--> 提取出图片: $src');
            resultList.add(src);
            //  resultList.add(" ");
          } else if (localName == 'video') {
            String src = ele.attributes['src'];
            // print('--> 提取出视频: $src');
            resultList.add(src);
            // resultList.add(" ");
          } else if (localName == 'audio') {
            String src = ele.attributes['src'];
            resultList.add(src);
            // resultList.add(" ");
          }

          //  print(
          //     '==============================================================================\n\n');
        }

        if (i < children.length - 1) {
          dom.Element netEle = children[i + 1];
          String currentTag = '</${ele.localName}>';
          String netTag = netEle != null ? '<${netEle.localName}' : '';
          //  print('currentTag: $currentTag, netTag: $netTag');

          String outerHtml = ele.outerHtml;
          String regStr = "$currentTag(.*)$netTag";
          List<RegExpMatch> matches =
              RegExp(regStr).allMatches(outerHtml).toList();
          matches.forEach((RegExpMatch match) {
            String text = match.group(1);
            //  print('~~~提取出文本: $text');
            if (text != null && text.length > 0) {
              resultList.add(text);
            }
          });
        }
      }
    };
    fn(children);

    // print('提取结果：${resultList}');
  }

  final _formKey = GlobalKey<FormState>();
  String newTitle;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        resizeToAvoidBottomPadding: false,
        appBar: AppBar(
          // title:Text("目录界面"),
          // centerTitle: true,
          //backgroundColor: Colors.deepOrangeAccent,
          actions: <Widget>[
            IconButton(
              icon: Icon(Icons.check_sharp),
              onPressed: () {
                var _state = _formKey.currentState;
                if (_state.validate()) {
                  _state.save();
                  //print("22222222222222" + '${widget.nCategory}');
                  _sendMessage(controller, id, '${widget.nCategory}', context);
                }
                /*Navigator.push(context, MaterialPageRoute(builder: (c) {
                return Pre(
                  data: controller.generateHtml(),
                );
              }));*/
              },
            )
          ],
        ),
        body: //RichEdit(controller),
            Column(
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
                      initialValue: '${widget.ntitle}',
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
                  height: ScreenUtil.getInstance().setHeight(1000),
                  child: MultiProvider(
                    providers: [
                      ChangeNotifierProvider(
                        builder: (_) => VoiceRecordProvider(),
                      )
                    ],
                    child: RichEdit(controller),
                  ),
                  /*SizedBox(
                  height: ScreenUtil.getInstance().setHeight(1100),
                  child: MultiProvider(
                          providers: [
                            ChangeNotifierProvider(
                              builder: (_) => VoiceRecordProvider(),
                            )
                          ],RichEdit(
                      controller), */ //需要指定height，才不会报错，之后可以用ScreenUtil包适配屏幕
                ),
              ),
            ]));
  }

  _sendMessage(SimpleRichEditController controller, String id, String nCategory,
      BuildContext context) async {
    var htmlCode = await controller.generateHtmlUrl();
    //print(htmlCode);
    //修改内容时先把之前的内容删除然后在上传
    postDeleteTitle(id, '${widget.ntitle}');
    //controller.generateHtml();
    Future.delayed(Duration(seconds: 1), () {
      postRequestFunction(htmlCode, newTitle, id, nCategory);
      Navigator.of(context).pushNamed('/category');
    });

    // controller.generateHtml();
    //这里是用html初始化一个页面

    /*Navigator.push(context, MaterialPageRoute(builder: (c) {
      return Pre(
        htmlCode: htmlCode,
      );
    }));*/
    //print("发送成功");
    //Navigator.of(context).pushNamed('/category');

    // }
  }

  void postDeleteTitle(String id, String value) async {
    print(id);
    print(value);
    String url =
        "http://47.110.150.159:8080/note/delete?uId=${id}&noteTitle=${value}";

    ///创建Dio
    Dio dio = new Dio();

    ///创建Map 封装参数
    /*FormData formData = FormData.fromMap({
      "userid": "$id",
      "noteTitle": "$value",
    });*/

    ///发起post请求
    Response response = await dio.post(url);
    //var data = response.data;
    print(response.data);
    //Navigator.pop(context);
  }

  void postRequestFunction(
      String htmlCode, String title, String id, String nCategory) async {
    String url = "http://47.110.150.159:8080/insertNote";

    ///发起post请求
    Response response = await Dio().post(url, data: {
      "nNotetitle": "$title",
      "nNote": "$htmlCode",
      "uId": "$id",
      "nCategory": "$nCategory"
    });
    print(response.data);
  }
}
