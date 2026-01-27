import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../widgets/switch_control_widget.dart';
import '../providers/switch_state_provider.dart';

class SwitchScreen extends StatefulWidget {
  const SwitchScreen({super.key});

  @override
  State<SwitchScreen> createState() => _SwitchScreenState();
}

class _SwitchScreenState extends State<SwitchScreen> {
  @override
  Widget build(BuildContext context) {
    final hasConnectedDevices = context.select<SwitchStateProvider, bool>(
      (provider) => (provider.switchStatus?.connectedSwitches ?? 0) > 0
    );
    return !hasConnectedDevices
          ? _buildNoDevicesMessage()
          : Consumer<SwitchStateProvider>(
              builder: (context, switchProvider, _) {
                if (switchProvider.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                // Show error if present
                if (switchProvider.error != null) {
                  return _buildErrorView(switchProvider.error!);
                }

                if (switchProvider.switchStatus == null) {
                  return const Center(child: Text('No switch status available'));
                }

                final switches = switchProvider.switchStatus!.switches;
                return OrientationBuilder(
                  builder: (context, orientation) {
                    final isLandscape = orientation == Orientation.landscape;
                    
                    if (isLandscape) {
                      // Use GridView for landscape mode
                      return GridView.builder(
                        padding: const EdgeInsets.all(16),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 1.2,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                        ),
                        itemCount: switches.length,
                        itemBuilder: (context, index) {
                          final switchId = switches.keys.elementAt(index);
                          return SwitchControlWidget(switchId: switchId);
                        },
                      );
                    } else {
                      // Use ListView for portrait mode
                      return ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: switches.length,
                        itemBuilder: (context, index) {
                          final switchId = switches.keys.elementAt(index);
                          return SwitchControlWidget(switchId: switchId);
                        },
                      );
                    }
                  },
                );
              },
            );
  }

  Widget _buildErrorView(String error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: Colors.red[400],
          ),
          const SizedBox(height: 16),
          Text(
            'Connection Error',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: Colors.red[700],
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              error.replaceAll('TrainWebServiceException: ', ''),
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey[700],
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              context.read<SwitchStateProvider>();
            },
            icon: const Icon(Icons.refresh),
            label: const Text('Retry'),
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
