import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:weitong/widget/Input.dart';
import 'package:weitong/widget/JdButton.dart';

class TagChipDemo extends StatefulWidget {
  @override
  _TagState createState() => _TagState();
}

class _TagState extends State<TagChipDemo> {
  @override
  List<String> _tags = [
    '111',
    '222',
    '333',
  ];

  // void initState() {}

  _awaitReturnNewTag(BuildContext context) async {
    final newTag = await Navigator.push(
      context,
      new MaterialPageRoute(
          builder: (context) => new Input("新建关键词", "输入您要新建的关键词", 12, "关键词")),
    );
    if (newTag != null) {
      setState(() {
        _tags.add(newTag);
      });
    }
  }

  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("关键词"),
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
                  style: TextStyle(fontSize: 32.0),
                ),
                SizedBox(height: 15),
                Wrap(
                  spacing: 8.0,
                  children: _tags.map((tag) {
                    return Chip(
                      label: Text(tag),
                      onDeleted: () {
                        setState(() {
                          _tags.remove(tag);
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
                JdButton(
                  text: '完成',
                  cb: () {
                    _saveTags();
                  },
                ),
              ]),
        ))));
  }

  void _saveTags() async {
    //执行保存操作
    Navigator.of(context).pop();
  }
}
