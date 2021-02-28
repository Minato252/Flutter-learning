import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/style.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:weitong/services/providerServices.dart';
import 'package:weitong/widget/Input.dart';
import 'package:weitong/widget/JdButton.dart';

class TagChipDemo extends StatefulWidget {
  final Map arguments;
  TagChipDemo({Key key, this.arguments}) : super(key: key);
  @override
  _TagState createState() => _TagState(arguments: this.arguments);
}

class _TagState extends State<TagChipDemo> {
  Map arguments;
  _TagState({this.arguments});

  // List<String> _tags = [
  //   '111',
  //   '222',
  //   '333',
  // ];
  List<String> _tags = [];
  @override
  void initState() {
    super.initState();
    _getTag();
  }

  _awaitReturnNewTag(BuildContext context) async {
    final newTag = await Navigator.push(
      context,
      new MaterialPageRoute(
          builder: (context) => new Input("新建关键词", "输入您要新建的关键词", 12, "关键词")),
    );
    if (newTag != null) {
      final ps = Provider.of<ProviderServices>(context);
      // _tags = ps.keyWords;
      if (!_tags.contains(newTag)) {
        setState(() {
          _tags.add(newTag);
          ps.upDataKeyWords(_tags);
        });
      }
    }
    _updataTagToServer();
  }

  _updataTagToServer() async {
    if (arguments['identify'] == "admin") {
      String s = _tags.join(',');
      SharedPreferences prefs = await SharedPreferences.getInstance();

      print("*********************${s}*******************");
      Dio().post(
          "http://47.110.150.159:8080/updataWord?id=${prefs.get("adminId")}&word=${s}");
    }
  }

  _getTag() async {
    // print("***********************${arguments['identify']}*******************");
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String id;
    if (arguments['identify'] == "admin") {
      id = prefs.get("adminId");
    } else {
      id = prefs.get("id");
    }

    var rel =
        await Dio().post("http://47.110.150.159:8080/selectWord?id=${id}");
    List<String> s = rel.data.toString().split(',');

    for (int i = 0; i < s.length; i++) {
      if (!_tags.contains(s[i])) {
        _tags.add(s[i]);
      }
    }
    setState(() {});
  }

  Widget build(BuildContext context) {
    print("***********************${arguments['identify']}*******************");
    // _getTag();
    if (arguments['identify'] == "user") {
      final ps = Provider.of<ProviderServices>(context);
      // _tags = ps.keyWords;
      List<String> s = ps.keyWords;
      for (int i = 0; i < s.length; i++) {
        if (!_tags.contains(s[i])) {
          _tags.add(s[i]);
        }
      }
    }
    // final ps = Provider.of<ProviderServices>(context);
    // _tags = ps.keyWords;

    // _getTag(context, arguments['identify'].toString());
    return Scaffold(
        appBar: AppBar(
          title: Text(
            "关键词",
            style: TextStyle(fontSize: 26.0),
          ),

          // actions: <Widget>[
          //   FlatButton(
          //       onPressed: null,
          //       child: Text(
          //         "完成",
          //         style: TextStyle(fontSize: 20),
          //       ))
          // ],
        ),
        body: Scrollbar(
            child: SingleChildScrollView(
                child: Container(
          padding: EdgeInsets.all(20),
          child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                SizedBox(height: 15),
                Text(
                  "管理您的关键词",
                  style: TextStyle(fontSize: 20.0),
                ),
                SizedBox(height: 15),
                Wrap(
                  spacing: 8.0,
                  children: _tags.map((tag) {
                    return Chip(
                      label: Text(tag),
                      onDeleted: () {
                        final ps = Provider.of<ProviderServices>(context);

                        setState(() {
                          _tags.remove(tag);

                          ps.upDataKeyWords(_tags);
                          if (arguments['identify'] == "admin") {
                            _updataTagToServer();
                          }
                        });
                      },
                      deleteButtonTooltipMessage: "删除这个关键词",
                    );
                  }).toList(),
                ),
                SizedBox(height: 15),
                ActionChip(
                  label: Text(
                    "新建关键词",
                    style: TextStyle(color: Colors.white),
                  ),
                  backgroundColor: Theme.of(context).accentColor,
                  onPressed: () {
                    _awaitReturnNewTag(context);
                  },
                  avatar: Icon(
                    Icons.add,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 15),
                Divider(
                  color: Colors.black12,
                ),
                SizedBox(
                  height: 15,
                ),
                arguments['identify'] == "user"
                    ? JdButton(
                        text: '完成',
                        cb: () {
                          _saveTags();
                        },
                      )
                    : Text(""),
              ]),
        ))));
  }

  Future<void> saveKeyWords() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final ps = Provider.of<ProviderServices>(context);
    List<String> tags = ps.keyWords;
    prefs.setString("keyWords", listToString(tags));
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

  void _saveTags() async {
    //执行保存操作
    await saveKeyWords();
    Navigator.of(context).pop();
  }
}
