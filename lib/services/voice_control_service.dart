import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:permission_handler/permission_handler.dart';

class VoiceControlService {
  static final VoiceControlService _instance = VoiceControlService._internal();
  factory VoiceControlService() => _instance;

  final SpeechToText _speechToText = SpeechToText();
  bool _speechEnabled = false;
  bool _isListening = false;
  String _lastWords = '';

  final StreamController<String> _commandStreamController = StreamController<String>.broadcast();
  final StreamController<bool> _listeningStateController = StreamController<bool>.broadcast();
  final StreamController<String> _statusController = StreamController<String>.broadcast();

  VoiceControlService._internal();

  Stream<String> get commandStream => _commandStreamController.stream;
  Stream<bool> get listeningState => _listeningStateController.stream;
  Stream<String> get statusStream => _statusController.stream;

  bool get isListening => _isListening;
  bool get speechEnabled => _speechEnabled;
  String get lastWords => _lastWords;

  Future<bool> initialize() async {
    try {
      // Request microphone permission
      final permissionStatus = await Permission.microphone.request();
      if (permissionStatus != PermissionStatus.granted) {
        _statusController.add('Microphone permission denied');
        return false;
      }

      _speechEnabled = await _speechToText.initialize(
        onError: (error) {
          if (kDebugMode) {
            print('Speech recognition error: $error');
          }
          _statusController.add('Speech recognition error: ${error.errorMsg}');
          _stopListening();
        },
        onStatus: (status) {
          if (kDebugMode) {
            print('Speech recognition status: $status');
          }
          _statusController.add('Status: $status');
        },
      );

      if (_speechEnabled) {
        _statusController.add('Voice control initialized successfully');
      } else {
        _statusController.add('Voice control initialization failed');
      }

      return _speechEnabled;
    } catch (e) {
      if (kDebugMode) {
        print('Error initializing voice control: $e');
      }
      _statusController.add('Error initializing voice control: $e');
      return false;
    }
  }

  Future<void> startListening() async {
    if (!_speechEnabled) {
      await initialize();
      if (!_speechEnabled) return;
    }

    if (_isListening) {
      await stopListening();
    }

    try {
      await _speechToText.listen(
        onResult: _onSpeechResult,
        listenFor: const Duration(seconds: 10),
        pauseFor: const Duration(seconds: 3),
        partialResults: true,
        localeId: 'en_US',
        cancelOnError: false,
        listenMode: ListenMode.confirmation,
      );

      _isListening = true;
      _listeningStateController.add(true);
      _statusController.add('Listening for commands...');
    } catch (e) {
      if (kDebugMode) {
        print('Error starting speech recognition: $e');
      }
      _statusController.add('Error starting speech recognition: $e');
    }
  }

  Future<void> stopListening() async {
    if (_isListening) {
      await _speechToText.stop();
      _stopListening();
    }
  }

  void _stopListening() {
    _isListening = false;
    _listeningStateController.add(false);
    _statusController.add('Stopped listening');
  }

  void _onSpeechResult(SpeechRecognitionResult result) {
    _lastWords = result.recognizedWords.toLowerCase();
    
    if (kDebugMode) {
      print('Recognized: $_lastWords (confidence: ${result.confidence})');
    }

    // Only process final results with good confidence
    if (result.finalResult && result.confidence > 0.5) {
      _commandStreamController.add(_lastWords);
      _statusController.add('Command recognized: $_lastWords');
      _stopListening();
    }
  }

  void dispose() {
    _commandStreamController.close();
    _listeningStateController.close();
    _statusController.close();
  }
}