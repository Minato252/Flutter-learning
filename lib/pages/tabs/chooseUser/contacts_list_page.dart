import 'dart:convert';

import 'package:azlistview/azlistview.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lpinyin/lpinyin.dart';
import 'package:provider/provider.dart';
import 'package:weitong/pages/group/GroupMessageService.dart';
import 'package:weitong/pages/imageEditor/common_widget.dart';
import 'package:weitong/pages/tabs/chooseUser/search_contacts_list.dart';
import 'package:weitong/pages/tree/tree.dart';
import 'package:weitong/services/ScreenAdapter.dart';
import 'package:weitong/services/providerServices.dart';

import 'common/models.dart';

class ContactListPage extends StatefulWidget {
  @override
  List users;
  String groupid;
  String grouptitle;
  bool isSingle;
  String title;
  Function deleteStaff;

  ContactListPage(this.users,
      {this.groupid,
      this.grouptitle,
      this.isSingle = false,
      this.title = "",
      this.deleteStaff});
  State<StatefulWidget> createState() {
    return new _ContactListPageState(
        users, groupid, grouptitle, isSingle, title, deleteStaff);
  }
}

class _ContactListPageState extends State<ContactListPage> {
  List<ContactInfo> _contacts = [];
  List users;
  Function deleteStaff;
  String groupid;
  String grouptitle;
  _ContactListPageState(this.users, this.groupid, this.grouptitle,
      this.isSingle, this.title, this.deleteStaff);
  double susItemHeight = 40;
  List<String> targIdList = [];
  List<String> noteList = [];

  bool isSingle;
  String title;
  @override
  void initState() {
    super.initState();
    loadData();
  }

  void loadData() async {
    users.forEach((v) {
      _contacts.add(ContactInfo.fromJson(v));
    });
    _handleList(_contacts);
  }

  void _handleList(List<ContactInfo> list) {
    if (list == null || list.isEmpty) return;
    for (int i = 0, length = list.length; i < length; i++) {
      String pinyin = PinyinHelper.getPinyinE(list[i].name);
      String tag = pinyin.substring(0, 1).toUpperCase();
      list[i].namePinyin = pinyin;
      if (RegExp("[A-Z]").hasMatch(tag)) {
        list[i].tagIndex = tag;
      } else {
        list[i].tagIndex = "#";
      }
    }
    // A-Z sort.
    SuspensionUtil.sortListBySuspensionTag(_contacts);

    // show sus tag.
    SuspensionUtil.setShowSuspensionStatus(_contacts);

    // add header.
    _contacts.insert(0, ContactInfo(name: 'header', tagIndex: '↑'));

    setState(() {});
  }

  Widget _buildHeader() {
    // return Container(
    //   padding: EdgeInsets.all(20),
    //   alignment: Alignment.center,
    //   child: Column(
    //     mainAxisAlignment: MainAxisAlignment.center,
    //     children: <Widget>[
    //       ClipOval(
    //           child: Image.asset(
    //         "./assets/images/avatar.png",
    //         width: 80.0,
    //       )),
    //       Padding(
    //         padding: const EdgeInsets.all(8.0),
    //         child: Text(
    //           "远行",
    //           textScaleFactor: 1.2,
    //         ),
    //       ),
    //       Text("+86 182-286-44678"),
    //     ],
    //   ),
    // );
    return Container();
  }

  Widget _buildSusWidget(String susTag) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 15.0),
      height: susItemHeight,
      width: double.infinity,
      alignment: Alignment.centerLeft,
      child: Row(
        children: <Widget>[
          Text(
            '$susTag',
            textScaleFactor: 1.2,
          ),
          Expanded(
              child: Divider(
            height: .0,
            indent: 10.0,
          ))
        ],
      ),
    );
  }

  Widget _buildListItem(ContactInfo model) {
    String susTag = model.getSuspensionTag();
    return Column(
      children: <Widget>[
        Offstage(
          offstage: model.isShowSuspension != true,
          child: _buildSusWidget(susTag),
        ),
        Stack(
          children: [
            ListTile(
              leading: CircleAvatar(
                backgroundColor: Theme.of(context).accentColor,
                child: Text(
                  model.name[0],
                  style: TextStyle(color: Colors.white),
                ),
              ),
              title: Text(model.name),
              subtitle: Text(model.id),
              // onTap: () {
              //   print("OnItemClick: $model");
              //   Navigator.pop(context, model);
              // },
            ),
            Positioned(
              right: 60,
              child: Checkbox(
                onChanged: (bool value) {
                  if (!isSingle) {
                    if (targIdList.contains(model.id)) {
                      targIdList.remove(model.id);
                      if (mounted) {
                        setState(() {});
                      }
                      // value = false;
                    } else {
                      // targIdList.add(friends);
                      targIdList.add(model.id);

                      // value = true;
                      if (mounted) {
                        setState(() {});
                      }
                    }
                  } else {
                    //如果是单选模式
                    if (targIdList.contains(model.id)) {
                      targIdList.remove(model.id);
                      if (mounted) {
                        setState(() {});
                      }
                      // value = false;
                    } else {
                      // targIdList.add(friends);
                      targIdList.clear();
                      targIdList.add(model.id);

                      // value = true;
                      if (mounted) {
                        setState(() {});
                      }
                    }
                  }
                  print(targIdList);
                },
                value: targIdList.contains(model.id),
              ),
            ),
            Positioned(
              right: 30,
              child: Checkbox(
                onChanged: (bool value) {
                  if (!isSingle) {
                    if (noteList.contains(model.id)) {
                      noteList.remove(model.id);
                      if (mounted) {
                        setState(() {});
                      }
                      // value = false;
                    } else {
                      // noteList.add(friends);
                      noteList.add(model.id);

                      // value = true;
                      if (mounted) {
                        setState(() {});
                      }
                    }
                  } else {
                    //如果是单选模式
                    if (noteList.contains(model.id)) {
                      noteList.remove(model.id);
                      if (mounted) {
                        setState(() {});
                      }
                      // value = false;
                    } else {
                      // noteList.add(friends);
                      noteList.clear();
                      noteList.add(model.id);

                      // value = true;
                      if (mounted) {
                        setState(() {});
                      }
                    }
                  }
                  print(noteList);
                },
                value: noteList.contains(model.id),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Decoration getIndexBarDecoration(Color color) {
    return BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(20.0),
        border: Border.all(color: Colors.grey[300], width: .5));
  }

  void _addAllorRemoveAll() {
    if (targIdList.isEmpty) {
      users.forEach((e) {
        if (!targIdList.contains(e["id"])) {
          targIdList.add(e["id"]);
        }
      });
    } else {
      targIdList.clear();
      noteList.clear();
    }
    setState(() {});
  }

  void _addGroupUser() async {
    final ps = Provider.of<ProviderServices>(context);
    Map userInfo = ps.userInfo;
    String jsonTree = await Tree.getTreeFromSer(userInfo["id"], false, context);
    var parsedJson = json.decode(jsonTree);
    List users1 = []; //树的总人数

    Tree.getAllPeople(parsedJson, users1);
    List<String> groupMember = [];
    List users2 = []; //不在群成员的人
    for (int i = 0; i < users.length; i++) {
      groupMember.add(users[i]["id"]);
    }
    for (int i = 0; i < users1.length; i++) {
      if (!groupMember.contains(users1[i]["id"])) {
        users2.add(users1[i]);
      }
    }
    // List addtargetList = await Navigator.of(context).push(MaterialPageRoute(
    var result = await Navigator.of(context).push(MaterialPageRoute(
        builder: (BuildContext context) => ContactListPage(
              users2,
            )));
    if (result == null) {
      return;
    }
    List addtargetList = result;
    List<String> targetIdList = [];
    if (addtargetList[0] != null && !addtargetList[0].isEmpty) {
      addtargetList[0].forEach((element) {
        targetIdList.add(element["id"]);
      });
    }

    String user;

    user = listToString(targetIdList);
    await GroupMessageService.joinGroup(groupid, grouptitle, user);
    Navigator.pop(context);
  }

  String listToString(List<String> list) {
    if (list == null) {
      return null;
    }
    String result;
    list.forEach((string) =>
        {if (result == null) result = string else result = '$result,$string'});
    return result.toString();
  }

  @override
  Widget build(BuildContext context) {
    ScreenAdapter.init(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        actions: [
          IconButton(
              icon: Icon(Icons.search),
              iconSize: ScreenAdapter.size(35),
              onPressed: () async {
                List<Map> users2 = List<Map>.from(users);
                String rel = await showSearch(
                    context: context, delegate: SearchContactList(users2));

                print(rel);
                String targetListString = rel.split(";")[0];
                String noteListString = rel.split(";")[1];
                List<String> targetListFromString =
                    targetListString.split(',').toList();
                List<String> noteListFromString =
                    noteListString.split(',').toList();
                for (int i = 0; i < targetListFromString.length; i++) {
                  if (!targIdList.contains(targetListFromString[i])) {
                    targIdList.add(targetListFromString[i]);
                  }
                }
                for (int i = 0; i < noteListFromString.length; i++) {
                  if (!noteList.contains(noteListFromString[i])) {
                    noteList.add(noteListFromString[i]);
                  }
                }
                print(targIdList);
                print(noteList);
                setState(() {});
              }),
          FlatButton(
              onPressed: () {
                _addAllorRemoveAll();
              },
              child: Text(
                "全选/反选",
                style: TextStyle(
                    //fontSize: 20.0,
                    fontSize: ScreenAdapter.size(30),
                    //fontWeight: FontWeight.w400,
                    color: Colors.white),
              )),
          // FlatButton(
          //     onPressed: () {
          //       //_addAllorRemoveAll();
          //  _addGroupUser();
          //     },
          //     child: Text(
          //       "新增",
          //       style: TextStyle(
          //           fontSize: ScreenAdapter.size(30),
          //           //fontSize: 20.0,
          //           //fontWeight: FontWeight.w400,
          //           color: Colors.white),
          //     )),
          IconButton(
            onPressed: () {
              List targetAllList = [];
              users.forEach((e) {
                if (targIdList.contains(e["id"])) {
                  targetAllList.add(e);
                }
              });

              List noteAllList = [];
              users.forEach((e) {
                if (noteList.contains(e["id"])) {
                  noteAllList.add(e);
                }
              });
              print("*******************" + noteAllList.toString());
              // List targetIdAndNotList = [][2];
              // targetIdAndNotList[0].addAll(targetAllList);
              // targetIdAndNotList[1].addAll(noteAllList);
              // Navigator.of(context).pop(targetAllList);
              Navigator.of(context).pop([targetAllList, noteAllList]);
            },
            icon: Icon(Icons.done),
            color: Colors.white,
          ),
          IconButton(
              onPressed: () {
                Navigator.of(context).pushNamedAndRemoveUntil(
                  '/',
                  (route) => route == null,
                );
              },
              icon: Icon(Icons.account_balance)),
        ],
      ),
      body: AzListView(
        data: _contacts,
        itemCount: _contacts.length,
        itemBuilder: (BuildContext context, int index) {
          if (index == 0) return _buildHeader();
          ContactInfo model = _contacts[index];
          return _buildListItem(model);
        },
        physics: BouncingScrollPhysics(),
        indexBarData: SuspensionUtil.getTagIndexList(_contacts),
        indexHintBuilder: (context, hint) {
          return Container(
            alignment: Alignment.center,
            width: 60.0,
            height: 60.0,
            decoration: BoxDecoration(
              color: Colors.blue[700].withAlpha(200),
              shape: BoxShape.circle,
            ),
            child: Text(hint,
                style: TextStyle(color: Colors.white, fontSize: 30.0)),
          );
        },
        indexBarMargin: EdgeInsets.all(10),
        indexBarOptions: IndexBarOptions(
          needRebuild: true,
          decoration: getIndexBarDecoration(Colors.grey[50]),
          downDecoration: getIndexBarDecoration(Colors.grey[200]),
        ),
      ),
    );
  }
}
