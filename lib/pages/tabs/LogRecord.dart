import 'package:flutter/material.dart';

class LogRecordPage extends StatefulWidget {
  double _width = 200.0;
  LogRecordPage({Key key}) : super(key: key);

  @override
  _LogRecordPageState createState() => _LogRecordPageState();
}

class _LogRecordPageState extends State<LogRecordPage> {
  double _width; //通过修改图片宽度来达到缩放效果
  @override
  Widget build(BuildContext context) {
    return Container(
      child: GestureDetector(
        //指定宽度，高度自适应
        child: Image.network(
            "https://pic24.photophoto.cn/20120928/0035035561837079_b.jpg",
            fit: BoxFit.contain,
            width: _width),
        onScaleUpdate: (details) {
          setState(() {
            //缩放倍数在0.8到10倍之间
            _width = 200 * details.scale.clamp(.4, 10.0);
          });
        },
      ),
    );
  }
}
