// import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:weitong/Model/messageModel.dart';
import 'package:weitong/pages/tabs/friendList.dart';
import 'package:weitong/pages/tabs/searchedResult.dart';
import 'package:weitong/pages/tree/tree.dart';
import 'package:weitong/services/event_util.dart';
import 'package:weitong/services/providerServices.dart';
import 'package:weitong/widget/JdButton.dart';
import 'package:weitong/widget/toast.dart';

import 'NullResult.dart';
import 'dart:convert';

String staff = "人员";

// import 'package:flutter_plugin_record/index.dart';

class LogRecordPage extends StatefulWidget {
  LogRecordPage({Key key}) : super(key: key);

  @override
  _LogRecordPageState createState() => _LogRecordPageState();
}

class _LogRecordPageState extends State<LogRecordPage> {
  String _searchTag;
  String _searchStaffId;
  DateTime _searchTime;

  String _curchosedTag = "";
  String _curchosedStaff = "";
  String _curchosedTime = "";

  String _actionChipStaffString = "选择创建人";
  IconData _actionChipStaffIconData = Icons.add;

  String _actionChipTime = "选择创建日";
  IconData _actionChipTimeIconData = Icons.add;

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
          //       MessageModel.strToTime("2021-01-22 00:00:00.000000");
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
                // Text("在此进行信息查询，至少选择下列一个参数。"),
                Divider(),
                Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Row(
                        children: [
                          Text("关键词:"),
                          SizedBox(
                            width: 20,
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
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: <Widget>[
                        Text("创建人:"),
                        SizedBox(
                          width: 20,
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
                            _actionChipStaffIconData,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                    IconButton(
                      icon: Icon(Icons.refresh),
                      onPressed: () {
                        _searchStaffId = "";
                        _curchosedStaff = "";
                        _updateChooseStaffButton();
                      },
                    )
                  ],
                ),
                Divider(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: <Widget>[
                        Text("创建日:"),
                        SizedBox(
                          width: 20,
                        ),
                        ActionChip(
                          label: Text(
                            _actionChipTime,
                            style: TextStyle(color: Colors.white),
                          ),
                          backgroundColor: Colors.blue,
                          onPressed: () {
                            //_awaitReturnNewTag(context);
                            // _awaitReturnChooseStaff(context);
                            _awaitReturnChooseTime(context);
                          },
                          avatar: Icon(
                            _actionChipTimeIconData,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                    IconButton(
                      icon: Icon(Icons.refresh),
                      onPressed: () {
                        _searchTime = null;
                        _curchosedTime = "";
                        _updateChooseTimeButton();
                      },
                    )
                  ],
                ),
                Divider(),
                // Text("注意：选择后一项时，请先确保选择了前一项。"),

                // Divider(),
                JdButton(
                    text: "查询",
                    cb: () async {
                      await searchMessage();
                      // print("123");
                    }),
              ]),
        ),
      ),
    );
  }

  searchMessage() async {
    bool isEmpty = true;
    String url = "http://47.110.150.159:8080/messages/selectId?";
    if (_searchTag != "" && _searchTag != null) {
      //有关键词
      isEmpty = false;
      url += "keyWords=$_searchTag&";
    }

    if (_searchTime != null) {
      //有时间

      isEmpty = false;
      url += "time=${_searchTime.toString().split(" ")[0]}&";
    }

    if (_searchStaffId != "" && _searchStaffId != null) {
      //有id
      isEmpty = false;
      url += "id=$_searchStaffId&";
    } else if (!isEmpty) {
      //没id,且别的不为空，需要查找
      List<Map> subStaff = await _getSubs();
      for (int i = 0; i < subStaff.length; i++) {
        url += "id=${subStaff[i]["id"]}&";
      }
    } else {
      //没id，别的也没，就不用查找
      MyToast.AlertMesaage("请至少选择一项");
      print("请至少选择一项");
      return;
    }

    var rel = await Dio().post(url);
    Map m = rel.data;
    if (m.isEmpty) {
      Navigator.push(context,
          new MaterialPageRoute(builder: (context) => new NullResult()));
    } else {
      List<MessageModel> l = new List<MessageModel>();
      m.forEach((key, value) {
        if (value is List) {
          for (int i = 0; i < value.length; i++) {
            MessageModel mm = MessageModel.formServerJsonString(value[i]);
            mm.modify = true;
            l.add(mm);
          }
        }
      });

      Navigator.push(
          context,
          new MaterialPageRoute(
              builder: (context) =>
                  new SearchedResult(new List<MessageModel>.from(l.reversed))));
    }

    //有关键词有id且有日期
    //按照关键词+id+日期查找
    // List<MessageModel> l = [
    //   MessageModel.formServerJsonString("""
    //         {
    //     "mId": 29,
    //     "mTitle": "ok",
    //     "mKeywords": "im",
    //     "mPostmessages": "Hello Word",
    //     "mStatus": "0",
    //     "mTime": "2021-01-22 00:00:00.000000",
    //     "mFromuserid": "188777777",
    //     "mTouserid": "173XXXXXX"
    // }

    //     """)
    // ];
  }

  _awaitReturnChooseTag(BuildContext context) async {
    print("open choose Tags");
    final chosedTag = await Navigator.pushNamed(context, '/chooseTags');
    if (chosedTag != null) {
      _curchosedTag = chosedTag;
      _searchTag = chosedTag;
      print(_searchTag);
      _updateChooseTagButton();
    }
  }

  _awaitReturnChooseStaff(BuildContext context) async {
    List<Map> users = await _getSubs();

    final Map userDetails = await Navigator.push(
        context,
        new MaterialPageRoute(
            builder: (BuildContext context) => new ChooseFriendPage(users)));
    if (userDetails != null) {
      _curchosedStaff =
          "姓名:${userDetails["name"]} 手机:${userDetails["id"]} 职务:${userDetails["job"]}";
      _searchStaffId = userDetails["id"];
      _updateChooseStaffButton();
    }
  }

  _awaitReturnChooseTime(BuildContext context) async {
    DateTime time;

    await DatePicker.showDatePicker(context,
        // 是否展示顶部操作按钮
        showTitleActions: true,
        // 最小时间
        minTime: DateTime(2021, 1, 1),
        // 最大时间
        maxTime: DateTime.now(),
        // change事件
        onChanged: (date) {
      print('change $date');
    },
        // 确定事件
        onConfirm: (date) {
      print('confirm $date');
      time = date;
    },
        // 当前时间
        currentTime: DateTime.now(),
        // 语言
        locale: LocaleType.zh);
    if (time != null) {
      _curchosedTime = "${time.year}年 ${time.month}月 ${time.day}日";
      _searchTime = time;
    }
    _updateChooseTimeButton();
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
    if (_curchosedStaff != '') {
      setState(() {
        _actionChipStaffString = _curchosedStaff;
        _actionChipStaffIconData = Icons.people;
      });
    } else {
      print("null");
      setState(() {
        _actionChipStaffString = "选择创建人";
        _actionChipStaffIconData = Icons.add;
      });
    }
  }

  _updateChooseTimeButton() {
    if (_curchosedTime != '') {
      setState(() {
        _actionChipTime = _curchosedTime;
        _actionChipTimeIconData = Icons.date_range;
      });
    } else {
      print("null");
      setState(() {
        _actionChipTime = "选择创建日";
        _actionChipTimeIconData = Icons.add;
      });
    }
  }

  Future<List<Map>> _getSubs() async {
    //通过网络获取树

    final ps = Provider.of<ProviderServices>(context);
    Map userInfo = ps.userInfo;

    String jsonTree = await Tree.getTreeFormSer(userInfo["id"], false, context);

    var parsedJson = json.decode(jsonTree);
    List users = [];
    Map subRight = Tree.getSubRight(parsedJson, userInfo["right"]);
    print("subRight" + subRight.toString());
    subRight.forEach((key, value) {
      if (key != staff) {
        Tree.getAllPeople(value, users);
      }
    });
    users.add(userInfo);
    users = List<Map>.from(users);
    return users;
  }
}
