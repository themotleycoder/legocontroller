import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'train-screen.dart';
import 'switch-screen.dart';
import '../providers/train_state_provider.dart';
import '../providers/switch_state_provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  final List<Widget> _tabs = [const TrainScreen(), const SwitchScreen()];

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return OrientationBuilder(
      builder: (context, orientation) {
        final isLandscape = orientation == Orientation.landscape;

        return Scaffold(
          appBar: AppBar(
            title: Text(
              _currentIndex == 0 ? 'Train Controls' : 'Switch Controls',
            ),
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
                          _buildNavItem(
                            1,
                            Icons.call_split,
                            'Switches',
                            isLandscape,
                          ),
                          const Spacer(),
                          const SizedBox(height: 16),
                        ],
                      ),
                    ),
                    // Main content
                    Expanded(
                      child: IndexedStack(
                        index: _currentIndex,
                        children: _tabs,
                      ),
                    ),
                  ],
                )
              : IndexedStack(index: _currentIndex, children: _tabs),
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
        );
      },
    );
  }

  Widget _buildNavItem(
    int index,
    IconData icon,
    String label,
    bool isLandscape,
  ) {
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
            Icon(icon, color: Colors.white, size: 24),
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(fontSize: 10, color: Colors.white),
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
            final hasConnectedDevices =
                (trainProvider.trainStatus?.connectedTrains ?? 0) > 0;
            return Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (hasConnectedDevices)
                  IconButton(
                    icon: const Icon(Icons.bluetooth_disabled),
                    tooltip: 'Disconnect All Trains',
                    onPressed: () => _showTrainDisconnectAllDialog(context),
                  ),
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
            final hasConnectedDevices =
                (switchProvider.switchStatus?.connectedSwitches ?? 0) > 0;
            return Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (hasConnectedDevices)
                  IconButton(
                    icon: const Icon(Icons.bluetooth_disabled),
                    tooltip: 'Disconnect All Switches',
                    onPressed: () => _showSwitchDisconnectAllDialog(context),
                  ),
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
