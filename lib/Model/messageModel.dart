import 'dart:convert';

//消息modle
//共有四个属性
class MessageModel {
  String content; //整个发送到融云的内容
  String title; //标题
  String keyWord; //关键词
  String htmlCode; //内容代码
  bool isJson = true;

  MessageModel({String htmlCode, String title, String keyWord})
      : htmlCode = htmlCode,
        title = title,
        keyWord = keyWord;

  MessageModel.fromJson(Map<String, dynamic> json) {
    //通过Map转换
    title = json['title'];
    keyWord = json['keyWord'];
    htmlCode = json['htmlCode'];
    content = jsonEncode(json);
  }

  Map<String, dynamic> toJson() {
    //转换成map
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['title'] = this.title;
    data['keyWord'] = this.keyWord;
    data['htmlCode'] = this.htmlCode;
    return data;
  }

  String toJsonString() {
    //转换成json字符串
    Map<String, dynamic> m = toJson();
    return jsonEncode(m);
  }

  MessageModel.fromJsonString(String s) {
    //通过json字符串转换
    try {
      Map json = jsonDecode(s);
      content = s;
      title = json['title'];
      keyWord = json['keyWord'];
      htmlCode = json['htmlCode'];
    } catch (e) {
      isJson = false;
    }
  }
}
