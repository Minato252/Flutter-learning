import 'package:flutter/material.dart';

class CategorySliverList extends StatefulWidget {
  List _leftCateList;
  CategorySliverList(List _leftCateList) {
    this._leftCateList = _leftCateList;
  }
  @override
  _CategorySliverListState createState() =>
      _CategorySliverListState(_leftCateList);
}

class _CategorySliverListState extends State<CategorySliverList> {
  @override
  List _leftCateList;
  _CategorySliverListState(List _leftCateList) {
    this._leftCateList = _leftCateList;
  }
  Widget build(BuildContext context) {
    return SliverList(
        delegate: SliverChildBuilderDelegate(
      (BuildContext context, int index) {
        return Padding(
          padding: EdgeInsets.only(bottom: 32),
          child: Material(
            borderRadius: BorderRadius.circular(12.0),
            elevation: 14.0,
            shadowColor: Colors.grey.withOpacity(0.5),
            child: Container(
                padding: EdgeInsets.all(20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(_leftCateList[index]["category"]),
                    Row(
                      children: [
                        IconButton(
                            icon: Icon(Icons.more_horiz), onPressed: () {}),
                        IconButton(
                            icon: Icon(Icons.delete),
                            onPressed: () {
                              _alertDialog(_leftCateList, index);
                            }),
                      ],
                    )
                  ],
                )),
          ),
        );
      },
      childCount: _leftCateList.length,
    ));
  }

  Future _alertDialog(_leftCateList, index) async {
    var result = await showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text("提示信息"),
            content: Text("您确定要删除此人员吗,该操作会删除有关此人员的所有数据"),
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
  }
}
