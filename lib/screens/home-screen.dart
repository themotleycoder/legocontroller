import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'train-screen.dart';
import 'switch-screen.dart';
// Voice control disabled
// import '../providers/voice_control_provider.dart';
import '../providers/train_state_provider.dart';
import '../providers/switch_state_provider.dart';
// import '../widgets/voice_control_widget.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  final List<Widget> _tabs = [
    const TrainScreen(),
    const SwitchScreen(),
  ];

  @override
  void initState() {
    super.initState();
    // Voice control disabled
    // WidgetsBinding.instance.addPostFrameCallback((_) {
    //   context.read<VoiceControlProvider>().initialize();
    // });
  }

  @override
  Widget build(BuildContext context) {
    return OrientationBuilder(
      builder: (context, orientation) {
        final isLandscape = orientation == Orientation.landscape;
        
        return Scaffold(
          appBar: AppBar(
            title: Text(_currentIndex == 0 ? 'Train Controls' : 'Switch Controls'),
            iconTheme: const IconThemeData(color: Colors.white),
            actionsIconTheme: const IconThemeData(color: Colors.white),
            actions: _buildAppBarActions(),
          ),
          body: isLandscape 
              ? Row(
                  children: [
                    // Compact side navigation for landscape
                    Container(
                      width: 80,
                      color: Theme.of(context).colorScheme.surfaceContainer,
                      child: Column(
                        children: [
                          const SizedBox(height: 16),
                          _buildNavItem(0, Icons.train, 'Trains', isLandscape),
                          const SizedBox(height: 8),
                          _buildNavItem(1, Icons.call_split, 'Switches', isLandscape),
                          const Spacer(),
                          // Voice Control in sidebar for landscape
                          // const VoiceControlFAB(),
                          const SizedBox(height: 16),
                        ],
                      ),
                    ),
                    // Main content
                    Expanded(
                      child: Stack(
                        children: [
                          IndexedStack(
                            index: _currentIndex,
                            children: _tabs,
                          ),
                          // Voice control status overlay
                          // Positioned(
                          //   top: 16,
                          //   left: 16,
                          //   right: 16,
                          //   child: Consumer<VoiceControlProvider>(
                          //     builder: (context, voiceProvider, child) {
                          //       if (!voiceProvider.isListening &&
                          //           voiceProvider.lastCommand.isEmpty &&
                          //           voiceProvider.lastError == null) {
                          //         return const SizedBox.shrink();
                          //       }
                          //       return Card(
                          //         child: Padding(
                          //           padding: const EdgeInsets.all(12),
                          //           child: Column(
                          //             crossAxisAlignment: CrossAxisAlignment.start,
                          //             children: [
                          //               if (voiceProvider.isListening)
                          //                 const Row(
                          //                   children: [
                          //                     SizedBox(
                          //                       width: 16,
                          //                       height: 16,
                          //                       child: CircularProgressIndicator(strokeWidth: 2),
                          //                     ),
                          //                     SizedBox(width: 8),
                          //                     Text('Listening for voice commands...'),
                          //                   ],
                          //                 ),
                          //               if (voiceProvider.lastCommand.isNotEmpty)
                          //                 Text('Command: "${voiceProvider.lastCommand}"'),
                          //               if (voiceProvider.lastError != null)
                          //                 Text('Error: ${voiceProvider.lastError}',
                          //                      style: const TextStyle(color: Colors.red)),
                          //               if (voiceProvider.lastError == null && voiceProvider.lastStatus.isNotEmpty)
                          //                 Text('Status: ${voiceProvider.lastStatus}',
                          //                      style: const TextStyle(color: Colors.green)),
                          //             ],
                          //           ),
                          //         ),
                          //       );
                          //     },
                          //   ),
                          // ),
                        ],
                      ),
                    ),
                  ],
                )
              : Stack(
                  children: [
                    IndexedStack(
                      index: _currentIndex,
                      children: _tabs,
                    ),
                    // Voice control status overlay for portrait
                    // Positioned(
                    //   top: 16,
                    //   left: 16,
                    //   right: 16,
                    //   child: Consumer<VoiceControlProvider>(
                    //     builder: (context, voiceProvider, child) {
                    //       if (!voiceProvider.isListening &&
                    //           voiceProvider.lastCommand.isEmpty &&
                    //           voiceProvider.lastError == null) {
                    //         return const SizedBox.shrink();
                    //       }
                    //       return Card(
                    //         child: Padding(
                    //           padding: const EdgeInsets.all(12),
                    //           child: Column(
                    //             crossAxisAlignment: CrossAxisAlignment.start,
                    //             children: [
                    //               if (voiceProvider.isListening)
                    //                 const Row(
                    //                   children: [
                    //                     SizedBox(
                    //                       width: 16,
                    //                       height: 16,
                    //                       child: CircularProgressIndicator(strokeWidth: 2),
                    //                     ),
                    //                     SizedBox(width: 8),
                    //                     Text('Listening for voice commands...'),
                    //                   ],
                    //                 ),
                    //               if (voiceProvider.lastCommand.isNotEmpty)
                    //                 Text('Command: "${voiceProvider.lastCommand}"'),
                    //               if (voiceProvider.lastError != null)
                    //                 Text('Error: ${voiceProvider.lastError}',
                    //                      style: const TextStyle(color: Colors.red)),
                    //               if (voiceProvider.lastError == null && voiceProvider.lastStatus.isNotEmpty)
                    //                 Text('Status: ${voiceProvider.lastStatus}',
                    //                      style: const TextStyle(color: Colors.green)),
                    //             ],
                    //           ),
                    //         ),
                    //       );
                    //     },
                    //   ),
                    // ),
                  ],
                ),
          bottomNavigationBar: isLandscape 
              ? null 
              : NavigationBar(
                  selectedIndex: _currentIndex,
                  onDestinationSelected: (index) {
                    setState(() {
                      _currentIndex = index;
                    });
                  },
                  destinations: const [
                    NavigationDestination(
                      icon: Icon(Icons.train),
                      label: 'Trains',
                    ),
                    NavigationDestination(
                      icon: Icon(Icons.call_split),
                      label: 'Switches',
                    ),
                  ],
                ),
          // floatingActionButton: isLandscape ? null : const VoiceControlFAB(),
          floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
        );
      },
    );
  }

  Widget _buildNavItem(int index, IconData icon, String label, bool isLandscape) {
    final isSelected = _currentIndex == index;
    return InkWell(
      onTap: () {
        setState(() {
          _currentIndex = index;
        });
      },
      child: Container(
        width: 64,
        height: 64,
        decoration: BoxDecoration(
          color: isSelected 
              ? Theme.of(context).colorScheme.primaryContainer
              : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: Colors.white,
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(
                fontSize: 10,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildAppBarActions() {
    if (_currentIndex == 0) {
      // Train screen actions
      return [
        Consumer<TrainStateProvider>(
          builder: (context, trainProvider, _) {
            final hasConnectedDevices = (trainProvider.trainStatus?.connectedTrains ?? 0) > 0;
            return Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (hasConnectedDevices)
                  IconButton(
                    icon: const Icon(Icons.bluetooth_disabled),
                    tooltip: 'Disconnect All Trains',
                    onPressed: () => _showTrainDisconnectAllDialog(context),
                  ),
                // Voice control help disabled
                // IconButton(
                //   icon: const Icon(Icons.help_outline),
                //   onPressed: () {
                //     showDialog(
                //       context: context,
                //       builder: (context) => const VoiceControlHelpDialog(),
                //     );
                //   },
                // ),
              ],
            );
          },
        ),
      ];
    } else {
      // Switch screen actions
      return [
        Consumer<SwitchStateProvider>(
          builder: (context, switchProvider, _) {
            final hasConnectedDevices = (switchProvider.switchStatus?.connectedSwitches ?? 0) > 0;
            return Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (hasConnectedDevices)
                  IconButton(
                    icon: const Icon(Icons.bluetooth_disabled),
                    tooltip: 'Disconnect All Switches',
                    onPressed: () => _showSwitchDisconnectAllDialog(context),
                  ),
                // Voice control help disabled
                // IconButton(
                //   icon: const Icon(Icons.help_outline),
                //   onPressed: () {
                //     showDialog(
                //       context: context,
                //       builder: (context) => const VoiceControlHelpDialog(),
                //     );
                //   },
                // ),
              ],
            );
          },
        ),
      ];
    }
  }

  Future<void> _showTrainDisconnectAllDialog(BuildContext context) {
    final trainProvider = context.read<TrainStateProvider>();
    
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Disconnect All Trains?'),
        content: const Text(
          'Are you sure you want to disconnect all trains?\n\n'
              'All trains will stop if currently in motion.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              await trainProvider.disconnectAll();
              if (context.mounted) {
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

  Future<void> _showSwitchDisconnectAllDialog(BuildContext context) {
    final switchProvider = context.read<SwitchStateProvider>();
    
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Disconnect All Switches?'),
        content: const Text(
          'Are you sure you want to disconnect all switches?\n\n'
              'This will reset all switch positions.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              await switchProvider.disconnectAll();
              if (context.mounted) {
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
}
