import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/train_status.dart';
import '../services/lego-webservice.dart';

class TrainStateProvider with ChangeNotifier {
  final TrainWebService _webService;
  TrainStatus? _trainStatus;
  Timer? _pollTimer;
  static const _pollInterval = Duration(seconds: 1);
  
  // Track speed and direction for each train
  final Map<String, int> _trainSpeeds = {};
  final Map<String, String> _trainDirections = {};
  final Map<String, bool> _trainSelfDrives = {};

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
    required int hubId,
    required int power, // Default power
  }) async {
    try {
      final trains = _trainStatus?.trains;
      if (trains == null || trains.isEmpty) return;
      
      await _webService.controlTrain(
        hubId: hubId,
        power: power,
      );

      // Update speed and direction tracking
      final trainId = hubId.toString();
      _trainSpeeds[trainId] = power;
      _trainDirections[trainId] = power == 0 ? "Stopped" :
                               power > 0 ? "Forward" : "Backward";
      
      if (kDebugMode) {
        print('Updated train $trainId power to: $power');
      }

      // Immediately fetch new status after control command
      await _fetchTrainStatus();
    } catch (e) {
      debugPrint('Error controlling train: $e');
      rethrow;
    }
  }

  Future<void> selfDriveTrain({
    required int hubId,
    required bool selfDrive,
  }) async {
    try {
      final trains = _trainStatus?.trains;
      if (trains == null || trains.isEmpty) return;

      await _webService.selfDriveTrain(
        hubId: hubId,
        selfDrive: selfDrive,
      );

      // Update speed and direction tracking
      final trainId = hubId.toString();
      _trainSelfDrives[trainId] = selfDrive;

      if (kDebugMode) {
        print('Updated train $trainId self drive to: $selfDrive');
      }

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
        hubId: int.parse(trainId),
        power: 0,
        // command: TrainCommand.stop,
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
