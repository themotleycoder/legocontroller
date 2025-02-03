import 'package:flutter/material.dart';
import 'package:legocontroller/screens/scan-screen.dart';
import 'control-screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  final List<Widget> _tabs = [
    const ControlScreen(),
    const ScanTab(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _tabs[_currentIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.train),
            label: 'Control',
          ),
          NavigationDestination(
            icon: Icon(Icons.bluetooth_searching),
            label: 'Connect',
          ),
        ],
      ),
    );
  }
}