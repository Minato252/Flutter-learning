import 'package:flutter/material.dart';
import 'Mine.dart';
import 'StaffManage.dart';
import 'DepartmentManage.dart';

class AdminTabs extends StatefulWidget {
  AdminTabs({Key key}) : super(key: key);

  @override
  _AdminTabsState createState() => _AdminTabsState();
}

class _AdminTabsState extends State<AdminTabs> {
  int _currentIndex = 0;
  // List _pagelist = [StaffManagePage(), DepartmentManagePage(), Mine()];
  List _pagelist = [StaffManagePage(), DepartmentManagePage(), Mine()];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(
      //   title: Text("微通"),
      // ),
      // floatingActionButton: FloatingActionButton(
      //   child: Icon(Icons.delete),
      //   onPressed: () {
      //     // _cleanToken();
      //   },
      // ),
      body: this._pagelist[this._currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: this._currentIndex,
        onTap: (index) {
          setState(() {
            this._currentIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        fixedColor: Colors.red,
        items: [
          BottomNavigationBarItem(
              icon: Icon(Icons.account_balance), title: Text("体系")),
          BottomNavigationBarItem(
              icon: Icon(Icons.account_circle), title: Text("人员")),
          // BottomNavigationBarItem(
          //     icon: Icon(Icons.library_books), title: Text("草稿")),
          BottomNavigationBarItem(icon: Icon(Icons.people), title: Text("我的"))
        ],
      ),
    );
  }
}
