import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:weitong/pages/tabs/friendList.dart';
import 'package:weitong/pages/tree/tree.dart';
import 'package:weitong/services/event_util.dart';
import 'package:weitong/services/providerServices.dart';

String staff = "人员";

List<String> targIdList = [];

class LogRecordPage extends StatefulWidget {
  LogRecordPage({Key key}) : super(key: key);

  @override
  _LogRecordPageState createState() => _LogRecordPageState();
}

class _LogRecordPageState extends State<LogRecordPage> {
  String _curchosedTag = "";
  String _curchosedStaff = "";

  String _actionChipStaffString = "选择创建人";
  IconData _actionChipStaffIconData = Icons.add;

  String _actionChipString = "选择关键词";
  IconData _actionChipIconData = Icons.add;
  List<Widget> _containerList;

  StreamSubscription<PageEvent> sss; //eventbus传值
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("信息查询"),
        actions: [
          // IconButton(
          //     onPressed: () {
          //       print("***************打印选择的联系人************");
          //       print(targIdList.toString());
          //     },
          //     icon: Icon(Icons.ac_unit)),
        ],
      ),
      body: Scrollbar(
        child: SingleChildScrollView(
          child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: _containerList = [
                Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Row(
                        children: [
                          Text("关键词:"),
                          SizedBox(
                            width: 15,
                          ),
                          ActionChip(
                            label: Text(
                              _actionChipString,
                              style: TextStyle(color: Colors.white),
                            ),
                            backgroundColor: Colors.blue,
                            onPressed: () {
                              //_awaitReturnNewTag(context);
                              _awaitReturnChooseTag(context);
                            },
                            avatar: Icon(
                              _actionChipIconData,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                      FlatButton(
                          onPressed: () {
                            Navigator.pushNamed(context, '/updateTags');
                          },
                          child: Text("管理关键词")),
                    ]),
                Divider(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    Text("创建人:"),
                    SizedBox(
                      width: 15,
                    ),
                    ActionChip(
                      label: Text(
                        _actionChipStaffString,
                        style: TextStyle(color: Colors.white),
                      ),
                      backgroundColor: Colors.blue,
                      onPressed: () {
                        //_awaitReturnNewTag(context);
                        _awaitReturnChooseStaff(context);
                      },
                      avatar: Icon(
                        _actionChipIconData,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ]),
        ),
      ),
    );
  }

  _awaitReturnChooseTag(BuildContext context) async {
    print("open choose Tags");
    final chosedTag = await Navigator.pushNamed(context, '/chooseTags');
    if (chosedTag != null) {
      _curchosedTag = chosedTag;
      _updateChooseTagButton();
    }
  }

  _awaitReturnChooseStaff(BuildContext context) async {
    List<Map> users = _getSubs();

    Navigator.push(
        context,
        new MaterialPageRoute(
            builder: (BuildContext context) => new ChooseFriendPage(users)));
    // if (chosedTag != null) {
    //   _curchosedTag = chosedTag;
    //   _updateChooseTagButton();
    // }
  }

  _updateChooseTagButton() {
    if (_curchosedTag != '') {
      setState(() {
        _actionChipString = _curchosedTag;
        _actionChipIconData = Icons.turned_in_not;
      });
    } else {
      print("null");
      setState(() {
        _actionChipString = "选择关键词";
        _actionChipIconData = Icons.add;
      });
    }
  }

  _updateChooseStaffButton() {
    if (_curchosedTag != '') {
      setState(() {
        _actionChipString = _curchosedTag;
        _actionChipIconData = Icons.turned_in_not;
      });
    } else {
      print("null");
      setState(() {
        _actionChipString = "选择关键词";
        _actionChipIconData = Icons.add;
      });
    }
  }

  List<Map> _getSubs() {
    //这里可能需要通过网络获取树，暂时只能本地
    final ps = Provider.of<ProviderServices>(context);
    String jsonTree = ps.tree;
    var parsedJson = json.decode(jsonTree);
    List users = [];
    Tree.getAllPeople(parsedJson, users);
    users = List<Map>.from(users);
    return users;
  }
}
