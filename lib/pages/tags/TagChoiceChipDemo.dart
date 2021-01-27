import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:weitong/services/providerServices.dart';
import 'package:weitong/widget/JdButton.dart';

class TagChoiceChipDemo extends StatefulWidget {
  @override
  _TagChoiceState createState() => _TagChoiceState();
}

class _TagChoiceState extends State<TagChoiceChipDemo> {
  @override
  List<String> _tags;
  // = [
  //   '111',
  //   '222',
  //   '333',
  // ];
  String _choice = "";
  // void initState() {}

  Widget build(BuildContext context) {
    final ps = Provider.of<ProviderServices>(context);
    _tags = ps.keyWords;
    return Scaffold(
        appBar: AppBar(
          title: Text("关键词"),
          // actions: <Widget>[
          //   FlatButton(
          //       onPressed: null,
          //       child: Text(
          //         "完成",
          //         style: TextStyle(fontSize: 20),
          //       ))
          // ],
        ),
        body: Scrollbar(
            child: SingleChildScrollView(
                child: Container(
          padding: EdgeInsets.all(20),
          child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                SizedBox(height: 15),
                Text(
                  "选择您的关键词",
                  style: TextStyle(fontSize: 32.0),
                ),
                SizedBox(height: 15),
                Wrap(
                  spacing: 8.0,
                  children: _tags.map((tag) {
                    return ChoiceChip(
                      label: Text(tag),
                      selected: _choice == tag,
                      // selectedColor: Theme.of(context).accentColor,
                      onSelected: (value) {
                        setState(() {
                          _choice = tag;
                        });
                      },
                      // onDeleted: () {
                      //   setState(() {
                      //     _tags.remove(tag);
                      //   });
                      // },
                      // deleteButtonTooltipMessage: "删除这个关键词",
                      // onSelected: ,
                    );
                  }).toList(),
                ),
                SizedBox(height: 15),
                Text("已选择关键词: $_choice"),
                SizedBox(height: 15),
                Divider(
                  color: Colors.black12,
                ),
                SizedBox(
                  height: 15,
                ),
                JdButton(
                  text: '完成',
                  cb: () {
                    _sendDataBack(context);
                  },
                ),
              ]),
        ))));
  }

  void _sendDataBack(BuildContext context) {
    Navigator.pop(context, _choice);
  }
}
