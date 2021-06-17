import 'package:flutter/material.dart';
import 'package:rongcloud_im_plugin/rongcloud_im_plugin.dart';

class MessageItemPage extends StatefulWidget {
  final Map arguments;
  MessageItemPage({Key key, this.arguments}) : super(key: key);

  @override
  _MessageItemPageState createState() =>
      _MessageItemPageState(arguments: this.arguments);
}

class _MessageItemPageState extends State<MessageItemPage> {
  Map arguments;
  int conversationType;
  String targetId;

  bool isFirstGetHistoryMessages = true;
  _MessageItemPageState({this.arguments});

  @override
  void initState() {
    super.initState();

    conversationType = arguments["coversationType"];
    targetId = arguments["targetId"];
  }

  @override
  Widget build(BuildContext context) {
    List conlist = arguments['conlist'];

    return Scaffold(
      appBar: AppBar(
        title: Text("信息"),
        // leading: FlatButton(
        //   onPressed: () {
        //     Navigator.pop(context);
        //   },
        //   // child: Text("返回"),
        // ),
      ),
      body: ListView.builder(
        scrollDirection: Axis.vertical,
        itemCount: conlist.length,
        // controller: _scrollController,
        itemBuilder: (BuildContext context, int index) {
          if (conlist.length <= 0) {
            // return WidgetUtil.buildEmptyWidget();
            return Container(
              height: 1,
              width: 1,
            );
          }
          return Container(
            margin: EdgeInsets.all(20),
            child: InkWell(
              onTap: () {
                Navigator.pushNamed(context, '/readMessage', arguments: {
                  'conversation':
                      conlist[index].latestMessageContent.conversationDigest()
                });
              },
              child: Text(conlist[index].senderUserId +
                  "    " +
                  conlist[index].sentTime.toString()),
            ),
          );
        },
      ),
    );
  }
}
