import 'package:flutter/material.dart';
//import 'package:react/react.dart';
import 'package:weitong/pages/tabs/SimpleRichEditController.dart';
import 'package:flutter_html/flutter_html.dart';
//import 'package:weitong/pages/tabs/SimpleRichEditController.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_html/style.dart';

Scrollbar getPre(htmlCode, ntitle) {
  return Scrollbar(
    child: SingleChildScrollView(
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "标题：              $ntitle",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 20),
              ),
            ],
          ),
          Divider(),
          Html(
            data: htmlCode,
            style: {
              'img': Style(width: 250, height: 250),
              'video': Style(width: 150, height: 150),
              // '#12': Style(width: 400, height: 400),
            },
          ),
        ],
      ),
    ),
  );
}

class Note extends StatelessWidget {
  SimpleRichEditController controller = SimpleRichEditController();
  final htmlCode;
  String ntitle;
  Note({Key key, this.htmlCode, this.ntitle}) : super(key: key);
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
        title: Text("内容"),
        //backgroundColor: Colors.yellow,
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.edit),
            onPressed: () {
              /*Navigator.push(context, MaterialPageRoute(builder: (c) {
                      return Pre(
                        data: controller.generateHtml(),
                      );
                    }));*/
            },
          )
        ],
      ),
      body: getPre(htmlCode, ntitle),
      /*Column(
              //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
              // crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Form(
                  child: Column(
                    //  mainAxisAlignment: MainAxisAlignment.start,
                    //  crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ListTile(
                        leading: Icon(Icons.title),
                        title: Text('$ntitle'),
                      )
                    ],
                  ),
                ),
                Divider(),
                SafeArea(
                  child: getPre(htmlCode, ntitle),
                )
                //getPre(htmlCode, ntitle),

                /*Expanded(
                    child: Html(data: htmlCode),
                    scrollDirection: Axis.vertical,
                  )*/
                // SafeArea(
                //child: getPre(htmlCode, ntitle),
                /* SizedBox(
                        height: ScreenUtil.getInstance().setHeight(1100),
                        child: SizedBox(
                          height: ScreenUtil.getInstance().setHeight(1100),
                          child: Html(data: htmlCode),
                        )*/
                /*Html(
                          data:
                              htmlCode),*/
              ],*/
    ));
  }
  //这个类在初始化时传入html代码就可以生成对应的页面了

}

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
