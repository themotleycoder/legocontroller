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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lego Train Controls'),
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
          : Consumer<SwitchStateProvider>(
              builder: (context, switchProvider, _) {
                if (switchProvider.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (switchProvider.switchStatus == null) {
                  return const Center(child: Text('No switch status available'));
                }

                final switches = switchProvider.switchStatus!.switches;
                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: switches.length,
                  itemBuilder: (context, index) {
                    final switchId = switches.keys.elementAt(index);
                    return SwitchControlWidget(switchId: switchId);
                  },
                );
              },
            ),
    );
  }


  Future<void> _showDisconnectAllDialog(BuildContext context) {
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
