import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import '../models/train_status.dart';
import '../services/lego-webservice.dart';
import '../models/train_command.dart';

class TrainStateProvider with ChangeNotifier {
  final TrainWebService _webService;
  TrainStatus? _trainStatus;
  Timer? _pollTimer;
  static const _pollInterval = Duration(seconds: 1);
  
  // Track speed and direction for each train
  final Map<String, int> _trainSpeeds = {};
  final Map<String, String> _trainDirections = {};

  TrainStateProvider(this._webService) {
    _startPolling();
  }

  // Get current speed for a train
  int getTrainSpeed(String trainId) => _trainSpeeds[trainId] ?? 0;
  
  // Get current direction for a train
  String getTrainDirection(String trainId) {
    final speed = getTrainSpeed(trainId);
    if (speed == 0) return "Stopped";
    return speed > 0 ? "Forward" : "Backward";
  }

  TrainStatus? get trainStatus => _trainStatus;
  bool get isLoading => _trainStatus == null;

  void _startPolling() {
    // Initial fetch
    _fetchTrainStatus();
    
    // Set up periodic polling
    _pollTimer = Timer.periodic(_pollInterval, (_) => _fetchTrainStatus());
  }

  Future<void> _fetchTrainStatus() async {
    try {
      final status = await _webService.getConnectedTrains();
      if (_trainStatus != status) {
        _trainStatus = status;
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error fetching train status: $e');
    }
  }

  Future<void> controlTrain({
    int hubId = 0,
    required TrainCommand command,
    int power = 40,
  }) async {
    try {
      final trains = _trainStatus?.trains;
      if (trains == null || trains.isEmpty) return;

      await _webService.controlTrain(
        hubId: hubId,
        command: command,
        power: power,
      );

      // Update speed and direction tracking
      final trainId = trains.keys.elementAt(hubId).toString();
      final motorPower = switch (command) {
        TrainCommand.forward => power,
        TrainCommand.backward => -power,
        TrainCommand.stop => 0,
      };
      _trainSpeeds[trainId] = motorPower;
      _trainDirections[trainId] = motorPower == 0 ? "Stopped" : 
                                 motorPower > 0 ? "Forward" : "Backward";

      // Immediately fetch new status after control command
      await _fetchTrainStatus();
    } catch (e) {
      debugPrint('Error controlling train: $e');
      rethrow;
    }
  }

  Future<void> disconnect(String trainId) async {
    try {
      // Stop the train first
      _trainSpeeds[trainId] = 0;
      _trainDirections[trainId] = "Stopped";
      
      // Send stop command through web service
      await _webService.controlTrain(
        command: TrainCommand.stop,
      );
      
      // Update status
      await _fetchTrainStatus();
    } catch (e) {
      debugPrint('Error disconnecting train: $e');
      rethrow;
    }
  }

  Future<void> disconnectAll() async {
    try {
      // Stop all trains
      final trains = _trainStatus?.trains ?? {};
      for (final trainId in trains.keys) {
        _trainSpeeds[trainId] = 0;
        _trainDirections[trainId] = "Stopped";
      }
      
      // Reset bluetooth through web service
      await _webService.resetBluetooth();
      
      // Clear speed and direction tracking
      _trainSpeeds.clear();
      _trainDirections.clear();
      
      // Update status
      await _fetchTrainStatus();
    } catch (e) {
      debugPrint('Error disconnecting all trains: $e');
      rethrow;
    }
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    super.dispose();
  }
}
