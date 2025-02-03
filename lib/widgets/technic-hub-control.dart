import 'package:flutter/material.dart';
import 'dart:math';
import '../services/lego-service.dart';
import '../utils/constants.dart';
import '../widgets/buttons.dart';

class TechnicHubControl extends StatefulWidget {
  final ConnectedHub hub;
  final Function(String deviceId) onDisconnect;

  const TechnicHubControl({
    super.key,
    required this.hub,
    required this.onDisconnect,
  });

  @override
  State<TechnicHubControl> createState() => _TechnicHubControlState();
}

class _TechnicHubControlState extends State<TechnicHubControl> {
  final Map<int, int> _motorSpeeds = {
    0: 0, // Port A
    1: 0, // Port B
    2: 0, // Port C
    3: 0, // Port D
  };

  final Map<int, String> _portNames = {
    0: 'A',
    1: 'B',
    2: 'C',
    3: 'D',
  };

  void _handleSpeedChange(int port, int newSpeed) {
    setState(() {
      _motorSpeeds[port] = newSpeed;
    });
    LegoService().setMotorPower(widget.hub.device.deviceId, port, newSpeed);
  }

  Widget _buildMotorControl(int port) {
    final speed = _motorSpeeds[port] ?? 0;
    final bool isMoving = speed != 0;
    final String direction = speed > 0 ? 'Forward' : speed < 0 ? 'Backward' : 'Stopped';

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Port Header
            Text(
              'Motor Port ${_portNames[port]}',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),

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
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  '${speed.abs()}%',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
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
                  fontSize: 12,
                ),
              ),
            ),
            const SizedBox(height: 8),

            // Speed Controls
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                SpeedButton(
                  icon: Icons.remove,
                  onPressed: speed > -100
                      ? () => _handleSpeedChange(port, max(speed - 10, -100))
                      : null,
                  color: Colors.red,
                  small: true,
                ),
                Expanded(
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
                      onChanged: (value) => _handleSpeedChange(port, value.toInt()),
                    ),
                  ),
                ),
                SpeedButton(
                  icon: Icons.add,
                  onPressed: speed < 100
                      ? () => _handleSpeedChange(port, min(speed + 10, 100))
                      : null,
                  color: Colors.green,
                  small: true,
                ),
              ],
            ),

            // Quick Controls
            Row(
              children: [
                Expanded(
                  child: ControlButton(
                    icon: Icons.arrow_back_ios,
                    onPressed: () => _handleSpeedChange(port, -50),
                    color: speed < 0 ? Colors.yellow : Colors.grey.shade300,
                    small: true,
                  ),
                ),
                const SizedBox(width: 8),
                ControlButton(
                  icon: Icons.stop,
                  onPressed: isMoving ? () => _handleSpeedChange(port, 0) : null,
                  color: speed != 0 ? Colors.red : Colors.grey.shade300,
                  small: true,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ControlButton(
                    icon: Icons.arrow_forward_ios,
                    onPressed: () => _handleSpeedChange(port, 50),
                    color: speed > 0 ? Colors.yellow : Colors.grey.shade300,
                    small: true,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 0,
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Hub Header with Status
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.hub.device.name ?? 'Unknown Hub',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'ID: ${widget.hub.device.deviceId}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                StreamBuilder<HubConnectionState>(
                  stream: widget.hub.stateController.stream,
                  initialData: widget.hub.state,
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

            // Motor Controls
            ..._motorSpeeds.keys.map((port) => _buildMotorControl(port)),

            // Stop All Motors Button
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () {
                for (var port in _motorSpeeds.keys) {
                  _handleSpeedChange(port, 0);
                }
              },
              icon: const Icon(Icons.stop_circle),
              label: const Text('Stop All Motors'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
            ),

            // Disconnect Button
            const SizedBox(height: 8),
            TextButton.icon(
              onPressed: () => widget.onDisconnect(widget.hub.device.deviceId),
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
}
