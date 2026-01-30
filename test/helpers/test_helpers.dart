/// Test helpers and utilities for LEGO Controller tests.
///
/// Provides mock data, common setup functions, and test utilities.
library;

import 'package:flutter/material.dart' hide Switch;
import 'package:flutter_test/flutter_test.dart';
import 'package:legocontroller/models/train_status.dart';
import 'package:legocontroller/models/switch_status.dart';
import 'package:provider/provider.dart';

/// Creates a mock TrainStatus with sample data for testing.
TrainStatus createMockTrainStatus({
  int connectedTrains = 2,
  Map<String, Train>? customTrains,
}) {
  return TrainStatus(
    connectedTrains: connectedTrains,
    trains:
        customTrains ??
        {
          '21': const Train(
            status: 'running',
            speed: 50.0,
            direction: 'forward',
            name: 'Train Hub 1',
            selfDrive: false,
            lastUpdateSecondsAgo: 1.5,
            rssi: -75,
          ),
          '22': const Train(
            status: 'idle',
            speed: 0.0,
            direction: 'stopped',
            name: 'Train Hub 2',
            selfDrive: true,
            lastUpdateSecondsAgo: 2.3,
            rssi: -82,
          ),
        },
  );
}

/// Creates a mock SwitchStatus with sample data for testing.
SwitchStatus createMockSwitchStatus({
  int connectedSwitches = 2,
  Map<String, Switch>? customSwitches,
}) {
  return SwitchStatus(
    connectedSwitches: connectedSwitches,
    switches:
        customSwitches ??
        {
          '1': const Switch(
            switchPositions: {'SWITCH_A': 0, 'SWITCH_B': 1},
            switchStates: {'SWITCH_A': 1, 'SWITCH_B': 1},
            lastUpdateSecondsAgo: 0.8,
            name: 'Technic Hub 1',
            status: 97,
            connected: true,
            active: true,
          ),
          '2': const Switch(
            switchPositions: {'SWITCH_A': 1},
            switchStates: {'SWITCH_A': 1},
            lastUpdateSecondsAgo: 1.2,
            name: 'Technic Hub 2',
            status: 97,
            connected: true,
            active: true,
          ),
        },
  );
}

/// Creates a MaterialApp wrapper for widget testing with providers.
Widget createTestApp({
  required Widget child,
  List<ChangeNotifierProvider>? providers,
}) {
  return MaterialApp(
    home: providers != null
        ? MultiProvider(providers: providers, child: child)
        : child,
  );
}

/// Pumps the widget and settles all animations.
Future<void> pumpAndSettleWidget(WidgetTester tester, Widget widget) async {
  await tester.pumpWidget(widget);
  await tester.pumpAndSettle();
}

/// Extension methods for easier test assertions.
extension TestExtensions on WidgetTester {
  /// Finds a widget by its exact text content.
  Finder findTextExact(String text) {
    return find.text(text);
  }

  /// Finds a button with specific text.
  Finder findButtonWithText(String text) {
    return find.widgetWithText(ElevatedButton, text);
  }

  /// Taps a button and waits for animations.
  Future<void> tapAndSettle(Finder finder) async {
    await tap(finder);
    await pumpAndSettle();
  }
}
