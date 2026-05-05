import 'package:flutter/material.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;
import '../../../core/utils/api_client.dart';

class SocketService {
  static SocketService? _instance;
  io.Socket? _socket;
  final _listeners = <Function>[];

  static SocketService get instance {
    _instance ??= SocketService._();
    return _instance!;
  }

  SocketService._();

  void connect() {
    if (_socket != null) return;

    final token = ApiClient.accessToken;
    if (token == null) return;

    _socket = io.io(
      'https://creadorcontador-production.up.railway.app',
      <String, dynamic>{
        'transports': ['websocket'],
        'autoConnect': true,
        'auth': {'token': token},
      },
    );

    _socket!.onConnect((_) {
      debugPrint('Socket connected');
    });

    _socket!.onDisconnect((_) {
      debugPrint('Socket disconnected');
    });

    _socket!.on('message:receive', (data) {
      for (final listener in _listeners) {
        listener(data);
      }
    });

    _socket!.on('typing:receive', (data) {
      // Handle typing indicator
    });

    _socket!.connect();
  }

  void disconnect() {
    _socket?.disconnect();
    _socket?.dispose();
    _socket = null;
  }

  void sendMessage(String receiverId, String content) {
    _socket?.emit('message:send', {
      'receiverId': receiverId,
      'content': content,
    });
  }

  void sendTyping(String receiverId) {
    _socket?.emit('typing:start', {'receiverId': receiverId});
  }

  void stopTyping(String receiverId) {
    _socket?.emit('typing:stop', {'receiverId': receiverId});
  }

  void addListener(Function callback) {
    _listeners.add(callback);
  }

  void removeListener(Function callback) {
    _listeners.remove(callback);
  }

  bool get isConnected => _socket?.connected ?? false;
}