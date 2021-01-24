import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:html/dom.dart' as dom;
import 'package:html/parser.dart' as parser;

class LogRecordPage extends StatefulWidget {
  double _width = 200.0;
  LogRecordPage({Key key}) : super(key: key);

  @override
  _LogRecordPageState createState() => _LogRecordPageState();
}

class _LogRecordPageState extends State<LogRecordPage> {
  double _width; //通过修改图片宽度来达到缩放效果
  dom.NodeList _parseHtml(String html) => parser.HtmlParser(
        html,
        generateSpans: false,
        parseMeta: false,
      ).parseFragment().nodes;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("123"),
        actions: [
          IconButton(
            icon: Icon(Icons.ac_unit),
            onPressed: () {
              String htmlCode = """
              <p><span style="font-size:30px;">123</span></p ><p><image style="padding: 10px;max-width: 90%;" src="http://47.110.150.159:8080/picture/20210119/c311effd92fb4db38c6267340e4d5a08.jpg;"/></p ><p><span style="font-size:30px;"></span></p ><p>          <video src="http://47.120.150.159:8080/videos/20210119/5f5088f93e534395a7d87c5f49e9287a.mp4;" playsinline="true" webkit-playsinline="true" x-webkit-airplay="allow" airplay="allow" x5-video-player-type="h5" x5-video-player-fullscreen="true" x5-video-orientation="portrait" controls="controls"  style="width: 100%;height: 300px;"></video>
     </p ><p><span style="font-size:30px;"></span></p >
              """;
              dom.NodeList l = _parseHtml(htmlCode);
              print("domNodeList: " + l.toString());
            },
          )
        ],
      ),
      body: Container(
        // child: GestureDetector(
        //   //指定宽度，高度自适应
        //   child: Image.network(
        //       "https://pic24.photophoto.cn/20120928/0035035561837079_b.jpg",
        //       fit: BoxFit.contain,
        //       width: _width),
        //   onScaleUpdate: (details) {
        //     setState(() {
        //       //缩放倍数在0.8到10倍之间
        //       _width = 200 * details.scale.clamp(.4, 10.0);
        //     });
        //   },
        // ),

        child: HtmlWidget(
            '<span style="font-size:30px;"></span></p><p><image  style="width:80.0px;" src="http://47.110.150.159:8080/picture/20210120/297595b5edb94cb684ce11a6a17a22ca.jpg;"/></p><p><span style="font-size:30px;"></span></p>'),
      ),
    );
  }
}
