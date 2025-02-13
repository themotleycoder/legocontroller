import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import '../models/switch_status.dart';
import '../services/lego-webservice.dart';

class SwitchStateProvider with ChangeNotifier {
  final TrainWebService _webService;
  SwitchStatus? _switchStatus;
  Timer? _pollTimer;
  static const _pollInterval = Duration(seconds: 1);

  SwitchStateProvider(this._webService) {
    _startPolling();
  }

  SwitchStatus? get switchStatus => _switchStatus;
  bool get isLoading => _switchStatus == null;

  void _startPolling() {
    // Initial fetch
    _fetchSwitchStatus();
    
    // Set up periodic polling
    _pollTimer = Timer.periodic(_pollInterval, (_) => _fetchSwitchStatus());
  }

  Future<void> _fetchSwitchStatus() async {
    try {
      final status = await _webService.getSwitchStatus();
      if (_switchStatus != status) {
        _switchStatus = status;
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error fetching switch status: $e');
    }
  }

  Future<void> controlSwitch({
    required String switchId,
    required SwitchPosition position,
  }) async {
    try {
      await _webService.controlSwitch(
        switchId: switchId,
        position: position,
      );
      // Immediately fetch new status after control command
      await _fetchSwitchStatus();
    } catch (e) {
      debugPrint('Error controlling switch: $e');
      rethrow;
    }
  }

  Future<void> disconnectAll() async {
    try {
      await _webService.disconnectAllSwitches();
      await _fetchSwitchStatus();
    } catch (e) {
      debugPrint('Error disconnecting all switches: $e');
      rethrow;
    }
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    super.dispose();
  }
}
