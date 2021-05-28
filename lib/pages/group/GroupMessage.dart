import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_swiper/flutter_swiper.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:rongcloud_im_plugin/rongcloud_im_plugin.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:weitong/Model/style.dart';
import 'package:weitong/pages/Login.dart';
import 'package:weitong/services/event_bus.dart';
import 'package:weitong/widget/conversation_list_item.dart';
import 'package:weitong/widget/dialog_util.dart';
import 'package:weitong/widget/mylocally.dart';

class GropuMessagePage extends StatefulWidget {
  GropuMessagePage({Key key}) : super(key: key);

  _GropuMessagePageState createState() => _GropuMessagePageState();
}

class _GropuMessagePageState extends State<GropuMessagePage>
    implements ConversationListItemDelegate {
  // String pageName = "example.ConversationListPage";
  List conList = new List();
  List<int> displayConversationType = [
    RCConversationType.Private,
    RCConversationType.Group
  ];
  ScrollController _scrollController;
  double mPosition = 0;

  @override
  void initState() {
    super.initState();
    addIMhandler();
    updateConversationList();

    EventBus.instance.addListener(EventKeys.ConversationPageDispose, (arg) {
      Timer(Duration(milliseconds: 10), () {
        addIMhandler();
        updateConversationList();
        _renfreshUI();
      });
    });
  }

  @override
  void dispose() {
    super.dispose();
    EventBus.instance.removeListener(EventKeys.ConversationPageDispose);
  }

  updateConversationList() async {
    List list = await RongIMClient.getConversationList(displayConversationType);

    if (list != null) {
      // list.sort((a,b) => b.sentTime.compareTo(a.sentTime));

      conList = list;
    }
    _renfreshUI();
  }

  void _renfreshUI() {
    if (mounted) {
      setState(() {});
    }
  }

  addIMhandler() {
    EventBus.instance.addListener(EventKeys.ReceiveMessage, (map) {
      Message msg = map["message"];
      int left = map["left"];
      bool hasPackage = map["hasPackage"];
      bool isDisplayConversation = msg.conversationType != null &&
          displayConversationType.contains(msg.conversationType);
      //如果离线消息过多，那么可以等到 hasPackage 为 false 并且 left == 0 时更新会话列表
      if (!hasPackage && left == 0 && isDisplayConversation) {
        updateConversationList();
      }
      // easyNotification().show();
    });

    RongIMClient.onConnectionStatusChange = (int connectionStatus) {
      if (RCConnectionStatus.KickedByOtherClient == connectionStatus ||
          RCConnectionStatus.TokenIncorrect == connectionStatus ||
          RCConnectionStatus.UserBlocked == connectionStatus) {
        // String toast = "连接状态变化 $connectionStatus, 请退出后重新登录";
        String toast = "您的账户在其他地方登入, 请注意账户安全";
        DialogUtil.showAlertDiaLog(context, toast,
            confirmButton: FlatButton(
                onPressed: () async {
                  SharedPreferences prefs =
                      await SharedPreferences.getInstance();
                  prefs.remove("token");
                  Navigator.of(context).pushAndRemoveUntil(
                      new MaterialPageRoute(
                          builder: (context) => new LoginPage()),
                      (route) => route == null);
                },
                child: Text("重新登录")));
      } else if (RCConnectionStatus.Connected == connectionStatus) {
        updateConversationList();
      }
    };

    RongIMClient.onRecallMessageReceived = (Message message) {
      updateConversationList();
    };
  }

  void _deleteConversation(Conversation conversation) {
    //删除会话需要刷新会话列表数据
    RongIMClient.removeConversation(
        conversation.conversationType, conversation.targetId, (bool success) {
      if (success) {
        updateConversationList();
        // // 如果需要删除会话中的消息调用下面的接口
        // RongIMClient.deleteMessages(
        //     conversation.conversationType, conversation.targetId, (int code) {
        //   updateConversationList();
        // });
      }
    });
  }

  void _clearConversationUnread(Conversation conversation) async {
    //清空未读需要刷新会话列表数据
    bool success = await RongIMClient.clearMessagesUnreadStatus(
        conversation.conversationType, conversation.targetId);
    if (success) {
      updateConversationList();
    }
  }

  void _setConversationToTop(Conversation conversation, bool isTop) {
    RongIMClient.setConversationToTop(
        conversation.conversationType, conversation.targetId, isTop,
        (bool status, int code) {
      if (code == 0) {
        updateConversationList();
      }
    });
  }

  void _addScroolListener() {
    _scrollController.addListener(() {
      mPosition = _scrollController.position.pixels;
    });
  }

  Widget _buildConversationListView() {
    //把conversationlist展开

    return new ListView.builder(
      scrollDirection: Axis.vertical,
      itemCount: conList.length,
      controller: _scrollController,
      itemBuilder: (BuildContext context, int index) {
        if (conList.length <= 0) {
          // return WidgetUtil.buildEmptyWidget();
          return Container(
            height: 1,
            width: 1,
          );
        }
        return ConversationListItem(
          delegate: this,
          conversation: conList[index],
          conlist: this.conList, ////这里进入对话列表
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    this._scrollController = ScrollController(initialScrollOffset: mPosition);
    _addScroolListener();
    return new Scaffold(
      appBar: AppBar(
        title: Text("信息列表"),
      ),
      key: UniqueKey(),
      body: _buildConversationListView(),
    );
  }

  // @override
  // void didLongPressConversation(Conversation conversation, Offset tapPos) {
  //   Map<String, String> actionMap = {
  //     RCLongPressAction.DeleteConversationKey:
  //         RCLongPressAction.DeleteConversationValue,
  //     RCLongPressAction.ClearUnreadKey: RCLongPressAction.ClearUnreadValue,
  //     RCLongPressAction.SetConversationToTopKey: conversation.isTop
  //         ? RCLongPressAction.CancelConversationToTopValue
  //         : RCLongPressAction.SetConversationToTopValue
  //   };
  //   WidgetUtil.showLongPressMenu(context, tapPos, actionMap, (String key) {
  //     developer.log("当前选中的是 " + key, name: pageName);
  //     if (key == RCLongPressAction.DeleteConversationKey) {
  //       _deleteConversation(conversation);
  //     } else if (key == RCLongPressAction.ClearUnreadKey) {
  //       _clearConversationUnread(conversation);
  //     } else if (key == RCLongPressAction.SetConversationToTopKey) {
  //       bool isTop = true;
  //       if (conversation.isTop) {
  //         isTop = false;
  //       }
  //       _setConversationToTop(conversation, isTop);
  //     } else {
  //       developer.log("未实现操作 " + key, name: pageName);
  //     }
  //   });
  // }

  @override
  void didTapConversation(Conversation conversation) {
    print("didTapConversation中的conversation");
    print(conversation);
    Map arg = {
      "coversationType": conversation.conversationType,
      "targetId": conversation.targetId
    };
    Navigator.pushNamed(context, "/conversation", arguments: arg);
    // Navigator.pushNamed(context, "/readMessage",
    //     arguments: {conversation: conversation});
  }

  @override
  void didLongPressConversation(Conversation conversation, Offset tapPos) {
    // Map<String, String> actionMap = {
    //   RCLongPressAction.DeleteConversationKey:
    //       RCLongPressAction.DeleteConversationValue,
    //   RCLongPressAction.ClearUnreadKey: RCLongPressAction.ClearUnreadValue,
    //   RCLongPressAction.SetConversationToTopKey: conversation.isTop
    //       ? RCLongPressAction.CancelConversationToTopValue
    //       : RCLongPressAction.SetConversationToTopValue

    _deleteConversation(conversation);

    // WidgetUtil.showLongPressMenu(context, tapPos, actionMap, (String key) {
    //   // developer.log("当前选中的是 " + key, name: pageName);
    //   if (key == RCLongPressAction.DeleteConversationKey) {
    //     _deleteConversation(conversation);
    //   } else if (key == RCLongPressAction.ClearUnreadKey) {
    //     _clearConversationUnread(conversation);
    //   } else if (key == RCLongPressAction.SetConversationToTopKey) {
    //     bool isTop = true;
    //     if (conversation.isTop) {
    //       isTop = false;
    //     }
    //     _setConversationToTop(conversation, isTop);
    //   } else {
    //     // developer.log("未实现操作 " + key, name: pageName);
    //   }
    // });
  }

  void deleteConversation(Conversation conversation) {
    CupertinoAlertDialog(
      title: Text('确定要清空对话吗？'),
      content: Text('回话将会被删除'),
      actions: <Widget>[
        CupertinoDialogAction(
          child: Text('删除'),
          onPressed: () {
            _deleteConversation(conversation);
            // Navigator.of(context).pop();
          },
        ),
        CupertinoDialogAction(
          child: Text('取消'),
          onPressed: () {
            // Navigator.of(context).pop();
          },
        ),
      ],
    );
  }
}
