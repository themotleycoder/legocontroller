import 'dart:async';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/train_status.dart';
import '../models/train_command.dart';
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

  TrainWebService._internal() : baseUrl = 'http://192.168.86.41:8000';

  // Allow custom base URL for different environments
  void configure({String? customBaseUrl}) {
    if (customBaseUrl != null) {
      baseUrl = customBaseUrl;
    }
  }

  Future<void> controlTrain({
    required int hubId,
    required int power
  }) async {
    final url = Uri.parse('$baseUrl/train');

    // final commandStr = command.toString().split('.').last.toUpperCase();

    try {
      final response = await http.post(
          url,
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'hub_id': hubId,
            'power': power
          })
      );

      if (response.statusCode != 200) {
        throw TrainWebServiceException(
            'Failed to control train: ${response.body}'
        );
      }
    } catch (e) {
      throw TrainWebServiceException(
          'Network error while controlling train: $e'
      );
    }
  }

  Future<void> controlSwitch({
    required int hubId,
    required String switchId,  // "SWITCH_A", "SWITCH_B", etc.
    required SwitchPosition position,
  }) async {
    final url = Uri.parse('$baseUrl/switch');

    final positionStr = position.toString().split('.').last;
    final switchName = switchId.substring(switchId.lastIndexOf("_")+1,switchId.length);

    try {
      final response = await http.post(
          url,
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'hub_id': hubId,
            'switch': switchName,
            'position': positionStr
          })
      );

      if (response.statusCode != 200) {
        throw TrainWebServiceException(
            'Failed to control switch: ${response.body}'
        );
      }
    } catch (e) {
      throw TrainWebServiceException(
          'Network error while controlling switch: $e'
      );
    }
  }

  Future<void> resetBluetooth() async {
    final url = Uri.parse('$baseUrl/reset');

    try {
      final response = await http.post(url);

      if (response.statusCode != 200) {
        throw TrainWebServiceException(
            'Failed to reset bluetooth: ${response.body}'
        );
      }
    } catch (e) {
      throw TrainWebServiceException(
          'Network error while resetting bluetooth: $e'
      );
    }
  }

  Future<TrainStatus> getConnectedTrains() async {
    final url = Uri.parse('$baseUrl/connected/trains');

    try {
      final response = await http.get(url);

      if (response.statusCode != 200) {
        throw TrainWebServiceException(
            'Failed to get connected trains: ${response.body}'
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
          'Network error while getting connected trains: $e'
      );
    }
  }

  Future<int> getConnectedSwitches() async {
    final url = Uri.parse('$baseUrl/connected/switches');

    try {
      final response = await http.get(url);

      if (response.statusCode != 200) {
        throw TrainWebServiceException(
            'Failed to get connected switches: ${response.body}'
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
          'Network error while getting connected switches: $e'
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

  Future<SwitchStatus> getSwitchStatus() async {
    final url = Uri.parse('$baseUrl/connected/switches');

    try {
      final response = await http.get(url);

      if (response.statusCode != 200) {
        throw TrainWebServiceException(
            'Failed to get switch status: ${response.body}'
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
          'Network error while getting switch status: $e'
      );
    }
  }

  Future<void> disconnectAllSwitches() async {
    await resetBluetooth();
  }
}
