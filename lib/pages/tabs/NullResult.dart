import 'package:flutter/material.dart';

class NullResult extends StatelessWidget {
  const NullResult({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("查询结果"),
        actions: [
          IconButton(
              onPressed: () {
                Navigator.of(context).pushNamedAndRemoveUntil(
                  '/',
                  (route) => route == null,
                );
              },
              icon: Icon(Icons.account_balance)),
        ],
      ),
      body: Container(
        child:
            Text("无查询结果", style: TextStyle(color: Colors.grey, fontSize: 20)),
        alignment: Alignment.center,
      ),
    );
  }
}
