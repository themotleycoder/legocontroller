import 'package:flutter/foundation.dart';
import '../services/voice_control_service.dart';
import '../services/voice_command_parser.dart';
import '../services/lego-webservice.dart';
import 'train_state_provider.dart';
import 'switch_state_provider.dart';
import '../models/switch_status.dart';

class VoiceControlProvider extends ChangeNotifier {
  final VoiceControlService _voiceService = VoiceControlService();
  final TrainWebService _trainService = TrainWebService();
  
  TrainStateProvider? _trainProvider;
  SwitchStateProvider? _switchProvider;
  
  bool _isInitialized = false;
  bool _isListening = false;
  String _lastCommand = '';
  String _lastStatus = '';
  String? _lastError;

  bool get isInitialized => _isInitialized;
  bool get isListening => _isListening;
  String get lastCommand => _lastCommand;
  String get lastStatus => _lastStatus;
  String? get lastError => _lastError;

  void setProviders({
    required TrainStateProvider trainProvider,
    required SwitchStateProvider switchProvider,
  }) {
    _trainProvider = trainProvider;
    _switchProvider = switchProvider;
  }

  Future<bool> initialize() async {
    try {
      _isInitialized = await _voiceService.initialize();
      
      if (_isInitialized) {
        // Listen for voice commands
        _voiceService.commandStream.listen((command) {
          _processVoiceCommand(command);
        });

        // Listen for listening state changes
        _voiceService.listeningState.listen((listening) {
          _isListening = listening;
          notifyListeners();
        });

        // Listen for status updates
        _voiceService.statusStream.listen((status) {
          _lastStatus = status;
          notifyListeners();
        });
      }

      notifyListeners();
      return _isInitialized;
    } catch (e) {
      if (kDebugMode) {
        print('Error initializing voice control: $e');
      }
      _lastError = 'Failed to initialize voice control: $e';
      notifyListeners();
      return false;
    }
  }

  Future<void> startListening() async {
    if (!_isInitialized) {
      await initialize();
      if (!_isInitialized) return;
    }

    _lastError = null;
    await _voiceService.startListening();
    notifyListeners();
  }

  Future<void> stopListening() async {
    await _voiceService.stopListening();
    notifyListeners();
  }

  void _processVoiceCommand(String command) async {
    _lastCommand = command;
    _lastError = null;
    
    try {
      // Get current train metadata from train provider
      final trainStatus = _trainProvider?.trainStatus;
      
      // Get current train speeds from TrainStateProvider
      Map<String, int>? currentTrainSpeeds;
      if (_trainProvider != null && trainStatus?.trains != null) {
        currentTrainSpeeds = {};
        for (final trainId in trainStatus!.trains.keys) {
          currentTrainSpeeds[trainId] = _trainProvider!.getTrainSpeed(trainId);
        }
      }
      
      final parsedCommand = VoiceCommandParser.parse(command, 
        trainStatus: trainStatus, 
        currentTrainSpeeds: currentTrainSpeeds);

      if (!parsedCommand.isValid) {
        _lastError = parsedCommand.error;
        notifyListeners();
        return;
      }

      switch (parsedCommand.type) {
        case VoiceCommandType.trainControl:
          await _handleTrainControl(parsedCommand);
          break;
        case VoiceCommandType.switchControl:
          await _handleSwitchControl(parsedCommand);
          break;
        case VoiceCommandType.selfDrive:
          await _handleSelfDriveControl(parsedCommand);
          break;
        case VoiceCommandType.emergencyStop:
          await _handleEmergencyStop();
          break;
        case VoiceCommandType.unknown:
          _lastError = 'Unknown command: $command';
          break;
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error processing voice command: $e');
      }
      _lastError = 'Error processing command: $e';
    }
    
    notifyListeners();
  }

  Future<void> _handleTrainControl(ParsedVoiceCommand command) async {
    if (command.hubId == null || command.power == null) {
      _lastError = 'Invalid train control command';
      return;
    }

    try {
      await _trainService.controlTrain(
        hubId: command.hubId!,
        power: command.power!,
      );
      
      // Update the train provider if available
      if (_trainProvider != null) {
        await _trainProvider!.controlTrain(
          hubId: command.hubId!,
          power: command.power!,
        );
      }
      
      _lastStatus = 'Train ${command.hubId} ${command.direction} at power ${command.power?.abs()}';
    } catch (e) {
      _lastError = 'Failed to control train: $e';
    }
  }

  Future<void> _handleSwitchControl(ParsedVoiceCommand command) async {
    if (command.hubId == null || command.switchPosition == null) {
      _lastError = 'Invalid switch control command';
      return;
    }

    try {
      await _trainService.controlSwitch(
        hubId: command.hubId!,
        switchId: command.switchId ?? 'SWITCH_A',
        position: command.switchPosition!,
      );
      
      // Update the switch provider if available
      if (_switchProvider != null) {
        await _switchProvider!.controlSwitch(
          hubId: command.hubId!,
          switchId: command.switchId ?? 'SWITCH_A',
          position: command.switchPosition!,
        );
      }
      
      final positionName = command.switchPosition == SwitchPosition.STRAIGHT ? 'straight' : 'diverging';
      _lastStatus = 'Switch ${command.hubId} set to $positionName';
    } catch (e) {
      _lastError = 'Failed to control switch: $e';
    }
  }

  Future<void> _handleSelfDriveControl(ParsedVoiceCommand command) async {
    if (command.hubId == null || command.selfDrive == null) {
      _lastError = 'Invalid self drive command';
      return;
    }

    try {
      await _trainService.selfDriveTrain(
        hubId: command.hubId!,
        selfDrive: command.selfDrive!,
      );
      
      // Update the train provider if available
      if (_trainProvider != null) {
        await _trainProvider!.selfDriveTrain(
          hubId: command.hubId!,
          selfDrive: command.selfDrive!,
        );
      }
      
      final action = command.selfDrive! ? 'enabled' : 'disabled';
      _lastStatus = 'Self drive $action for train ${command.hubId}';
    } catch (e) {
      _lastError = 'Failed to control self drive: $e';
    }
  }

  Future<void> _handleEmergencyStop() async {
    try {
      // Get current train status to stop all trains
      if (_trainProvider != null) {
        final trainStatus = _trainProvider!.trainStatus;
        if (trainStatus != null) {
          for (final trainId in trainStatus.trains.keys) {
            final hubId = int.parse(trainId);
            await _trainService.controlTrain(hubId: hubId, power: 0);
          }
        }
      } else {
        // Fallback: try to stop common train IDs
        for (int i = 1; i <= 10; i++) {
          try {
            await _trainService.controlTrain(hubId: i, power: 0);
          } catch (e) {
            // Ignore errors for non-existent trains
          }
        }
      }
      
      _lastStatus = 'Emergency stop executed - all trains stopped';
    } catch (e) {
      _lastError = 'Failed to execute emergency stop: $e';
    }
  }

  @override
  void dispose() {
    _voiceService.dispose();
    super.dispose();
  }
}