import "package:flutter/material.dart";
import 'package:weitong/pages/Admin/Edituserdetails.dart';

import 'Edituserdetails.dart';

Map name = {
  "name": "姓名",
  "id": "手机号",
  "password": "密码",
  "job": "职务",
  "right": "权限",
};

class UserDetails extends StatelessWidget {
  Map details;
  UserDetails(Map details) {
    this.details = details;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("${details["name"]}详细信息"),
        actions: [
          FlatButton(
            child: Text(
              "修改",
              style: TextStyle(color: Colors.white),
            ),
            onPressed: () async {
              var result = await Navigator.push(
                  context,
                  new MaterialPageRoute(
                      builder: (context) => new Edituserdetails(details)));
              if (result == true) {
                Navigator.pop(context);
              }
            },
          )
        ],
      ),
      body: CustomScrollView(
        slivers: <Widget>[
          SliverSafeArea(
              sliver: SliverPadding(
            padding: EdgeInsets.all(20),
            sliver: UserDetailsSliverList(details),
          ))
        ],
      ),
    );
  }
}

class UserDetailsSliverList extends StatefulWidget {
  Map details;
  UserDetailsSliverList(details) {
    this.details = details;
  }

  @override
  _UserDetailsSliverListState createState() =>
      _UserDetailsSliverListState(details);
}

class _UserDetailsSliverListState extends State<UserDetailsSliverList> {
  Map details;

  List keys = [];
  List values = [];
  _UserDetailsSliverListState(details) {
    this.details = details;
    details.forEach((k, v) {
      keys.add(k);
      values.add(v);
      // print(k);
      // print(v);
    });
  }
  @override
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
                    Text(name[this.keys[index].toString()]),
                    Text(this.values[index].toString()),
                  ]),
            ),
          ),
        );
      },
      childCount: details.length,
    ));
  }
}
