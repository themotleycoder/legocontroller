import 'package:flutter/material.dart';
import 'package:universal_ble/universal_ble.dart';
import '../services/lego-service.dart';
import '../utils/constants.dart';
import '../widgets/motor-control.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final LegoService _legoService = LegoService();
  List<BleDevice> _devices = [];
  bool _isScanning = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('LEGO Train Controller'),
      ),
      body: Column(
        children: [
          _buildConnectionButtons(),
          _buildDeviceList(),
          Expanded(child: _buildTrainControls()),
        ],
      ),
    );
  }

  Widget _buildConnectionButtons() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          ElevatedButton(
            onPressed: _isScanning || !_legoService.canConnectMore ? null : _startScan,
            child: Text(_isScanning ? 'Scanning...' : 'Add Train'),
          ),
          if (_legoService.connectedHubs.isNotEmpty)
            ElevatedButton(
              onPressed: () => _legoService.disconnectAll(),
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

  Widget _buildDeviceList() {
    if (_devices.isEmpty) return const SizedBox();

    return Container(
      height: 200,
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Available Trains:', style: TextStyle(fontWeight: FontWeight.bold)),
          Expanded(
            child: ListView.builder(
              itemCount: _devices.length,
              itemBuilder: (context, index) {
                final device = _devices[index];
                return ListTile(
                  title: Text(device.name ?? 'Unknown Train'),
                  subtitle: Text(device.deviceId),
                  trailing: ElevatedButton(
                    onPressed: !_legoService.canConnectMore ? null : () => _connectToDevice(device),
                    child: const Text('Connect'),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTrainControls() {
    final connectedHubs = _legoService.connectedHubs;
    if (connectedHubs.isEmpty) {
      return const Center(
        child: Text('No trains connected.\nTap "Add Train" to connect a train.'),
      );
    }

    return ListView.builder(
      itemCount: connectedHubs.length,
      itemBuilder: (context, index) {
        final hub = connectedHubs[index];
        return _buildTrainControl(hub);
      },
    );
  }

  Widget _buildTrainControl(ConnectedHub hub) {
    return Card(
      margin: const EdgeInsets.all(8.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  hub.device.name ?? 'Unknown Train',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                StreamBuilder<HubConnectionState>(
                  stream: hub.stateController.stream,
                  initialData: hub.state,
                  builder: (context, snapshot) {
                    final state = snapshot.data!;
                    return Row(
                      children: [
                        Container(
                          width: 12,
                          height: 12,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: _getStatusColor(state),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(state.toString().split('.').last),
                      ],
                    );
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Expanded(
                  child: MotorControl(
                    motorPort: LegoConstants.portA,
                    label: 'Motor A',
                    onPowerChanged: (port, power) =>
                        _legoService.setMotorPower(hub.device.deviceId, port, power),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: MotorControl(
                    motorPort: LegoConstants.portB,
                    label: 'Motor B',
                    onPowerChanged: (port, power) =>
                        _legoService.setMotorPower(hub.device.deviceId, port, power),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Center(
              child: ElevatedButton(
                onPressed: () => _legoService.disconnect(hub.device.deviceId),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Disconnect'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(HubConnectionState state) {
    switch (state) {
      case HubConnectionState.connected:
        return Colors.green;
      case HubConnectionState.connecting:
        return Colors.yellow;
      case HubConnectionState.error:
        return Colors.red;
      case HubConnectionState.disconnected:
        return Colors.grey;
    }
  }

  Future<void> _startScan() async {
    if (_isScanning) return;

    setState(() {
      _devices = [];
      _isScanning = true;
    });

    try {
      final devices = await _legoService.scanForDevices();
      setState(() {
        _devices = devices;
      });
    } finally {
      setState(() {
        _isScanning = false;
      });
    }
  }

  Future<void> _connectToDevice(BleDevice device) async {
    try {
      await _legoService.connect(device);
      setState(() {
        // Remove the device from available devices list
        _devices.removeWhere((d) => d.deviceId == device.deviceId);
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Connection error: $e')),
      );
    }
  }

  @override
  void dispose() {
    _legoService.dispose();
    super.dispose();
  }
}