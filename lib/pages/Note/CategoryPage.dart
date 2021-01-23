import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
//import 'package:react/react.dart';
//import 'package:weitong/pages/tabs/Config.dart';
//import 'package:weitong/pages/tabs/CategoryModel.dart';
import 'package:weitong/services/ScreenAdapter.dart';
import 'package:weitong/pages/Note/SearchCategory.dart';
import 'package:weitong/pages/Note/NoteContent.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:weitong/pages/Note/EditCreate.dart';
import 'package:weitong/pages/Note/NewCategory.dart';

class CategoryPage extends StatefulWidget {
  CategoryPage({Key key}) : super(key: key);

  @override
  _CategoryPageState createState() => _CategoryPageState();
}

class _CategoryPageState extends State<CategoryPage>
    with AutomaticKeepAliveClientMixin {
  @override
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive => true;
  String id;
  //String index;

  int _selectIndex = 0;
  List _leftCateList = [];
  List _rightCateList = [];
  String newcategory;

  void initState() {
    super.initState();
    _getUserInfo();
    //_getLeftCateData();

    //_getRightCateData();
  }

  _getUserInfo() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    this.id = prefs.get("id");
    setState(() {
      id;
      print(id);
      _getLeftCateData(id);
    });
  }

  _getLeftCateData(String id) async {
    //var api = '${Config.domain}insertCategory';
    Dio dio = new Dio();
    Map<String, dynamic> map = Map();
    print(id);
    map["userid"] = "${id}";
    print(map);
    FormData formData = FormData.fromMap(map);
    Response response = await dio
        .post("http://47.110.150.159:8080/selectCategory", data: formData);
    print(response);
    var leftCateList = response;
    //var leftCateList = new CategoryModel.fromJson(response.data);
    setState(() {
      this._leftCateList = leftCateList.data;
    });
    _getRightCateData(id, _leftCateList[0]["category"]);
  }

  _getRightCateData(String id, String nCategory) async {
    print(id);
    var api =
        'http://47.110.150.159:8080/note/select?uId=${id}&category=${nCategory}';
    Dio dio = new Dio();
    Response response = await dio.post(api);
    print(response);
    var rightCateList = response;
    //var rightCateList = new NoteModel.fromJson(result.data);
    setState(() {
      this._rightCateList = rightCateList.data;
    });
  }

//左边数据加载
  Widget _leftCateWidget(leftWidth) {
    if (this._leftCateList.length > 0) {
      return Container(
        width: leftWidth,
        height: double.infinity,
        child: ListView.builder(
          //支持滑动，动态生成
          itemCount: this._leftCateList.length,
          itemBuilder: (context, index) {
            return Column(
              children: [
                InkWell(
                    onTap: () {
                      _selectIndex = index;
                      this._getRightCateData(
                          this._leftCateList[index]["userid"],
                          this._leftCateList[index]["category"]);
                      //print(this._leftCateList[index]["userid"]);
                    },
                    onLongPress: () {
                      _alertDialog(_leftCateList, index);
                    },
                    child: Container(
                      width: double.infinity,
                      height: ScreenAdapter.height(84),
                      padding: EdgeInsets.only(top: ScreenAdapter.height(24)),
                      //child: Text('${this._leftCateList[index].Category}',
                      child: Text('${this._leftCateList[index]["category"]}',
                          textAlign: TextAlign.center),
                      color: _selectIndex == index
                          //? Colors.white
                          ? Color.fromRGBO(255, 255, 204, 50)
                          : Color.fromRGBO(240, 246, 246, 0.9),
                    )
                    //: Color.fromRGBO(255, 255, 204, 50)),
                    ),
                Divider(height: 1), //设置默认间隙为1
              ],
            );
          },
        ),
      );
    } else {
      return Container(
        width: leftWidth,
        height: double.infinity,
      );
    }
  }

//右边数据加载
  Widget _rightCateWidget(rightItemWidth, rightItemHeight) {
    if (this._rightCateList.length > 0) {
      return Container(
        width: rightItemWidth,
        height: double.infinity,
        child: ListView.builder(
          //支持滑动，动态生成
          itemCount: this._rightCateList.length,
          itemBuilder: (context, index) {
            return Column(
              children: [
                InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (c) {
                          return Note(
                              htmlCode:
                                  '${this._rightCateList[index]["nNote"]}',
                              ntitle:
                                  '${this._rightCateList[index]["nNotetitle"]}');
                        },
                      ),
                    );
                  },
                  onLongPress: () {
                    _alertDialogtitle(_rightCateList, index);
                  },
                  child: Container(
                      width: double.infinity,
                      height: ScreenAdapter.height(84),
                      padding: EdgeInsets.only(top: ScreenAdapter.height(24)),
                      child: Text('${this._rightCateList[index]["nNotetitle"]}',
                          textAlign: TextAlign.center),
                      color: Colors.white
                      //_selectIndex == index
                      // ? Color.fromRGBO(240, 246, 246, 0.9)
                      //: Colors.white,
                      ),
                ),
                Divider(height: 1), //设置默认间隙为1
              ],
            );
          },
        ),
      );
    } else {
      return Container(
        width: rightItemWidth,
        height: double.infinity,
      );
    }
  }

  Future _alertDialog(_leftCateList, index) async {
    var result = await showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text("提示信息"),
            content: Text("确定要删除此类别？"),
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
                    postDeleteFunction(_leftCateList[index]["category"]);
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

//删除类别
  void postDeleteFunction(String value) async {
    String url = "http://47.110.150.159:8080/deleteCategory";

    ///创建Dio
    Dio dio = new Dio();

    ///创建Map 封装参数
    FormData formData = FormData.fromMap({
      "userid": "$id",
      "category": "$value",
    });

    ///发起post请求
    Response response = await dio.post(url, data: formData);
    //var data = response.data;
    //print(response);
    //Navigator.pop(context);
  }

//删除标题
  Future _alertDialogtitle(_rightCateList, index) async {
    var result = await showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text("提示信息"),
            content: Text("确定要删除此标题？"),
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
                    postDeleteTitle(_rightCateList[index]["nNotetitle"]);
                    _rightCateList.removeAt(index);
                  });

                  Navigator.pop(context);
                },
              ),
            ],
          );
        });
    return result;
  }

//删除标题
  void postDeleteTitle(String value) async {
    print(id);
    print(value);
    String url =
        "http://47.110.150.159:8080/note/delete?uId=${id}&noteTitle=${value}";

    ///创建Dio
    Dio dio = new Dio();

    ///创建Map 封装参数
    /*FormData formData = FormData.fromMap({
      "userid": "$id",
      "noteTitle": "$value",
    });*/

    ///发起post请求
    Response response = await dio.post(url);
    //var data = response.data;
    print(response.data);
    //Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    ScreenAdapter.init(context);
    var leftWidth = ScreenAdapter.getScreenWidth() / 4;
    var rightItemWidth = (ScreenAdapter.getScreenWidth() - leftWidth + 100) / 1;
    //获取计算后的宽度
    rightItemWidth = ScreenAdapter.width(rightItemWidth);
    //获取计算后的高度
    var rightItemHeight = rightItemWidth + ScreenAdapter.height(35);
    return Scaffold(
        appBar: AppBar(title: Text("目录界面"), actions: <Widget>[
          IconButton(
            icon: Icon(
              Icons.search,
              color: Colors.white,
            ),
            onPressed: () {
              showSearch(
                  context: context, delegate: SearchCategory(_leftCateList));
            },
          ),
          IconButton(
            icon: Icon(
              Icons.add,
              color: Colors.white,
            ),
            onPressed: () {
              //newcategory = _newcategory(context);
              //setState(() {
              //  _leftCateList.add(newcategory);
              //});
              // Navigator.of(context).pushNamed('/edit');
              Navigator.pushNamed(context, '/newcategory').then(
                (data) => {
                  if (data != null)
                    setState(() {
                      // _leftCateList.add(data);
                      _getLeftCateData(id);
                    }),
                  //print(data)
                },
              );
            },
          ),
        ]),
        body: Row(
          children: <Widget>[
            _leftCateWidget(leftWidth),
            _rightCateWidget(rightItemWidth, rightItemHeight)
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            print("id=" + id);
            //Navigator.pushNamed(context, '/newcategory');
            //Navigator.of(context).pushNamed('/edit');
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (c) {
                  return EditCreate(
                      category:
                          '${this._leftCateList[_selectIndex]["category"]}',
                      id: id);
                },
              ),
            ).then((data) => {
                  if (data != null)
                    setState(() {
                      this._getRightCateData(
                          id, this._leftCateList[_selectIndex]["category"]);
                    }),
                  print("data" + data),
                  print(_selectIndex)
                });
          },
          tooltip: '添加主题',
          child: Icon(Icons.add),
          backgroundColor: Colors.yellow,
        ));
  }

  /* _newcategory(BuildContext context) async {
    //async是启用异步方法

    final result = await Navigator.push(
        //等待
        context,
        MaterialPageRoute(builder: (context) => NewCategory()));
    return result;
  }*/
}
