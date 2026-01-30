import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../widgets/train_control_widget.dart';
import '../providers/train_state_provider.dart';

class TrainScreen extends StatefulWidget {
  const TrainScreen({super.key});

  @override
  State<TrainScreen> createState() => _TrainScreenState();
}

class _TrainScreenState extends State<TrainScreen> {
  @override
  Widget build(BuildContext context) {
    final hasConnectedDevices = context.select<TrainStateProvider, bool>(
      (provider) => (provider.trainStatus?.connectedTrains ?? 0) > 0,
    );
    return !hasConnectedDevices
        ? _buildNoDevicesMessage()
        : Consumer<TrainStateProvider>(
            builder: (context, trainProvider, _) {
              if (trainProvider.isLoading) {
                return const Center(child: CircularProgressIndicator());
              }

              // Show error if present
              if (trainProvider.error != null) {
                return _buildErrorView(trainProvider.error!);
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
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
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

  Widget _buildErrorView(String error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64, color: Colors.red[400]),
          const SizedBox(height: 16),
          Text(
            'Connection Error',
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(color: Colors.red[700]),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              error.replaceAll('TrainWebServiceException: ', ''),
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: Colors.grey[700]),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              context.read<TrainStateProvider>();
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
          Icon(Icons.bluetooth_connected, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'No devices connected',
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(color: Colors.grey[600]),
          ),
          const SizedBox(height: 8),
          Text(
            'Go to the Connect tab to add devices',
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }
}
