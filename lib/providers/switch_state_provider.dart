import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../models/switch_status.dart';
import '../services/lego-webservice.dart';

class SwitchStateProvider with ChangeNotifier {
  final TrainWebService _webService;
  SwitchStatus? _switchStatus;
  String? _error;
  Timer? _pollTimer;
  late final Duration _pollInterval;

  SwitchStateProvider(this._webService) {
    _pollInterval = Duration(
      seconds: int.tryParse(dotenv.env['POLL_INTERVAL_SECONDS'] ?? '1') ?? 1,
    );
    _startPolling();
  }

  SwitchStatus? get switchStatus => _switchStatus;
  String? get error => _error;
  bool get isLoading => _switchStatus == null && _error == null;

  void _startPolling() {
    // Initial fetch
    _fetchSwitchStatus();

    // Set up periodic polling
    _pollTimer = Timer.periodic(_pollInterval, (_) => _fetchSwitchStatus());
  }

  Future<void> _fetchSwitchStatus() async {
    try {
      final status = await _webService.getSwitchStatus();
      _error = null; // Clear error on success
      _switchStatus = status;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      debugPrint('Error fetching switch status: $e');
      notifyListeners();
    }
  }

  Future<void> controlSwitch({
    required int hubId,
    required String switchId,
    required SwitchPosition position,
  }) async {
    try {
      await _webService.controlSwitch(
        hubId: hubId,
        switchId: switchId,
        position: position,
      );
      // Give the physical switch time to move before fetching new status
      await Future.delayed(const Duration(milliseconds: 500));
      await _fetchSwitchStatus();
      // Fetch one more time after another delay to ensure we have the final position
      await Future.delayed(const Duration(milliseconds: 500));
      await _fetchSwitchStatus();
    } catch (e) {
      _error = e.toString();
      debugPrint('Error controlling switch: $e');
      notifyListeners();
      rethrow;
    }
  }

  Future<void> disconnectAll() async {
    try {
      await _webService.disconnectAllSwitches();
      await _fetchSwitchStatus();
    } catch (e) {
      _error = e.toString();
      debugPrint('Error disconnecting all switches: $e');
      notifyListeners();
      rethrow;
    }
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    super.dispose();
  }
}
