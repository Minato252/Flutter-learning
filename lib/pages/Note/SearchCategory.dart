import 'package:flutter/material.dart';
import 'package:weitong/pages/Note/DeleteCategory.dart';
//import 'package:dio/dio.dart';
import 'package:html/parser.dart' show parse;
import 'package:html/dom.dart' as dom;

class SearchCategory extends SearchDelegate<String> {
  // 搜索条右侧的按钮执行方法，我们在这里方法里放入一个clear图标。 当点击图片时，清空搜索的内容。
  List _titleList;
  SearchCategory(List _titleList) : super(searchFieldLabel: "查询") {
    this._titleList = _titleList;
  }

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: Icon(Icons.clear),
        onPressed: () {
          // 清空搜索内容
          query = "";
        },
      )
    ];
  }

  // 搜索栏左侧的图标和功能，点击时关闭整个搜索页面
  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: AnimatedIcon(
          icon: AnimatedIcons.menu_arrow, progress: transitionAnimation),
      onPressed: () {
        close(context, "");
      },
    );
  }

  // 搜索到内容了
  @override
  Widget buildResults(BuildContext context) {
    return Container(
      child: CustomScrollView(
        slivers: <Widget>[
          SliverSafeArea(
              sliver: SliverPadding(
            padding: EdgeInsets.all(20),
            sliver: CategorySliverList(search(query)),
          ))
        ],
      ),
    );
  }

//从users表中搜索结果，生成新的List<Map>
  List<Map> search(String searchText) {
    List<Map> result = [];
    // List contentlist = [];
    int j = 0;
    String content;
    for (int i = 0; i < _titleList.length; i++) {
      content = _content(_titleList[i]["nNote"], searchText);
      if (content != null) {
        if (_titleList[i]["nNotetitle"].contains(searchText) ||
            content.contains(searchText)) {
          // print(_titleList[i]["nNotetitle"]);
          result.add(_titleList[i]);
          print(_content(_titleList[i]["nNote"], searchText));
          result[j]["ncontent"] =
              "${_content(_titleList[i]["nNote"], searchText)}";
          j++;
        }
      } else {
        if (_titleList[i]["nNotetitle"].contains(searchText)) {
          result.add(_titleList[i]);
          print(_content(_titleList[i]["nNote"], searchText));
          result[j]["ncontent"] =
              "${_content(_titleList[i]["nNote"], searchText)}";
          j++;
        }
      }
    }
    //print(result);
    return result;
  }

  String _content(htmlCode, searchText) {
    //提取出内容
    var str = "$htmlCode";
    print(str);

    List resultList = [];
    var document = parse(str);
    List<dom.Element> children = document.children;
    Function fn;
    fn = (children) {
      for (int i = 0; i < children.length; i++) {
        dom.Element ele = children[i];
        String localName = ele.localName;
        if (localName == 'html' || localName == 'head' || localName == 'body') {
          if (ele.children.length > 0) {
            fn(ele.children);
          }
          continue;
        }

        // print(
        //    '===============================标签名: <$localName>=================================\n');
        // print(ele);
        // print('toString: ' + ele.toString());
        //print('innerHTML: ' + ele.innerHtml);
        // print('outerHTML: ' + ele.outerHtml);
        // print('localName: ' + ele.localName);
        // print('text: ' + ele.text);
        // print('attributes: ' + ele.attributes.toString());

        if (ele.children.length > 0) {
          dom.Element firstChildEle = ele.children.first;
          String preTag = '<${ele.localName}>';
          String firstChildTag = '<${firstChildEle.localName}';
          // print('preTag: $preTag, fistChildTag: $firstChildTag');

          String outerHtml = ele.outerHtml;
          String regStr = "<${ele.localName}\.*>(.*)$firstChildTag";
          List<RegExpMatch> matches =
              RegExp(regStr).allMatches(outerHtml).toList();
          matches.forEach((RegExpMatch match) {
            String text = match.group(1);
            //print('~~~提取出文本: $text');
            if (text != null && text.length > 0) {
              resultList.add(text);
            }
          });

          //  print(
          //     '==============================================================================\n\n');
          fn(ele.children);

          dom.Element lastChildEle = ele.children.last;
          String lastChildTag = '</${lastChildEle.localName}>';
          preTag = '</${ele.localName}';
          //  print('lastChildTag: $lastChildTag, preTag: $preTag');

          regStr = "$lastChildTag(.*)$preTag";
          matches = RegExp(regStr).allMatches(outerHtml).toList();
          matches.forEach((RegExpMatch match) {
            String text = match.group(1);
            // print('~~~提取出文本: $text');
            if (text != null && text.length > 0) {
              resultList.add(text);
            }
          });
        } else {
          String text = ele.innerHtml;
          //  print('~~~提取出文本: $text');
          if (text != null && text.length > 0) {
            resultList.add(text);
          }

          /* if (localName == 'img') {
            String src = ele.attributes['src'];
            print('--> 提取出图片: $src');
            resultList.add(src);
          } else if (localName == 'video') {
            String src = ele.attributes['src'];
            print('--> 提取出视频: $src');
            resultList.add(src);
          }*/

        }

        if (i < children.length - 1) {
          dom.Element netEle = children[i + 1];
          String currentTag = '</${ele.localName}>';
          String netTag = netEle != null ? '<${netEle.localName}' : '';
          // print('currentTag: $currentTag, netTag: $netTag');

          String outerHtml = ele.outerHtml;
          String regStr = "$currentTag(.*)$netTag";
          List<RegExpMatch> matches =
              RegExp(regStr).allMatches(outerHtml).toList();
          matches.forEach((RegExpMatch match) {
            String text = match.group(1);
            //print('~~~提取出文本: $text');
            if (text != null && text.length > 0) {
              resultList.add(text);
            }
          });
        }
      }
    };
    fn(children);

    // print(resultList);
    //print("${resultList[1]}");
    for (int i = 0; i < resultList.length; i++) {
      if (resultList[i].contains(searchText)) {
        return resultList[i];
      }
    }
    if (resultList.length != 0) {
      return resultList[0];
    } else {
      //return null;
      return "";
    }
  }

  // 输入时的推荐及搜索结果
  @override
  Widget buildSuggestions(BuildContext context) {
    final suggestionList = query.isEmpty
        ? recentList
        : searchList.where((input) => input.startsWith(query)).toList();
    return ListView.builder(
      itemCount: suggestionList.length,
      itemBuilder: (context, index) {
        // 创建一个富文本，匹配的内容特别显示
        return ListTile(
          title: RichText(
              text: TextSpan(
            text: suggestionList[index].substring(0, query.length),
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
            children: [
              TextSpan(
                  text: suggestionList[index].substring(query.length),
                  style: TextStyle(color: Colors.grey))
            ],
          )),
          onTap: () {
            query = suggestionList[index];
            Scaffold.of(context).showSnackBar(SnackBar(content: Text(query)));
          },
        );
      },
    );
  }
}

///================= 模拟后台数据 ========================
const searchList = [
  // "搜索结果数据1-aa",
  // "搜索结果数据2-bb",
  // "搜索结果数据3-cc",
  // "搜索结果数据4-dd",
  // "搜索结果数据5-ee",
  // "搜索结果数据6-ff",
  // "搜索结果数据7-gg",
  // "搜索结果数据8-hh"
];

const recentList = [
  // "推荐结果1-ii",
  // "推荐结果2-jj",
  // "推荐结果3-kk",
  // "推荐结果4-ll",
  // "推荐结果5-mm",
  // "推荐结果6-nn",
  // "推荐结果7-oo",
  // "推荐结果8-pp",
];
