import 'dart:async';
import 'dart:typed_data';
import 'package:universal_ble/universal_ble.dart';
import '../utils/constants.dart';
import '../utils/hub-identifier.dart';

enum HubConnectionState { disconnected, connecting, connected, error }

class ConnectedHub {
  final BleDevice device;
  final StreamController<HubConnectionState> stateController;
  HubConnectionState state;

  ConnectedHub({
    required this.device,
    required this.state,
  }) : stateController = StreamController<HubConnectionState>.broadcast();

  void updateState(HubConnectionState newState) {
    state = newState;
    stateController.add(newState);
  }

  void dispose() {
    stateController.close();
  }
}

class LegoService {
  static final LegoService _instance = LegoService._internal();
  factory LegoService() => _instance;

  LegoService._internal() {
    _initializeBle();
  }

  final Map<String, ConnectedHub> _connectedHubs = {};
  static const int maxConnections = 2;  // Limit to 2 trains

  bool get canConnectMore => _connectedHubs.length < maxConnections;
  List<ConnectedHub> get connectedHubs => _connectedHubs.values.toList();

  void _initializeBle() {
    UniversalBle.onConnectionChange = _handleConnectionChange;
    UniversalBle.onValueChange = _handleValueChange;
    UniversalBle.timeout = const Duration(seconds: 10);
  }

  void _handleConnectionChange(String deviceId, bool isConnected, String? error) {
    final hub = _connectedHubs[deviceId];
    if (hub != null) {
      if (error != null) {
        print('Connection error for ${hub.device.name}: $error');
        hub.updateState(HubConnectionState.error);
      } else {
        hub.updateState(isConnected ? HubConnectionState.connected : HubConnectionState.disconnected);
        if (!isConnected) {
          _connectedHubs.remove(deviceId);
        }
      }
    }
  }

  void _handleValueChange(String deviceId, String characteristicId, Uint8List value) {
    final hub = _connectedHubs[deviceId];
    if (hub != null) {
      print('Received value from ${hub.device.name}: ${value.map((b) => b.toRadixString(16).padLeft(2, '0')).join(' ')}');
    }
  }

  Future<List<BleDevice>> scanForDevices() async {
    List<BleDevice> devices = [];
    final Set<String> seenDeviceIds = {};  // Track unique devices

    try {
      // Set up scan result handler
      UniversalBle.onScanResult = (BleDevice device) {
        if (HubIdentifier.isLegoHub(device)) {
          // Don't add already connected devices or duplicates
          if (!_connectedHubs.containsKey(device.deviceId) &&
              !seenDeviceIds.contains(device.deviceId)) {
            print('Found LEGO Hub: ${HubIdentifier.getHubType(device)} - ${device.name}');
            seenDeviceIds.add(device.deviceId);
            devices.add(device);
          }
        }
      };

      await UniversalBle.startScan(
        scanFilter: ScanFilter(
          withServices: [LegoConstants.legoHubService],
        ),
      );

      // Scan for 10 seconds
      await Future.delayed(const Duration(seconds: 10));
      await UniversalBle.stopScan();

    } catch (e) {
      print('Scan error: $e');
      rethrow;
    }

    return devices;
  }

  Future<void> connect(BleDevice device) async {
    if (!canConnectMore) {
      throw Exception('Maximum number of connections reached');
    }

    try {
      final hub = ConnectedHub(
        device: device,
        state: HubConnectionState.connecting,
      );
      _connectedHubs[device.deviceId] = hub;

      print('Connecting to ${device.name}...');

      await UniversalBle.connect(device.deviceId);
      await UniversalBle.discoverServices(device.deviceId);

      // Set up notifications
      await UniversalBle.setNotifiable(
          device.deviceId,
          LegoConstants.legoHubService,
          LegoConstants.characteristicUuid,
          BleInputProperty.notification
      );

      hub.updateState(HubConnectionState.connected);
      print('Successfully connected to ${device.name}');

    } catch (e) {
      print('Connection error: $e');
      _connectedHubs[device.deviceId]?.updateState(HubConnectionState.error);
      await disconnect(device.deviceId);
      rethrow;
    }
  }

  Future<void> disconnect(String deviceId) async {
    try {
      final hub = _connectedHubs[deviceId];
      if (hub != null) {
        await UniversalBle.disconnect(deviceId);
        hub.updateState(HubConnectionState.disconnected);
        _connectedHubs.remove(deviceId);
      }
    } catch (e) {
      print('Disconnect error: $e');
    }
  }

  Future<void> disconnectAll() async {
    for (var deviceId in _connectedHubs.keys.toList()) {
      await disconnect(deviceId);
    }
  }

  Future<void> setMotorPower(String deviceId, int port, int power) async {
    final hub = _connectedHubs[deviceId];
    if (hub == null || hub.state != HubConnectionState.connected) {
      throw Exception('Device not connected');
    }

    power = power.clamp(-100, 100);
    int powerByte = power < 0 ? 256 + power : power;

    // Command format according to LWP 3.0:
    // [Length][Hub ID][Port Output Command][Port ID][Startup & Completion][Write Direct Mode][Mode][Power]
    final command = Uint8List.fromList([
      0x08,                // Length (8 bytes)
      0x00,                // Hub ID
      0x81,                // Port Output Command
      port,                // Port ID
      0x11,                // Execute Immediately (0x11)
      0x51,                // Write Direct Mode
      0x00,                // Mode = 0 (setPower)
      powerByte,           // Power value (-100 to 100)
    ]);

    print('Sending motor command to ${hub.device.name}: ${command.map((b) => '0x${b.toRadixString(16).padLeft(2, '0')}').join(', ')}');

    try {
      await UniversalBle.writeValue(
        deviceId,
        LegoConstants.legoHubService,
        LegoConstants.characteristicUuid,
        command,
        BleOutputProperty.withResponse,
      );
      print('Motor command sent successfully');
    } catch (e) {
      print('Error sending motor command: $e');
      rethrow;
    }
  }

  Future<void> stopMotor(String deviceId, int port) async {
    await setMotorPower(deviceId, port, 0);
  }

  void dispose() {
    disconnectAll();
    for (var hub in _connectedHubs.values) {
      hub.dispose();
    }
    _connectedHubs.clear();
  }

  Stream<HubConnectionState> getConnectionState(String deviceId) {
    return _connectedHubs[deviceId]?.stateController.stream ??
        Stream.value(HubConnectionState.disconnected);
  }

  HubConnectionState getCurrentState(String deviceId) {
    return _connectedHubs[deviceId]?.state ?? HubConnectionState.disconnected;
  }
}