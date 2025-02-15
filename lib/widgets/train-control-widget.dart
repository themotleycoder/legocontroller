import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:math';
import '../providers/train_state_provider.dart';
import '../widgets/buttons.dart';
import '../models/train_command.dart';
import '../models/train_status.dart';

class TrainControlWidget extends StatelessWidget {
  final String trainId;
  late final Train train;

  TrainControlWidget({
    super.key,
    required this.trainId,
  });

  void _updateSpeed(BuildContext context, int speed) {
    // final command = speed == 0
    //         ? TrainCommand.stop
    //         : speed > 0
    //             ? TrainCommand.forward
    //             : TrainCommand.backward;
            
    context.read<TrainStateProvider>().controlTrain(
      hubId: int.parse(trainId),
      power: speed,
    );
  }

  void _disconnect(BuildContext context) {
    context.read<TrainStateProvider>().disconnect(trainId);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<TrainStateProvider>(
      builder: (context, trainProvider, _) {
        if (trainProvider.isLoading || trainProvider.trainStatus == null) {
          return const Center(child: CircularProgressIndicator());
        }

        final currentTrain = trainProvider.trainStatus!.trains[trainId];
        if (currentTrain == null) {
          return const SizedBox.shrink();
        }
        train = currentTrain;

        // Convert speed to integer and ensure it's within slider range
        final speed = train.speed.round().clamp(-100, 100);
        final bool isMoving = speed != 0;
        final String direction = train.direction;
        print("speed: $speed");
        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          elevation: 0,
          color: Colors.white,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Train Header with Status
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            train.name,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'ID: $trainId',
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
                        color: Colors.green.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.green,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            train.status,
                            style: const TextStyle(
                              color: Colors.green,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const Divider(height: 32),

                // Speed and Direction Display
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      speed > 0
                          ? Icons.arrow_forward
                          : speed < 0
                          ? Icons.arrow_back
                          : Icons.remove,
                      color: isMoving ? Colors.green : Colors.grey,
                      size: 24,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '$speed',
                      style: Theme.of(context).textTheme.displaySmall?.copyWith(
                        color: isMoving ? Colors.green : Colors.grey,
                      ),
                    ),
                  ],
                ),
                Center(
                  child: Text(
                    direction,
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Speed Controls
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    SpeedButton(
                      icon: Icons.remove,
                      onPressed: speed > -100
                          ? () => _updateSpeed(context, max(speed - 10, -100))
                          : null,
                      color: Colors.red,
                    ),
                    SizedBox(
                      width: 180,
                      child: SliderTheme(
                        data: SliderTheme.of(context).copyWith(
                          activeTrackColor: Colors.blue,
                          inactiveTrackColor: Colors.grey[300],
                          thumbColor: Colors.blue,
                          trackHeight: 4,
                        ),
                        child: Slider(
                          value: speed.toDouble(),
                          min: -100,
                          max: 100,
                          divisions: 10,
                          label: '$speed%',
                          onChanged: (value) => _updateSpeed(context, value.toInt()),
                        ),
                      ),
                    ),
                    SpeedButton(
                      icon: Icons.add,
                      onPressed: speed < 100
                          ? () => _updateSpeed(context, min(speed + 10, 100))
                          : null,
                      color: Colors.green,
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Direction Controls
                Row(
                  children: [
                    Expanded(
                      child: ControlButton(
                        icon: Icons.arrow_back_ios,
                        onPressed: () => _updateSpeed(context, -50),
                        color: speed < 0 ? Colors.yellow : Colors.grey.shade300,
                      ),
                    ),
                    const SizedBox(width: 8),
                    ControlButton(
                      icon: Icons.stop,
                      onPressed: isMoving ? () => _updateSpeed(context, 0) : null,
                      color: speed != 0 ? Colors.red : Colors.grey.shade300,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ControlButton(
                        icon: Icons.arrow_forward_ios,
                        onPressed: () => _updateSpeed(context, 50),
                        color: speed > 0 ? Colors.yellow : Colors.grey.shade300,
                      ),
                    ),
                  ],
                ),

                // Disconnect Button
                const SizedBox(height: 16),
                TextButton.icon(
                  onPressed: () => _disconnect(context),
                  icon: const Icon(Icons.bluetooth_disabled),
                  label: const Text('Disconnect'),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.red,
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
