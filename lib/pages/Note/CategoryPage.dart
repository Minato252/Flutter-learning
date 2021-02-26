import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
//import 'package:react/react.dart';
import 'package:weitong/services/ScreenAdapter.dart';
import 'package:weitong/pages/Note/SearchCategory.dart';
import 'package:weitong/pages/Note/NoteContent.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:weitong/pages/Note/EditCreate.dart';
import 'package:flutter/cupertino.dart';

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
  List _titleList = [];
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
      _getTitleCateData(id);
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

//获取查找标题数据
  _getTitleCateData(String id) async {
    Map<String, dynamic> map = Map();
    print(id);
    map["uId"] = "${id}";
    Dio dio = new Dio();
    FormData formData = FormData.fromMap(map);
    Response response = await dio
        .post("http://47.110.150.159:8080/note/selectId", data: formData);

    print(response);
    var titleList = response;
    setState(() {
      this._titleList = titleList.data;
    });
    // print(_titleList);
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
                      _alertDialog(context, _leftCateList, index);
                    },
                    child: Container(
                      margin: EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        border: Border.all(
                            color: Colors.white,
                            width: 1,
                            style: BorderStyle.solid),
                        borderRadius: BorderRadius.circular(20.0),
                        boxShadow: [
                          BoxShadow(
                              blurRadius: 6,
                              spreadRadius: 4,
                              color: _selectIndex == index
                                  ? Colors.blue
                                  : Colors.blue[100]),
                        ],
                      ),
                      width: double.infinity,
                      height: ScreenAdapter.height(100),
                      padding: EdgeInsets.only(top: ScreenAdapter.height(30)),
                      //child: Text('${this._leftCateList[index].Category}',
                      child: Text(
                        '${this._leftCateList[index]["category"]}',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 20.0,
                        ),
                      ),
                      /*color: _selectIndex == index
                          ? Colors.deepOrange[100]
                          //? Color.fromRGBO(255, 255, 204, 50)
                          : Color.fromRGBO(240, 246, 246, 0.9),*/
                    )
                    //: Color.fromRGBO(255, 255, 204, 50)),
                    ),
                // Divider(
                //  height: 5,
                // ), //设置默认间隙为1
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
                              nCategory:
                                  '${this._rightCateList[index]["nCategory"]}',
                              ntitle:
                                  '${this._rightCateList[index]["nNotetitle"]}');
                        },
                      ),
                    );
                  },
                  onLongPress: () {
                    _alertDialogtitle(context, _rightCateList, index);
                  },
                  child: Container(
                    margin: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      border: Border.all(
                          color: Color.fromARGB(9, 0, 0, 0),
                          width: 1,
                          style: BorderStyle.solid),
                      borderRadius: BorderRadius.circular(13.0),
                      boxShadow: [
                        BoxShadow(
                          blurRadius: 6,
                          spreadRadius: 4,
                          color: Color.fromARGB(20, 0, 0, 0),
                        ),
                      ],
                    ),
                    width: double.infinity,
                    height: ScreenAdapter.height(100),
                    padding: EdgeInsets.only(top: ScreenAdapter.height(24)),
                    child: Text(
                      '${this._rightCateList[index]["nNotetitle"]}',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 18),
                    ),
                    //color: Colors.white
                    //_selectIndex == index
                    // ? Color.fromRGBO(240, 246, 246, 0.9)
                    //: Colors.white,
                  ),
                ),
                // Divider(height: 5), //设置默认间隙为1
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

  Future _alertDialog(widgetContext, _leftCateList, index) async {
    var result = await showCupertinoDialog(
      context: widgetContext,
      builder: (context) {
        return CupertinoAlertDialog(
          title: Text(
            "确认删除该类别",
            style: TextStyle(
              fontSize: 20,
            ),
          ),
          content: Text('\n'),
          actions: [
            CupertinoDialogAction(
              child: Text('确认'),
              onPressed: () {
                setState(() {
                  postDeleteFunction(_leftCateList[index]["category"]);
                  _leftCateList.removeAt(index);
                });
                Navigator.of(context).pop();
              },
            ),
            CupertinoDialogAction(
              child: Text('取消'),
              isDestructiveAction: true,
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

//删除类别
/*
  Future _alertDialog(_leftCateList, index) async {
    var result = await showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text("提示信息", style: TextStyle(fontSize: 20)),
            content: Text(
              "确定要删除此类别？",
              style: TextStyle(fontSize: 15),
            ),
            actions: <Widget>[
              RaisedButton(
                child: Text("取消"),
                color: Colors.deepOrange,
                textColor: Colors.white,
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
              RaisedButton(
                child: Text("确定"),
                color: Colors.deepOrange,
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
*/
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

  Future _alertDialogtitle(widgetContext, _rightCateList, index) async {
    var result = await showCupertinoDialog(
      context: widgetContext,
      builder: (context) {
        return CupertinoAlertDialog(
          title: Text(
            "确认删除该标题",
            style: TextStyle(
              fontSize: 20,
            ),
          ),
          content: Text('\n'),
          actions: [
            CupertinoDialogAction(
              child: Text('确认'),
              onPressed: () {
                setState(() {
                  postDeleteTitle(_rightCateList[index]["nNotetitle"]);
                  _rightCateList.removeAt(index);
                });
                Navigator.of(context).pop();
              },
            ),
            CupertinoDialogAction(
              child: Text('取消'),
              isDestructiveAction: true,
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

/*
//删除标题
  Future _alertDialogtitle(_rightCateList, index) async {
    var result = await showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text("提示信息", style: TextStyle(fontSize: 20)),
            content: Text(
              "确定要删除此标题？",
              style: TextStyle(fontSize: 17),
            ),
            actions: <Widget>[
              RaisedButton(
                child: Text("取消"),
                color: Colors.deepOrange,
                textColor: Colors.white,
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
              RaisedButton(
                child: Text("确定"),
                color: Colors.deepOrange,
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
*/
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

//新建类别
  final int _maxLength = 10;
  String text = '';
  final _formKey = GlobalKey<FormState>();
  Future _showDialog(widgetContext) {
    showCupertinoDialog(
      context: widgetContext,
      builder: (context) {
        return CupertinoAlertDialog(
          title: Text(
            '新建类别',
            style: TextStyle(
              fontSize: 20,
            ),
          ),
          content: Card(
            elevation: 0.0,
            child: Form(
              key: _formKey,
              child: Column(
                children: <Widget>[
                  //Text('请输入类别名称'),
                  TextFormField(
                    style: TextStyle(
                      fontSize: 17,
                      // color: Colors.black,
                    ),
                    decoration: InputDecoration(
                        labelText: "输入类别名称",
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        // border: OutlineInputBorder(),
                        hintText: "最多输入 ${_maxLength.toString()} 个字",
                        filled: true,
                        fillColor: Colors.grey.shade200),
                    onSaved: (value) {
                      text = value;
                      print('$value');
                    },
                    validator: (String value) {
                      return value.length > 0 ? null : '类别不能为空';
                    },
                  ),
                ],
              ),
            ),
          ),
          actions: [
            CupertinoDialogAction(
                child: Text('确认'),
                onPressed: () {
                  setState(() {
                    var _state = _formKey.currentState;
                    if (_state.validate()) {
                      _state.save();
                      postRequestFunction(text);
                      Navigator.pop(context);
                      // int length = _leftCateList.length;
                      // _leftCateList[length]["userid"] = id;
                      // _leftCateList[length]["category"] = text;
                    }
                  });
                }),
            CupertinoDialogAction(
              child: Text('取消'),
              isDestructiveAction: true,
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void postRequestFunction(String text) async {
    String url = "http://47.110.150.159:8080/insertCategory";

    ///创建Dio
    //Dio dio = new Dio();

    ///创建Map 封装参数
    /* Map<String, dynamic> map = Map();
    map['userid']:"123",
    map['category']:textToSendBack;
*/
    ///发起post请求
    Response response =
        await Dio().post(url, data: {"userid": "$id", "category": "$text"});
    var data = response.data;
    print(data);
    if (data != null) {
      setState(() {
        _getLeftCateData(id);
      });
    }
    // Navigator.pop(context, "$text");
  }

  @override
  Widget build(BuildContext context) {
    ScreenAdapter.init(context);
    var leftWidth = ScreenAdapter.getScreenWidth() / 3;
    var rightItemWidth = (ScreenAdapter.getScreenWidth() - leftWidth + 50) / 1;
    //获取计算后的宽度
    rightItemWidth = ScreenAdapter.width(rightItemWidth);
    //获取计算后的高度
    var rightItemHeight = rightItemWidth + ScreenAdapter.height(75);
    return Scaffold(
        //backgroundColor: Colors.white,
        appBar: AppBar(
            title: Text(
              '目录',
              style: TextStyle(
                  fontSize: 18.0,
                  //fontWeight: FontWeight.w400,
                  color: Colors.black),
            ),
            centerTitle: true,
            backgroundColor: Colors.white,
            actions: <Widget>[
              IconButton(
                icon: Icon(
                  Icons.search,
                  size: 25.0,
                  color: Colors.black,
                ),
                onPressed: () {
                  showSearch(
                      context: context, delegate: SearchCategory(_titleList));
                },
              ),
              IconButton(
                icon: Icon(
                  Icons.add,
                  size: 25.0,
                  color: Colors.black,
                ),
                onPressed: () {
                  _showDialog(context);
                  /*   Navigator.pushNamed(context, '/newcategory').then(
                    (data) => {
                      if (data != null)
                        setState(() {
                          // _leftCateList.add(data);
                          _getLeftCateData(id);
                        }),
                      //print(data)
                    },
                  );*/
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
                  // print("data" + data),
                  // print(_selectIndex)
                });
          },
          tooltip: '添加主题',
          child: Icon(
            Icons.add,
            color: Colors.blue,
          ),
          backgroundColor: Colors.white,
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
