import 'dart:convert';

import 'package:azlistview/azlistview.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:lpinyin/lpinyin.dart';
import 'package:weitong/pages/Admin/UserDetails.dart';
import 'package:weitong/pages/tabs/chooseUser/common/models.dart';
import 'package:weitong/pages/tree/tree.dart';
import 'package:weitong/widget/JdButton.dart';

class ContactsSliverList extends StatefulWidget {
  List<Map> users;

  Function deleteStaff;

  ContactsSliverList(this.users, {this.deleteStaff});
  @override
  _ContactsSliverListState createState() =>
      _ContactsSliverListState(users, deleteStaff);
}

class _ContactsSliverListState extends State<ContactsSliverList> {
  @override
  List<Map> users; //现在只有id和name了
  Function deleteStaff;
  List<ContactInfo> _contacts = [];
  double susItemHeight = 40;
  List<String> targIdList = [];
  List<String> noteList = [];

  bool isSingle = false;
  String title = "测试";
  _ContactsSliverListState(this.users, this.deleteStaff);
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

  Widget build(BuildContext context) {
    return SliverList(
        delegate: SliverChildBuilderDelegate(
      (BuildContext context, int index) {
        if (index == 0) return _buildHeader(context);
        ContactInfo model = _contacts[index];
        return _buildListItem(model);
      },
      childCount: widget.users.length + 1,
    ));
  }

  void refreshUI() {
    setState(() {});
  }

  Widget _buildSusWidget(String susTag) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 15.0),
      height: 40,
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

  Widget _buildHeader(BuildContext context) {
    return Container(
        width: 200,
        child: JdButton(
          text: "确定",
          cb: () {
            String targetListString = targIdList.join(','); //用于返回id字符串
            String noteListString = noteList.join(','); //用于返回短信列表字符串
            String tn = targetListString + ";" + noteListString;
            Navigator.of(context).pop(tn);
          },
        ));
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
}
