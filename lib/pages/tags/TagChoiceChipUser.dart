import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:weitong/pages/tree/tree.dart';
import 'package:weitong/services/providerServices.dart';
import 'package:weitong/widget/JdButton.dart';

class TagChoiceChipUser extends StatefulWidget {
  @override
  _TagChoiceState createState() => _TagChoiceState();
}

class _TagChoiceState extends State<TagChoiceChipUser> {
  @override
  List<String> _tags = [];
  List<String> companys = [];
  Map m;
  bool exittag = false;
  // = [
  //   '111',
  //   '222',
  //   '333',
  // ];
  String _choicecompany = "";
  String _choicetag = "";

  @override
  void initState() {
    super.initState();
    _getTag();
  }

  // void initState() {}
  _getTag() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    // print("***********************${arguments['identify']}*******************");

    String id = prefs.get("id");

    //用户
    var rel = await Dio().post("http://47.110.150.159:8080/GetWords?id=${id}");
    // List<String> s = rel.data.toString().split(',');
    m = rel.data;
    m.forEach((key, value) {
      List<String> tags = [];
      String regex = ",";
      List result = value.split(regex);
      for (int i = 0; i < result.length; i++) {
        tags.add(result[i]);
      }
      m["$key"] = tags;
      companys.add(key);
      // List<String> tag = [];
      // String regex = ",";
      // List result = value.split(regex);
      // _tag.add(result);
    });
    setState(() {});
  }

  Widget build(BuildContext context) {
    final ps = Provider.of<ProviderServices>(context);
    List<String> s = ps.keyWords;
    for (int i = 0; i < s.length; i++) {
      if (!_tags.contains(s[i])) {
        _tags.add(s[i]);
      }
    }
    return Scaffold(
        appBar: AppBar(
          title: Text(
            "关键词",
            style: TextStyle(fontSize: 26.0),
          ),
          actions: <Widget>[
            IconButton(
                onPressed: () {
                  Navigator.of(context).pushNamedAndRemoveUntil(
                    '/',
                    (route) => route == null,
                  );
                },
                icon: Icon(Icons.account_balance)),
            //   FlatButton(
            //       onPressed: null,
            //       child: Text(
            //         "完成",
            //         style: TextStyle(fontSize: 20),
            //       ))
          ],
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
                  "选择您的公司",
                  style: TextStyle(fontSize: 20.0),
                ),
                SizedBox(height: 15),
                // Text(
                //   "选择您的关键词",
                //   style: TextStyle(fontSize: 20.0),
                // ),

                Wrap(
                  spacing: 8.0,
                  children: companys.map((company) {
                    return ChoiceChip(
                      label: Text(company),
                      selected: _choicecompany == company,
                      // selectedColor: Theme.of(context).accentColor,
                      onSelected: (value) {
                        setState(() {
                          _choicecompany = company;
                          exittag = true;
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
                Text(
                  "选择您的关键词",
                  style: TextStyle(fontSize: 20.0),
                ),
                SizedBox(height: 15),
                exittag
                    ? Wrap(
                        spacing: 8.0,
                        children: m["$_choicecompany"].map<Widget>((tag) {
                          return ChoiceChip(
                              label: Text(tag),
                              selected: _choicetag == tag,
                              // selectedColor: Theme.of(context).accentColor,
                              onSelected: (value) {
                                setState(() {
                                  _choicetag = tag;
                                });
                              }
                              // onDeleted: () {
                              //   setState(() {
                              //     _tags.remove(tag);
                              //   });
                              // },
                              // deleteButtonTooltipMessage: "删除这个关键词",
                              // onSelected: ,
                              );
                        }).toList(),
                      )
                    : SizedBox(height: 30),
                SizedBox(height: 15),
                Text("已选择公司和关键词: $_choicecompany:$_choicetag"),
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
    Navigator.pop(context, _choicetag);
  }
}
