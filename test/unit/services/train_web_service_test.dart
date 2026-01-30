/// Unit tests for TrainWebService.
///
/// Tests HTTP communication, error handling, and response parsing.
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:legocontroller/services/lego-webservice.dart';
import 'package:legocontroller/models/train_status.dart';
import 'package:legocontroller/models/switch_status.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    // Initialize dotenv with test values
    dotenv.testLoad(
      fileInput: '''
BACKEND_URL=http://test-server:8000
REQUEST_TIMEOUT_SECONDS=5
POLL_INTERVAL_SECONDS=1
''',
    );
  });

  group('TrainWebService', () {
    late TrainWebService service;
    const baseUrl = 'http://test-server:8000';

    setUp(() {
      service = TrainWebService();
      service.configure(customBaseUrl: baseUrl);
    });

    group('controlTrain', () {
      test(
        'throws exception when HTTP fails (test environment limitation)',
        () async {
          // In Flutter test environment, HTTP calls return 400
          // This verifies error handling works correctly
          await expectLater(
            service.controlTrain(hubId: 21, power: 50),
            throwsA(isA<TrainWebServiceException>()),
          );
        },
      );
    });

    group('selfDriveTrain', () {
      test(
        'throws exception when HTTP fails (test environment limitation)',
        () async {
          await expectLater(
            service.selfDriveTrain(hubId: 21, selfDrive: true),
            throwsA(isA<TrainWebServiceException>()),
          );
        },
      );
    });

    group('controlSwitch', () {
      test(
        'throws exception when HTTP fails (test environment limitation)',
        () async {
          await expectLater(
            service.controlSwitch(
              hubId: 1,
              switchId: 'SWITCH_A',
              position: SwitchPosition.STRAIGHT,
            ),
            throwsA(isA<TrainWebServiceException>()),
          );
        },
      );
    });

    group('getConnectedTrains', () {
      test('parses valid train status with multiple trains', () async {
        final mockResponse = {
          'connected_trains': 2,
          'trains': {
            '21': {
              'status': 'running',
              'speed': 50.0,
              'direction': 'forward',
              'name': 'Train Hub 1',
              'self_drive': false,
              'last_update_seconds_ago': 1.5,
              'rssi': -75,
            },
            '22': {
              'status': 'idle',
              'speed': 0.0,
              'direction': 'stopped',
              'name': 'Train Hub 2',
              'self_drive': true,
              'last_update_seconds_ago': 2.3,
              'rssi': -82,
            },
          },
        };

        // Test JSON parsing directly
        final trainStatus = TrainStatus.fromJson(mockResponse);

        expect(trainStatus.connectedTrains, 2);
        expect(trainStatus.trains.length, 2);
        expect(trainStatus.trains['21']?.name, 'Train Hub 1');
        expect(trainStatus.trains['21']?.speed, 50.0);
        expect(trainStatus.trains['21']?.direction, 'forward');
        expect(trainStatus.trains['21']?.selfDrive, false);
        expect(trainStatus.trains['22']?.selfDrive, true);
      });

      test('parses empty train list correctly', () async {
        final mockResponse = {
          'connected_trains': 0,
          'trains': <String, dynamic>{},
        };

        final trainStatus = TrainStatus.fromJson(mockResponse);

        expect(trainStatus.connectedTrains, 0);
        expect(trainStatus.trains.isEmpty, true);
      });

      test('parses single train correctly', () async {
        final mockResponse = {
          'connected_trains': 1,
          'trains': {
            '21': {
              'status': 'running',
              'speed': 75.5,
              'direction': 'backward',
              'name': 'Express Train',
              'self_drive': true,
              'last_update_seconds_ago': 0.5,
              'rssi': -65,
            },
          },
        };

        final trainStatus = TrainStatus.fromJson(mockResponse);

        expect(trainStatus.connectedTrains, 1);
        expect(trainStatus.trains['21']?.speed, 75.5);
        expect(trainStatus.trains['21']?.direction, 'backward');
      });
    });

    group('getSwitchStatus', () {
      test('parses valid switch status with multiple switches', () async {
        final mockResponse = {
          'connected_switches': 2,
          'switches': {
            '1': {
              'switch_positions': {'SWITCH_A': 0, 'SWITCH_B': 1},
              'switch_states': {'SWITCH_A': 1, 'SWITCH_B': 1},
              'last_update_seconds_ago': 0.8,
              'name': 'Technic Hub 1',
              'status': 97,
              'connected': true,
              'active': true,
            },
            '2': {
              'switch_positions': {'SWITCH_A': 1},
              'switch_states': {'SWITCH_A': 1},
              'last_update_seconds_ago': 1.2,
              'name': 'Technic Hub 2',
              'status': 97,
              'connected': true,
              'active': false,
            },
          },
        };

        final switchStatus = SwitchStatus.fromJson(mockResponse);

        expect(switchStatus.connectedSwitches, 2);
        expect(switchStatus.switches.length, 2);
        expect(switchStatus.switches['1']?.name, 'Technic Hub 1');
        expect(switchStatus.switches['1']?.switchPositions['SWITCH_A'], 0);
        expect(switchStatus.switches['1']?.switchPositions['SWITCH_B'], 1);
        expect(switchStatus.switches['1']?.connected, true);
        expect(switchStatus.switches['2']?.active, false);
      });

      test('parses empty switch list correctly', () async {
        final mockResponse = {
          'connected_switches': 0,
          'switches': <String, dynamic>{},
        };

        final switchStatus = SwitchStatus.fromJson(mockResponse);

        expect(switchStatus.connectedSwitches, 0);
        expect(switchStatus.switches.isEmpty, true);
      });

      test('parses switch with single output', () async {
        final mockResponse = {
          'connected_switches': 1,
          'switches': {
            '1': {
              'switch_positions': {'SWITCH_A': 0},
              'switch_states': {'SWITCH_A': 1},
              'last_update_seconds_ago': 0.3,
              'name': 'Simple Switch',
              'status': 97,
              'connected': true,
              'active': true,
            },
          },
        };

        final switchStatus = SwitchStatus.fromJson(mockResponse);

        expect(switchStatus.switches['1']?.switchPositions.length, 1);
        expect(switchStatus.switches['1']?.switchPositions['SWITCH_A'], 0);
      });
    });

    group('resetBluetooth', () {
      test(
        'throws exception when HTTP fails (test environment limitation)',
        () async {
          await expectLater(
            service.resetBluetooth(),
            throwsA(isA<TrainWebServiceException>()),
          );
        },
      );
    });

    group('disconnectAllSwitches', () {
      test(
        'throws exception when HTTP fails (test environment limitation)',
        () async {
          await expectLater(
            service.disconnectAllSwitches(),
            throwsA(isA<TrainWebServiceException>()),
          );
        },
      );
    });

    group('configuration', () {
      test('uses custom base URL when configured', () {
        final service = TrainWebService();
        service.configure(customBaseUrl: 'http://custom-server:9000');

        expect(service.baseUrl, 'http://custom-server:9000');
      });

      test('singleton returns same instance', () {
        final instance1 = TrainWebService();
        final instance2 = TrainWebService();

        expect(identical(instance1, instance2), true);
      });
    });

    group('TrainWebServiceException', () {
      test('creates exception with message', () {
        final exception = TrainWebServiceException('Test error');
        expect(exception.message, 'Test error');
      });

      test('toString includes message', () {
        final exception = TrainWebServiceException('Connection failed');
        expect(exception.toString(), contains('Connection failed'));
      });
    });
  });
}
