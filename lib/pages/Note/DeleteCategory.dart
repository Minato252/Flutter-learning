import 'package:flutter/material.dart';
import 'package:flutter_html/html_parser.dart';
import 'package:flutter_html/style.dart';
import 'package:weitong/pages/Note/NoteContent.dart';

class CategorySliverList extends StatefulWidget {
  List _titleList;
  CategorySliverList(List _titleList) {
    this._titleList = _titleList;
  }
  @override
  _CategorySliverListState createState() =>
      _CategorySliverListState(_titleList);
}

class _CategorySliverListState extends State<CategorySliverList> {
  @override
  List _titleList;
  _CategorySliverListState(List _titleList) {
    this._titleList = _titleList;
  }
  Widget build(BuildContext context) {
    return SliverList(
        delegate: SliverChildBuilderDelegate(
      (BuildContext context, int index) {
        return Padding(
          padding: EdgeInsets.only(bottom: 15),
          child: Material(
            borderRadius: BorderRadius.circular(12.0),
            elevation: 50.0,
            shadowColor: Colors.grey.withOpacity(0.5),
            child: Column(
              children: [
                ListTile(
                  leading: Icon(Icons.title),
                  title: Text(
                    _titleList[index]["nNotetitle"],
                    style: TextStyle(
                      fontSize: 23,
                      color: Colors.black,
                    ),
                  ),
                  subtitle: Text(
                    "内容:${_titleList[index]["ncontent"]}",
                    style: TextStyle(fontSize: 15, color: Colors.grey[700]),
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (c) {
                          return Note(
                              htmlCode: _titleList[index]["nNote"],
                              ntitle: _titleList[index]["nNotetitle"]);
                        },
                      ),
                    );
                  },
                ),
              ],
            ),
          ),

          /*Container(
                padding: EdgeInsets.all(20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(_titleList[index]["nNotetitle"]),
                    Row(
                      children: [
                        IconButton(
                            icon: Icon(Icons.more_horiz),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (c) {
                                    return Note(
                                        htmlCode: _titleList[index]["nNote"],
                                        ntitle: _titleList[index]
                                            ["nNotetitle"]);
                                  },
                                ),
                              );
                            }),
                        /*IconButton(
                            icon: Icon(Icons.delete),
                            onPressed: () {
                             // _alertDialog(_titleList, index);
                            }),*/
                      ],
                    )
                  ],
                )),*/
        );
      },
      childCount: _titleList.length,
    ));
  }

  /* Future _alertDialog(_leftCateList, index) async {
    var result = await showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text("提示信息"),
            content: Text(""),
            actions: <Widget>[
              RaisedButton(
                child: Text("取消"),
                color: Colors.blue,
                textColor: Colors.white,
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
              RaisedButton(
                child: Text("确定"),
                color: Colors.blue,
                textColor: Colors.white,
                onPressed: () {
                  setState(() {
                    _leftCateList.removeAt(index);
                  });

                  Navigator.pop(context);
                },
              ),
            ],
          );
        });
    return result;
  }*/
}
