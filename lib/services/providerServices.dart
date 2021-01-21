import 'package:flutter/material.dart';
import 'package:rongcloud_im_plugin/rongcloud_im_plugin.dart';

class ProviderServices with ChangeNotifier {
  String _tree;
  String get tree => _tree;
  void upDataTree(String tree) {
    _tree = tree;
    notifyListeners();
  }
}
