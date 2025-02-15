import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/switch_state_provider.dart';
import '../models/switch_status.dart' as switch_model;

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

        final currentSwitch = switchProvider.switchStatus!.switches[switchId];
        if (currentSwitch == null) {
          return const SizedBox.shrink();
        }
        final switchData = currentSwitch;

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
                Column(
                  children: ['A', 'B', 'C', 'D'].map((switchLetter) {
                    final currentSwitchId = "SWITCH_$switchLetter";
                    // Only show switches that have a position set
                    if (!switchData.switchPositions.containsKey(currentSwitchId)) {
                      return const SizedBox.shrink();
                    }
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: Column(
                        children: [
                          Text(
                            'Switch $switchLetter',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade200,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    TextButton(
                                      onPressed: () {
                                        switchProvider.controlSwitch(
                                          hubId: int.parse(switchId),
                                          switchId: currentSwitchId,
                                          position: switch_model.SwitchPosition.STRAIGHT,
                                        );
                                      },
                                      style: TextButton.styleFrom(
                                        backgroundColor: switchData.switchPositions[currentSwitchId] == 0 ? Colors.blue : null,
                                        shape: const RoundedRectangleBorder(
                                          borderRadius: BorderRadius.horizontal(left: Radius.circular(20)),
                                        ),
                                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                      ),
                                      child: Text(
                                        'Straight',
                                        style: TextStyle(
                                          color: switchData.switchPositions[currentSwitchId] == 0 ? Colors.white : Colors.black87,
                                        ),
                                      ),
                                    ),
                                    TextButton(
                                      onPressed: () {
                                        switchProvider.controlSwitch(
                                          hubId: int.parse(switchId),
                                          switchId: currentSwitchId,
                                          position: switch_model.SwitchPosition.DIVERGING,
                                        );
                                      },
                                      style: TextButton.styleFrom(
                                        backgroundColor: switchData.switchPositions[currentSwitchId] == 1 ? Colors.blue : null,
                                        shape: const RoundedRectangleBorder(
                                          borderRadius: BorderRadius.horizontal(right: Radius.circular(20)),
                                        ),
                                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                      ),
                                      child: Text(
                                        'Turn',
                                        style: TextStyle(
                                          color: switchData.switchPositions[currentSwitchId] == 1 ? Colors.white : Colors.black87,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  }).toList(),
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
