import 'package:weitong/services/event_util.dart';

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
    if (parsedJson is Map<String, dynamic>) {
      parsedJson.forEach((key, value) {
        getAllPeople(parsedJson[key], result);
      });
    } else if (parsedJson is List) {
      print("11");
      result.addAll(parsedJson);
    }
  }
}
