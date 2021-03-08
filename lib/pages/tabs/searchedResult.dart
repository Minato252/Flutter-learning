import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:weitong/Model/messageModel.dart';
import 'package:weitong/pages/Admin/UserDetails.dart';
import 'package:weitong/pages/tree/tree.dart';
import 'package:weitong/services/providerServices.dart';
import 'package:weitong/widget/bloc/message_bloc.dart';

import 'Pre.dart';

class SearchedResult extends StatefulWidget {
  List<MessageModel> messageList = [];
  SearchedResult(this.messageList);

  @override
  _SearchedResultState createState() => _SearchedResultState(messageList);
}

class _SearchedResultState extends State<SearchedResult> {
  @override
  List<MessageModel> messageList = [];
  _SearchedResultState(this.messageList);
  @override
  void initState() {
    super.initState();
  }

  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("查询到了${messageList.length}条结果"),
        ),
        body: Column(
          children: [
            // Container(
            //   padding: EdgeInsets.all(20),
            //   child: Text("总人数: ${users.length} 人"),
            // ),
            Expanded(
              child: CustomScrollView(
                slivers: <Widget>[
                  SliverSafeArea(
                      sliver: SliverPadding(
                    padding: EdgeInsets.all(20),
                    sliver: MessageSliverList(messageList),
                  ))
                ],
              ),
            )
          ],
        ));
  }
}

class MessageSliverList extends StatefulWidget {
  List<MessageModel> messageList;

  MessageSliverList(this.messageList);
  @override
  _MessageSliverListState createState() => _MessageSliverListState(messageList);
}

class _MessageSliverListState extends State<MessageSliverList> {
  @override
  List<MessageModel> messageList;

  _MessageSliverListState(this.messageList);

  Widget build(BuildContext context) {
    return SliverList(
        delegate: SliverChildBuilderDelegate(
      (BuildContext context, int index) {
        return Padding(
          padding: EdgeInsets.only(bottom: 32),
          child: Material(
            borderRadius: BorderRadius.circular(12.0),
            elevation: 14.0,
            shadowColor: Colors.grey.withOpacity(0.5),
            child: Container(
              padding: EdgeInsets.all(20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("标题：${messageList[index].title}"),
                      Text("创建人：${messageList[index].fromuserid}"),
                      Text("时间：${messageList[index].time.toString()}"),
                    ],
                  ),
                  IconButton(
                      icon: Icon(Icons.more_horiz),
                      onPressed: () {
                        Navigator.push(context, MaterialPageRoute(builder: (c) {
                          return PreAndSend(
                            messageModel: messageList[index],
                            isSearchResult: true,
                          );
                        }));
                      })
                ],
              ),
            ),
          ),
        );
      },
      childCount: messageList.length,
    ));
  }

  void refreshUI() {
    setState(() {});
  }
}
