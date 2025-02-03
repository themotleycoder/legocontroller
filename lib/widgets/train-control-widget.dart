import 'package:flutter/material.dart';
import 'dart:math';
import '../services/lego-service.dart';
import '../utils/constants.dart';
import '../widgets/buttons.dart';

class TrainControlWidget extends StatefulWidget {
  final ConnectedHub hub;
  final Function(String deviceId, int newSpeed) onSpeedChanged;
  final Function(String deviceId) onDisconnect;
  final int currentSpeed;

  const TrainControlWidget({
    super.key,
    required this.hub,
    required this.onSpeedChanged,
    required this.onDisconnect,
    required this.currentSpeed,
  });

  @override
  State<TrainControlWidget> createState() => _TrainControlWidgetState();
}

class _TrainControlWidgetState extends State<TrainControlWidget> {
  @override
  Widget build(BuildContext context) {
    final speed = widget.currentSpeed;
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
                        widget.hub.device.name ?? 'Unknown Train',
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
                SpeedButton(
                  icon: Icons.remove,
                  onPressed: speed > -100
                      ? () => widget.onSpeedChanged(widget.hub.device.deviceId, max(speed - 10, -100))
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
                      onChanged: (value) => widget.onSpeedChanged(widget.hub.device.deviceId, value.toInt()),
                    ),
                  ),
                ),
                SpeedButton(
                  icon: Icons.add,
                  onPressed: speed < 100
                      ? () => widget.onSpeedChanged(widget.hub.device.deviceId, min(speed + 10, 100))
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
                  child: ControlButton(
                    icon: Icons.arrow_back_ios,
                    onPressed: () => widget.onSpeedChanged(widget.hub.device.deviceId, -50),
                    color: speed < 0 ? Colors.yellow : Colors.grey.shade300,
                  ),
                ),
                const SizedBox(width: 8),
                ControlButton(
                  icon: Icons.stop,
                  onPressed: isMoving ? () => widget.onSpeedChanged(widget.hub.device.deviceId, 0) : null,
                  color: speed != 0 ? Colors.red : Colors.grey.shade300,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ControlButton(
                    icon: Icons.arrow_forward_ios,
                    onPressed: () => widget.onSpeedChanged(widget.hub.device.deviceId, 50),
                    color: speed > 0 ? Colors.yellow : Colors.grey.shade300,
                  ),
                ),
              ],
            ),

            // Disconnect Button
            const SizedBox(height: 16),
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
