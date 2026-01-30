import 'dart:async';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../models/train_status.dart';
import '../models/switch_status.dart';

class TrainWebServiceException implements Exception {
  final String message;
  TrainWebServiceException(this.message);

  @override
  String toString() => 'TrainWebServiceException: $message';
}

class ConnectionStatus {
  final int connectedTrains;
  final int connectedSwitches;

  ConnectionStatus({
    required this.connectedTrains,
    required this.connectedSwitches,
  });
}

class TrainWebService {
  static final TrainWebService _instance = TrainWebService._internal();
  factory TrainWebService() => _instance;

  String baseUrl;
  String? _apiKey;
  Duration _requestTimeout;

  TrainWebService._internal()
    : baseUrl = dotenv.env['BACKEND_URL'] ?? 'http://192.168.86.39:8000',
      _apiKey = dotenv.env['API_KEY'],
      _requestTimeout = Duration(
        seconds:
            int.tryParse(dotenv.env['REQUEST_TIMEOUT_SECONDS'] ?? '5') ?? 5,
      );

  // Allow custom base URL for different environments
  void configure({String? customBaseUrl, String? apiKey}) {
    if (customBaseUrl != null) {
      baseUrl = customBaseUrl;
    }
    if (apiKey != null) {
      _apiKey = apiKey;
    }
  }

  /// Get HTTP headers with authentication
  Map<String, String> _getHeaders() {
    final headers = {
      'Content-Type': 'application/json',
    };

    // Add API key header if configured
    if (_apiKey != null && _apiKey!.isNotEmpty) {
      headers['X-API-Key'] = _apiKey!;
    }

    return headers;
  }

  Future<void> selfDriveTrain({
    required int hubId,
    required bool selfDrive,
  }) async {
    final url = Uri.parse('$baseUrl/selfdrive');

    int selfDriveVal = 0;
    if (selfDrive) {
      selfDriveVal = 1;
    }

    try {
      final payload = {'hub_id': hubId, 'self_drive': selfDriveVal};

      final response = await http
          .post(
            url,
            headers: _getHeaders(),
            body: jsonEncode(payload),
          )
          .timeout(_requestTimeout);

      if (response.statusCode != 200) {
        throw TrainWebServiceException(
          'Failed to switch self drive on train: ${response.body}',
        );
      }
    } catch (e) {
      throw TrainWebServiceException(
        'Network error while controlling train: $e',
      );
    }
  }

  Future<void> controlTrain({required int hubId, required int power}) async {
    final url = Uri.parse('$baseUrl/train');

    try {
      final payload = {'hub_id': hubId, 'power': power};

      final response = await http
          .post(
            url,
            headers: _getHeaders(),
            body: jsonEncode(payload),
          )
          .timeout(_requestTimeout);

      if (response.statusCode != 200) {
        throw TrainWebServiceException(
          'Failed to control train: ${response.body}',
        );
      }
    } catch (e) {
      throw TrainWebServiceException(
        'Network error while controlling train: $e',
      );
    }
  }

  Future<void> controlSwitch({
    required int hubId,
    required String switchId, // "SWITCH_A", "SWITCH_B", etc.
    required SwitchPosition position,
  }) async {
    final url = Uri.parse('$baseUrl/switch');

    final positionStr = position.toString().split('.').last;
    final switchName = switchId.substring(
      switchId.lastIndexOf("_") + 1,
      switchId.length,
    );

    try {
      final response = await http.post(
        url,
        headers: _getHeaders(),
        body: jsonEncode({
          'hub_id': hubId,
          'switch': switchName,
          'position': positionStr,
        }),
      );

      if (response.statusCode != 200) {
        throw TrainWebServiceException(
          'Failed to control switch: ${response.body}',
        );
      }
    } catch (e) {
      throw TrainWebServiceException(
        'Network error while controlling switch: $e',
      );
    }
  }

  Future<void> resetBluetooth() async {
    final url = Uri.parse('$baseUrl/reset');

    try {
      final response = await http
          .post(url, headers: _getHeaders())
          .timeout(_requestTimeout);

      if (response.statusCode != 200) {
        throw TrainWebServiceException(
          'Failed to reset bluetooth: ${response.body}',
        );
      }
    } catch (e) {
      throw TrainWebServiceException(
        'Network error while resetting bluetooth: $e',
      );
    }
  }

  Future<TrainStatus> getConnectedTrains() async {
    final url = Uri.parse('$baseUrl/connected/trains');

    try {
      final response = await http
          .get(url, headers: _getHeaders())
          .timeout(_requestTimeout);

      if (response.statusCode != 200) {
        throw TrainWebServiceException(
          'Failed to get connected trains: ${response.body}',
        );
      }

      final data = jsonDecode(response.body) as Map<String, dynamic>;
      // final data = {
      //   "connected_trains": 1,
      //   "trains": {
      //     "21": {
      //       "status": "running",
      //       "speed": 8.2,
      //       "direction": "backward",
      //       "name": "Train Hub 1",
      //       "last_update_seconds_ago": 4.41,
      //       "rssi": -86
      //     },
      //     "22": {
      //       "status": "running",
      //       "speed": 8.2,
      //       "direction": "backward",
      //       "name": "Train Hub 2",
      //       "last_update_seconds_ago": 4.41,
      //       "rssi": -86
      //     }
      //   }
      // };
      return TrainStatus.fromJson(data);
    } catch (e) {
      throw TrainWebServiceException(
        'Network error while getting connected trains: $e',
      );
    }
  }

  Future<int> getConnectedSwitches() async {
    final url = Uri.parse('$baseUrl/connected/switches');

    try {
      final response = await http
          .get(url, headers: _getHeaders())
          .timeout(_requestTimeout);

      if (response.statusCode != 200) {
        throw TrainWebServiceException(
          'Failed to get connected switches: ${response.body}',
        );
      }

      final data = jsonDecode(response.body) as Map<String, dynamic>;

      // final data = {
      //   "connected_switches": 1,
      //   "switches": {
      //     "1": {
      //       "position": 1,
      //       "last_update_seconds_ago": 0.77,
      //       "name": "Technic Hub 1",
      //       "status": 97,
      //       "connected": true
      //     },
      //     "2": {
      //       "position": 1,
      //       "last_update_seconds_ago": 0.77,
      //       "name": "Technic Hub 2",
      //       "status": 97,
      //       "connected": true
      //     }
      //   }
      // };
      return data['connected_switches'] as int;
    } catch (e) {
      throw TrainWebServiceException(
        'Network error while getting connected switches: $e',
      );
    }
  }

  Future<ConnectionStatus> getConnectionStatus() async {
    final trainStatus = await getConnectedTrains();
    return ConnectionStatus(
      connectedTrains: trainStatus.connectedTrains,
      connectedSwitches: await getConnectedSwitches(),
    );
  }

  /// Test connection to a server without modifying singleton configuration
  ///
  /// Uses a shorter timeout (3 seconds) for testing purposes.
  /// Throws [TrainWebServiceException] on connection failure.
  static Future<ConnectionStatus> testConnection({
    required String baseUrl,
    String? apiKey,
    Duration timeout = const Duration(seconds: 3),
  }) async {
    final headers = {'Content-Type': 'application/json'};
    if (apiKey?.isNotEmpty ?? false) {
      headers['X-API-Key'] = apiKey!;
    }

    final trainUrl = Uri.parse('$baseUrl/connected/trains');
    final switchUrl = Uri.parse('$baseUrl/connected/switches');

    try {
      final trainResponse =
          await http.get(trainUrl, headers: headers).timeout(timeout);
      final switchResponse =
          await http.get(switchUrl, headers: headers).timeout(timeout);

      if (trainResponse.statusCode != 200 || switchResponse.statusCode != 200) {
        throw TrainWebServiceException(
          'Server returned error status: ${trainResponse.statusCode}',
        );
      }

      final trainData = jsonDecode(trainResponse.body) as Map<String, dynamic>;
      final switchData =
          jsonDecode(switchResponse.body) as Map<String, dynamic>;

      return ConnectionStatus(
        connectedTrains: trainData['connected_trains'] as int,
        connectedSwitches: switchData['connected_switches'] as int,
      );
    } catch (e) {
      if (e is TrainWebServiceException) rethrow;
      throw TrainWebServiceException('Connection failed: $e');
    }
  }

  Future<SwitchStatus> getSwitchStatus() async {
    final url = Uri.parse('$baseUrl/connected/switches');

    try {
      final response = await http
          .get(url, headers: _getHeaders())
          .timeout(_requestTimeout);

      if (response.statusCode != 200) {
        throw TrainWebServiceException(
          'Failed to get switch status: ${response.body}',
        );
      }

      final data = jsonDecode(response.body) as Map<String, dynamic>;
      // final data = {
      //   "connected_switches": 1,
      //   "switches": {
      //     "1": {
      //       "position": 1,
      //       "last_update_seconds_ago": 0.77,
      //       "name": "Technic Hub 1",
      //       "status": 97,
      //       "connected": true
      //     },
      //     "2": {
      //       "position": 1,
      //       "last_update_seconds_ago": 0.77,
      //       "name": "Technic Hub 2",
      //       "status": 97,
      //       "connected": true
      //     }
      //   }
      // };
      return SwitchStatus.fromJson(data);
    } catch (e) {
      throw TrainWebServiceException(
        'Network error while getting switch status: $e',
      );
    }
  }

  Future<void> disconnectAllSwitches() async {
    await resetBluetooth();
  }
}
