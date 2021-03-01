import 'dart:io';
import 'package:chewie/chewie.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:rich_edit/rich_edit.dart';
import 'package:video_player/video_player.dart';
import '../../main.dart';
import 'uploadFile.dart';
import 'package:weitong/pages/imageEditor/image_shower_demo.dart';
//import 'package:flutter_sound/flutter_sound.dart';
//import 'package:uuid/uuid.dart';

class SimpleRichEditController extends RichEditController {
  Map<String, ChewieController> controllers = Map();

  // String imgurl;
  //String videourl;
  //将数据写入
  void setData(String value) {
    String _value = value.replaceAll(' ', '');
    String result = _value
        .replaceAll(']', '')
        .replaceAll('[', '')
        .replaceAll(',,', ',')
        .replaceAll('"', '');
    print('解析数据::$result');
    List insertText = result.split(',');
    List<RichEditData> data = insertText.map((e) {
      String _e = e;
      bool _isHttp = _e.startsWith('http');
      if (_isHttp && (_e.contains('jpg') || _e.contains('png'))) {
        return RichEditData(RichEditDataType.IMAGE, _e.replaceAll(';', ''));
      } else if (_isHttp && _e.contains('mp4')) {
        return RichEditData(RichEditDataType.VIDEO, _e);
      } else if (_isHttp && _e.contains('mp3')) {
        return RichEditData(RichEditDataType.VOICE, _e);
      } else if (_isHttp && _e.contains('m4a')) {
        //ios系统
        return RichEditData(RichEditDataType.VOICE, _e);
      } else {
        return RichEditData(RichEditDataType.TEXT, e);
      }
    }).toList();
    int index = data.length;
    data.insert(index, RichEditData(RichEditDataType.TEXT, ""));
    super.data = data;
  }

  void setDataFromList(List<RichEditData> data) {
    super.data = data;
  }

  //添加视频方法
  @override
  Future<String> addVideo() async {
    String oldPath = await showVidDialog();
    if (oldPath != null && oldPath != "") {
      return oldPath;
    }
  }

  //添加图片方法
  @override
  Future addImage() async {
    String oldPath = await showImgDialog();
    if (oldPath != null && oldPath != "") {
      String path =
          await Navigator.of(navigatorKey.currentState.overlay.context).push(
              MaterialPageRoute(
                  builder: (context) => new ImageShowerDemo(oldPath)));
      return path;
    }
    return;
  }

  //生成视频view方法
  @override
  Widget generateVideoView(RichEditData data) {
    if (!controllers.containsKey(data.data)) {
      var controller = ChewieController(
        videoPlayerController: VideoPlayerController.network(data.data),
        autoPlay: false,
        autoInitialize: true,
        aspectRatio: 16 / 9,

        //aspectRatio: 3 / 2,
        //looping: false,

        showControls: true,

        // 占位图
        placeholder: new Container(

            //color: Colors.grey,
            // color: Colors.black,
            ),
      );
      controllers[data.data] = controller;
    }
    var video = Chewie(
      controller: controllers[data.data],
    );
    return video;
  }

  @override
  Widget generateImageView(RichEditData data) {
    var image;
    if (data.data.startsWith('http')) {
      image = Image.network(data.data);
    } else {
      image = Image.file(File(data.data));
    }
    return image;
  }

//重写html函数

  Future<String> generateHtmlUrl() async {
    StringBuffer sb = StringBuffer();
    List<RichEditData> _data = getDataList();
    for (int i = 0; i < _data.length; i++) {
      RichEditData element = _data[i];
      switch (element.type) {
        case RichEditDataType.TEXT:
          generateTextHtml(sb, element);
          break;
        case RichEditDataType.IMAGE:
          await generateImageHtmlUrl(sb, element);
          break;
        case RichEditDataType.VIDEO:
          await generateVideoHtmlUrl(sb, element);
          break;
        case RichEditDataType.VOICE:
          await generateVoiceHtmlUrl(sb, element);
          break;
      }
    }

    print("html" + sb.toString());
    return sb.toString();
  }

  // void generateTextHtml(StringBuffer sb, RichEditData element) {
  //   sb.write("<p>");
  //   sb.write("<span style=\"font-size:30px;\">");
  //   sb.write(element.data);
  //   sb.write("<\/span>");
  //   sb.write("<\/p>");
  // }

  void generateTextHtml(StringBuffer sb, RichEditData element) {
    sb.write("<p>");
    sb.write("<span style=\"font-size:15px;\">");
    //sb.write(element.data);
    sb.write("${element.data}"
        .replaceAll("\r\n", "<\/span><\/p>")
        .replaceAll("\n", "<p><span style=\"font-size:15px;\">"));
    sb.write("<\/span>");
    // sb.write("<\/span>");
    sb.write("<\/p>");
  }

  Future<void> generateImageHtmlUrl(
      StringBuffer sb, RichEditData element) async {
    String url;
    if (element.data.startsWith('http')) {
      url = element.data;
    } else {
      url = await UploadFile.fileUplod(element.data);
    }
    sb.write("<div style=\"text-align: center;\">");
    sb.write("<image style=\"width:${element.imgWith}px\" src=\"");

    sb.write(url);
    sb.write("\"/>");
    sb.write("<\/div>");
  }

  Future<void> generateVideoHtmlUrl(
      StringBuffer sb, RichEditData element) async {
    String url;
    if (element.data.startsWith('http')) {
      url = element.data;
    } else {
      String path = element.data;
      String suffix = path.substring(0, path.lastIndexOf(".") + 1);
      int num = new DateTime.now().millisecondsSinceEpoch;
      String name = suffix + 'mp4';
      print("fileName: " + name);
      url = await UploadFile.fileUplod(element.data, fileName: name);
    }
    sb.write("<p>");
    sb.write('''
           <video src="${url}" playsinline="true" webkit-playsinline="true" x-webkit-airplay="allow" airplay="allow" x5-video-player-type="h5" x5-video-player-fullscreen="true" x5-video-orientation="portrait" controls="controls"  style="width: 100%;height: 300px;"></video>
           ''');
    sb.write("<\/p>");

    // sb.write('''
    //   <video style="width:300px;height:150px" controls> <source src="${url}"></video>
    //      ''');
    // sb.write("<\/p>");
  }

  Future<void> generateVoiceHtmlUrl(
      StringBuffer sb, RichEditData element) async {
    //String path = element.data;
    String path;
    if (element.data.startsWith('http')) {
      path = element.data;
    } else {
      path = await UploadFile.fileUplod(element.data);
    }
    sb.write("<p>");
    sb.write('''<audio controls="true" src="$path"></audio>''');
    //上传服务器

    sb.write("<\/p>");
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

  Future<String> showVidDialog() async {
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
                          imgPath = await _getVideoFromCamera();

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
                              '录制',
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
                          imgPath = await _getVideoFromGallery();

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

  Future _getVideoFromCamera() async {
    PickedFile image = await ImagePicker().getVideo(source: ImageSource.camera);
    if (image != null) {
      return image.path;
    }
  }

  //相册选择
  Future<String> _getVideoFromGallery() async {
    PickedFile image =
        await ImagePicker().getVideo(source: ImageSource.gallery);
    if (image != null) {
      return image.path;
    }
  }
}
