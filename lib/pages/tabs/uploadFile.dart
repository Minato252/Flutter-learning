import 'dart:io';

import 'dart:convert' as convert;
import 'package:dio/dio.dart';

class UploadFile {
  ///上传的服务器地址
  static String netUploadUrl = "http://47.110.150.159:8080/upload";

  ///dio 实现文件上传
  static Future<String> fileUplod(String localPath, {String fileName}) async {
    ///创建Dio
    ///
    List l = localPath.split("/");
    if (fileName == null) {
      fileName = l[l.length - 1];
    } else {
      fileName = fileName.split("/")[l.length - 1];
    }
    BaseOptions option = new BaseOptions(
        //     // baseUrl: API_PREFIX,
        //     // connectTimeout: CONNECT_TIMEOUT,
        //     // receiveTimeout: RECEIVE_TIMEOUT,
        //     // headers: params,
        //     contentType: 'multipart/form-data',
        responseType: ResponseType.plain);
    // Dio dio = new Dio(option);
    Dio dio = new Dio(option);
    Map<String, dynamic> map = Map();
    print("fileName3: " + fileName);
    map["fileName"] =
        await MultipartFile.fromFile(localPath, filename: fileName);

    ///通过FormData
    FormData formData = FormData.fromMap(map);

    ///发送post
    Response response = await dio.post(
      netUploadUrl, data: formData,

      ///这里是发送请求回调函数
      ///[progress] 当前的进度
      ///[total] 总进度
      onSendProgress: (int progress, int total) {
        print("当前进度是 $progress 总进度是 $total");
      },
    );

    ///服务器响应结果
    print("url：" + response.data.toString());
    return response.data.toString();
  }
}
