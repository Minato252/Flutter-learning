import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutterfileselector/model/file_util_model.dart';
import 'package:open_file/open_file.dart';
import 'package:flutterfileselector/flutterfileselector.dart';
import 'package:flutterfileselector/model/file_util_model.dart';
import 'package:flutterfileselector/flutterfileselector.dart';

class fileSelect extends StatefulWidget {
  fileSelect({Key key}) : super(key: key);

  @override
  _fileSelectState createState() => _fileSelectState();
}

class _fileSelectState extends State<fileSelect> {
  List<FileModelUtil> v;
  @override
  Widget build(BuildContext context) {
    return Container(
        child: Column(children: <Widget>[
      FlutterSelect(
        /// todo:  标题
        /// todo:  按钮
        btn: Text("选择文档"),

        /// todo:  最大可选
        maxCount: 1,

        /// todo:  开启筛选
        isScreen: true,

        /// todo:  往数组里添加需要的格式
        /// todo:  自定义下拉选项，不传默认

        valueChanged: (v) {
          print(v[0].filePath);
          this.v = v;
          setState(() {});
        },
      ),
      MaterialButton(
        color: Colors.blue,
        onPressed: () {
          OpenFile.open(v[0].filePath);
        },
        child: Text("打开文件：  ${v != null ? v[0].fileName : ''}"),
      ),
    ]));
  }
}
