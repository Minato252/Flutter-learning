class MessageHistoryModel {
  String userId;
  String targetId;
  String keyWords;
  String title;
  String htmlCode;
  int sendTime;
  // MessageHistoryModel(
  //     this.htmlCode, this.targetId, this.keyWords, this.title, this.userId);

  Map<String, dynamic> toMap() {
    var map = new Map<String, dynamic>();
    map['userId'] = userId;
    map['targetId'] = targetId;
    map['keyWords'] = keyWords;
    map['title'] = title;
    map['htmlCode'] = htmlCode;
    map['sendTime'] = sendTime;
    return map;
  }

  static MessageHistoryModel fromMap(Map<String, dynamic> map) {
    MessageHistoryModel message = new MessageHistoryModel();
    message.htmlCode = map['htmlCode'];
    message.keyWords = map['keyWords'];
    message.targetId = map['targetId'];
    message.userId = map['userId'];
    message.title = map['title'];
    message.sendTime = map['sendTime'];
    return message;
  }

  static List<MessageHistoryModel> fromMapList(dynamic mapList) {
    List<MessageHistoryModel> list = new List(mapList.length);
    for (int i = 0; i < mapList.length; i++) {
      list[i] = fromMap(mapList[i]);
    }
    return list;
  }
}
