import 'package:supabase_flutter/supabase_flutter.dart';

import 'websocket_service.dart';
import 'message.dart';

class MessageService {
  MessageService({
    required this.websocket,
  });

  final WebsocketService websocket;

  final List<Function(Message)> _onActions = [];

  void send(Message action) {
    websocket.sendMessage(action.toJson());
  }

  void onListen(
    String action,
    Function(Message) onUpdateAction,
  ) {
    _onActions.add(((message) {
      print(message.toJson());
      if (message.action == action) {
        onUpdateAction(message);
      }
    }));
  }

  Future<void> init() async {
    await websocket.initConnection();
    await websocket.broadcastNotifications(onReceive: (json) {
      final message = Message.fromJson(json);
      for (var onAction in _onActions) {
        onAction(message);
      }
    });
  }

  void dispose() async {
    await websocket.disconnect();
  }
}
