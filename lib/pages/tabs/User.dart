//https://material.io/tools/icons/?icon=favorite&style=baseline

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:rongcloud_im_plugin/rongcloud_im_plugin.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:weitong/pages/imageEditor/image_shower_demo.dart';
import 'package:weitong/pages/tabs/uploadFile.dart';
import 'package:weitong/services/providerServices.dart';
import 'package:weitong/widget/JdButton.dart';
import 'package:weitong/widget/loading.dart';
import '../../main.dart';
import '../../services/ScreenAdapter.dart';
import '../Login.dart';
import 'Tabs.dart';

class UserPage extends StatefulWidget {
  UserPage({Key key}) : super(key: key);

  @override
  _UserPageState createState() => _UserPageState();
}

class _UserPageState extends State<UserPage> {
  @override
  String id;
  String photoUrl = "";

  bool isLoadFinshed = false;

  void initState() {
    super.initState();
    // 1.初始化 im SDK
    _getUserInfo();
    _getPortrait();
  }

  @override
  Widget build(BuildContext context) {
    ScreenAdapter.init(context);
    return Scaffold(
        appBar: AppBar(
          title: Text("我的"),
        ),
        body: ListView(
          children: [
            Container(
              height: ScreenAdapter.height(220),
              width: double.infinity,
              decoration: BoxDecoration(
                  image: DecorationImage(
                      image: AssetImage('images/user_bg.jpg'),
                      fit: BoxFit.cover)),
              child: Row(
                children: [
                  Container(
                    margin: EdgeInsets.fromLTRB(10, 0, 10, 0),
                    child: ClipOval(
                        child: InkWell(
                      child: Image.network(
                        photoUrl,
                        fit: BoxFit.cover,
                        width: ScreenAdapter.width(100),
                        height: ScreenAdapter.width(100),
                      ),
                      onTap: () async {
                        String url = await addImage();
                        setState(() {
                          photoUrl = url;
                        });
                      },
                    )),
                  ),
                  Expanded(
                      flex: 1,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("用户名：${id}",
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: ScreenAdapter.size(32))),
                          Text("普通员工",
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: ScreenAdapter.size(24))),
                        ],
                      ))
                ],
              ),
            ),
            ListTile(
              leading: Icon(Icons.history),
              title: Text("记录"),
            ),
            ListTile(
                leading: Icon(Icons.settings),
                title: Text("我的资料"),
                onTap: () {
                  Navigator.of(context).pushNamed('/category');
                }),
            ListTile(
                leading: Icon(Icons.settings),
                title: Text("设置"),
                onTap: () {
                  Navigator.of(context).pushNamed('/setting');
                }),
            JdButton(
              text: "退出登录",
              cb: () {
                _logout();
              },
            )
          ],
        )
        // : MyLoading(
        //     loading: true,
        //     msg: '正在加载...',
        //     child: Center(
        //       child: RaisedButton(
        //         onPressed: () {},
        //         child: Text('显示加载动画'),
        //       ),
        //     ),
        //   )
        );
  }

  void _logout() async {
    RongIMClient.disconnect(false);

    cleanToken();
    saveKeyWords();
    Navigator.of(context).pushAndRemoveUntil(
        new MaterialPageRoute(builder: (context) => new LoginPage()),
        (route) => route == null);
  }

  void _getPortrait() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    this.id = prefs.get("id");
    var rel = await Dio()
        .post("http://47.110.150.159:8080/record/selectrecord?id=" + this.id);
    setState(() {
      this.photoUrl = rel.data["portrait"].toString();
      isLoadFinshed = true;
    });
  }

  Future<void> cleanToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString("token", null);
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

  Future<void> saveKeyWords() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final ps = Provider.of<ProviderServices>(context);
    List<String> tags = ps.keyWords;
    prefs.setString("keyWords", listToString(tags));
  }

  _getUserInfo() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    this.id = prefs.get("id");
    setState(() {
      id;
    });
  }

  Future<String> addImage() async {
    String oldPath = await showImgDialog();
    print(oldPath);
    String url;
    if (oldPath != null && oldPath != "") {
      String path =
          await Navigator.of(navigatorKey.currentState.overlay.context).push(
              MaterialPageRoute(
                  builder: (context) => new ImageShowerDemo(oldPath)));
      // return path;
      url = await UploadFile.fileUplod(path);
      var r = await Dio().post("http://47.110.150.159:8080/record/updatarecord",
          data: {"id": this.id, "portrait": url});
      return url;
    }
    url = await UploadFile.fileUplod(oldPath);
    var r = await Dio().post("http://47.110.150.159:8080/record/updatarecord",
        data: {"id": this.id, "portrait": url});

    return url;
  }

  Future<String> showImgDialog() async {
    String imgPath = null;
    await showModalBottomSheet(
        context: navigatorKey.currentState.overlay.context,
        backgroundColor: Colors.transparent,
        builder: (BuildContext context) {
          return Container(
            height: 171,
            margin: EdgeInsets.only(left: 15, right: 15), //控制底部的距离
            child: Column(
              children: <Widget>[
                Container(
                  height: 101,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  child: Column(
                    children: <Widget>[
                      InkWell(
                        onTap: () async {
                          imgPath = await _getImageFromCamera();

                          Navigator.pop(context);
                          // Navigator.pop(context, imgPath);
                          //   switch (type) {
                          //     case 0:
                          //       notifyImg = imgPath;
                          //       break;
                          //     case 1:
                          //       emergencyImg = imgPath;
                          //       break;
                          //     case 2:
                          //       promiseImg = imgPath;
                          //       break;
                          //   }
                          //   setState(() {});
                        },
                        child: Container(
                          height: 50,
                          child: Center(
                            child: Text(
                              '拍照',
                              style: TextStyle(
//                                fontSize: Config.fontSize17,
                                  letterSpacing: 2.0,
                                  fontWeight: FontWeight.w200),
                            ),
                          ),
                        ),
                      ),
                      Divider(
                        height: 1,
                        color: Colors.grey,
                      ),
                      InkWell(
                        onTap: () async {
                          imgPath = await _getImageFromGallery();

                          Navigator.pop(context);

                          // switch (type) {
                          //   case 0:
                          //     notifyImg = imgPath;
                          //     break;
                          //   case 1:
                          //     emergencyImg = imgPath;
                          //     break;
                          //   case 2:
                          //     promiseImg = imgPath;
                          //     break;
                          // }
                          // setState(() {});
                        },
                        child: Container(
                          height: 50,
                          child: Center(
                            child: Text(
                              '本地相册',
                              style: TextStyle(
//                                fontSize: Config.fontSize17,
                                  letterSpacing: 2.0,
                                  fontWeight: FontWeight.w200),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                InkWell(
                  onTap: () {
                    // NavigatorUtils.goBack(context);

                    Navigator.pop(context);
                    // return null;
                  },
                  child: Container(
                    margin: EdgeInsets.only(
                      top: 10,
                      bottom: 10,
                    ),
                    height: 50,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    child: Center(
                      child: Text(
                        '取消',
                        style: TextStyle(
                            color: Colors.red,
//                          fontSize: Config.fontSize17,
                            fontWeight: FontWeight.w200),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        });
    return imgPath;
  }

  Future _getImageFromCamera() async {
    PickedFile image =
        await ImagePicker().getImage(source: ImageSource.camera, maxWidth: 400);
    if (image != null) {
      return image.path;
    }
  }

  //相册选择
  Future<String> _getImageFromGallery() async {
    PickedFile image =
        await ImagePicker().getImage(source: ImageSource.gallery);
    if (image != null) {
      return image.path;
    }
  }
}
