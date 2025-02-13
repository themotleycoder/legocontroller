import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/switch_state_provider.dart';
import '../models/switch_status.dart';

class SwitchControlWidget extends StatelessWidget {
  final String switchId;

  const SwitchControlWidget({
    super.key,
    required this.switchId,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<SwitchStateProvider>(
      builder: (context, switchProvider, _) {
        if (switchProvider.isLoading || switchProvider.switchStatus == null) {
          return const Center(child: CircularProgressIndicator());
        }

        final switchData = switchProvider.switchStatus!.switches[switchId];
        if (switchData == null) {
          return const SizedBox.shrink();
        }

        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          elevation: 0,
          color: Colors.white,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Switch Header with Status
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            switchData.name,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'ID: $switchId',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: switchData.connected ? Colors.green.withOpacity(0.1) : Colors.red.withOpacity(0.1),
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
                              color: switchData.connected ? Colors.green : Colors.red,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            switchData.connected ? 'Connected' : 'Disconnected',
                            style: TextStyle(
                              color: switchData.connected ? Colors.green : Colors.red,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const Divider(height: 32),

                // Switch Position Controls
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton.icon(
                      onPressed: () => switchProvider.controlSwitch(
                        switchId: switchId,
                        position: SwitchPosition.straight,
                      ),
                      icon: const Icon(Icons.arrow_forward),
                      label: const Text('Straight'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: switchData.position == 0 ? Colors.blue : Colors.grey,
                      ),
                    ),
                    ElevatedButton.icon(
                      onPressed: () => switchProvider.controlSwitch(
                        switchId: switchId,
                        position: SwitchPosition.turn,
                      ),
                      icon: const Icon(Icons.turn_right),
                      label: const Text('Turn'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: switchData.position == 1 ? Colors.blue : Colors.grey,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),
                Text(
                  'Last update: ${switchData.lastUpdateSecondsAgo.toStringAsFixed(1)} seconds ago',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
