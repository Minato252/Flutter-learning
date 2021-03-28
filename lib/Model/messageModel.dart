import 'dart:convert';

//消息modle
//共有四个属性
class MessageModel {
  String content; //整个发送到融云的内容
  String title; //标题
  String keyWord; //关键词
  String htmlCode; //内容代码
  DateTime time;
  String fromuserid;
  bool isJson = true;

  String hadLook;
  String messageId = "";

  bool modify = true;

  MessageModel(
      {String htmlCode,
      String title,
      String keyWord,
      String hadLook,
      DateTime dateTime})
      : htmlCode = htmlCode,
        title = title,
        hadLook = hadLook,
        keyWord = keyWord,
        time = dateTime;

  MessageModel.fromJson(Map<String, dynamic> json) {
    //通过Map转换
    title = json['title'];
    keyWord = json['keyWord'];
    htmlCode = json['htmlCode'];
    hadLook = json['hadLook'];
    messageId = json['messageId'];
    content = jsonEncode(json);
  }

  Map<String, dynamic> toJson() {
    //转换成map
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['title'] = this.title;
    data['keyWord'] = this.keyWord;
    data['htmlCode'] = this.htmlCode;
    data['hadLook'] = this.hadLook;
    data['messageId'] = this.messageId;
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
      hadLook = json['hadLook'];
      messageId = json['messageId'];
    } catch (e) {
      isJson = false;
    }
  }

  MessageModel.formServerJsonString(Map json) {
    //处理服务器发来的json，把他转换为messageModel
//     {
//     "mId": 29,
//     "mTitle": "ok",
//     "mKeywords": "im",
//     "mPostmessages": "Hello Word",
//     "mStatus": "0",
//     "mTime": "2021-01-22 00:00:00.000000",
//     "mFromuserid": "188777777",
//     "mTouserid": "173XXXXXX"
//     "hadLook": ""
// }

    try {
      // Map json = jsonDecode(s);
      title = json['mTitle'];
      keyWord = json['mKeywords'];
      htmlCode = json['mPostmessages'];
      hadLook = json['mHadLook'];
      time = strToTime(json["mTime"]);
      fromuserid = json["mFromuserid"];
      // messageId = json['messageId'];
      messageId = json['mMesId'];
      // content = jsonEncode(json);
    } catch (e) {
      isJson = false;
    }
  }

  DateTime strToTime(String str) {
// "2021-01-30 22:03:31"
    List ymAndTim = str.split(" ");
    List ym = ymAndTim[0].split('-');
    List time = ymAndTim[1].split(":");
    int year = int.parse(ym[0]);
    int month = int.parse(ym[1]);
    int day = int.parse(ym[2]);

    int hour = int.parse(time[0]);
    int minute = int.parse(time[1]);
    int second = int.parse(time[2]);

    DateTime datetime = DateTime(year, month, day, hour, minute, second);

    print(datetime);
    return datetime;
  }
}
