import 'package:html/parser.dart' show parse;
import 'package:html/dom.dart';

void getRichContent() {
  var str =
      '''<p><span style="font-size:30px;">123</span></p><p><image style="padding: 10px;max-width: 90%;" src="http://47.110.150.159:8080/picture/20210119/c311effd92fb4db38c6267340e4d5a08.jpg"></image></p><p><span style="font-size:30px;"></span></p><p><video src="http://47.120.150.159:8080/videos/20210119/5f5088f93e534395a7d87c5f49e9287a.mp4;" playsinline="true" webkit-playsinline="true" x-webkit-airplay="allow" airplay="allow" x5-video-player-type="h5" x5-video-player-fullscreen="true" x5-video-orientation="portrait" controls="controls"  style="width: 100%;height: 300px;"></video></p><p><span style="font-size:30px;"></span></p>''';
  Document document = parse(str);
  var a = document.createElement("div");
  a.innerHtml = str;
  //console.log(a)
  var child = a.children;
  fn(child);
  //console.log(arr)
}

void fn(obj) {
  var arr = [];
  for (var i = 0; i < obj.length; i++) {
    if (obj[i].children) {
      fn(obj[i].children);
    }
    arr.add(obj[i]); //遍历到的元素添加到arr这个数组中间
  }
  print(arr);
}
