import 'package:flutter/material.dart';

class TrainHubControl extends StatefulWidget {
  final int motorPort;
  final String label;
  final Future<void> Function(int port, int power) onPowerChanged;

  const TrainHubControl({
    super.key,
    required this.motorPort,
    required this.label,
    required this.onPowerChanged,
  });

  @override
  State<TrainHubControl> createState() => _TrainHubControlState();
}

class _TrainHubControlState extends State<TrainHubControl> {
  double _power = 0;
  bool _isActive = false;

  void _updatePower(double newPower) {
    setState(() {
      _power = newPower;
    });
    widget.onPowerChanged(widget.motorPort, newPower.round());
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(widget.label),
            const SizedBox(height: 8),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.remove),
                  onPressed: () {
                    if (_power > -100) {
                      _updatePower(_power - 10);
                    }
                  },
                ),
                Text('${_power.round()}%'),
                IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: () {
                    if (_power < 100) {
                      _updatePower(_power + 10);
                    }
                  },
                ),
              ],
            ),
            const SizedBox(height: 8),
            Slider(
              value: _power,
              min: -100,
              max: 100,
              divisions: 20,
              label: '${_power.round()}%',
              onChanged: _updatePower,
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _isActive = !_isActive;
                });
                _updatePower(_isActive ? _power : 0);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: _isActive ? Colors.red : Colors.green,
                foregroundColor: Colors.white,
              ),
              child: Text(_isActive ? 'Stop' : 'Start'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    widget.onPowerChanged(widget.motorPort, 0);
    super.dispose();
  }
}
