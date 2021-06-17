import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:weitong/pages/tabs/chooseUser/ChoseList.dart';
import 'package:weitong/pages/tree/tree.dart';
import 'package:weitong/services/providerServices.dart';
import 'package:weitong/widget/JdButton.dart';

class CompanyChoiceChipUser extends StatefulWidget {
  @override
  _CompanyChoiceState createState() => _CompanyChoiceState();
}

class _CompanyChoiceState extends State<CompanyChoiceChipUser> {
  @override
  List companys = [];
  String _choicecompany = "";
  String _choicetag = "";
  String _choiceuser = "";
  List result = [];
  List user;

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

    var type =
        await Dio().post("http://47.110.150.159:8080/MutilGetType?id=$id");
    Map<String, dynamic> s = type.data;

    s.forEach((key, value) {
      companys.add(key);
    });

    setState(() {});
  }

  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(
            "公司",
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
                      onSelected: (value) async {
                        // setState(() {
                        //   _choicecompany = company;
                        // });
                        List treeList = await Tree.getMulTreeFromSer(company);
                        List user = [];
                        treeList.forEach((element) {
                          var parsedJson = json.decode(element);
                          Tree.getAllPeople(parsedJson, user);
                          //   List idList = [];
                          //   l.forEach((element) {
                          //     idList.add(element["id"]);
                          //   });
                          //   user.add(idList);
                        });
                        result = await Navigator.push(
                            context,
                            new MaterialPageRoute(
                                builder: (BuildContext context) =>
                                    new ChoseListPage(
                                      user,
                                      isSingle: true,
                                      title: "选择创建人",
                                    )));
                        List nameList = [];
                        result.forEach((element) {
                          nameList.add(element["name"]);
                          _choiceuser = _choiceuser + element["name"] + ",";
                        });

                        setState(() {
                          _choicecompany = company;
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
                Text("已选择的创建人： $_choiceuser"),
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
    Navigator.pop(context, result);
  }
}
