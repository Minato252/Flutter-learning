import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';

//这个类在初始化时传入html代码就可以生成对应的页面了
class Pre extends StatelessWidget {
  final htmlCode;

  Pre({Key key, this.htmlCode}) : super(key: key);
  @override
  @override
  Widget build(BuildContext context) {
    print("html:" + htmlCode);
    return Scrollbar(
      child: SingleChildScrollView(
        child: Html(data: htmlCode),
      ),
    );
  }
}
