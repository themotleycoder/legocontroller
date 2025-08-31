import 'package:flutter/foundation.dart';
import '../models/switch_status.dart';
import '../models/train_status.dart';

enum VoiceCommandType {
  trainControl,
  switchControl,
  selfDrive,
  emergencyStop,
  unknown
}

class ParsedVoiceCommand {
  final VoiceCommandType type;
  final int? hubId;
  final int? power;
  final String? direction;
  final String? switchId;
  final SwitchPosition? switchPosition;
  final bool? selfDrive;
  final String originalCommand;
  final String? error;

  const ParsedVoiceCommand({
    required this.type,
    this.hubId,
    this.power,
    this.direction,
    this.switchId,
    this.switchPosition,
    this.selfDrive,
    required this.originalCommand,
    this.error,
  });

  bool get isValid => error == null;
}

class VoiceCommandParser {
  static const Map<String, int> _speedWords = {
    'slow': 30,
    'medium': 50,
    'fast': 80,
    'full': 100,
    'half': 50,
    'quarter': 25,
    'max': 100,
    'maximum': 100,
    'minimum': 10,
    'min': 10,
  };

  // Dynamic train name mapping - will be populated from metadata
  static Map<String, int> _trainNames = {};

  static const Map<String, SwitchPosition> _switchPositions = {
    'straight': SwitchPosition.STRAIGHT,
    'diverging': SwitchPosition.DIVERGING,
    'left': SwitchPosition.STRAIGHT,
    'right': SwitchPosition.DIVERGING,
    'main': SwitchPosition.STRAIGHT,
    'side': SwitchPosition.DIVERGING,
  };

  /// Update train names from metadata
  static void updateTrainNames(TrainStatus? trainStatus) {
    _trainNames.clear();
    
    if (trainStatus?.trains != null) {
      trainStatus!.trains.forEach((trainId, train) {
        final hubId = int.tryParse(trainId);
        
        if (hubId != null) {
          // Use the train's name from metadata
          final name = train.name.toLowerCase().trim();
          if (name.isNotEmpty && name != 'unknown' && name != 'null') {
            _trainNames[name] = hubId;
            
            // Also add common variations
            if (name.contains('passenger')) {
              _trainNames['passenger'] = hubId;
            }
            if (name.contains('freight')) {
              _trainNames['freight'] = hubId;
            }
            if (name.contains('cargo')) {
              _trainNames['cargo'] = hubId;
            }
            if (name.contains('red')) {
              _trainNames['red'] = hubId;
            }
            if (name.contains('blue')) {
              _trainNames['blue'] = hubId;
            }
          }
          
          // Add some common aliases based on position
          final trainsList = trainStatus.trains.keys.toList()..sort();
          final position = trainsList.indexOf(trainId);
          
          switch (position) {
            case 0:
              _trainNames['first'] = hubId;
              _trainNames['main'] = hubId;
              break;
            case 1:
              _trainNames['second'] = hubId;
              break;
            case 2:
              _trainNames['third'] = hubId;
              break;
          }
        }
      });
    }
    
  }

  static ParsedVoiceCommand parse(String command, {TrainStatus? trainStatus, Map<String, int>? currentTrainSpeeds}) {
    // Update train names if we have metadata
    if (trainStatus != null) {
      updateTrainNames(trainStatus);
    }
    
    final words = command.toLowerCase().trim().split(RegExp(r'\s+'));

    // Emergency stop commands
    if (_isEmergencyStop(words)) {
      return ParsedVoiceCommand(
        type: VoiceCommandType.emergencyStop,
        originalCommand: command,
      );
    }

    // Train commands
    if (_isTrainCommand(words)) {
      return _parseTrainCommand(words, command, trainStatus: trainStatus, currentTrainSpeeds: currentTrainSpeeds);
    }

    // Switch commands
    if (_isSwitchCommand(words)) {
      return _parseSwitchCommand(words, command);
    }

    // Self drive commands
    if (_isSelfDriveCommand(words)) {
      return _parseSelfDriveCommand(words, command);
    }

    return ParsedVoiceCommand(
      type: VoiceCommandType.unknown,
      originalCommand: command,
      error: 'Could not understand command: $command',
    );
  }

  static bool _isEmergencyStop(List<String> words) {
    return words.contains('stop') && 
           (words.contains('all') || words.contains('everything') || words.contains('emergency'));
  }

  static bool _isTrainCommand(List<String> words) {
    return words.contains('train') || words.contains('locomotive');
  }

  static bool _isSwitchCommand(List<String> words) {
    return words.contains('switch') || words.contains('turnout');
  }

  static bool _isSelfDriveCommand(List<String> words) {
    return words.contains('self') && words.contains('drive');
  }

  static ParsedVoiceCommand _parseTrainCommand(List<String> words, String command, {TrainStatus? trainStatus, Map<String, int>? currentTrainSpeeds}) {
    try {
      // Find train ID - support multiple patterns
      int? hubId;
      
      // Pattern 1: "train [ID]" or "locomotive [ID]"
      for (int i = 0; i < words.length; i++) {
        if ((words[i] == 'train' || words[i] == 'locomotive') && i + 1 < words.length) {
          final idString = words[i + 1];
          hubId = int.tryParse(idString);
          if (hubId == null) {
            // Try to parse train names from our mapping
            hubId = _trainNames[idString];
            if (hubId == null) {
              // Try to parse old common train names for backward compatibility
              switch (idString) {
                case 'one':
                  // Try to get first train from metadata, fallback to 101
                  hubId = _getFirstTrainId() ?? 101;
                  break;
                case 'two':
                  // Try to get second train from metadata, fallback to 102
                  hubId = _getSecondTrainId() ?? 102;
                  break;
                case 'three':
                case 'third':
                  hubId = _getThirdTrainId() ?? 3;
                  break;
              }
            }
          }
          break;
        }
      }
      
      // Pattern 2: "[NAME] train" - check if any word before "train" matches a train name
      if (hubId == null) {
        for (int i = 0; i < words.length; i++) {
          if (words[i] == 'train' || words[i] == 'locomotive') {
            // Check all combinations of words before "train"
            for (int j = 0; j < i; j++) {
              // Single word
              final singleWord = words[j];
              if (_trainNames.containsKey(singleWord)) {
                hubId = _trainNames[singleWord];
                break;
              }
              
              // Multiple words combined
              for (int k = j + 1; k <= i; k++) {
                final multiWord = words.sublist(j, k).join(' ');
                if (_trainNames.containsKey(multiWord)) {
                  hubId = _trainNames[multiWord];
                  break;
                }
              }
              if (hubId != null) break;
            }
            break;
          }
        }
      }
      
      // Pattern 3: Direct numeric ID anywhere in the command
      if (hubId == null) {
        for (final word in words) {
          final numericId = int.tryParse(word);
          if (numericId != null) {
            hubId = numericId;
            break;
          }
        }
      }

      if (hubId == null) {
        // Enhanced error message with available options
        final availableTrains = _trainNames.keys.toList()..sort();
        final availableIds = _trainNames.values.toSet().toList()..sort();
        
        String errorMsg = 'Could not identify train ID from "$command"';
        if (availableTrains.isNotEmpty) {
          errorMsg += '. Available train names: ${availableTrains.join(', ')}';
        }
        if (availableIds.isNotEmpty) {
          errorMsg += '. Available IDs: ${availableIds.join(', ')}';
        }
        
        return ParsedVoiceCommand(
          type: VoiceCommandType.trainControl,
          originalCommand: command,
          error: errorMsg,
        );
      }

      // Check for stop command
      if (words.contains('stop')) {
        return ParsedVoiceCommand(
          type: VoiceCommandType.trainControl,
          hubId: hubId,
          power: 0,
          direction: 'stop',
          originalCommand: command,
        );
      }

      // Determine direction
      String? direction;
      int power = 50; // default speed
      bool hasRelativeSpeed = false;

      // Check for relative speed commands first
      hasRelativeSpeed = words.contains('faster') || words.contains('slower') || 
                        words.contains('speed') && (words.contains('up') || words.contains('down'));

      if (words.contains('forward') || words.contains('ahead') || words.contains('go')) {
        direction = 'forward';
      } else if (words.contains('backward') || words.contains('back') || words.contains('reverse')) {
        direction = 'backward';
      } else if (hasRelativeSpeed && trainStatus != null) {
        // For relative speed commands, try to maintain current direction
        final currentTrain = trainStatus.trains[hubId.toString()];
        if (currentTrain != null) {
          direction = currentTrain.direction.toLowerCase() == 'backward' ? 'backward' : 'forward';
        }
      }

      if (direction == null) {
        return ParsedVoiceCommand(
          type: VoiceCommandType.trainControl,
          originalCommand: command,
          error: 'Could not determine direction (forward/backward)',
        );
      }

      // Parse speed (including relative speed adjustments)
      int speedAdjustment = 0;
      
      // Check for relative speed words first
      if (words.contains('faster') || words.contains('speed up')) {
        speedAdjustment = 10;
      } else if (words.contains('slower') || words.contains('slow down')) {
        speedAdjustment = -10;
      }
      
      // If relative speed, we need current train speed
      if (speedAdjustment != 0) {
        int currentSpeed = 0;
        
        // Try to get current speed from TrainStateProvider first (more accurate)
        if (currentTrainSpeeds != null) {
          currentSpeed = (currentTrainSpeeds[hubId.toString()] ?? 0).abs();
        } else if (trainStatus != null) {
          // Fallback to metadata speed
          final currentTrain = trainStatus.trains[hubId.toString()];
          if (currentTrain != null) {
            currentSpeed = currentTrain.speed.abs().toInt();
          }
        }
          
        // Calculate new speed
        int newSpeed = currentSpeed + speedAdjustment;
        newSpeed = newSpeed.clamp(0, 100);
        
        
        // Direction was already set above based on current train state for relative speed commands
        
        power = newSpeed;
      } else {
        // Parse absolute speed values
        for (final word in words) {
          if (_speedWords.containsKey(word)) {
            power = _speedWords[word]!;
            break;
          }
          // Try to parse numeric speed
          final numericSpeed = int.tryParse(word);
          if (numericSpeed != null && numericSpeed >= 0 && numericSpeed <= 100) {
            power = numericSpeed;
            break;
          }
        }
      }

      // Apply direction to power
      if (direction == 'backward') {
        power = -power;
      }

      return ParsedVoiceCommand(
        type: VoiceCommandType.trainControl,
        hubId: hubId,
        power: power,
        direction: direction,
        originalCommand: command,
      );
    } catch (e) {
      return ParsedVoiceCommand(
        type: VoiceCommandType.trainControl,
        originalCommand: command,
        error: 'Error parsing train command: $e',
      );
    }
  }

  static ParsedVoiceCommand _parseSwitchCommand(List<String> words, String command) {
    try {
      // Find switch ID
      int? hubId;
      for (int i = 0; i < words.length; i++) {
        if ((words[i] == 'switch' || words[i] == 'turnout') && i + 1 < words.length) {
          final idString = words[i + 1];
          hubId = int.tryParse(idString);
          if (hubId == null) {
            // Try to parse common switch names
            switch (idString) {
              case 'one':
              case 'first':
              case 'a':
                hubId = 1;
                break;
              case 'two':
              case 'second':
              case 'b':
                hubId = 2;
                break;
              case 'three':
              case 'third':
              case 'c':
                hubId = 3;
                break;
            }
          }
          break;
        }
      }

      if (hubId == null) {
        return ParsedVoiceCommand(
          type: VoiceCommandType.switchControl,
          originalCommand: command,
          error: 'Could not identify switch ID',
        );
      }

      // Find position
      SwitchPosition? position;
      for (final word in words) {
        if (_switchPositions.containsKey(word)) {
          position = _switchPositions[word];
          break;
        }
      }

      if (position == null) {
        return ParsedVoiceCommand(
          type: VoiceCommandType.switchControl,
          originalCommand: command,
          error: 'Could not determine switch position (straight/diverging/left/right)',
        );
      }

      return ParsedVoiceCommand(
        type: VoiceCommandType.switchControl,
        hubId: hubId,
        switchId: 'SWITCH_A', // Default to A, can be made configurable
        switchPosition: position,
        originalCommand: command,
      );
    } catch (e) {
      return ParsedVoiceCommand(
        type: VoiceCommandType.switchControl,
        originalCommand: command,
        error: 'Error parsing switch command: $e',
      );
    }
  }

  static ParsedVoiceCommand _parseSelfDriveCommand(List<String> words, String command) {
    try {
      // Find train ID
      int? hubId;
      for (int i = 0; i < words.length; i++) {
        if ((words[i] == 'train' || words[i] == 'locomotive') && i + 1 < words.length) {
          final idString = words[i + 1];
          hubId = int.tryParse(idString);
          if (hubId == null) {
            // Try to parse train names from our mapping
            hubId = _trainNames[idString];
            if (hubId == null) {
              // Try to parse old common train names for backward compatibility
              switch (idString) {
                case 'one':
                  hubId = _getFirstTrainId() ?? 101; // Map to first actual train
                  break;
                case 'two':
                  hubId = _getSecondTrainId() ?? 102; // Map to second actual train
                  break;
                default:
                  hubId = _getFirstTrainId() ?? 101; // Default to first train
                  break;
              }
            }
          }
          break;
        }
      }

      // Determine if enabling or disabling
      bool enableSelfDrive = true;
      if (words.contains('off') || words.contains('disable') || words.contains('stop')) {
        enableSelfDrive = false;
      }

      return ParsedVoiceCommand(
        type: VoiceCommandType.selfDrive,
        hubId: hubId ?? 1, // Default to train 1
        selfDrive: enableSelfDrive,
        originalCommand: command,
      );
    } catch (e) {
      return ParsedVoiceCommand(
        type: VoiceCommandType.selfDrive,
        originalCommand: command,
        error: 'Error parsing self drive command: $e',
      );
    }
  }

  // Helper methods to get train IDs by position
  static int? _getFirstTrainId() {
    return _trainNames['first'] ?? _trainNames['main'];
  }

  static int? _getSecondTrainId() {
    return _trainNames['second'];
  }

  static int? _getThirdTrainId() {
    return _trainNames['third'];
  }
}