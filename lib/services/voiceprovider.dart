import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_sound/flutter_sound.dart';
//import 'package:react/react.dart';
import 'package:uuid/uuid.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:flutter_sound/flauto.dart';

class VoiceRecordProvider with ChangeNotifier {
  bool ifTap;
  FlutterSound flutterSound;
  //String appDocPath;
  String filePath;
  int recordStatus;
  DateTime start;
  String fileName;
  DateTime end;
  String uploadPath;
  String appDocPath;
  //WebSocketChannel channel;
  String convertText = "";

  bool speaked = false;

  bool ifVoiceRecord;
  @override
  void dispose() {
    if (flutterSound != null && flutterSound.isRecording) {
      flutterSound.stopRecorder();
    }
    super.dispose();
  }

  VoiceRecordProvider() {
    flutterSound = FlutterSound();
    ifTap = false;
    getAppDocPath();
  }
  getAppDocPath() async {
    var folder = await getApplicationDocumentsDirectory();
    appDocPath = folder.path;
    notifyListeners();
  }

//录音开始
  Future<String> beginRecord() async {
    ifTap = true;
    //recordStatus = RECORDSTATUS.START;
    fileName = Uuid().v4().toString();
    String fileType = '';
    if (Platform.isIOS) {
      fileType = '.m4a';
    } else {
      fileType = '.mp3';
    }
    //fileType = '.mp3';
    //filePath = fileName + fileType;
    Directory appDocDir = await getApplicationDocumentsDirectory();
    String appDocPath = appDocDir.path;
    filePath = p.join(appDocPath, fileName + fileType);

    print(filePath);
    //flutterSound.startRecorder(filePath);

    Future<String> result = flutterSound.startRecorder(
      uri: filePath,
      codec: t_CODEC.CODEC_AAC,
    );
    print(result);
    result.then((path) {
      print('startRecorder: $path');
      //uploadPath = path.replaceAll("file://", ""); //filepath 只是最后一层，不包括文件夹目录
    });
    notifyListeners();
    return result;
  }
  //录音结束

  stopRecord({bool ifBreak = false}) async {
    ifTap = false;
    /*if (ifBreak) {
      recordStatus = RECORDSTATUS.BREAK;
    } else {
      recordStatus = RECORDSTATUS.END;
    }
*/
    if (flutterSound.isRecording) {
      await flutterSound.stopRecorder();
    }
    notifyListeners();
  }

//异常结束，删除文件
  cancelRecord() async {
    ifTap = false;
    if (flutterSound.isRecording) {
      await flutterSound.stopRecorder();
    }
    //recordStatus = RECORDSTATUS.CANCEL;
    if (File(filePath).existsSync()) {
      File(filePath).delete();
    }
    notifyListeners();
  }

  playVoice(filePath) async {
    bool ifPlaying = flutterSound.isPlaying;

    if (ifPlaying) {
      await flutterSound.stopPlayer();
    } else {
      await flutterSound.startPlayer(filePath);
    }
  }
}
