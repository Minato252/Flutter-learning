// import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:rongcloud_im_plugin/rongcloud_im_plugin.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:weitong/Model/MessageModelToConversation.dart';
import 'package:weitong/Model/messageModel.dart';
import 'package:weitong/pages/SearchMessage/SearchMessage.dart';

import 'package:weitong/pages/tabs/chooseUser/ChoseList.dart';
import 'package:weitong/pages/tabs/friendList.dart';
import 'package:weitong/pages/tabs/searchedResult.dart';
import 'package:weitong/pages/tree/tree.dart';
import 'package:weitong/services/event_util.dart';
import 'package:weitong/services/providerServices.dart';
import 'package:weitong/widget/JdButton.dart';
import 'package:weitong/widget/toast.dart';

import 'NullResult.dart';
import 'dart:convert';

import 'chooseUser/contacts_list_page.dart';

String staff = "人员";

// import 'package:flutter_plugin_record/index.dart';

class LogRecordPage extends StatefulWidget {
  LogRecordPage({Key key}) : super(key: key);

  @override
  _LogRecordPageState createState() => _LogRecordPageState();
}

class _LogRecordPageState extends State<LogRecordPage>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;
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
                      IconButton(
                        icon: Icon(Icons.refresh),
                        onPressed: () {
                          _searchTag = "";
                          _curchosedTag = "";
                          _updateChooseTagButton();
                        },
                      )
                      // FlatButton(
                      //     onPressed: () {
                      //       Map args = {
                      //         "identify": "user",
                      //       }; //用于标识是用户维护关键词
                      //       Navigator.pushNamed(context, '/updateTags',
                      //           arguments: args);
                      //     },
                      //     child: Text("管理关键词")),
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
    String url = "http://47.110.150.159:8080/messages/fuzzyselect?";
    if (_searchTag != "" && _searchTag != null) {
      //有关键词
      isEmpty = false;
      url += "mTitle=$_searchTag&";
      // url += "keyWords=1群&";
    }

    if (_searchTime != null) {
      //有时间

      isEmpty = false;
      url += "time=${_searchTime.toString().split(" ")[0]}&";
      print("time=${_searchTime.toString().split(" ")[0]}");
    }

    if (_searchStaffId != "" && _searchStaffId != null) {
      //有id
      isEmpty = false;
      url += "fromuserid=$_searchStaffId&";
    } else if (!isEmpty) {
      // // 没id,且别的不为空，需要查找
      // List<Map> subStaff = await _getSubs();
      // for (int i = 0; i < subStaff.length; i++) {
      //   url += "fromuserid=${subStaff[i]["id"]}&";
      // }
    } else {
      //没id，别的也没，就不用查找
      MyToast.AlertMesaage("请至少选择一项");
      print("请至少选择一项");
      return;
    }
    print(url);
    var rel = await Dio().post(url);
    // Map m = rel.data;
    // if (m.isEmpty) {
    //   Navigator.push(context,
    //       new MaterialPageRoute(builder: (context) => new NullResult()));
    // } else {
    //   List<MessageModel> l = new List<MessageModel>();
    //   m.forEach((key, value) {
    //     if (value is List) {
    //       for (int i = 0; i < value.length; i++) {
    //         MessageModel mm = MessageModel.formServerJsonString(value[i]);
    //         mm.modify = true;
    //         l.add(mm);
    //       }
    //     }
    //   });

    List m = rel.data;
    print("1**********" + m.length.toString());

    await _getSubMessage(url, m); //把下级的群消息也加到m中
    print("2**********" + m.length.toString());
    await _getShelterMessage(m); //获取遮蔽表的消息
    print("3*******" + m.length.toString());

    if (m.isEmpty) {
      Navigator.push(context,
          new MaterialPageRoute(builder: (context) => new NullResult()));
    } else {
      List<MessageModel> l = new List<MessageModel>();
      for (int i = 0; i < m.length; i++) {
        MessageModel mm = MessageModel.formServerJsonString(m[i]);
        mm.modify = true;
        l.add(mm);
      }

      for (int i = 0; i < l.length; i++) {
        int min = i;
        for (int j = i + 1; j < l.length; j++) {
          if (l[j].time.millisecondsSinceEpoch <
              l[min].time.millisecondsSinceEpoch) {
            min = j;
          }
        }
        if (min != i) {
          MessageModel t = l[i];
          l[i] = l[min];
          l[min] = t;
        }
      }

      // Navigator.push(
      //     context,
      //     new MaterialPageRoute(
      //         builder: (context) =>
      //             new SearchedResult(new List<MessageModel>.from(l.reversed))));
      List<MessageModel> r = new List<MessageModel>.from(l.reversed);
      _showMessageByTitle(r); //按标题去展示消息
    }
  }

  _getShelterMessage(List m) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String id = prefs.getString("id");
    List groupId = new List();
    for (int i = 0; i < m.length; i++) {
      if (!groupId.contains(m[i]["mMesId"])) {
        groupId.add(m[i]["mMesId"]);
      }
    }
    for (int j = 0; j < groupId.length; j++) {
      var rel = await Dio().post("http://47.110.150.159:8080/shelter/select",
          data: {"touserid": id, "mMesId": groupId[j]});
      List shelterMessage = rel.data;
      for (int i = 0; i < shelterMessage.length; i++) {
        m.add(shelterMessage[i]);
      }
    }
    return m;
  }

  _getSubMessage(String url, List m) async {
    List subUser = await _getSubs(); //获得下级
    List<String> subIdList = new List(); //所有下级所在的群id
    for (int i = 0; i < subUser.length; i++) {
      //该循环获取下级群id
      String subUserId = subUser[0]["id"];
      var rel = await Dio().post("http://47.110.150.159:8080/group/select",
          data: {"groupcreatorid": subUserId}); //获取下级的群id
      List subIdLIstItem = rel.data;
      for (int j = 0; j < subIdLIstItem.length; j++) {
        if (!subIdList.contains(subIdLIstItem[j]["groupid"])) {
          subIdList.add(subIdLIstItem[j]["groupid"]);
        }
      }
    }
    for (int i = 0; i < subIdList.length; i++) {
      //根据下级群id拉去所有群消息
      var result = await Dio().post(url + "touserid=" + subIdList[i]);
      List rm = result.data;
      for (int j = 0; j < rm.length; j++) {
        if (!m.contains(rm[j])) {
          m.add(rm[j]);
        }
      }
    }
    return m;
  }

  _showMessageByTitle(List<MessageModel> messageList) async {
    List<String> idList = new List(); //获取查询到的自己所有群id
    for (int i = 0; i < messageList.length; i++) {
      String mid = messageList[i].messageId;
      if (!idList.contains(mid)) {
        idList.add(mid);
      }
    }

    // List<List<MessageModel>> conList = new List(titleList.length);
    List conList = new List();
    List conversation = new List(); //conversation类型二维数组
    for (int i = 0; i < idList.length; i++) {
      List<MessageModel> list = new List();
      conList.add(list);
      List<Conversation> con = new List();
      conversation.add(con);
    }
    // List

    for (int i = 0; i < messageList.length; i++) {
      for (int j = 0; j < idList.length; j++) {
        if (idList[j] == messageList[i].messageId) {
          conList[j].add(messageList[i]);
          Conversation item =
              MessageModelToConversation.transation(messageList[i]);
          conversation[j].add(item);
        }
      }
    }

    print(conversation);
    Navigator.push(context, MaterialPageRoute(builder: (c) {
      return SearchMessagePage(conList: conversation
          // title:title,
          );
    }));
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

    List result = await Navigator.push(
        context,
        new MaterialPageRoute(
            builder: (BuildContext context) => new ChoseListPage(
                  users,
                  isSingle: true,
                  title: "选择创建人",
                )));
    if (result != null && !result.isEmpty) {
      final Map userDetails = result[0];
      _curchosedStaff = "姓名:${userDetails["name"]} 手机:${userDetails["id"]} ";
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
    Map userInfoAll =
        await Tree.getUserInfo(userInfo["id"], userInfo["password"]);

    List rightList = userInfoAll["right"].split(",");

    // List superList = new List();
    List users = [];
    rightList.forEach((element) {
      // Tree.getSuperRight(parsedJson, element, superList);
      Map subRight = Tree.getSubRight(parsedJson, element);
      print("subRight" + subRight.toString());
      subRight.forEach((key, value) {
        if (key != staff) {
          Tree.getAllPeople(value, users);
        }
      });
      users.add(userInfo);
    });

    users = List<Map>.from(users);

    List<Map> result = List<Map>.from(Tree.setPeoplelistUnique(users));
    return result;
  }
}
