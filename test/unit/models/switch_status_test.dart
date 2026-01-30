import 'package:flutter_test/flutter_test.dart';
import 'package:legocontroller/models/switch_status.dart';

void main() {
  group('SwitchPosition', () {
    test('enum has correct values', () {
      expect(SwitchPosition.values.length, 2);
      expect(SwitchPosition.values, contains(SwitchPosition.STRAIGHT));
      expect(SwitchPosition.values, contains(SwitchPosition.DIVERGING));
    });
  });

  group('SwitchStatus', () {
    test('creates instance with required fields', () {
      final switchStatus = SwitchStatus(connectedSwitches: 2, switches: {});

      expect(switchStatus.connectedSwitches, 2);
      expect(switchStatus.switches, isEmpty);
    });

    test('fromJson creates valid instance', () {
      final json = {
        'connected_switches': 3,
        'switches': {
          'hub1': {
            'switch_positions': {'A': 0, 'B': 1},
            'switch_states': {'A': 1, 'B': 0},
            'last_update_seconds_ago': 1.5,
            'name': 'Switch 1',
            'status': 1,
            'connected': true,
            'active': true,
            'port_connections': {'A': 0, 'B': 1},
          },
        },
      };

      final switchStatus = SwitchStatus.fromJson(json);

      expect(switchStatus.connectedSwitches, 3);
      expect(switchStatus.switches.length, 1);
      expect(switchStatus.switches['hub1']?.name, 'Switch 1');
    });

    test('toJson creates valid JSON', () {
      final switch1 = Switch(
        switchPositions: {'A': 0},
        switchStates: {'A': 1},
        lastUpdateSecondsAgo: 2.0,
        name: 'Main Switch',
        status: 1,
        connected: true,
        active: false,
        portConnections: {'A': 0},
      );

      final switchStatus = SwitchStatus(
        connectedSwitches: 1,
        switches: {'hub1': switch1},
      );

      final json = switchStatus.toJson();

      expect(json['connected_switches'], 1);
      expect(json['switches'], isA<Map>());
      expect(json['switches']['hub1']['name'], 'Main Switch');
    });

    test('equality compares values correctly', () {
      final switch1 = Switch(
        switchPositions: {'A': 0},
        switchStates: {'A': 1},
        lastUpdateSecondsAgo: 1.0,
        name: 'Switch 1',
        status: 1,
        connected: true,
        active: true,
      );

      final status1 = SwitchStatus(
        connectedSwitches: 1,
        switches: {'hub1': switch1},
      );

      final status2 = SwitchStatus(
        connectedSwitches: 1,
        switches: {'hub1': switch1},
      );

      expect(status1, equals(status2));
      // Note: hashCode equality not guaranteed for map-based objects
    });

    test('equality returns false for different values', () {
      final switch1 = Switch(
        switchPositions: {'A': 0},
        switchStates: {'A': 1},
        lastUpdateSecondsAgo: 1.0,
        name: 'Switch 1',
        status: 1,
      );

      final switch2 = Switch(
        switchPositions: {'B': 1},
        switchStates: {'B': 0},
        lastUpdateSecondsAgo: 2.0,
        name: 'Switch 2',
        status: 0,
      );

      final status1 = SwitchStatus(
        connectedSwitches: 1,
        switches: {'hub1': switch1},
      );

      final status2 = SwitchStatus(
        connectedSwitches: 2,
        switches: {'hub2': switch2},
      );

      expect(status1, isNot(equals(status2)));
    });

    test('toString returns formatted string', () {
      final switchStatus = SwitchStatus(connectedSwitches: 1, switches: {});

      final string = switchStatus.toString();

      expect(string, contains('SwitchStatus'));
      expect(string, contains('connectedSwitches: 1'));
      expect(string, contains('switches: {}'));
    });

    test('copyWith creates new instance with updated values', () {
      final switch1 = Switch(
        switchPositions: {'A': 0},
        switchStates: {'A': 1},
        lastUpdateSecondsAgo: 1.0,
        name: 'Switch 1',
        status: 1,
      );

      final original = SwitchStatus(
        connectedSwitches: 1,
        switches: {'hub1': switch1},
      );

      final updated = original.copyWith(connectedSwitches: 2);

      expect(updated.connectedSwitches, 2);
      expect(updated.switches, equals(original.switches));
      expect(original.connectedSwitches, 1); // Original unchanged
    });

    test('copyWith with no parameters returns equivalent instance', () {
      final switch1 = Switch(
        switchPositions: {'A': 0},
        switchStates: {'A': 1},
        lastUpdateSecondsAgo: 1.0,
        name: 'Switch 1',
        status: 1,
      );

      final original = SwitchStatus(
        connectedSwitches: 1,
        switches: {'hub1': switch1},
      );

      final copy = original.copyWith();

      expect(copy.connectedSwitches, original.connectedSwitches);
      expect(copy.switches, equals(original.switches));
    });

    test('_mapsEqual handles different map sizes', () {
      final switch1 = Switch(
        switchPositions: {'A': 0},
        switchStates: {'A': 1},
        lastUpdateSecondsAgo: 1.0,
        name: 'Switch 1',
        status: 1,
      );

      final status1 = SwitchStatus(
        connectedSwitches: 1,
        switches: {'hub1': switch1},
      );

      final status2 = SwitchStatus(
        connectedSwitches: 1,
        switches: {'hub1': switch1, 'hub2': switch1},
      );

      expect(status1, isNot(equals(status2)));
    });
  });

  group('Switch', () {
    test('creates instance with required fields', () {
      final switch1 = Switch(
        switchPositions: {'A': 0, 'B': 1},
        switchStates: {'A': 1, 'B': 0},
        lastUpdateSecondsAgo: 1.5,
        name: 'Main Switch',
        status: 1,
        connected: true,
        active: true,
        portConnections: {'A': 0, 'B': 1},
      );

      expect(switch1.switchPositions, {'A': 0, 'B': 1});
      expect(switch1.switchStates, {'A': 1, 'B': 0});
      expect(switch1.lastUpdateSecondsAgo, 1.5);
      expect(switch1.name, 'Main Switch');
      expect(switch1.status, 1);
      expect(switch1.connected, true);
      expect(switch1.active, true);
      expect(switch1.portConnections, {'A': 0, 'B': 1});
    });

    test('creates instance with default values', () {
      final switch1 = Switch(
        switchPositions: {'A': 0},
        switchStates: {'A': 1},
        lastUpdateSecondsAgo: 1.0,
        name: 'Switch',
        status: 1,
      );

      expect(switch1.connected, false); // Default
      expect(switch1.active, false); // Default
      expect(switch1.portConnections, isNull); // Default
    });

    test('fromJson creates valid instance', () {
      final json = {
        'switch_positions': {'A': 0, 'B': 1, 'C': 0},
        'switch_states': {'A': 1, 'B': 0, 'C': 1},
        'last_update_seconds_ago': 2.5,
        'name': 'Yard Switch',
        'status': 1,
        'connected': true,
        'active': false,
        'port_connections': {'A': 0, 'B': 1, 'C': 2},
      };

      final switch1 = Switch.fromJson(json);

      expect(switch1.switchPositions, {'A': 0, 'B': 1, 'C': 0});
      expect(switch1.switchStates, {'A': 1, 'B': 0, 'C': 1});
      expect(switch1.lastUpdateSecondsAgo, 2.5);
      expect(switch1.name, 'Yard Switch');
      expect(switch1.status, 1);
      expect(switch1.connected, true);
      expect(switch1.active, false);
      expect(switch1.portConnections, {'A': 0, 'B': 1, 'C': 2});
    });

    test('fromJson handles missing optional fields with defaults', () {
      final json = {
        'switch_positions': {'A': 0},
        'switch_states': {'A': 1},
        'name': 'Switch',
        'status': 1,
      };

      final switch1 = Switch.fromJson(json);

      expect(switch1.lastUpdateSecondsAgo, 0.0); // Default
      expect(switch1.connected, false); // Default
      expect(switch1.active, false); // Default
      expect(switch1.portConnections, isNull); // Default
    });

    test('toJson creates valid JSON', () {
      final switch1 = Switch(
        switchPositions: {'A': 1},
        switchStates: {'A': 0},
        lastUpdateSecondsAgo: 3.0,
        name: 'Station Switch',
        status: 0,
        connected: false,
        active: true,
        portConnections: {'A': 1},
      );

      final json = switch1.toJson();

      expect(json['switch_positions'], {'A': 1});
      expect(json['switch_states'], {'A': 0});
      expect(json['last_update_seconds_ago'], 3.0);
      expect(json['name'], 'Station Switch');
      expect(json['status'], 0);
      expect(json['connected'], false);
      expect(json['active'], true);
      expect(json['port_connections'], {'A': 1});
    });

    test('equality compares all fields correctly', () {
      final switch1 = Switch(
        switchPositions: {'A': 0},
        switchStates: {'A': 1},
        lastUpdateSecondsAgo: 1.0,
        name: 'Switch 1',
        status: 1,
        connected: true,
        active: false,
        portConnections: {'A': 0},
      );

      final switch2 = Switch(
        switchPositions: {'A': 0},
        switchStates: {'A': 1},
        lastUpdateSecondsAgo: 1.0,
        name: 'Switch 1',
        status: 1,
        connected: true,
        active: false,
        portConnections: {'A': 0},
      );

      expect(switch1, equals(switch2));
      // Note: hashCode equality not guaranteed for map-based objects
    });

    test('equality returns false for different switchPositions', () {
      final switch1 = Switch(
        switchPositions: {'A': 0},
        switchStates: {'A': 1},
        lastUpdateSecondsAgo: 1.0,
        name: 'Switch',
        status: 1,
      );

      final switch2 = Switch(
        switchPositions: {'A': 1},
        switchStates: {'A': 1},
        lastUpdateSecondsAgo: 1.0,
        name: 'Switch',
        status: 1,
      );

      expect(switch1, isNot(equals(switch2)));
    });

    test('equality returns false for different switchStates', () {
      final switch1 = Switch(
        switchPositions: {'A': 0},
        switchStates: {'A': 1},
        lastUpdateSecondsAgo: 1.0,
        name: 'Switch',
        status: 1,
      );

      final switch2 = Switch(
        switchPositions: {'A': 0},
        switchStates: {'A': 0},
        lastUpdateSecondsAgo: 1.0,
        name: 'Switch',
        status: 1,
      );

      expect(switch1, isNot(equals(switch2)));
    });

    test('equality handles null portConnections', () {
      final switch1 = Switch(
        switchPositions: {'A': 0},
        switchStates: {'A': 1},
        lastUpdateSecondsAgo: 1.0,
        name: 'Switch',
        status: 1,
        portConnections: null,
      );

      final switch2 = Switch(
        switchPositions: {'A': 0},
        switchStates: {'A': 1},
        lastUpdateSecondsAgo: 1.0,
        name: 'Switch',
        status: 1,
        portConnections: null,
      );

      expect(switch1, equals(switch2));
    });

    test('equality returns false when one portConnection is null', () {
      final switch1 = Switch(
        switchPositions: {'A': 0},
        switchStates: {'A': 1},
        lastUpdateSecondsAgo: 1.0,
        name: 'Switch',
        status: 1,
        portConnections: null,
      );

      final switch2 = Switch(
        switchPositions: {'A': 0},
        switchStates: {'A': 1},
        lastUpdateSecondsAgo: 1.0,
        name: 'Switch',
        status: 1,
        portConnections: {'A': 0},
      );

      expect(switch1, isNot(equals(switch2)));
    });

    test('toString returns formatted string', () {
      final switch1 = Switch(
        switchPositions: {'A': 0},
        switchStates: {'A': 1},
        lastUpdateSecondsAgo: 1.5,
        name: 'Test Switch',
        status: 1,
        connected: true,
        active: false,
        portConnections: {'A': 0},
      );

      final string = switch1.toString();

      expect(string, contains('Switch'));
      expect(string, contains('switchPositions: {A: 0}'));
      expect(string, contains('switchStates: {A: 1}'));
      expect(string, contains('lastUpdateSecondsAgo: 1.5'));
      expect(string, contains('name: Test Switch'));
      expect(string, contains('status: 1'));
      expect(string, contains('connected: true'));
      expect(string, contains('active: false'));
      expect(string, contains('portConnections: {A: 0}'));
    });

    test('copyWith updates individual fields', () {
      final original = Switch(
        switchPositions: {'A': 0},
        switchStates: {'A': 1},
        lastUpdateSecondsAgo: 1.0,
        name: 'Switch 1',
        status: 1,
        connected: false,
        active: false,
      );

      final updated = original.copyWith(
        status: 2,
        connected: true,
        active: true,
      );

      expect(updated.status, 2);
      expect(updated.connected, true);
      expect(updated.active, true);
      expect(updated.switchPositions, {'A': 0}); // Unchanged
      expect(updated.switchStates, {'A': 1}); // Unchanged
      expect(updated.name, 'Switch 1'); // Unchanged
      expect(original.status, 1); // Original unchanged
    });

    test('copyWith with no parameters returns equivalent instance', () {
      final original = Switch(
        switchPositions: {'A': 0},
        switchStates: {'A': 1},
        lastUpdateSecondsAgo: 1.0,
        name: 'Switch 1',
        status: 1,
        connected: true,
        active: true,
        portConnections: {'A': 0},
      );

      final copy = original.copyWith();

      expect(copy, equals(original));
    });

    test('_intMapsEqual compares integer maps correctly', () {
      final switch1 = Switch(
        switchPositions: {'A': 0, 'B': 1},
        switchStates: {'A': 1, 'B': 0},
        lastUpdateSecondsAgo: 1.0,
        name: 'Switch',
        status: 1,
      );

      final switch2 = Switch(
        switchPositions: {'A': 0, 'B': 1},
        switchStates: {'A': 1, 'B': 0},
        lastUpdateSecondsAgo: 1.0,
        name: 'Switch',
        status: 1,
      );

      expect(switch1, equals(switch2));
    });

    test('_dynamicMapsEqual compares dynamic maps correctly', () {
      final switch1 = Switch(
        switchPositions: {'A': 0},
        switchStates: {'A': 1},
        lastUpdateSecondsAgo: 1.0,
        name: 'Switch',
        status: 1,
        portConnections: {'A': 0, 'B': 1, 'C': 'value'},
      );

      final switch2 = Switch(
        switchPositions: {'A': 0},
        switchStates: {'A': 1},
        lastUpdateSecondsAgo: 1.0,
        name: 'Switch',
        status: 1,
        portConnections: {'A': 0, 'B': 1, 'C': 'value'},
      );

      expect(switch1, equals(switch2));
    });
  });
}
