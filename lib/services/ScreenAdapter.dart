import 'package:flutter/cupertino.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ScreenAdapter {
  static init(context) {
    ScreenUtil.init(
        BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width,
            maxHeight: MediaQuery.of(context).size.height),
        designSize: Size(750, 1334),
        orientation: Orientation.portrait);
    // ScreenUtil.init(context, width: 750, height: 1334);
  }

  static height(double value) {
    return ScreenUtil().setHeight(value);
  }

  static width(double value) {
    return ScreenUtil().setWidth(value);
  }

//更新版本之后没有screenHeightDp了，screenHeight就返回dp，下面的都返回dp
  static getScreenHeight() {
    // return ScreenUtil.screenHeightDp;
    return ScreenUtil().screenHeight;
  }

  static getScreenWidth() {
    // return ScreenUtil.screenWidthDp;
    return ScreenUtil().screenWidth;
  }

  static getScreenPxHeight() {
    return ScreenUtil().screenHeight;
  }

  static getScreenPxWidth() {
    return ScreenUtil().screenWidth;
  }

  static size(double value) {
    return ScreenUtil().setSp(value);
  }

  // ScreenUtil.screenHeight
}

// ScreenAdaper
