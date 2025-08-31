import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../widgets/train_control_widget.dart';
import '../models/train_status.dart';
import '../providers/train_state_provider.dart';
import '../models/train_command.dart';
import '../widgets/voice_control_widget.dart';

class TrainScreen extends StatefulWidget {
  const TrainScreen({super.key});

  @override
  State<TrainScreen> createState() => _TrainScreenState();
}

class _TrainScreenState extends State<TrainScreen> {
  @override
  Widget build(BuildContext context) {
    final hasConnectedDevices = context.select<TrainStateProvider, bool>(
      (provider) => (provider.trainStatus?.connectedTrains ?? 0) > 0
    );
    return !hasConnectedDevices
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
                        itemCount: trains.length,
                        itemBuilder: (context, index) {
                          final trainId = trains.keys.elementAt(index);
                          return TrainControlWidget(trainId: trainId);
                        },
                      );
                    } else {
                      // Use ListView for portrait mode
                      return ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: trains.length,
                        itemBuilder: (context, index) {
                          final trainId = trains.keys.elementAt(index);
                          return TrainControlWidget(trainId: trainId);
                        },
                      );
                    }
                  },
                );
              },
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
              await trainProvider.disconnect(trainId);
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
              await trainProvider.disconnectAll();
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
