import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:weitong/pages/Admin/AddUser.dart';
import 'package:weitong/pages/tree/tree.dart';
import 'package:weitong/routers/router.dart';
import 'package:weitong/services/event_util.dart';
import 'package:weitong/services/providerServices.dart';
import 'UsersList.dart';

import 'searchDemo.dart';

String staff = "人员";

//在这里管理人员详细信息,添加人员
class DepartmentManagePage extends StatefulWidget {
  DepartmentManagePage({Key key}) : super(key: key);

  @override
  _DepartmentManagePageState createState() => _DepartmentManagePageState();
}

class _DepartmentManagePageState extends State<DepartmentManagePage> {
  @override
  List<Map> users;
  @override
  void initState() {
    super.initState();
  }

  Widget build(BuildContext context) {
    final tree = Provider.of<ProviderServices>(context);
    String jsonTree = tree.tree;
    //这里用了jsontree
    //在这里根据json提取所有人员
    users = getUsers(jsonTree);
    return Scaffold(
        appBar: AppBar(
          title: Text("人员信息"),
          actions: [
            IconButton(
              icon: Icon(Icons.search),
              onPressed: () {
                showSearch(
                    context: context, delegate: SearchBarDelegate(users));
              },
            ),
            IconButton(
                onPressed: () {
                  print("addUser");
                  _addUser(context);
                },
                icon: Icon(Icons.add)),
            IconButton(
              icon: Icon(Icons.refresh),
              onPressed: () async {
                SharedPreferences prefs = await SharedPreferences.getInstance();
                String id = prefs.getString("adminId");
                await Tree.getTreeFormSer(id, true, context);

                EventBusUtil.getInstance().fire(UpdataNode("updataNode"));
              },
            ),
          ],
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
                    sliver: UserSliverList(users, deleteStaff: _deleteUser),
                  ))
                ],
              ),
            )
          ],
        ));
  }

  _addUser(BuildContext context) async {
    //这里用了jsontree
    final tree = Provider.of<ProviderServices>(context);
    String jsonTree = tree.tree;

    var parsedJson = json.decode(jsonTree);
    List<String> idList = [];
    Tree.getAllPeopleId(parsedJson, idList);
    final newUser = await Navigator.push(context,
        new MaterialPageRoute(builder: (context) => new AddUser(idList)));
    if (newUser != null) {
      insertStaff(parsedJson, newUser, newUser["right"]);
      jsonTree = json.encode(parsedJson);

      tree.upDataTree(jsonTree);
      //这里需要利用jsonTree更新页面了======
      setState(() {
        final tree = Provider.of<ProviderServices>(context);
        String jsonTree = tree.tree;
        //这里用了jsontree
        //在这里根据json提取所有人员
        this.users = getUsers(jsonTree);
      });
    }
  }

  Future<bool> deleteAccount(String id) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String adminId = prefs.get("adminId");
    var rel = await Dio()
        .post("http://47.110.150.159:8080/deleteMember?type=$adminId&id=$id");
    return true;
  }

  bool _deleteUser(Map staff) {
    deleteAccount(staff["id"]);
    final tree = Provider.of<ProviderServices>(context);
    String jsonTree = tree.tree;

    var parsedJson = json.decode(jsonTree);
    deleteStaff(parsedJson, staff);
    jsonTree = json.encode(parsedJson);

    //这里需要更新jsonTree===================

    tree.upDataTree(jsonTree);
    return true; //成功返回true
  }

  void deleteStaff(var parsedJson, Map staffMap) {
    if (parsedJson is Map<String, dynamic>) {
      parsedJson.forEach((key, value) {
        if (key == staffMap["right"] && value["$staff"] is List) {
          List staffList = value["$staff"];
          for (int i = 0; i < staffList.length; i++) {
            Map element = staffList[i];
            if (element["id"] == staffMap["id"]) {
              print("delete" + staffMap["name"]);
              value["$staff"].removeAt(i);
              break;
            }
          }
        } else {
          deleteStaff(parsedJson[key], staffMap);
        }
      });
    }
  }

  void insertStaff(var parsedJson, Map staffMap, String right) {
    if (parsedJson is Map<String, dynamic>) {
      parsedJson.forEach((key, value) {
        if (key == right) {
          value["$staff"].add(staffMap);
        } else {
          insertStaff(parsedJson[key], staffMap, right);
        }
      });
    }
  }

  List<Map> getUsers(String jsonTree) {
    //在这里根据json提取所有人员（获得users）
    List users = [];
    var parsedJson = json.decode(jsonTree);
    Tree.getAllPeople(parsedJson, users);
    users = List<Map>.from(users);
    return users;
  }
}
