import 'package:flutter/material.dart';
import 'train-screen.dart';
import 'switch-screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  final List<Widget> _tabs = [
    const TrainScreen(),
    const SwitchScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return OrientationBuilder(
      builder: (context, orientation) {
        final isLandscape = orientation == Orientation.landscape;
        
        return Scaffold(
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
                          _buildNavItem(1, Icons.call_split, 'Switches', isLandscape),
                        ],
                      ),
                    ),
                    // Main content
                    Expanded(child: _tabs[_currentIndex]),
                  ],
                )
              : _tabs[_currentIndex],
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

  Widget _buildNavItem(int index, IconData icon, String label, bool isLandscape) {
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
            Icon(
              icon,
              color: isSelected 
                  ? Theme.of(context).colorScheme.onPrimaryContainer
                  : Theme.of(context).colorScheme.onSurfaceVariant,
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                color: isSelected 
                    ? Theme.of(context).colorScheme.onPrimaryContainer
                    : Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
