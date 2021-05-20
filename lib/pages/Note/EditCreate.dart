import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutterfileselector/flutterfileselector.dart';
import 'package:flutterfileselector/model/drop_down_model.dart';
import 'package:flutterfileselector/model/file_util_model.dart';
import 'package:rich_edit/rich_edit.dart';
import 'package:weitong/pages/Note/File_select.dart';
import 'package:weitong/pages/tabs/SimpleRichEditController.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:dio/dio.dart';
import 'package:weitong/pages/tabs/uploadFile.dart';
import 'package:weitong/services/voiceprovider.dart';
import 'package:provider/provider.dart';
import 'package:weitong/pages/Note/File_select.dart';

class EditCreate extends StatefulWidget {
  String category;
  String id;
  EditCreate({Key key, this.category, this.id}) : super(key: key);

  @override
  _EditCreateState createState() => _EditCreateState();
}

class _EditCreateState extends State<EditCreate> {
//class EditCreate extends StatelessWidget {
  SimpleRichEditController controller;
  String newTitle;
  List<FileModelUtil> v;
  String _platformVersion = 'Unknown';
  //String category;
  //String id;
  final _formKey = GlobalKey<FormState>();
  void initState() {
    super.initState();
    initPlatformState();
  }

  Future<void> initPlatformState() async {
    String platformVersion;
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
//      platformVersion = await Flutterfileselector.platformVersion;
    } on PlatformException {
      platformVersion = 'Failed to get platform version.';
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    setState(() {
      _platformVersion = platformVersion;
    });
  }

  _EditCreateState() {
    controller = new SimpleRichEditController();
  }
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
        home: new Scaffold(
            resizeToAvoidBottomPadding: false,
            appBar: AppBar(
              leading: IconButton(
                  icon: Icon(Icons.arrow_back),
                  onPressed: () {
                    Navigator.pop(context, null);
                  }),
              title: Text("编辑页面"),
              centerTitle: true,
              //backgroundColor: Colors.deepOrangeAccent,
              //backgroundColor: Colors.yellow,
              actions: <Widget>[
                FlatButton(
                  //onPressed: () {
                  //   Navigator.of(context).pushNamed('/fileselect');
                  // },
                  // child: Text("上传文件")),
                  child: FlutterSelect(
                    /// todo:  标题
                    /// todo:  按钮
                    btn: Text(
                      "上传文件",
                      style: TextStyle(color: Colors.white),
                    ),

                    /// todo:  最大可选
                    maxCount: 1,

                    /// todo:  开启筛选
                    isScreen: true,

                    /// todo:  往数组里添加需要的格式
                    /// todo:  自定义下拉选项，不传默认

                    valueChanged: (v) async {
                      // print(v[0].filePath);
                      // this.v = v;
                      // setState(() {});
                      String title = v[0].fileName;
                      String html = await generatefileHtmlUrl(v[0].filePath);
                      postRequestFunction(html, title, '${widget.id}');
                      Navigator.pop(context);
                    },
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.check_sharp),
                  onPressed: () {
                    var _state = _formKey.currentState;
                    if (_state.validate()) {
                      _state.save();
                      _sendMessage(controller, '${widget.id}', context);
                    }
                  },
                )
              ],
            ),
            body: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
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
                        height: ScreenUtil.getInstance().setHeight(1000),
                        child: MultiProvider(
                          providers: [
                            ChangeNotifierProvider(
                              builder: (_) => VoiceRecordProvider(),
                            )
                          ],
                          child: RichEdit(
                              controller), //需要指定height，才不会报错，之后可以用ScreenUtil包适配屏幕
                        )),
                  )
                ])));
  }

  @override
  void dispose() {
    super.dispose();
    controller.controllers.forEach((key, value) {
      value.videoPlayerController.dispose();
      value.dispose();
    });
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

  //上传文件
  //Future<void>
  Future<String> generatefileHtmlUrl(String path) async {
    StringBuffer sb = StringBuffer();
    String url;
    url = await UploadFile.fileUplod(path);
    // sb.write("<p>");
    //  sb.write("<span style=\"font-size:15px;\">");
    //sb.write(element.data);
    sb.write("<p>点击");
    sb.write("<a href='");
    sb.write("$url".replaceAll(";", ""));
    sb.write("'>文件</a>");
    sb.write("进行下载</p>");
    print(sb.toString());
    // sb.write("<\/span>");
    //sb.write("<\/p>");
    return sb.toString();
  }

  void postRequestFunction(String htmlCode, String title, String id) async {
    String url = "http://47.110.150.159:8080/insertNote";

    ///发起post请求
    Response response = await Dio().post(url, data: {
      "nNotetitle": "$title",
      "nNote": "$htmlCode",
      "uId": "$id",
      "nCategory": '${widget.category}'
    });
    // print(response.data);
    // print(id);
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
