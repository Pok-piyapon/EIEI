import 'package:socket_io_client/socket_io_client.dart' as IO;

class SocketClient {
  late IO.Socket _socket;

  /// Constructor: Connects automatically
  SocketClient(String url) {
    _socket = IO.io(
      url,
      IO.OptionBuilder()
          .setTransports(['websocket'])
          .enableAutoConnect()
          .build(),
    );

    _socket.onConnect((_) {
      print('✅ Socket connected');
    });

    _socket.onDisconnect((_) {
      print('⚠️ Socket disconnected');
    });

    _socket.onConnectError((error) {
      print('❌ Connect error: $error');
    });

    _socket.onError((error) {
      print('⚠️ Socket error: $error');
    });
  }

  /// Listen for a specific event
  void onMessage(String event, void Function(dynamic data) callback) {
    _socket.on(event, callback);
  }

  /// Emit (send) a message
  void sendMessage(String event, dynamic data) {
    _socket.emit(event, data);
  }

  /// Dispose / Disconnect
  void dispose() {
    _socket.dispose();
    print('🛑 Socket disposed');
  }
}
