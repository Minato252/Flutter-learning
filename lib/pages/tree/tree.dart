import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:weitong/pages/tabs/uploadFile.dart';
import 'package:weitong/services/event_util.dart';
import 'package:weitong/services/providerServices.dart';

String demoTree = """


{
    "value": "公司",
    "defaultValue": "公司",
    "key": "0-1",
    "parentKey": "0",
    "isEditable": false,
    "title": null,
    "children": [
        {
            "value": "一部门",
            "defaultValue": "一部门",
            "key": "0-10.7652253529686537",
            "parentKey": "0-1",
            "isEditable": false,
            "title": null,
            "children": [
                {
                    "value": "一部门1组",
                    "defaultValue": "一部门1组",
                    "key": "0-10.76522535296865370.9985945851952409",
                    "parentKey": "0-10.7652253529686537",
                    "isEditable": false,
                    "title": null,
                    "children": [
                        {
                            "phone": "3",
                            "name": "jack3",
                            "password": "3",
                            "value": "jack3",
                            "job": "员工",
                            "right": "一部门",
                            "key": "3",
                            "parentKey": "一部门1组",
                            "parentname": "一部门1组",
                            "isEditable": false,
                            "title": null
                        }
                    ]
                },
                {
                    "phone": "2",
                    "name": "jack2",
                    "password": "2",
                    "value": "jack2",
                    "job": "员工",
                    "right": "公司",
                    "key": "2",
                    "parentKey": "一部门",
                    "parentname": "一部门",
                    "isEditable": false,
                    "title": null
                }
            ]
        },
        {
            "value": "二部门",
            "defaultValue": "二部门",
            "key": "0-10.8114799205124112",
            "parentKey": "0-1",
            "isEditable": false,
            "title": null,
            "children": [
                {
                    "value": "二部门1组",
                    "defaultValue": "二部门1组",
                    "key": "0-10.81147992051241120.31582169271024485",
                    "parentKey": "0-10.8114799205124112",
                    "isEditable": false,
                    "title": null,
                    "children": [
                        {
                            "phone": "5",
                            "name": "jack5",
                            "password": "5",
                            "value": "jack5",
                            "job": "员工",
                            "right": "二部门",
                            "key": "5",
                            "parentKey": "二部门1组",
                            "parentname": "二部门1组",
                            "isEditable": false,
                            "title": null
                        }
                    ]
                },
                {
                    "phone": "4",
                    "name": "jack4",
                    "password": "4",
                    "value": "jack4",
                    "job": "员工",
                    "right": "一部门1组",
                    "key": "4",
                    "parentKey": "二部门",
                    "parentname": "二部门",
                    "isEditable": false,
                    "title": null
                }
            ]
        },
        {
            "value": "三部门",
            "defaultValue": "三部门",
            "key": "0-10.13819441013845313",
            "parentKey": "0-1",
            "isEditable": false,
            "title": null,
            "children": [
                {
                    "phone": "6",
                    "name": "jack6",
                    "password": "6",
                    "value": "jack6",
                    "job": "员工",
                    "right": "二部门1组",
                    "key": "6",
                    "parentKey": "三部门",
                    "parentname": "三部门",
                    "isEditable": false,
                    "title": null
                }
            ]
        },
        {
            "value": "四部门",
            "defaultValue": "四部门",
            "key": "0-10.3633340814745494",
            "parentKey": "0-1",
            "isEditable": false,
            "title": null,
            "children": [
                {
                    "phone": "7",
                    "name": "jack7",
                    "password": "7",
                    "value": "jack7",
                    "job": "员工",
                    "right": "三部门",
                    "key": "7",
                    "parentKey": "四部门",
                    "parentname": "四部门",
                    "isEditable": false,
                    "title": null
                }
            ]
        },
        {
            "phone": "1",
            "name": "jack1",
            "password": "1",
            "value": "jack1",
            "job": "员工",
            "key": "1",
            "parentKey": "公司",
            "parentname": "公司",
            "isEditable": false,
            "title": null
        }
    ]
}

""";

class Tree {
  static String staff = "人员";
  static void getAllKeyName(parsedJson, List<String> result) {
    if (parsedJson is Map<String, dynamic>) {
      parsedJson.forEach((key, value) {
        if (!result.contains(key)) {
          result.add(key);
        }
        getAllKeyName(parsedJson[key], result);
        return;
      });
    } else {
      return;
    }
  }

  static bool mapIsEmpty(Map<String, dynamic> m) {
    bool isEmpty = true;
    if (m["$staff"].length != 0) {
      isEmpty = false;
      return isEmpty;
    }
    if (m.keys.length > 1) {
      isEmpty = false;
      return isEmpty;
    }
    return isEmpty;
  }

  static dynamic insertNode(parsedJson, parent, child) {
    if (parent == null) {
      parsedJson[child] = {
        "$staff": [],
      };
      return parsedJson;
    }
    if (parsedJson is Map<String, dynamic>) {
      parsedJson.forEach((key, value) {
        if (key == parent) {
          value[child] = {
            "$staff": [],
          };
        } else {
          parsedJson[key] = insertNode(parsedJson[key], parent, child);
        }
      });
    }
    return parsedJson;
  }

  static dynamic editNode(
      parsedJson, parentName, String oldName, String newName) {
    if (parsedJson is Map<String, dynamic>) {
      if (parentName == null) {
        //在第一级一定会有
        parsedJson[newName] = Map.from(parsedJson[oldName]);

        parsedJson.remove(oldName);
        parsedJson[newName]["$staff"].forEach((e) {
          e["right"] = newName;
        });
        return parsedJson;
      } else {
        parsedJson.forEach((key, value) {
          if (key == parentName) {
            //一定在这一级
            Map<String, dynamic> m = Map.from(value);
            m[newName] = m[oldName];
            m.remove(oldName);
            m[newName]["$staff"].forEach((e) {
              e["right"] = newName;
            });
            parsedJson[key] = m;
          } else {
            parsedJson[key] =
                editNode(parsedJson[key], parentName, oldName, newName);
          }
        });
        return parsedJson;
      }
    } else {
      return parsedJson;
    }
  }

  static dynamic deleteNode(parsedJson, parentName, deleteName) {
    if (parsedJson is Map<String, dynamic>) {
      if (parentName == null) {
        //在第一级一定会有待删除结点
        if (mapIsEmpty(parsedJson[deleteName])) {
          //待删除结点里面为空
          parsedJson.remove(deleteName);
        } else {
          //这里需要调用另一个类的函数
          print("非空");
          return null; //非空删除失败
          // //在这里eventBus====================
          // EventBusUtil.getInstance().fire(UpdataNode("rejectDeleteNode"));
//==========================================
        }
      } else {
        parsedJson.forEach((key, value) {
          if (key == parentName) {
            //一定在这一级
            Map<String, dynamic> m = Map.from(value);
            if (mapIsEmpty(m[deleteName])) {
              //待删除结点里面为空
              m.remove(deleteName);
              parsedJson[key] = m;
            } else {
              //这里需要调用另一个类的函数
              print("非空");
              EventBusUtil.getInstance().fire(UpdataNode("rejectDeleteNode"));
            }
          } else {
            parsedJson[key] =
                deleteNode(parsedJson[key], parentName, deleteName);
          }
        });
      }

      return parsedJson;
    } else {
      return parsedJson;
    }
  }

  static void getAllPeopleId(parsedJson, List result) {
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

  static void getAllPeople(parsedJson, List result) {
    if (parsedJson is Map) {
      parsedJson.forEach((key, value) {
        getAllPeople(parsedJson[key], result);
      });
    } else if (parsedJson is List) {
      print("11");
      result.addAll(parsedJson);
    }
  }

  static Map getUserInfoAndSave(parsedJson, String id, BuildContext context) {
    if (parsedJson is Map<String, dynamic>) {
      Map result;
      parsedJson.forEach((key, value) {
        var temp = getUserInfoAndSave(parsedJson[key], id, context);

        if (temp != null) {
          result = Map.from(temp);
        }
      });
      return result;
    } else if (parsedJson is List) {
      for (int i = 0; i < parsedJson.length; i++) {
        if (parsedJson[i]["id"] == id) {
          Map user = parsedJson[i];
          final ps = Provider.of<ProviderServices>(context);
          ps.upDatauserInfo(user);
          return user;
        }
      }
    }
    return null;
  }

  static Map getSubRight(parsedJson, String right) {
    if (parsedJson is Map<String, dynamic>) {
      if (parsedJson.containsKey(right)) {
        //一定在这一级
        return parsedJson[right];
      } else {
        Map result;
        parsedJson.forEach((key, value) {
          var temp = getSubRight(parsedJson[key], right);
          if (temp != null) {
            result = Map.from(temp);
          }
        });
        return result;
      }
    }
    return null;
  }

  static bool isMyModel(String jsonTree) {
//判断这个树是否是采用手机端的模式
    var parsedJson = json.decode(jsonTree);
    if (parsedJson is Map) {
      if (parsedJson.containsKey("value")) {
        return false;
      } else {
        return true;
      }
    } else {
      return false;
    }
  }

  // static void modifyTreeResu(Map my, List other) {
  //   my = new Map<String, dynamic>.from(my);

  //   Map tempMap = {"$staff": []};
  //   for (int i = 0; i < other.length; i++) {
  //     if (other[i] is Map) {
  //       Map m = Map.from(other[i]);
  //       if (m.containsKey("children")) {
  //         //说明这个m是权限
  //         List tempList = m["children"];
  //         if (tempList == null) tempList = [];
  //         modifyTreeResu(tempMap, tempList);

  //         if (my is Map) {
  //           String s = m["value"];
  //           my[s] = Map.from(tempMap);
  //           print("my: " +
  //               my.toString() +
  //               "other:" +
  //               other.toString() +
  //               "index:" +
  //               i.toString());
  //         }
  //       } else if (my["$staff"] is List) {
  //         //说明这个m是人员
  //         Map mm = {
  //           "name": "${m["name"]}",
  //           "id": "${m["phone"]}",
  //           "password": "${m["password"]}",
  //           "job": "${m["job"]}",
  //           "right": "${m["right"]}"
  //         };
  //         List l = my["$staff"];
  //         l.add(mm);
  //         print("加入人员后：" + my.toString());
  //       }
  //     }
  //   }
  // }

  static Map modifyTreeResu(Map my, List other) {
    my = new Map<String, dynamic>.from(my);

    for (int i = 0; i < other.length; i++) {
      if (other[i] is Map) {
        Map m = Map.from(other[i]);
        if (m.containsKey("children")) {
          //说明这个m是权限
          List tempList = m["children"];
          if (tempList == null) tempList = [];

          Map tempMap = {"$staff": []};
          Map realM = modifyTreeResu(tempMap, tempList);
          print(realM);
          if (my is Map) {
            String s = m["value"];
            my[s] = Map.from(realM);
            print("my: " + my.toString());
          }
        } else if (my["$staff"] is List) {
          //说明这个m是人员
          Map mm = {
            "name": "${m["name"]}",
            "id": "${m["phone"]}",
            "password": "${m["password"]}",
            "job": "${m["job"]}",
            "right": "${m["right"]}"
          };
          List l = my["$staff"];
          l.add(mm);
          print("加入人员后：" + my.toString());
        }
      }
    }

    return my;
  }

  static String modifyTree(String jsonTree) {
    var parsedJson = json.decode(jsonTree);
    Map myMap = {
      "${parsedJson["value"]}": {"$staff": []}
    };

    List tempList =
        parsedJson["children"] is List ? parsedJson["children"] : [];

    myMap[parsedJson["value"]] =
        modifyTreeResu(myMap[parsedJson["value"]], tempList);

    return json.encode(myMap);
  }

  static getTreeFormSer(String id, bool isAdmin, BuildContext context) async {
//管理员调用，远程获取树写入provider中

    //1、权限检查
    bool status = await Permission.storage.isGranted;
    //判断如果还没拥有读写权限就申请获取权限
    if (!status) {
      return await Permission.storage.request().isGranted;
    }
    // 调用下载方法 --------做该做的事

    //从网络获取树的url
    var rel;
    if (isAdmin) {
      rel =
          await Dio().post("http://47.110.150.159:8080/tree/selectAdm?id=$id");
    } else {
      rel =
          await Dio().post("http://47.110.150.159:8080/tree/selectMem?id=$id");
    }
    String treeUrl = rel.data;

    if (treeUrl == null || treeUrl == "") {
      //这个肯定是第一次登录管理员
      String initTreeStr = """
      {
    "公司": {
        "$staff": []
        
    }
}
      """;

      // setTreeInSer(id, "{}", context);
      // SharedPreferences prefs = await SharedPreferences.getInstance();
      // await prefs.setString("tree", "{}");
      // final ps = Provider.of<ProviderServices>(context);
      // ps.upDataTree("{}");
      setTreeInSer(id, initTreeStr, context);
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString("tree", initTreeStr);
      final ps = Provider.of<ProviderServices>(context);
      ps.upDataTree(initTreeStr);

      return;
    }

    //从url读取文件
    try {
      Directory tempDir = await getTemporaryDirectory();
      String tempPath = tempDir.path;
      var response = await Dio().download(treeUrl, "$tempPath/tree.json");

      if (response.statusCode == 200) {
        print('下载请求成功');
        var contents = await File('$tempPath/tree.json').readAsString();
        print("从服务器拉取的树：" + contents);
        //contents就是树的字符串

//         //以下是测试=====

        // bool re = isMyModel("{}");
        // print("ismyModel: $re");

        // String demoswitchString = modifyTree(demoTree);
        // print(demoswitchString);
// //===测试结束

//==尝试更改pc端的树==
        if (!isMyModel(contents)) {
          //如果是pc端的树
          contents = modifyTree(demoTree);
        }

//更改完成==
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString("tree", contents);

        final ps = Provider.of<ProviderServices>(context);
        ps.upDataTree(contents);
        return contents;
      } else {
        throw Exception('接口出错');
      }
    } catch (e) {
      print('服务器出错或网络连接失败！');
      return print('ERROR:======>$e');
    }
  }

  static setTreeInSer(String id, String jsonStr, BuildContext context) async {
//管理员调用，远程获取树写入内存中

    //1、权限检查
    bool status = await Permission.storage.isGranted;
    //判断如果还没拥有读写权限就申请获取权限
    if (!status) {
      return await Permission.storage.request().isGranted;
    }

    try {
      //新建本地文件，写入json树
      Directory tempDir = await getTemporaryDirectory();
      String tempPath = tempDir.path;
      File f = await File("$tempPath/tree.json").writeAsString(jsonStr);

      //把本地文件上传到服务器，并获取url
      String url =
          await UploadFile.fileUplod("$tempPath/tree.json", isAdmin: true);

      //把url传到数据库
      await Dio()
          .post("http://47.110.150.159:8080/tree/updateAdm?id=$id&url=$url");

      final ps = Provider.of<ProviderServices>(context);
      ps.upDataTree(jsonStr);
    } catch (e) {
      print('服务器出错或网络连接失败！');
      return print('ERROR:======>$e');
    }
  }
}
