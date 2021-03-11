import 'dart:convert';

import 'package:azlistview/azlistview.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lpinyin/lpinyin.dart';
import 'package:provider/provider.dart';
import 'package:weitong/pages/imageEditor/common_widget.dart';
import 'package:weitong/pages/tree/tree.dart';
import 'package:weitong/services/providerServices.dart';

import 'common/models.dart';

class ChoseListPage extends StatefulWidget {
  @override
  List users;
  bool isSingle;
  String title;

  ChoseListPage(this.users, {this.isSingle = false, this.title = "选择联系人"});
  State<StatefulWidget> createState() {
    return new _ChoseListPageState(users, isSingle, title);
  }
}

class _ChoseListPageState extends State<ChoseListPage> {
  List<ContactInfo> _contacts = [];
  List users;
  _ChoseListPageState(this.users, this.isSingle, this.title);
  double susItemHeight = 40;
  List<String> targIdList = [];
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        actions: [
          IconButton(
            onPressed: () {
              List targetAllList = [];
              users.forEach((e) {
                if (targIdList.contains(e["id"])) {
                  targetAllList.add(e);
                }
              });
              Navigator.of(context).pop(targetAllList);
            },
            icon: Icon(Icons.done),
            color: Colors.white,
          ),
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
