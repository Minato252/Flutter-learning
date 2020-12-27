import 'package:flutter/material.dart';
import 'package:rongcloud_im_plugin/rongcloud_im_plugin.dart';

class MessageItemPage extends StatelessWidget {
  Map arguments;
  MessageItemPage({Key key, this.arguments}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    List conlist = arguments['conlist'];
    return Scaffold(
      appBar: AppBar(
        title: Text("消息"),
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
