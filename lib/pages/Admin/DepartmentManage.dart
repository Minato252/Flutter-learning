import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:weitong/pages/Admin/AddUser.dart';
import 'package:weitong/routers/router.dart';
import 'package:weitong/services/providerServices.dart';
import 'UsersList.dart';

import 'searchDemo.dart';

String staff = "人员";
// String jsonTree = '''
// {
//     "总经理": {
//         "$staff": [
//             {
//                 "name": "老总",
//                 "id": "这里是手机号",
//                 "password": "这里是密码",
//                 "job": "这里是职务",
//                 "right": "总经理"
//             }
//         ],
//         "美术部门": {
//             "$staff": [
//                 {
//                     "name": "张三",
//                     "id": "这里是手机号",
//                     "password": "这里是密码",
//                     "job": "这里是职务",
//                      "right": "美术部门"
//                 },
//                 {
//                     "name": "美术李四",
//                     "id": "这里是手机号",
//                     "password": "这里是密码",
//                     "job": "这里是职务",
//                 "right": "美术部门"
//                 }
//             ],
//             "美术小组": {
//                "$staff": [
//                     {
//                         "name": "美术王五",
//                         "id": "这里是手机号",
//                         "password": "这里是密码",
//                         "job": "这里是职务",
//                         "right": "美术小组"
//                     }
//                 ]
//             }
//         },
//         "软件部门": {
//            "$staff": [
//                 {
//                     "name": "软件李四",
//                     "id": "这里是手机号",
//                     "password": "这里是密码",
//                     "job": "这里是职务",
//                     "right": "软件部门"
//                 }
//             ],
//             "软件小组": {
//                 "$staff": [
//                     {
//                         "name": "软件王五",
//                         "id": "这里是手机号",
//                         "password": "这里是密码",
//                         "job": "这里是职务",
//                     "right": "软件小组"
//                     }
//                 ]
//             }
//         },
//         "人力部门": {
//            "$staff": [ ]
//         },
//         "销售部门": {
//             "$staff": [ ]
//         }
//     }
// }
// '''; //一直以来更改的jsonTree
// void getAllPeopleName(parsedJson, List result) {
//   if (parsedJson is Map<String, dynamic>) {
//     parsedJson.forEach((key, value) {
//       getAllPeopleName(parsedJson[key], result);
//     });
//   } else if (parsedJson is List) {
//     print("11");
//     result.addAll(parsedJson);
//   }
// }

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
                onPressed: () {
                  String jsons = """{
	{
		"id": "minato",
		"password": "minato"
	}: {
		"id": "minato",
		"password": "minato"
	}
}""";
                  Map m = json.decode(jsons);
                  print(m.toString());
                },
                icon: Icon(Icons.ac_unit)),
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
    getAllPeopleId(parsedJson, idList);
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
    getAllPeopleName(parsedJson, users);
    users = List<Map>.from(users);
    return users;
  }

  void getAllPeopleId(parsedJson, List result) {
    if (parsedJson is Map<String, dynamic>) {
      parsedJson.forEach((key, value) {
        getAllPeopleId(parsedJson[key], result);
      });
    } else if (parsedJson is List) {
      for (int i = 0; i < parsedJson.length; i++) {
        result.add(parsedJson[i]["id"]);
      }
    }
  }

  void getAllPeopleName(parsedJson, List result) {
    if (parsedJson is Map<String, dynamic>) {
      parsedJson.forEach((key, value) {
        getAllPeopleName(parsedJson[key], result);
      });
    } else if (parsedJson is List) {
      print("11");
      result.addAll(parsedJson);
    }
  }
}
