import 'dart:convert';

import 'package:bonfire/bonfire.dart';
import 'package:flutter/cupertino.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:realtime_client/src/message.dart';

class WebsocketService {
  late WebSocketChannel websocket;
  late Supabase supabase;
  late RealtimeChannel supabaseChannel;
  late RealtimeClient realtimeChannel;

  initConnection() {
    final wsUrl = Uri.parse('ws://localhost:4040/ws');
    //final wsUrl = Uri.parse('wss://solanagameserver.fly.dev/ws');
    websocket = WebSocketChannel.connect(wsUrl);
  }

  Future disconnect() async {
    await websocket.sink.close();
  }

  Future _retryConnection({
    required void Function(Map<String, dynamic>) onReceive,
  }) async {
    await Future.delayed(const Duration(seconds: 5));
    await initConnection();
    await broadcastNotifications(
      onReceive: onReceive,
    );
  }

  Future broadcastNotifications({
    required void Function(Map<String, dynamic>) onReceive,
  }) async {
    websocket.stream.listen(
      (event) {
        try {
          final Map<String, dynamic> json = jsonDecode(event);
          onReceive(json);
        } on Exception {
          debugPrint('Error do Hello World - Inside');
        }
      },
      onError: (_) async {
        debugPrint('Error do Hello World - OnError');
        _retryConnection(onReceive: onReceive);
      },
      onDone: () async {
        debugPrint('Error do Hello World - OnDone');
        _retryConnection(onReceive: onReceive);
      },
      cancelOnError: true,
    );
  }

  void sendMessage(Map<String, dynamic> action) {
    websocket.sink.add(jsonEncode(action));
  }
}
