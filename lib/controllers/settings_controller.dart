import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Stores and persists LG connection settings across app sessions.
/// Uses shared_preferences so settings survive app restarts.
class SettingsController extends ChangeNotifier {
  static const _kIp       = 'lg_ip';
  static const _kPort     = 'lg_port';
  static const _kUsername = 'lg_username';
  static const _kPassword = 'lg_password';
  static const _kRigs     = 'lg_rigs';

  String _lgIp       = '';
  String _lgPort     = '22';
  String _lgUsername = 'lg';
  String _lgPassword = '';
  int    _lgRigs     = 3;

  String get lgIp       => _lgIp;
  String get lgPort     => _lgPort;
  String get lgUsername => _lgUsername;
  String get lgPassword => _lgPassword;
  int    get lgRigs     => _lgRigs;

  bool get isConfigured =>
      _lgIp.isNotEmpty && _lgPassword.isNotEmpty;

  /// Call once at app startup to restore persisted settings.
  Future<void> loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    _lgIp       = prefs.getString(_kIp)       ?? '';
    _lgPort     = prefs.getString(_kPort)      ?? '22';
    _lgUsername = prefs.getString(_kUsername)  ?? 'lg';
    _lgPassword = prefs.getString(_kPassword)  ?? '';
    _lgRigs     = prefs.getInt(_kRigs)         ?? 3;
    notifyListeners();
  }

  Future<void> updateLgIp(String v) async {
    if (v == _lgIp) return;
    _lgIp = v;
    await _persist(_kIp, v);
    notifyListeners();
  }

  Future<void> updateLgPort(String v) async {
    if (v == _lgPort) return;
    _lgPort = v;
    await _persist(_kPort, v);
    notifyListeners();
  }

  Future<void> updateLgUsername(String v) async {
    if (v == _lgUsername) return;
    _lgUsername = v;
    await _persist(_kUsername, v);
    notifyListeners();
  }

  Future<void> updateLgPassword(String v) async {
    if (v == _lgPassword) return;
    _lgPassword = v;
    await _persist(_kPassword, v);
    notifyListeners();
  }

  Future<void> updateLgRigs(int v) async {
    if (v == _lgRigs) return;
    _lgRigs = v;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_kRigs, v);
    notifyListeners();
  }

  Future<void> _persist(String key, String value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(key, value);
  }
}
