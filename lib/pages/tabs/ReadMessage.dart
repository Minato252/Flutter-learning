import 'package:flutter/rendering.dart';

import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:rongcloud_im_plugin/rongcloud_im_plugin.dart';
import 'package:weitong/widget/JdButton.dart';

class ReadMessage extends StatelessWidget {
  // final htmlCode;
  Conversation arguments;

  ReadMessage(
      {Key key,
      // this.htmlCode,
      this.arguments})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    print("**********显示消息详情**************");
    print(arguments);
    // return Scaffold(;
    //     appBar: AppBar(
    //       title: Text("预览页面"),
    //     ),
    //     body: Scrollbar(
    //       child: SingleChildScrollView(
    //         child: Column(
    //           children: [
    //             Html(data: htmlCode),
    //             // Text("测试"),
    //             JdButton(text: "确定发送", cb: () {}),
    //           ],
    //         ),
    //       ),
    //     ));
    return Text("显示消息");
  }
}
