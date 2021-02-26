import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'package:oktoast/oktoast.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:url_launcher/url_launcher.dart';

import 'common_widget.dart';
import 'crop_editor_helper.dart';
import 'editor/extended_image_editor.dart';
import 'editor/extended_image_editor_utils.dart';
import 'extended_image.dart';
import 'extended_image_utils.dart';
import 'gesture/extended_image_gesture.dart';
import 'gesture/extended_image_gesture_utils.dart';
import 'image_editor_demo.dart';

///
///  create by zmtzawqlp on 2019/8/22
///

class ImageShowerDemo extends StatefulWidget {
  @override
  String path;
  ImageShowerDemo(this.path);
  _ImageShowerDemoState createState() => _ImageShowerDemoState(path);
}

class _ImageShowerDemoState extends State<ImageShowerDemo> {
  final GlobalKey<ExtendedImageEditorState> editorKey =
      GlobalKey<ExtendedImageEditorState>();
  final GlobalKey<ExtendedImageGestureState> gestureKey =
      GlobalKey<ExtendedImageGestureState>();
  final GlobalKey<PopupMenuButtonState<ExtendedImageCropLayerCornerPainter>>
      popupMenuKey =
      GlobalKey<PopupMenuButtonState<ExtendedImageCropLayerCornerPainter>>();
  final List<AspectRatioItem> _aspectRatios = <AspectRatioItem>[
    AspectRatioItem(text: 'custom', value: CropAspectRatios.custom),
    AspectRatioItem(text: 'original', value: CropAspectRatios.original),
    AspectRatioItem(text: '1*1', value: CropAspectRatios.ratio1_1),
    AspectRatioItem(text: '4*3', value: CropAspectRatios.ratio4_3),
    AspectRatioItem(text: '3*4', value: CropAspectRatios.ratio3_4),
    AspectRatioItem(text: '16*9', value: CropAspectRatios.ratio16_9),
    AspectRatioItem(text: '9*16', value: CropAspectRatios.ratio9_16)
  ];
  AspectRatioItem _aspectRatio;
  bool _cropping = false;

  ExtendedImageCropLayerCornerPainter _cornerPainter;
  Uint8List _memoryImage;
  String path;
  bool isEdited = false;
  _ImageShowerDemoState(this.path);

  @override
  void initState() {
    _aspectRatio = _aspectRatios.first;
    _cornerPainter = const ExtendedImageCropLayerPainterNinetyDegreesCorner();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    this._memoryImage = File(this.path).readAsBytesSync();
    return Material(
      child: Column(
        children: <Widget>[
          // AppBar(
          //   title: const Text('zoom/pan image demo'),
          //   actions: <Widget>[
          //     IconButton(
          //       icon: const Icon(Icons.restore),
          //       onPressed: () {
          //         gestureKey.currentState.reset();
          //         //you can also change zoom manual
          //         //gestureKey.currentState.gestureDetails=GestureDetails();
          //       },
          //     )
          //   ],
          // ),
          AppBar(
            title: const Text('图片'),
            actions: <Widget>[
              FlatButton(
                child: Text("替换", style: TextStyle(color: Colors.white)),
                onPressed: _getImage,
              ),
              FlatButton(
                child: Text(
                  "编辑",
                  style: TextStyle(color: Colors.white),
                ),
                onPressed: () async {
                  this.isEdited = true;
                  print("之前的path" + this.path);
                  String url = await Navigator.of(context).push(
                      MaterialPageRoute(
                          builder: (BuildContext context) =>
                              new ImageEditorDemo(_memoryImage)));

                  setState(() {
                    this.path = url;
                  });
                  print("现在的" + this.path);
                },
              ),
              IconButton(
                icon: const Icon(Icons.done),
                onPressed: () async {
                  if (kIsWeb) {
                    _cropImage(false);
                  } else {
                    // _showCropDialog(context);

                    Navigator.pop(context, path);
                  }
                },
              ),
            ],
          ),
          // Expanded(
          //   child: ExtendedImage.network(
          //     "http://47.110.150.159:8080/picture/20210226/a12cea393aa441d485e6e0a6b80e7181.jpg",
          //     fit: BoxFit.contain,
          //     mode: ExtendedImageMode.gesture,
          //     extendedImageGestureKey: gestureKey,
          //     initGestureConfigHandler: (ExtendedImageState state) {
          //       return GestureConfig(
          //         minScale: 0.9,
          //         animationMinScale: 0.7,
          //         maxScale: 4.0,
          //         animationMaxScale: 4.5,
          //         speed: 1.0,
          //         inertialSpeed: 100.0,
          //         initialScale: 1.0,
          //         inPageView: false,
          //         initialAlignment: InitialAlignment.center,
          //         gestureDetailsIsChanged: (GestureDetails details) {
          //           //print(details.totalScale);
          //         },
          //       );
          //     },
          //   ),
          // ),
          Expanded(
            child: Image.memory(
              _memoryImage,
              fit: BoxFit.contain,
            ),
          ),
        ],
      ),
    );

    // Material(
    //   child: Column(
    //     children: [
    //       AppBar(
    //         title: const Text('图片'),
    //         actions: <Widget>[
    //           IconButton(
    //             icon: const Icon(Icons.photo_library),
    //             onPressed: _getImage,
    //           ),
    //           IconButton(
    //             icon: const Icon(Icons.done),
    //             onPressed: () async {
    //               if (kIsWeb) {
    //                 _cropImage(false);
    //               } else {
    //                 // _showCropDialog(context);

    //                 Navigator.pop(context, path);
    //               }
    //             },
    //           ),
    //           FlatButton(
    //             child: Text(
    //               "编辑",
    //               style: TextStyle(color: Colors.white),
    //             ),
    //             onPressed: () async {
    //               this.isEdited = true;
    //               print("之前的path" + this.path);
    //               String url = await Navigator.of(context).push(
    //                   MaterialPageRoute(
    //                       builder: (BuildContext context) =>
    //                           new ImageEditorDemo(_memoryImage)));

    //               setState(() {
    //                 this.path = url;
    //               });
    //               print("现在的" + this.path);
    //             },
    //           ),
    //         ],
    //       ),
    //       Column(
    //           crossAxisAlignment: CrossAxisAlignment.center,
    //           children: <Widget>[
    //             Expanded(
    //                 child: Container(
    //               decoration: BoxDecoration(color: Colors.green),
    //               child:
    //                   // Image.memory(
    //                   //   _memoryImage,
    //                   //   fit: BoxFit.contain,
    //                   // ),
    //                   ExtendedImage.network(
    //                 "http://47.110.150.159:8080/picture/20210226/a12cea393aa441d485e6e0a6b80e7181.jpg",
    //                 fit: BoxFit.contain,
    //                 mode: ExtendedImageMode.gesture,
    //                 extendedImageGestureKey: gestureKey,
    //                 initGestureConfigHandler: (ExtendedImageState state) {
    //                   return GestureConfig(
    //                     minScale: 0.9,
    //                     animationMinScale: 0.7,
    //                     maxScale: 4.0,
    //                     animationMaxScale: 4.5,
    //                     speed: 1.0,
    //                     inertialSpeed: 100.0,
    //                     initialScale: 1.0,
    //                     inPageView: false,
    //                     initialAlignment: InitialAlignment.center,
    //                     gestureDetailsIsChanged: (GestureDetails details) {
    //                       //print(details.totalScale);
    //                     },
    //                   );
    //                 },
    //               ),
    //             )),
    //             Text("ceshi"),
    //             // child: _memoryImage != null
    //             //     ? ExtendedImage.memory(
    //             //         _memoryImage,
    //             //         fit: BoxFit.contain,
    //             //         mode: ExtendedImageMode.editor,
    //             //         enableLoadState: true,
    //             //         extendedImageEditorKey: editorKey,
    //             //         initEditorConfigHandler: (ExtendedImageState state) {
    //             //           return EditorConfig(
    //             //               maxScale: 8.0,
    //             //               cropRectPadding: const EdgeInsets.all(20.0),
    //             //               hitTestSize: 20.0,
    //             //               cornerPainter: _cornerPainter,
    //             //               initCropRectType: InitCropRectType.imageRect,
    //             //               cropAspectRatio: _aspectRatio.value);
    //             //         },
    //             //       )
    //             //     : ExtendedImage.asset(
    //             //         'assets/image.jpg',
    //             //         fit: BoxFit.contain,
    //             //         mode: ExtendedImageMode.editor,
    //             //         enableLoadState: true,
    //             //         extendedImageEditorKey: editorKey,
    //             //         initEditorConfigHandler: (ExtendedImageState state) {
    //             //           return EditorConfig(
    //             //               maxScale: 8.0,
    //             //               cropRectPadding: const EdgeInsets.all(20.0),
    //             //               hitTestSize: 20.0,
    //             //               cornerPainter: _cornerPainter,
    //             //               initCropRectType: InitCropRectType.imageRect,
    //             //               cropAspectRatio: _aspectRatio.value);
    //             //         },
    //             //       ),
    //           ]),
    //     ],
    //   ),
    // );

    // body:
    // bottomNavigationBar: BottomAppBar(
    //   color: Colors.lightBlue,
    //   shape: const CircularNotchedRectangle(),
    //   child: ButtonTheme(
    //     minWidth: 0.0,
    //     child: Row(
    //       mainAxisAlignment: MainAxisAlignment.start,
    //       mainAxisSize: MainAxisSize.max,
    //       children: <Widget>[

    //       ],
    //     ),
    //   ),
    // ),
  }

  void _showCropDialog(BuildContext context) {
    showDialog<void>(
        context: context,
        builder: (BuildContext content) {
          return Column(
            children: <Widget>[
              Expanded(
                child: Container(),
              ),
              Container(
                  margin: const EdgeInsets.all(20.0),
                  child: Material(
                      child: Padding(
                    padding: const EdgeInsets.all(15.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        const Text(
                          'select library to crop',
                          style: TextStyle(
                              fontSize: 24.0, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(
                          height: 20.0,
                        ),
                        Text.rich(TextSpan(children: <TextSpan>[
                          TextSpan(
                            children: <TextSpan>[
                              TextSpan(
                                  text: 'Image',
                                  style: const TextStyle(
                                      color: Colors.blue,
                                      decorationStyle:
                                          TextDecorationStyle.solid,
                                      decorationColor: Colors.blue,
                                      decoration: TextDecoration.underline),
                                  recognizer: TapGestureRecognizer()
                                    ..onTap = () {
                                      launch(
                                          'https://github.com/brendan-duncan/image');
                                    }),
                              const TextSpan(
                                  text:
                                      '(Dart library) for decoding/encoding image formats, and image processing. It\'s stable.')
                            ],
                          ),
                          const TextSpan(text: '\n\n'),
                          TextSpan(
                            children: <TextSpan>[
                              TextSpan(
                                  text: 'ImageEditor',
                                  style: const TextStyle(
                                      color: Colors.blue,
                                      decorationStyle:
                                          TextDecorationStyle.solid,
                                      decorationColor: Colors.blue,
                                      decoration: TextDecoration.underline),
                                  recognizer: TapGestureRecognizer()
                                    ..onTap = () {
                                      launch(
                                          'https://github.com/fluttercandies/flutter_image_editor');
                                    }),
                              const TextSpan(
                                  text:
                                      '(Native library) support android/ios, crop flip rotate. It\'s faster.')
                            ],
                          )
                        ])),
                        const SizedBox(
                          height: 20.0,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: <Widget>[
                            OutlineButton(
                              child: const Text(
                                'Dart',
                                style: TextStyle(
                                  color: Colors.blue,
                                ),
                              ),
                              onPressed: () {
                                Navigator.of(context).pop();
                                _cropImage(false);
                              },
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10.0)),
                            ),
                            OutlineButton(
                              child: const Text(
                                'Native',
                                style: TextStyle(
                                  color: Colors.blue,
                                ),
                              ),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10.0)),
                              onPressed: () {
                                Navigator.of(context).pop();
                                _cropImage(true);
                              },
                            ),
                          ],
                        )
                      ],
                    ),
                  ))),
              Expanded(
                child: Container(),
              )
            ],
          );
        });
  }

  // void updateUI() {
  //   setState(() {

  //   });
  // }

  Future<String> _cropImage(bool useNative) async {
    if (_cropping) {
      return null;
    }
    String msg = '';
    try {
      _cropping = true;

      //await showBusyingDialog();

      Uint8List fileData;

      /// native library
      if (useNative) {
        fileData = Uint8List.fromList(await cropImageDataWithNativeLibrary(
            state: editorKey.currentState));
      } else {
        ///delay due to cropImageDataWithDartLibrary is time consuming on main thread
        ///it will block showBusyingDialog
        ///if you don't want to block ui, use compute/isolate,but it costs more time.
        //await Future.delayed(Duration(milliseconds: 200));

        ///if you don't want to block ui, use compute/isolate,but it costs more time.
        fileData = Uint8List.fromList(
            await cropImageDataWithDartLibrary(state: editorKey.currentState));
      }
      final String filePath =
          await ImageSaver.save('extended_image_cropped_image.jpg', fileData);
      // var filePath = await ImagePickerSaver.saveFile(fileData: fileData);

      msg = '图片已保存在 : $filePath';

      return filePath;
    } catch (e, stack) {
      msg = '图片保存失败: $e\n $stack';
      print(msg);
    }

    //Navigator.of(context).pop();
    showToast(msg);
    _cropping = false;
  }

  Future<void> _getImage() async {
    //不知道为啥有bug
    // _memoryImage = await pickImage(context); //这里之后换成imagepicker方法=========
    PickedFile pickedFile =
        await ImagePicker().getImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      _memoryImage = File(pickedFile.path).readAsBytesSync();
      this.path = pickedFile.path;
      // print(_memoryImage);
      Future<void>.delayed(const Duration(milliseconds: 200), () {
        setState(() {
          // editorKey.currentState.reset();
          this.path;
        });
      });
    }
    //when back to current page, may be editorKey.currentState is not ready.
  }
}

class ImageSaver {
  static Future<String> save(String name, Uint8List fileData) async {
    final AssetEntity imageEntity =
        await PhotoManager.editor.saveImage(fileData);
    final File file = await imageEntity.file;
    return file.path;
  }
}
