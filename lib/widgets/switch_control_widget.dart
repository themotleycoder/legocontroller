import 'package:flutter/material.dart';
import 'package:legocontroller/style/app_style.dart';
import 'package:provider/provider.dart';
import '../providers/switch_state_provider.dart';
import '../models/switch_status.dart' as switch_model;

class SwitchControlWidget extends StatefulWidget {
  final String switchId;

  const SwitchControlWidget({
    super.key,
    required this.switchId,
  });

  @override
  State<SwitchControlWidget> createState() => _SwitchControlWidgetState();
}

class _SwitchControlWidgetState extends State<SwitchControlWidget> {
  // Map to track expected positions
  final Map<String, bool> _expectedPositions = {};
  String? loadingSwitch;

  @override
  void initState() {
    super.initState();
    _startListeningToUpdates();
  }

  @override
  void dispose() {
    _stopListeningToUpdates();
    super.dispose();
  }

  void _startListeningToUpdates() {
    final provider = Provider.of<SwitchStateProvider>(context, listen: false);
    provider.addListener(_checkServerState);
  }

  void _stopListeningToUpdates() {
    if (mounted) {
      final provider = Provider.of<SwitchStateProvider>(context, listen: false);
      provider.removeListener(_checkServerState);
    }
  }

  void _checkServerState() {
    if (_expectedPositions.isEmpty) return;

    final provider = Provider.of<SwitchStateProvider>(context, listen: false);
    final switchData = provider.switchStatus?.switches[widget.switchId];
    if (switchData != null) {
      setState(() {
        // Remove entries where server state matches expected state
        _expectedPositions.removeWhere((switchId, expectedValue) {
          return switchData.switchPositions[switchId] == (expectedValue ? 1 : 0);
        });
      });
    }
  }

  void _handleSwitchControl(String switchId, switch_model.SwitchPosition position) async {
    final newValue = position == switch_model.SwitchPosition.DIVERGING;
    
    // Set expected position
    setState(() {
      _expectedPositions[switchId] = newValue;
      loadingSwitch = switchId;
    });
    
    try {
      await Provider.of<SwitchStateProvider>(context, listen: false).controlSwitch(
        hubId: int.parse(widget.switchId),
        switchId: switchId,
        position: position,
      );
      if (mounted) {
        setState(() {
          loadingSwitch = null;
        });
      }
      // _expectedPositions will be cleared by listener when server state matches
    } catch (e) {
      // On error, revert the local state
      if (mounted) {
        setState(() {
          _expectedPositions.remove(switchId);
          loadingSwitch = null;
        });
      }
    }
  }


  @override
  Widget build(BuildContext context) {
    return Consumer<SwitchStateProvider>(
      builder: (context, switchProvider, _) {
        if (switchProvider.isLoading || switchProvider.switchStatus == null) {
          return const Center(child: CircularProgressIndicator());
        }

        final currentSwitch = switchProvider.switchStatus!.switches[widget.switchId];
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
                            'ID: ${widget.switchId}',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: switchData.connected ? AppStyle.legoGreen.withOpacity(0.1) : AppStyle.legoRed.withOpacity(0.1),
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
                                  color: switchData.connected ? AppStyle.legoGreen : AppStyle.legoRed,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                switchData.connected ? 'Connected' : 'Disconnected',
                                style: TextStyle(
                                  color: switchData.connected ? AppStyle.legoGreen : AppStyle.legoRed,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: switchData.active ? Colors.blue.withOpacity(0.1) : Colors.grey.withOpacity(0.1),
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
                                  color: switchData.active ? Colors.blue : Colors.grey,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                switchData.active ? 'Active' : 'Inactive',
                                style: TextStyle(
                                  color: switchData.active ? Colors.blue : Colors.grey,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const Divider(height: 32),

                // Switch Position Controls
                Column(
                  children: ['A', 'B', 'C', 'D'].map((switchLetter) {
                    final currentSwitchId = "SWITCH_$switchLetter";
                    // Only show switches that have a position set and are connected
                    if (!switchData.switchPositions.containsKey(currentSwitchId) || 
                        switchData.switchStates[currentSwitchId] != 1) {
                      return const SizedBox.shrink();
                    }
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: Column(
                        children: [
                          Column(
                            children: [
                              Text(
                                'Switch $switchLetter',
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 8),
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Straight',
                                style: TextStyle(
                                  color: Colors.grey[700],
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                                child: Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    Theme(
                                      data: Theme.of(context).copyWith(
                                        useMaterial3: true,
                                        switchTheme: SwitchThemeData(
                                          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                          splashRadius: 24.0,
                                          thumbColor: WidgetStateProperty.resolveWith((states) {
                                            if (states.contains(WidgetState.selected)) {
                                              return AppStyle.legoBlue;
                                            }
                                            return AppStyle.legoYellow;
                                          }),
                                          trackColor: WidgetStateProperty.resolveWith((states) {
                                            if (states.contains(WidgetState.selected)) {
                                              return AppStyle.legoBlue.withOpacity(0.5);
                                            }
                                            return AppStyle.legoYellow.withOpacity(0.5);
                                          }),
                                          trackOutlineColor: WidgetStateProperty.resolveWith((states) {
                                            if (states.contains(WidgetState.selected)) {
                                              return AppStyle.legoBlue;
                                            }
                                            return AppStyle.legoYellow;
                                          }),
                                          overlayColor: WidgetStateProperty.resolveWith((states) {
                                            final isSelected = states.contains(WidgetState.selected);
                                            final color = isSelected ? AppStyle.legoBlue : AppStyle.legoGreen;
                                            
                                            if (states.contains(WidgetState.pressed)) {
                                              return color.withOpacity(0.2);
                                            }
                                            if (states.contains(WidgetState.focused) || 
                                                states.contains(WidgetState.hovered)) {
                                              return color.withOpacity(0.12);
                                            }
                                            return Colors.transparent;
                                          }),
                                        ),
                                      ),
                                      child: Switch(
                                      value: _expectedPositions[currentSwitchId] ?? 
                                             (switchData.switchPositions[currentSwitchId] == 1),
                                      onChanged: (bool value) {
                                        _handleSwitchControl(
                                          currentSwitchId,
                                          value ? switch_model.SwitchPosition.DIVERGING : switch_model.SwitchPosition.STRAIGHT,
                                        );
                                      },
                                      ),
                                    ),
                                    if (loadingSwitch == currentSwitchId)
                                      const SizedBox(
                                        width: 16,
                                        height: 16,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                              Text(
                                'Turn',
                                style: TextStyle(
                                  color: Colors.grey[700],
                                  fontWeight: FontWeight.w500,
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
