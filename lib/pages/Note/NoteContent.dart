//import 'dart:html';

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:weitong/pages/tabs/SimpleRichEditController.dart';
import 'package:flutter_html/flutter_html.dart';
//import 'package:weitong/pages/tabs/SimpleRichEditController.dart';
import 'package:flutter_html/style.dart';
import 'package:weitong/pages/Note/PreEdit.dart';
import 'package:weitong/pages/Note/CategoryPage.dart';
//import 'package:weitong/pages/Note/PreEdit.dart';
import 'package:html/parser.dart' show parse;
import 'package:html/dom.dart' as dom;
import 'package:url_launcher/url_launcher.dart';

Scrollbar getPre(htmlCode, ntitle, myFontSize) {
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
            onLinkTap: (String url) async {
              //open URL in webview, or launch URL in browser, or any other logic here
              if (await canLaunch(url)) {
                await launch(url);
              } else {
                throw '不能打开该链接';
              }
            },
            /*
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
              "P": Style(fontSize: FontSize(myFontSize)),
              'audio': Style(
                width: 300,
                // whiteSpace: WhiteSpace.PRE,
                //display: Display.BLOCK,
                //backgroundColor: Colors.red,
              )
              // '#12': Style(width: 400, height: 400),
            },
            // '#12': Style(width: 400, height: 400),
          ),
        ],
      ),
    ),
  );
}

class Note extends StatefulWidget {
  final htmlCode;
  String ntitle;
  String nCategory;
  Note({Key key, this.htmlCode, this.nCategory, this.ntitle}) : super(key: key);
  @override
  _NoteState createState() => _NoteState();
}

class _NoteState extends State<Note> {
  void initState() {
    super.initState();
    getContext(widget.htmlCode);
  }

//class Note extends StatelessWidget {
  SimpleRichEditController controller;
  //final htmlCode;
  // String ntitle;
  //String nCategory;
  String pctohtml = '';
  String retext;
  double myFontSize = 15.0;
  //List resultList = [];
  void getContext(String htmlCode) {
    var str = htmlCode;
    if (!str.contains('poster=')) {
      pctohtml = htmlCode;
    } else {
      var document = parse(str);
      List<dom.Element> children = document.children;
      Function fn;
      fn = (children) {
        for (int i = 0; i < children.length; i++) {
          dom.Element ele = children[i];
          String localName = ele.localName;
          if (localName == 'html' ||
              localName == 'head' ||
              localName == 'body') {
            if (ele.children.length > 0) {
              fn(ele.children);
            }
            continue;
          }

          if (ele.children.length > 0) {
            dom.Element firstChildEle = ele.children.first;
            String preTag = '<${ele.localName}>';
            String firstChildTag = '<${firstChildEle.localName}';

            String outerHtml = ele.outerHtml;
            String regStr = "<${ele.localName}\.*>(.*)$firstChildTag";
            List<RegExpMatch> matches =
                RegExp(regStr).allMatches(outerHtml).toList();
            matches.forEach((RegExpMatch match) {
              String text = match.group(1);
              if (text != null && text.length > 0) {
                // resultList.add(text);
                retext = text
                    .replaceAll("\r\n", "<\/span><\/p>")
                    .replaceAll("\n", "<p><span style=\"font-size:15px;\">");
                pctohtml = pctohtml +
                    '''<p><span style=\"font-size:15px;\">''' +
                    retext +
                    '''<\/span><\/p>''';
              }
            });

            fn(ele.children);

            dom.Element lastChildEle = ele.children.last;
            String lastChildTag = '</${lastChildEle.localName}>';
            preTag = '</${ele.localName}';

            regStr = "$lastChildTag(.*)$preTag";
            matches = RegExp(regStr).allMatches(outerHtml).toList();
            matches.forEach((RegExpMatch match) {
              String text = match.group(1);

              if (text != null && text.length > 0) {
                retext = text
                    .replaceAll("\r\n", "<\/span><\/p>")
                    .replaceAll("\n", "<p><span style=\"font-size:15px;\">");
                pctohtml = pctohtml +
                    '''<p><span style=\"font-size:15px;\">''' +
                    retext +
                    '''<\/span><\/p>''';
              }
            });
          } else {
            String text = ele.innerHtml;

            if (text != null && text.length > 0) {
              retext = text
                  .replaceAll("\r\n", "<\/span><\/p>")
                  .replaceAll("\n", "<p><span style=\"font-size:15px;\">");
              pctohtml = pctohtml +
                  '''<p><span style=\"font-size:15px;\">''' +
                  retext +
                  '''<\/span><\/p>''';
            }

            if (localName == 'img') {
              String src = ele.attributes['src'];
              String resrc = 'resrc';
              String srchtml =
                  '''<div style=\"text-align: center;\"><image style=\"width:200px\" src="resrc"/><\/div>'''
                      .replaceAll(resrc, src);
              // resultList.add(src);
              pctohtml = pctohtml + srchtml;
            } else if (localName == 'video') {
              String src = ele.attributes['src'];
              String revideo = 'revideo';
              String videohtml =
                  '''<p><video src=revideo playsinline="true" webkit-playsinline="true" x-webkit-airplay="allow" airplay="allow" x5-video-player-type="h5" x5-video-player-fullscreen="true" x5-video-orientation="portrait" controls="controls"  style="width: 100%;height: 300px;"></video><\/p>'''
                      .replaceAll(revideo, src);
              pctohtml = pctohtml + videohtml;

              //resultList.add(src);

            } else if (localName == 'audio') {
              String src = ele.attributes['src'];
              // resultList.add(src);
              String reaudio = 'reaudio';
              String audiohtml =
                  '''<p><audio controls="true" src=reaudio></audio><\/p>'''
                      .replaceAll(reaudio, src);
              pctohtml = pctohtml + audiohtml;
            }
          }

          if (i < children.length - 1) {
            dom.Element netEle = children[i + 1];
            String currentTag = '</${ele.localName}>';
            String netTag = netEle != null ? '<${netEle.localName}' : '';

            String outerHtml = ele.outerHtml;
            String regStr = "$currentTag(.*)$netTag";
            List<RegExpMatch> matches =
                RegExp(regStr).allMatches(outerHtml).toList();
            matches.forEach((RegExpMatch match) {
              String text = match.group(1);

              if (text != null && text.length > 0) {
                // resultList.add(text);
                retext = text
                    .replaceAll("\r\n", "<\/span><\/p>")
                    .replaceAll("\n", "<p><span style=\"font-size:15px;\">");
                pctohtml = pctohtml +
                    '''<p><span style=\"font-size:15px;\">''' +
                    retext +
                    '''<\/span><\/p>''';
              }
            });
          }
        }
      };
      fn(children);
    }
  }

  enlargeFontSize() {
    if (myFontSize <= 50) {
      myFontSize += 5.0;
      setState(() {});
    }
  }

  decreaseFontSize() {
    if (myFontSize > 5) {
      myFontSize -= 5.0;
      setState(() {});
    }
  }

  //Note({Key key, this.htmlCode, this.nCategory, this.ntitle}) : super(key: key);
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
        //centerTitle: true,
        //backgroundColor: Colors.yellow,
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.edit),
            onPressed: () {
              //Navigator.of(context).pushNamed('/preedit');
              //print("2222222222222222222" + htmlCode);
              //getContext(htmlCode);
              //print("111111111111111111111111" + pctohtml);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (c) {
                    return PreEdit(
                        //htmlCode: '$htmlCode',
                        htmlCode: '$pctohtml',
                        nCategory: '${widget.nCategory}',
                        ntitle: '${widget.ntitle}');
                  },
                ),
              );
            },
          ),
          /* FlatButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (c) {
                      return PreEdit(
                          //htmlCode: '$htmlCode',
                          htmlCode: '$pctohtml',
                          nCategory: '${widget.nCategory}',
                          ntitle: '${widget.ntitle}');
                    },
                  ),
                );
              },
              child: Text(
                "编辑",
                style: TextStyle(
                    fontSize: 20.0,
                    //fontWeight: FontWeight.w400,
                    color: Colors.white),
              )),*/
          IconButton(
            tooltip: "字体放大",
            iconSize: 24.0,
            padding: EdgeInsets.all(0),
            icon: Icon(
              Icons.add,
              // size: 20,
            ),
            onPressed: () {
              enlargeFontSize();
            },
          ),
          IconButton(
            tooltip: "字体缩小",
            iconSize: 24.0,

            padding: EdgeInsets.all(0),
            icon: Icon(
              Icons.minimize_outlined,
              // size: 20,
            ),
            // materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            onPressed: () {
              decreaseFontSize();
            },
          ),
          /* IconButton(
              icon: Icon(Icons.account_balance),
              onPressed: () {
                Navigator.of(context).pushNamedAndRemoveUntil(
                  '/',
                  (route) => route == null,
                );
              })*/
          IconButton(
              onPressed: () {
                Navigator.of(context).pushNamedAndRemoveUntil(
                  '/',
                  (route) => route == null,
                );
              },
              icon: Icon(Icons.account_balance)),
        ],
      ),
      body: getPre(pctohtml, widget.ntitle, myFontSize),
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
