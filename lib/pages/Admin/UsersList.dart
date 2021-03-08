import 'package:flutter/material.dart';
import 'package:weitong/pages/Admin/UserDetails.dart';

class UserSliverList extends StatefulWidget {
  List<Map> users;

  Function deleteStaff;

  UserSliverList(this.users, {this.deleteStaff});
  @override
  _UserSliverListState createState() =>
      _UserSliverListState(users, deleteStaff);
}

class _UserSliverListState extends State<UserSliverList> {
  @override
  List<Map> users;
  Function deleteStaff;
  _UserSliverListState(this.users, this.deleteStaff);

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
                            onPressed: () {
                              Navigator.of(context).push(MaterialPageRoute(
                                  builder: (context) =>
                                      UserDetails(widget.users[index])));
                            }),
                        IconButton(
                            icon: Icon(Icons.delete),
                            onPressed: () {
                              _alertDialog(widget.users, index);
                            }),
                      ],
                    )
                  ],
                )),
          ),
        );
      },
      childCount: widget.users.length,
    ));
  }

  void refreshUI() {
    setState(() {});
  }

  Future _alertDialog(users, index) async {
    var result = await showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text("提示信息"),
            content: Text("您确定要删除此人员吗,该操作会删除有关此人员的所有数据"),
            actions: <Widget>[
              RaisedButton(
                child: Text("取消"),
                color: Colors.blue,
                textColor: Colors.white,
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
              RaisedButton(
                child: Text("确定"),
                color: Colors.blue,
                textColor: Colors.white,
                onPressed: () async {
                  bool suc = await deleteStaff(users[index]);
                  if (suc) {
                    Navigator.pop(context);
                    setState(() {
                      users.removeAt(index);
                    });
                  }
                },
              ),
            ],
          );
        });
    return result;
  }
}
