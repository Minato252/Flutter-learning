import 'dart:io';
import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:rich_edit/rich_edit.dart';
import 'package:video_player/video_player.dart';
import 'uploadFile.dart';

class SimpleRichEditController extends RichEditController {
  Map<String, ChewieController> controllers = Map();
  String imgurl;
  String videourl;
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
      }
      return RichEditData(RichEditDataType.TEXT, e);
    }).toList();
    super.data = data;
  }

  void setDataFromList(List<RichEditData> data) {
    super.data = data;
  }

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
    // sb.write(element.data);
    sb.write("${element.data}"
        .replaceAll("\r\n", "<\/span><\/p>")
        .replaceAll("\n", "<p><span style=\"font-size:15px;\">"));
    sb.write("<\/span>");
    sb.write("<\/p>");
  }

  Future<void> generateImageHtmlUrl(
      StringBuffer sb, RichEditData element) async {
    // String url = await UploadFile.fileUplod(element.data);
    //imgurl = await UploadFile.fileUplod(element.data);

    sb.write("<p>");
    //sb.write("<image style=\"width:${element.imgWith}px\" src=\"");
    sb.write("<image style=\"padding: 10px;max-width: 90%;\" src=\"");

    // sb.write(url);
    sb.write(element.data);
    sb.write("\"/>");
    sb.write("<\/p>");
  }

  Future<void> generateVideoHtmlUrl(
      StringBuffer sb, RichEditData element) async {
    String path = element.data;
    String suffix = path.substring(0, path.lastIndexOf(".") + 1);
    int num = new DateTime.now().millisecondsSinceEpoch;
    String name = suffix + 'mp4';
    print("fileName: " + name);
    // String url = await UploadFile.fileUplod(element.data, fileName: name);
    //videourl = await UploadFile.fileUplod(element.data, fileName: name);
    sb.write("<p>");
    sb.write('''
           <video src="${element.data}" playsinline="true" webkit-playsinline="true" x-webkit-airplay="allow" airplay="allow" x5-video-player-type="h5" x5-video-player-fullscreen="true" x5-video-orientation="portrait" controls="controls"  style="width: 100%;height: 300px;"></video>
           ''');
    //videourl
    // sb.write("<\/p>");

    //sb.write('''
    //  <video style="width:300px;height:150px" controls> <source src="${url}"></video>
    //  ''');
    sb.write("<\/p>");
  }

//添加视频方法
  @override
  Future<String> addVideo() async {
    PickedFile pickedFile =
        await ImagePicker().getVideo(source: ImageSource.gallery);
    if (pickedFile != null) {
      //模拟上传后返回的路径
      var path = pickedFile.path;
      String suffix = path.substring(0, path.lastIndexOf(".") + 1);
      String name = suffix + 'mp4';
      videourl = await UploadFile.fileUplod(pickedFile.path, fileName: name);
      return videourl;
    }
    return null;
  }

  //添加图片方法
  @override
  Future addImage() async {
    PickedFile pickedFile =
        await ImagePicker().getImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      imgurl = await UploadFile.fileUplod(pickedFile.path);
      //return pickedFile.path;
      return imgurl;
    }
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
        looping: false,
        showControls: true,
        // 占位图
        placeholder: new Container(
          color: Colors.grey,
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
  Widget generateImageView(RichEditData data) =>
      //Image.file(File(data.data),
      Image.network(data.data, height: 200, width: 300);
  //width: data.imgWith,
  //  );

//重写html函数

}

/*class SimpleRichEditController extends RichEditController {
  Map<String, ChewieController> controllers = Map();

  //添加视频方法
  @override
  Future<String> addVideo() async {
    PickedFile pickedFile =
        await ImagePicker().getVideo(source: ImageSource.gallery);
    if (pickedFile != null) {
      //模拟上传后返回的路径
      var path = pickedFile.path;

      return path;
    }
    return null;
  }

  //添加图片方法
  @override
  Future addImage() async {
    PickedFile pickedFile =
        await ImagePicker().getImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      return pickedFile.path;
    }
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
        looping: false,
        showControls: true,

        // 占位图
        placeholder: new Container(
          color: Colors.grey,
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
  Widget generateImageView(RichEditData data) => Image.file(
        File(data.data),
        width: data.imgWith,
      );

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
    sb.write(element.data);
    sb.write("<\/span>");
    sb.write("<\/p>");
  }

  Future<void> generateImageHtmlUrl(
      StringBuffer sb, RichEditData element) async {
    String url = await UploadFile.fileUplod(element.data);

    sb.write("<div style=\"text-align: center;\">");
    sb.write("<image style=\"width:${element.imgWith}px\" src=\"");

    sb.write(url);
    sb.write("\"/>");
    sb.write("<\/div>");
  }

  Future<void> generateVideoHtmlUrl(
      StringBuffer sb, RichEditData element) async {
    String path = element.data;
    String suffix = path.substring(0, path.lastIndexOf(".") + 1);
    int num = new DateTime.now().millisecondsSinceEpoch;
    String name = suffix + 'mp4';
    print("fileName: " + name);
    String url = await UploadFile.fileUplod(element.data, fileName: name);

    sb.write("<p>");
    // sb.write('''
    //       <video src="${url}" playsinline="true" webkit-playsinline="true" x-webkit-airplay="allow" airplay="allow" x5-video-player-type="h5" x5-video-player-fullscreen="true" x5-video-orientation="portrait" controls="controls"  style="width: 100%;height: 300px;"></video>
    //       ''');
    // sb.write("<\/p>");

    sb.write('''
          <video style="width:300px;height:150px" controls> <source src="${url}"></video>
          ''');
    sb.write("<\/p>");
  }
}*/
