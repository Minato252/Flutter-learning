import 'package:flutter/material.dart';
import 'package:weitong/pages/tabs/searchedResult.dart';

class sresult extends StatelessWidget {
  List title;
  List content;
  sresult({Key key, @required this.title, @required this.content})
      : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("查询到了${title.length}条标题"),
        ),
        body: new ListView.builder(
          itemCount: title.length,
          itemBuilder: (context, index) {
            return Container(
                child: Column(
              children: [
                new ListTile(
                    leading: Icon(Icons.title),
                    title: Text(
                      title[index],
                      style: TextStyle(fontSize: 20),

                      //textAlign: TextAlign.center,
                      // style: TextStyle(fontSize: 18),
                    ),
                    //subtitle: Text(""),
                    trailing: new Icon(Icons.arrow_forward_ios),
                    contentPadding: EdgeInsets.symmetric(horizontal: 30.0),
                    enabled: true,
                    onTap: () {
                      Navigator.push(
                          context,
                          new MaterialPageRoute(
                              builder: (context) => new SearchedResult(
                                  new List.from(content[index]))));
                    }),
                Divider(
                  height: 25,
                  indent: 0.0,
                  color: Colors.black26,
                ),
              ],
            ));
          },

          /*  return Column(
              children: [
                InkWell(
                    onTap: () {
                      Navigator.push(
                          context,
                          new MaterialPageRoute(
                              builder: (context) => new SearchedResult(
                                  new List.from(content[index]))));
                    },
                    child: Container(
                      margin: EdgeInsets.all(12),
                      width: double.infinity,
                      height: 30,
                      child: Text(
                        title[index],
                        textAlign: TextAlign.center,
                        // style: TextStyle(fontSize: 18),
                      ),
                    )

                    //color: Colors.white
                    //_selectIndex == index
                    // ? Color.fromRGBO(240, 246, 246, 0.9)
                    //: Colors.white,
                    ),

                // Divider(height: 5), //设置默认间隙为1
              ],
            );*/
        ));
  }
}
