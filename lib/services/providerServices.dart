import 'package:flutter/material.dart';
import 'package:rongcloud_im_plugin/rongcloud_im_plugin.dart';
import 'package:weitong/widget/mylocally.dart';

class ProviderServices with ChangeNotifier {
  String _tree;
  String get tree => _tree;
  void upDataTree(String tree) {
    _tree = tree;
    notifyListeners();
  }

  List<String> _keyWords;
  List<String> get keyWords => _keyWords;
  void upDataKeyWords(List<String> keyWords) {
    _keyWords = keyWords;
    notifyListeners();
  }

  Map _userInfo;
  Map get userInfo => _userInfo;
  void upDatauserInfo(Map userInfo) {
    _userInfo = userInfo;
    notifyListeners();
  }

  // MyLocally _locally;
  // MyLocally get locally => _locally;
  // void upDatalocally(MyLocally locally) {
  //   _locally = locally;
  //   notifyListeners();
  // }

  // bool _isActive; //是否在前台
  // bool get isActive => _isActive;
  // void upDataisActive(bool isActive) {
  //   _isActive = isActive;
  //   notifyListeners();
  // }
}
