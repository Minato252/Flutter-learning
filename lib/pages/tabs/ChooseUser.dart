import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:weitong/services/event_util.dart';
import 'package:weitong/widget/JdButton.dart';

class ChooseUserPage extends StatefulWidget {
  ChooseUserPage({Key key}) : super(key: key);

  @override
  _ChooseUserPageState createState() => _ChooseUserPageState();
}

class _ChooseUserPageState extends State<ChooseUserPage> {
  StreamSubscription<PageEvent> sss; //eventbus传值
  List<String> targIdList = [];

  // String jsonFriends =
  //     "{'123':{'name':'张三','分支':'同事'},'456':{'name':'李四','分支':'同学'},'789':{'name':'小明','分支':'同事'}}";
  List<String> friends = ['123', '456', '789', '001'];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          FlatButton(
              onPressed: () {
                EventBusUtil.getInstance().fire(PageEvent(targIdList));
                Navigator.pop(context);
              },
              child: Text("完成"))
        ],
      ),
      body: new ListView.builder(
        scrollDirection: Axis.vertical,
        itemCount: friends.length,
        // controller: _scrollController,
        itemBuilder: (BuildContext context, int index) {
          if (friends.length <= 0) {
            // return WidgetUtil.buildEmptyWidget();
            return Container(
              height: 1,
              width: 1,
            );
          }
          return Container(
            child: Row(
              children: [
                Checkbox(
                  value: targIdList.contains(friends[index]),
                  activeColor: Colors.red,
                  onChanged: (value) {
                    if (targIdList.contains(friends[index])) {
                      targIdList.remove(friends[index]);
                      // value = false;
                    } else {
                      targIdList.add(friends[index]);
                      // value = true;
                    }

                    setState(() {});
                  },
                ),
                Text(friends[index])
              ],
            ),
          );
        },
      ),
    );
  }
}
