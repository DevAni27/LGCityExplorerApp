import 'package:dartssh2/dartssh2.dart';
import 'package:flutter/foundation.dart';

/// Handles all SSH connectivity to the Liquid Galaxy master rig.
/// This is the ONLY class that may import or use dartssh2.
/// All other classes must use this controller via dependency injection.
class SshController extends ChangeNotifier {
  SSHSocket? _socket;
  SSHClient? _client;

  String? _host;
  int? _port;
  String? _username;

  bool _isConnected = false;

  bool get isConnected => _isConnected;
  String? get host => _host;
  int? get port => _port;
  String? get username => _username;

  /// Establishes SSH socket + authenticates in one call.
  /// Throws on failure — callers must catch.
  Future<void> connect({
    required String host,
    required int port,
    required String username,
    required String password,
  }) async {
    await disconnect(); // clean up any existing connection

    _host = host;
    _port = port;
    _username = username;

    try {
      _socket = await SSHSocket.connect(host, port);
      _client = SSHClient(
        _socket!,
        username: username,
        onPasswordRequest: () => password,
      );
      _isConnected = true;
      debugPrint('[SshController] Connected to $host:$port as $username');
      notifyListeners();
    } catch (e) {
      _isConnected = false;
      _socket = null;
      _client = null;
      notifyListeners();
      throw Exception('[SshController] Connection failed: $e');
    }
  }

  /// Runs a shell command on the LG master and returns stdout as a String.
  /// Throws if not connected or if the command fails.
  Future<String> runCommand(String command) async {
    if (_client == null) {
      throw Exception('[SshController] Not connected. Call connect() first.');
    }
    try {
      final result = await _client!.run(command);
      return String.fromCharCodes(result);
    } catch (e) {
      debugPrint('[SshController] Command failed: $command\nError: $e');
      await _handleDisconnect();
      throw Exception('[SshController] Command failed: $e');
    }
  }

  /// Gracefully closes the SSH connection.
  Future<void> disconnect() async {
    _client?.close();
    await _socket?.close();
    _client = null;
    _socket = null;
    _isConnected = false;
    debugPrint('[SshController] Disconnected');
    notifyListeners();
  }

  Future<void> _handleDisconnect() async {
    _client = null;
    _socket = null;
    _isConnected = false;
    notifyListeners();
  }
}
