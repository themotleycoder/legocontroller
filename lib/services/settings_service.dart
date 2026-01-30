import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Service for managing persistent backend server settings
class SettingsService {
  static const String _keyHost = 'backend_host';
  static const String _keyPort = 'backend_port';
  static const String _keyApiKey = 'api_key';

  final SharedPreferences _prefs;

  SettingsService(this._prefs);

  /// Parse BACKEND_URL from .env to extract host and port
  static (String host, int port) _parseBackendUrl(String url) {
    final uri = Uri.parse(url);
    return (uri.host, uri.hasPort ? uri.port : 8000);
  }

  /// Get host from SharedPreferences, fall back to .env
  String getHost() {
    final saved = _prefs.getString(_keyHost);
    if (saved != null) return saved;

    final backendUrl = dotenv.env['BACKEND_URL'] ?? 'http://192.168.86.39:8000';
    final (host, _) = _parseBackendUrl(backendUrl);
    return host;
  }

  /// Get port from SharedPreferences, fall back to .env
  int getPort() {
    final saved = _prefs.getInt(_keyPort);
    if (saved != null) return saved;

    final backendUrl = dotenv.env['BACKEND_URL'] ?? 'http://192.168.86.39:8000';
    final (_, port) = _parseBackendUrl(backendUrl);
    return port;
  }

  /// Get API key from SharedPreferences, fall back to .env
  String? getApiKey() => _prefs.getString(_keyApiKey) ?? dotenv.env['API_KEY'];

  /// Save settings to SharedPreferences
  Future<void> saveSettings({
    required String host,
    required int port,
    String? apiKey,
  }) async {
    await _prefs.setString(_keyHost, host);
    await _prefs.setInt(_keyPort, port);
    if (apiKey != null && apiKey.isNotEmpty) {
      await _prefs.setString(_keyApiKey, apiKey);
    } else {
      await _prefs.remove(_keyApiKey);
    }
  }

  /// Reset to .env defaults by clearing saved settings
  Future<void> resetToDefaults() async {
    await _prefs.remove(_keyHost);
    await _prefs.remove(_keyPort);
    await _prefs.remove(_keyApiKey);
  }

  /// Validate host format (IP address or hostname)
  static bool isValidHost(String host) {
    if (host.isEmpty) return false;

    // IP address pattern (e.g., 192.168.1.1)
    final ipPattern = RegExp(r'^(\d{1,3}\.){3}\d{1,3}$');
    if (ipPattern.hasMatch(host)) {
      final parts = host.split('.');
      return parts.every((part) {
        final num = int.tryParse(part);
        return num != null && num >= 0 && num <= 255;
      });
    }

    // If it looks like an incomplete IP (only digits and dots), reject it
    final looksLikeIP = RegExp(r'^[\d.]+$');
    if (looksLikeIP.hasMatch(host)) return false;

    // Hostname pattern (RFC 1123) - e.g., localhost, server.local
    // Must start and end with alphanumeric, can contain hyphens in middle
    // Each label must be 1-63 characters
    final hostnamePattern = RegExp(
      r'^[a-zA-Z0-9]([a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(\.[a-zA-Z0-9]([a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*$',
    );

    // Additional validation: no label can start or end with hyphen
    if (host.contains('.-') || host.contains('-.')) return false;

    return hostnamePattern.hasMatch(host) && host.length <= 253;
  }

  /// Validate port number (1-65535)
  static bool isValidPort(int port) {
    return port >= 1 && port <= 65535;
  }

  /// Construct full URL from host and port
  static String constructUrl(String host, int port) {
    return 'http://$host:$port';
  }
}
