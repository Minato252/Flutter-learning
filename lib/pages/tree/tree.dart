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
        return parsedJson;
      } else {
        parsedJson.forEach((key, value) {
          if (key == parentName) {
            //一定在这一级
            Map<String, dynamic> m = Map.from(value);
            m[newName] = m[oldName];
            m.remove(oldName);
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
          //在这里eventBus====================
          EventBusUtil.getInstance().fire(UpdataNode("rejectDeleteNode"));
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
      setTreeInSer(id, "{}", context);
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString("tree", "{}");
      final ps = Provider.of<ProviderServices>(context);
      ps.upDataTree("{}");

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
      String url = await UploadFile.fileUplod("$tempPath/tree.json");

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
