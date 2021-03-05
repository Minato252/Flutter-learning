import 'package:flutter/material.dart';
import 'package:weitong/pages/tabs/SimpleRichEditController.dart';
import 'package:flutter_html/flutter_html.dart';
//import 'package:weitong/pages/tabs/SimpleRichEditController.dart';
import 'package:flutter_html/style.dart';
import 'package:weitong/pages/Note/PreEdit.dart';
//import 'package:weitong/pages/Note/PreEdit.dart';

Scrollbar getPre(htmlCode, ntitle) {
  return Scrollbar(
    child: SingleChildScrollView(
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                "\n$ntitle \n",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 20),
              ),
            ],
          ),
          Divider(),
          Html(
            data: htmlCode,
            /*onLinkTap: (String url) {
                print(url);
              },
              onImageTap: (String url) {
                print("image" + url);
                //open image in webview, or launch image in browser, or any other logic here
              }*/
            style: {
              'img': Style(width: 300, height: 300),
              'video': Style(width: 150, height: 150),
              // 'text': Style(fontSize: FontSize.large)
              //  "p":Style(,FontSize(20.0)),
              // "p": Style(FontSize(30.0))
              "P": Style(fontSize: FontSize(20)),
              'audio': Style(
                width: 300,
                // whiteSpace: WhiteSpace.PRE,
                //display: Display.BLOCK,
                //backgroundColor: Colors.red,
              )
              // '#12': Style(width: 400, height: 400),
            },
          ),
        ],
      ),
    ),
  );
}

class Note extends StatelessWidget {
  SimpleRichEditController controller;
  final htmlCode;
  String ntitle;
  String nCategory;
  Note({Key key, this.htmlCode, this.nCategory, this.ntitle}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    controller = new SimpleRichEditController();
    return new MaterialApp(
        home: new Scaffold(
      appBar: AppBar(
        // backgroundColor: Colors.deepOrangeAccent,
        leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.pop(context);
            }),
        title: Text("内容"),
        centerTitle: true,
        //backgroundColor: Colors.yellow,
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.edit),
            onPressed: () {
              //Navigator.of(context).pushNamed('/preedit');
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (c) {
                    return PreEdit(
                        htmlCode: '$htmlCode',
                        nCategory: '$nCategory',
                        ntitle: '$ntitle');
                  },
                ),
              );
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
