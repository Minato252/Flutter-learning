import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:oktoast/oktoast.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:url_launcher/url_launcher.dart';

import 'common_widget.dart';
import 'crop_editor_helper.dart';
import 'editor/extended_image_editor.dart';
import 'editor/extended_image_editor_utils.dart';
import 'extended_image.dart';
import 'extended_image_utils.dart';

///
///  create by zmtzawqlp on 2019/8/22
///

class ImageEditorDemo extends StatefulWidget {
  @override
  Uint8List _memoryImage;
  ImageEditorDemo(this._memoryImage);
  _ImageEditorDemoState createState() => _ImageEditorDemoState(_memoryImage);
}

class _ImageEditorDemoState extends State<ImageEditorDemo> {
  final GlobalKey<ExtendedImageEditorState> editorKey =
      GlobalKey<ExtendedImageEditorState>();
  final GlobalKey<PopupMenuButtonState<ExtendedImageCropLayerCornerPainter>>
      popupMenuKey =
      GlobalKey<PopupMenuButtonState<ExtendedImageCropLayerCornerPainter>>();
  final List<AspectRatioItem> _aspectRatios = <AspectRatioItem>[
    AspectRatioItem(text: '自定义', value: CropAspectRatios.custom),
    AspectRatioItem(text: '原始', value: CropAspectRatios.original),
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
  _ImageEditorDemoState(this._memoryImage);
  @override
  void initState() {
    _aspectRatio = _aspectRatios.first;
    _cornerPainter = const ExtendedImageCropLayerPainterNinetyDegreesCorner();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('编辑图片'),
        actions: <Widget>[
          // IconButton(
          //   icon: const Icon(Icons.photo_library),
          //   onPressed: _getImage,
          // ),
          IconButton(
            icon: const Icon(Icons.done),
            onPressed: () async {
              if (kIsWeb) {
                _cropImage(false);
              } else {
                // _showCropDialog(context);
                String url = await _cropImage(true);
                Navigator.pop(context, url);
              }
            },
          ),
        ],
      ),
      body: Column(children: <Widget>[
        Expanded(
          child: _memoryImage != null
              ? ExtendedImage.memory(
                  _memoryImage,
                  fit: BoxFit.contain,
                  mode: ExtendedImageMode.editor,
                  enableLoadState: true,
                  extendedImageEditorKey: editorKey,
                  initEditorConfigHandler: (ExtendedImageState state) {
                    return EditorConfig(
                        maxScale: 8.0,
                        cropRectPadding: const EdgeInsets.all(20.0),
                        hitTestSize: 20.0,
                        cornerPainter: _cornerPainter,
                        initCropRectType: InitCropRectType.imageRect,
                        cropAspectRatio: _aspectRatio.value);
                  },
                )
              : ExtendedImage.asset(
                  'assets/image.jpg',
                  fit: BoxFit.contain,
                  mode: ExtendedImageMode.editor,
                  enableLoadState: true,
                  extendedImageEditorKey: editorKey,
                  initEditorConfigHandler: (ExtendedImageState state) {
                    return EditorConfig(
                        maxScale: 8.0,
                        cropRectPadding: const EdgeInsets.all(20.0),
                        hitTestSize: 20.0,
                        cornerPainter: _cornerPainter,
                        initCropRectType: InitCropRectType.imageRect,
                        cropAspectRatio: _aspectRatio.value);
                  },
                ),
        ),
      ]),
      bottomNavigationBar: BottomAppBar(
        color: Colors.lightBlue,
        shape: const CircularNotchedRectangle(),
        child: ButtonTheme(
          minWidth: 0.0,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            mainAxisSize: MainAxisSize.max,
            children: <Widget>[
              FlatButtonWithIcon(
                icon: const Icon(Icons.crop),
                label: const Text(
                  "裁剪",
                  style: TextStyle(fontSize: 10.0),
                ),
                textColor: Colors.white,
                onPressed: () {
                  showDialog<void>(
                      context: context,
                      builder: (BuildContext context) {
                        return Column(
                          children: <Widget>[
                            const Expanded(
                              child: SizedBox(),
                            ),
                            SizedBox(
                              height: ScreenUtil.instance.setWidth(200.0),
                              child: ListView.builder(
                                shrinkWrap: true,
                                scrollDirection: Axis.horizontal,
                                padding: const EdgeInsets.all(20.0),
                                itemBuilder: (_, int index) {
                                  final AspectRatioItem item =
                                      _aspectRatios[index];
                                  return GestureDetector(
                                    child: AspectRatioWidget(
                                      aspectRatio: item.value,
                                      aspectRatioS: item.text,
                                      isSelected: item == _aspectRatio,
                                    ),
                                    onTap: () {
                                      Navigator.pop(context);
                                      setState(() {
                                        _aspectRatio = item;
                                      });
                                    },
                                  );
                                },
                                itemCount: _aspectRatios.length,
                              ),
                            ),
                          ],
                        );
                      });
                },
              ),
              FlatButtonWithIcon(
                icon: const Icon(Icons.flip),
                label: const Text(
                  '翻转',
                  style: TextStyle(fontSize: 10.0),
                ),
                textColor: Colors.white,
                onPressed: () {
                  editorKey.currentState.flip();
                },
              ),
              FlatButtonWithIcon(
                icon: const Icon(Icons.rotate_left),
                label: const Text(
                  '左旋',
                  style: TextStyle(fontSize: 8.0),
                ),
                textColor: Colors.white,
                onPressed: () {
                  editorKey.currentState.rotate(right: false);
                },
              ),
              FlatButtonWithIcon(
                icon: const Icon(Icons.rotate_right),
                label: const Text(
                  '右旋',
                  style: TextStyle(fontSize: 8.0),
                ),
                textColor: Colors.white,
                onPressed: () {
                  editorKey.currentState.rotate(right: true);
                },
              ),
              // FlatButtonWithIcon(
              //   icon: const Icon(Icons.rounded_corner_sharp),
              //   label: PopupMenuButton<ExtendedImageCropLayerCornerPainter>(
              //     key: popupMenuKey,
              //     enabled: false,
              //     offset: const Offset(100, -300),
              //     child: const Text(
              //       '裁剪框',
              //       style: TextStyle(fontSize: 8.0),
              //     ),
              //     initialValue: _cornerPainter,
              //     itemBuilder: (BuildContext context) {
              //       return <
              //           PopupMenuEntry<ExtendedImageCropLayerCornerPainter>>[
              //         PopupMenuItem<ExtendedImageCropLayerCornerPainter>(
              //           child: Row(
              //             children: const <Widget>[
              //               Icon(
              //                 Icons.rounded_corner_sharp,
              //                 color: Colors.blue,
              //               ),
              //               SizedBox(
              //                 width: 5,
              //               ),
              //               Text('直角'),
              //             ],
              //           ),
              //           value:
              //               const ExtendedImageCropLayerPainterNinetyDegreesCorner(),
              //         ),
              //         const PopupMenuDivider(),
              //         PopupMenuItem<ExtendedImageCropLayerCornerPainter>(
              //           child: Row(
              //             children: const <Widget>[
              //               Icon(
              //                 Icons.circle,
              //                 color: Colors.blue,
              //               ),
              //               SizedBox(
              //                 width: 5,
              //               ),
              //               Text('Circle'),
              //             ],
              //           ),
              //           value:
              //               const ExtendedImageCropLayerPainterCircleCorner(),
              //         ),
              //       ];
              //     },
              //     onSelected: (ExtendedImageCropLayerCornerPainter value) {
              //       if (_cornerPainter != value) {
              //         setState(() {
              //           _cornerPainter = value;
              //         });
              //       }
              //     },
              //   ),
              //   textColor: Colors.white,
              //   onPressed: () {
              //     popupMenuKey.currentState.showButtonMenu();
              //   },
              // ),
              FlatButtonWithIcon(
                icon: const Icon(Icons.restore),
                label: const Text(
                  '重置',
                  style: TextStyle(fontSize: 10.0),
                ),
                textColor: Colors.white,
                onPressed: () {
                  editorKey.currentState.reset();
                },
              ),
            ],
          ),
        ),
      ),
    );
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

      // showToast(msg, context: context);
      return filePath;
    } catch (e, stack) {
      msg = '图片保存失败: $e\n $stack';
      print(msg);

      // showToast(msg);
    }

    //Navigator.of(context).pop();
     finally {
      //在这里加个toast
      _cropping = false;
    }
  }

  // Future<void> _getImage() async {
  //   _memoryImage = await pickImage(context); //这里之后换成imagepicker方法=========
  //   //when back to current page, may be editorKey.currentState is not ready.
  //   Future<void>.delayed(const Duration(milliseconds: 200), () {
  //     setState(() {
  //       editorKey.currentState.reset();
  //     });
  //   });
  // }
}

class ImageSaver {
  static Future<String> save(String name, Uint8List fileData) async {
    final AssetEntity imageEntity =
        await PhotoManager.editor.saveImage(fileData);
    final File file = await imageEntity.file;
    return file.path;
  }
}
