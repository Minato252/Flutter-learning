import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:weitong/pages/Admin/UserDetails.dart';
import 'package:weitong/pages/tree/tree.dart';
import 'package:weitong/services/providerServices.dart';

String staff = "人员";

//在这里管理人员详细信息,添加人员
class ChooseFriendPage extends StatefulWidget {
  List<Map> users;
  ChooseFriendPage(this.users);

  @override
  _ChooseFriendPageState createState() => _ChooseFriendPageState(users);
}

class _ChooseFriendPageState extends State<ChooseFriendPage> {
  @override
  List<Map> users;
  _ChooseFriendPageState(this.users);
  @override
  void initState() {
    super.initState();
  }

  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("人员信息"),
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
                    sliver: FriendSliverList(users, _sendDataBack),
                  ))
                ],
              ),
            )
          ],
        ));
  }

  void _sendDataBack(Map userDetails) {
    Navigator.pop(context, userDetails);
  }
}

class FriendSliverList extends StatefulWidget {
  List<Map> users;
  Function callback;

  FriendSliverList(this.users, this.callback);
  @override
  _FriendSliverListState createState() =>
      _FriendSliverListState(users, callback);
}

class _FriendSliverListState extends State<FriendSliverList> {
  @override
  List<Map> users;

  Function callback;
  _FriendSliverListState(this.users, this.callback);

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
                  Text(widget.users[index]["name"]),
                  Row(
                    children: [
                      IconButton(
                          icon: Icon(Icons.more_horiz),
                          onPressed: () async {
                            Map details = await Tree.getUserInfo(
                                widget.users[index]["id"],
                                widget.users[index]["password"]);
                            Navigator.of(context).push(MaterialPageRoute(
                                builder: (context) => UserDetails(details)));
                          }),
                      IconButton(
                          icon: Icon(Icons.check),
                          onPressed: () {
                            callback(widget.users[index]);
                          }),
                    ],
                  )
                ],
              ),
            ),
          ),
        );
      },
      childCount: widget.users.length,
    ));
  }

  void refreshUI() {
    setState(() {});
  }
}
