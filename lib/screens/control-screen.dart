import 'package:flutter/material.dart';
import '../services/lego-service.dart';
import '../utils/constants.dart';
import '../widgets/train-control-widget.dart';
import '../widgets/technic-hub-control.dart';
import '../utils/hub-identifier.dart';

class ControlScreen extends StatefulWidget {
  const ControlScreen({super.key});

  @override
  State<ControlScreen> createState() => _ControlScreenState();
}

class _ControlScreenState extends State<ControlScreen> {
  final LegoService _legoService = LegoService();
  final Map<String, int> _trainSpeeds = {};

  @override
  Widget build(BuildContext context) {
    final bool hasConnectedDevices = _legoService.connectedHubs.any(
            (hub) => hub.state == HubConnectionState.connected
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('LEGO Controls'),
        elevation: 2,
        actions: [
          if (hasConnectedDevices)
            IconButton(
              icon: const Icon(Icons.bluetooth_disabled),
              tooltip: 'Disconnect All',
              onPressed: () => _showDisconnectAllDialog(context),
            ),
        ],
      ),
      body: !hasConnectedDevices
          ? _buildNoDevicesMessage()
          : ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _legoService.connectedHubs.length,
        itemBuilder: (context, index) {
          final hub = _legoService.connectedHubs[index];
          return _buildHubControl(hub);
        },
      ),
    );
  }

  Widget _buildHubControl(ConnectedHub hub) {
    final hubType = HubIdentifier.getHubType(hub.device);
    
    if (hubType == 'Technic Hub') {
      return TechnicHubControl(
        hub: hub,
        onDisconnect: (deviceId) => _showDisconnectDialog(context, hub),
      );
    } else {
      // Initialize speed for this train if not already set
      _trainSpeeds.putIfAbsent(hub.device.deviceId, () => 0);
      final speed = _trainSpeeds[hub.device.deviceId]!;

      return TrainControlWidget(
        hub: hub,
        currentSpeed: speed,
        onSpeedChanged: _updateTrainSpeed,
        onDisconnect: (deviceId) => _showDisconnectDialog(context, hub),
      );
    }
  }

  Future<void> _updateTrainSpeed(String deviceId, int newSpeed) async {
    setState(() {
      _trainSpeeds[deviceId] = newSpeed;
    });

    try {
      await _legoService.setMotorPower(deviceId, LegoConstants.portA, newSpeed);
      await _legoService.setMotorPower(deviceId, LegoConstants.portB, newSpeed);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error controlling device: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _showDisconnectDialog(BuildContext context, ConnectedHub hub) {
    final hubType = HubIdentifier.getHubType(hub.device);
    final isTrainHub = hubType == 'Train Hub';
    
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Disconnect ${isTrainHub ? "Train" : "Device"}?'),
        content: Text(
          'Are you sure you want to disconnect ${hub.device.name ?? "this device"}?\n\n'
              '${isTrainHub ? "The train" : "The device"} will stop if currently in motion.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (isTrainHub) {
                // Stop the train first
                await _updateTrainSpeed(hub.device.deviceId, 0);
              }
              // Then disconnect
              await _legoService.disconnect(hub.device.deviceId);
              if (mounted) {
                Navigator.pop(context);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Disconnect'),
          ),
        ],
      ),
    );
  }

  Future<void> _showDisconnectAllDialog(BuildContext context) {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Disconnect All Devices?'),
        content: const Text(
          'Are you sure you want to disconnect all devices?\n\n'
              'All devices will stop if currently in motion.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              // Stop all trains first
              for (var hub in _legoService.connectedHubs) {
                if (HubIdentifier.getHubType(hub.device) == 'Train Hub') {
                  await _updateTrainSpeed(hub.device.deviceId, 0);
                }
              }
              // Then disconnect all
              await _legoService.disconnectAll();
              if (mounted) {
                Navigator.pop(context);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Disconnect All'),
          ),
        ],
      ),
    );
  }

  Widget _buildNoDevicesMessage() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.bluetooth_connected,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'No devices connected',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Go to the Connect tab to add devices',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }
}
