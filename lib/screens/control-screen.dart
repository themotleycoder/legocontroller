import 'package:flutter/material.dart';
import 'dart:math';
import '../services/lego-service.dart';
import '../utils/constants.dart';

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
    final bool hasConnectedTrains = _legoService.connectedHubs.any(
            (hub) => hub.state == HubConnectionState.connected
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Train Controls'),
        elevation: 2,
        actions: [
          if (hasConnectedTrains)
            IconButton(
              icon: const Icon(Icons.bluetooth_disabled),
              tooltip: 'Disconnect All',
              onPressed: () => _showDisconnectAllDialog(context),
            ),
        ],
      ),
      body: !hasConnectedTrains
          ? _buildNoTrainsMessage()
          : ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _legoService.connectedHubs.length,
        itemBuilder: (context, index) {
          final hub = _legoService.connectedHubs[index];
          return _buildTrainControl(hub);
        },
      ),
    );
  }

  Widget _buildTrainControl(ConnectedHub hub) {
    // Initialize speed for this train if not already set
    _trainSpeeds.putIfAbsent(hub.device.deviceId, () => 0);
    final speed = _trainSpeeds[hub.device.deviceId]!;
    final bool isMoving = speed != 0;
    final String direction = speed > 0 ? 'Forward' : speed < 0 ? 'Backward' : 'Stopped';

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 0,
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Train Header with Status
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        hub.device.name ?? 'Unknown Train',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'ID: ${hub.device.deviceId}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                StreamBuilder<HubConnectionState>(
                  stream: hub.stateController.stream,
                  initialData: hub.state,
                  builder: (context, snapshot) {
                    final state = snapshot.data!;
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: _getStatusColor(state).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: _getStatusColor(state),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            state.toString().split('.').last,
                            style: TextStyle(
                              color: _getStatusColor(state),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ],
            ),
            const Divider(height: 32),

            // Speed and Direction Display
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  speed > 0
                      ? Icons.arrow_forward
                      : speed < 0
                      ? Icons.arrow_back
                      : Icons.remove,
                  color: isMoving ? Colors.green : Colors.grey,
                  size: 24,
                ),
                const SizedBox(width: 8),
                Text(
                  '${speed.abs()}%',
                  style: Theme.of(context).textTheme.displaySmall?.copyWith(
                    color: isMoving ? Colors.green : Colors.grey,
                  ),
                ),
              ],
            ),
            Center(
              child: Text(
                direction,
                style: TextStyle(
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Speed Controls
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _SpeedButton(
                  icon: Icons.remove,
                  onPressed: speed > -100
                      ? () => _updateTrainSpeed(hub.device.deviceId, max(speed - 10, -100))
                      : null,
                  color: Colors.red,
                ),
                SizedBox(
                  width: 180,
                  child: SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                      activeTrackColor: Colors.blue,
                      inactiveTrackColor: Colors.grey[300],
                      thumbColor: Colors.blue,
                      trackHeight: 4,
                    ),
                    child: Slider(
                      value: speed.toDouble(),
                      min: -100,
                      max: 100,
                      divisions: 20,
                      label: '${speed.abs()}%',
                      onChanged: (value) => _updateTrainSpeed(hub.device.deviceId, value.toInt()),
                    ),
                  ),
                ),
                _SpeedButton(
                  icon: Icons.add,
                  onPressed: speed < 100
                      ? () => _updateTrainSpeed(hub.device.deviceId, min(speed + 10, 100))
                      : null,
                  color: Colors.green,
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Direction Controls
            Row(
              children: [
                Expanded(
                  child: _ControlButton(
                    icon: Icons.arrow_back_ios,
                    onPressed: () => _updateTrainSpeed(hub.device.deviceId, -50),
                    color: speed < 0 ? Colors.yellow : Colors.grey.shade300,
                  ),
                ),
                const SizedBox(width: 8),
                _ControlButton(
                  icon: Icons.stop,
                  onPressed: isMoving ? () => _updateTrainSpeed(hub.device.deviceId, 0) : null,
                  color: speed != 0 ? Colors.red : Colors.grey.shade300,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _ControlButton(
                    icon: Icons.arrow_forward_ios,
                    onPressed: () => _updateTrainSpeed(hub.device.deviceId, 50),
                    color: speed > 0 ? Colors.yellow : Colors.grey.shade300,
                  ),
                ),
              ],
            ),

            // Disconnect Button
            const SizedBox(height: 16),
            TextButton.icon(
              onPressed: () => _showDisconnectDialog(context, hub),
              icon: const Icon(Icons.bluetooth_disabled),
              label: const Text('Disconnect'),
              style: TextButton.styleFrom(
                foregroundColor: Colors.red,
              ),
            ),
          ],
        ),
      ),
    );
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
            content: Text('Error controlling train: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _showDisconnectDialog(BuildContext context, ConnectedHub hub) {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Disconnect Train?'),
        content: Text(
          'Are you sure you want to disconnect ${hub.device.name ?? "this train"}?\n\n'
              'The train will stop moving if currently in motion.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              // Stop the train first
              await _updateTrainSpeed(hub.device.deviceId, 0);
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
        title: const Text('Disconnect All Trains?'),
        content: const Text(
          'Are you sure you want to disconnect all trains?\n\n'
              'All trains will stop moving if currently in motion.',
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
                await _updateTrainSpeed(hub.device.deviceId, 0);
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

  Color _getStatusColor(HubConnectionState state) {
    switch (state) {
      case HubConnectionState.connected:
        return Colors.green;
      case HubConnectionState.connecting:
        return Colors.orange;
      case HubConnectionState.error:
        return Colors.red;
      case HubConnectionState.disconnected:
        return Colors.grey;
    }
  }

  Widget _buildNoTrainsMessage() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.train_outlined,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'No trains connected',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Go to the Connect tab to add trains',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }
}

class _SpeedButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onPressed;
  final Color color;

  const _SpeedButton({
    required this.icon,
    required this.onPressed,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 40,
      height: 40,
      child: MaterialButton(
        onPressed: onPressed,
        color: color,
        disabledColor: Colors.grey,
        shape: const CircleBorder(),
        padding: EdgeInsets.zero,
        child: Icon(
          icon,
          size: 24,
          color: Colors.white,
        ),
      ),
    );
  }
}

class _ControlButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onPressed;
  final Color color;

  const _ControlButton({
    required this.icon,
    required this.onPressed,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 40,
      height: 40,
      child: MaterialButton(
        onPressed: onPressed,
        color: color,
        disabledColor: Colors.grey,
        shape: const CircleBorder(),
        padding: EdgeInsets.zero,
        child: Icon(
          icon,
          size: 24,
          color: Colors.white,
        ),
      ),
    );
  }
}