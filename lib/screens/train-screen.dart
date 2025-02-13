import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/lego-service.dart';
import '../services/lego-webservice.dart';
import '../utils/constants.dart';
import '../widgets/train-control-widget.dart';
import '../widgets/technic-hub-control.dart';
import '../utils/hub-identifier.dart';
import '../models/train_status.dart';
import '../providers/train_state_provider.dart';
import '../providers/switch_state_provider.dart';

class ControlScreen extends StatefulWidget {
  const ControlScreen({super.key});

  @override
  State<ControlScreen> createState() => _ControlScreenState();
}

class _ControlScreenState extends State<ControlScreen> {
  final LegoService _legoService = LegoService();

  @override
  Widget build(BuildContext context) {
    const bool hasConnectedDevices = true;
    return Scaffold(
      appBar: AppBar(
        title: const Text('LEGO Controls'),
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
          : Consumer<TrainStateProvider>(
              builder: (context, trainProvider, _) {
                if (trainProvider.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (trainProvider.trainStatus == null) {
                  return const Center(child: Text('No train status available'));
                }

                final trains = trainProvider.trainStatus!.trains;
                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: trains.length,
                  itemBuilder: (context, index) {
                    final trainId = trains.keys.elementAt(index);
                    return TrainControlWidget(trainId: trainId);
                  },
                );
              },
            ),
    );
  }


  Future<void> _showDisconnectDialog(BuildContext context, String trainId) {
    final trainProvider = context.read<TrainStateProvider>();
    final train = trainProvider.trainStatus?.trains[trainId];
    if (train == null) return Future.value();
    
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Disconnect Train?'),
        content: Text(
          'Are you sure you want to disconnect ${train.name}?\n\n'
              'The train will stop if currently in motion.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              // Stop the train first
              await trainProvider.controlTrain(command: TrainCommand.stop);
              // TODO: Implement disconnect in TrainStateProvider
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
              // Stop all trains first
              await trainProvider.controlTrain(command: TrainCommand.stop);
              // TODO: Implement disconnectAll in TrainStateProvider
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
