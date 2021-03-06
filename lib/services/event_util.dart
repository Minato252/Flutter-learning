import 'package:event_bus/event_bus.dart';
export 'dart:async';

class EventBusUtil {
  static EventBus _eventBus;

  static EventBus getInstance() {
    if (_eventBus == null) {
      _eventBus = new EventBus();
    }
    return _eventBus;
  }
}

class PageEvent {
  List<String> userList;
  PageEvent(this.userList);
}

class UpdataNode {
  String type;
  UpdataNode(this.type);
}
