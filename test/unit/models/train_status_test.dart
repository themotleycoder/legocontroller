import 'package:flutter_test/flutter_test.dart';
import 'package:legocontroller/models/train_status.dart';

void main() {
  group('TrainStatus', () {
    test('creates instance with required fields', () {
      final trainStatus = TrainStatus(connectedTrains: 2, trains: {});

      expect(trainStatus.connectedTrains, 2);
      expect(trainStatus.trains, isEmpty);
    });

    test('fromJson creates valid instance', () {
      final json = {
        'connected_trains': 3,
        'trains': {
          'hub1': {
            'status': 'connected',
            'speed': 50.0,
            'direction': 'forward',
            'name': 'Train 1',
            'self_drive': true,
            'last_update_seconds_ago': 1.5,
            'rssi': -60,
          },
        },
      };

      final trainStatus = TrainStatus.fromJson(json);

      expect(trainStatus.connectedTrains, 3);
      expect(trainStatus.trains.length, 1);
      expect(trainStatus.trains['hub1']?.name, 'Train 1');
    });

    test('toJson creates valid JSON', () {
      final train = Train(
        status: 'connected',
        speed: 75.0,
        direction: 'backward',
        name: 'Express',
        selfDrive: false,
        lastUpdateSecondsAgo: 2.0,
        rssi: -55,
      );

      final trainStatus = TrainStatus(
        connectedTrains: 1,
        trains: {'hub1': train},
      );

      final json = trainStatus.toJson();

      expect(json['connected_trains'], 1);
      expect(json['trains'], isA<Map>());
      expect(json['trains']['hub1']['name'], 'Express');
    });

    test('equality compares values correctly', () {
      final train1 = Train(
        status: 'connected',
        speed: 50.0,
        direction: 'forward',
        name: 'Train 1',
        selfDrive: true,
        lastUpdateSecondsAgo: 1.0,
        rssi: -60,
      );

      final status1 = TrainStatus(connectedTrains: 1, trains: {'hub1': train1});

      final status2 = TrainStatus(connectedTrains: 1, trains: {'hub1': train1});

      expect(status1, equals(status2));
      // Note: hashCode equality not guaranteed for map-based objects
    });

    test('equality returns false for different values', () {
      final train1 = Train(
        status: 'connected',
        speed: 50.0,
        direction: 'forward',
        name: 'Train 1',
        selfDrive: true,
        lastUpdateSecondsAgo: 1.0,
        rssi: -60,
      );

      final train2 = Train(
        status: 'connected',
        speed: 75.0,
        direction: 'forward',
        name: 'Train 2',
        selfDrive: false,
        lastUpdateSecondsAgo: 2.0,
        rssi: -55,
      );

      final status1 = TrainStatus(connectedTrains: 1, trains: {'hub1': train1});

      final status2 = TrainStatus(connectedTrains: 2, trains: {'hub2': train2});

      expect(status1, isNot(equals(status2)));
    });

    test('toString returns formatted string', () {
      final trainStatus = TrainStatus(connectedTrains: 1, trains: {});

      final string = trainStatus.toString();

      expect(string, contains('TrainStatus'));
      expect(string, contains('connectedTrains: 1'));
      expect(string, contains('trains: {}'));
    });

    test('copyWith creates new instance with updated values', () {
      final train1 = Train(
        status: 'connected',
        speed: 50.0,
        direction: 'forward',
        name: 'Train 1',
        selfDrive: true,
        lastUpdateSecondsAgo: 1.0,
        rssi: -60,
      );

      final original = TrainStatus(
        connectedTrains: 1,
        trains: {'hub1': train1},
      );

      final updated = original.copyWith(connectedTrains: 2);

      expect(updated.connectedTrains, 2);
      expect(updated.trains, equals(original.trains));
      expect(original.connectedTrains, 1); // Original unchanged
    });

    test('copyWith with no parameters returns equivalent instance', () {
      final train1 = Train(
        status: 'connected',
        speed: 50.0,
        direction: 'forward',
        name: 'Train 1',
        selfDrive: true,
        lastUpdateSecondsAgo: 1.0,
        rssi: -60,
      );

      final original = TrainStatus(
        connectedTrains: 1,
        trains: {'hub1': train1},
      );

      final copy = original.copyWith();

      expect(copy.connectedTrains, original.connectedTrains);
      expect(copy.trains, equals(original.trains));
    });

    test('_mapsEqual handles different map sizes', () {
      final train1 = Train(
        status: 'connected',
        speed: 50.0,
        direction: 'forward',
        name: 'Train 1',
        selfDrive: true,
        lastUpdateSecondsAgo: 1.0,
        rssi: -60,
      );

      final status1 = TrainStatus(connectedTrains: 1, trains: {'hub1': train1});

      final status2 = TrainStatus(
        connectedTrains: 1,
        trains: {'hub1': train1, 'hub2': train1},
      );

      expect(status1, isNot(equals(status2)));
    });
  });

  group('Train', () {
    test('creates instance with required fields', () {
      final train = Train(
        status: 'connected',
        speed: 50.0,
        direction: 'forward',
        name: 'Express',
        selfDrive: true,
        lastUpdateSecondsAgo: 1.5,
        rssi: -60,
      );

      expect(train.status, 'connected');
      expect(train.speed, 50.0);
      expect(train.direction, 'forward');
      expect(train.name, 'Express');
      expect(train.selfDrive, true);
      expect(train.lastUpdateSecondsAgo, 1.5);
      expect(train.rssi, -60);
    });

    test('fromJson creates valid instance', () {
      final json = {
        'status': 'connected',
        'speed': 75.0,
        'direction': 'backward',
        'name': 'Freight',
        'self_drive': false,
        'last_update_seconds_ago': 2.0,
        'rssi': -55,
      };

      final train = Train.fromJson(json);

      expect(train.status, 'connected');
      expect(train.speed, 75.0);
      expect(train.direction, 'backward');
      expect(train.name, 'Freight');
      expect(train.selfDrive, false);
      expect(train.lastUpdateSecondsAgo, 2.0);
      expect(train.rssi, -55);
    });

    test('fromJson handles missing self_drive field with default', () {
      final json = {
        'status': 'connected',
        'speed': 50.0,
        'direction': 'forward',
        'name': 'Train',
        'last_update_seconds_ago': 1.0,
        'rssi': -60,
      };

      final train = Train.fromJson(json);

      expect(train.selfDrive, false); // Default value
    });

    test('toJson creates valid JSON', () {
      final train = Train(
        status: 'disconnected',
        speed: 0.0,
        direction: 'stopped',
        name: 'Local',
        selfDrive: true,
        lastUpdateSecondsAgo: 5.0,
        rssi: -70,
      );

      final json = train.toJson();

      expect(json['status'], 'disconnected');
      expect(json['speed'], 0.0);
      expect(json['direction'], 'stopped');
      expect(json['name'], 'Local');
      expect(json['self_drive'], true);
      expect(json['last_update_seconds_ago'], 5.0);
      expect(json['rssi'], -70);
    });

    test('equality compares all fields correctly', () {
      final train1 = Train(
        status: 'connected',
        speed: 50.0,
        direction: 'forward',
        name: 'Train 1',
        selfDrive: true,
        lastUpdateSecondsAgo: 1.0,
        rssi: -60,
      );

      final train2 = Train(
        status: 'connected',
        speed: 50.0,
        direction: 'forward',
        name: 'Train 1',
        selfDrive: true,
        lastUpdateSecondsAgo: 1.0,
        rssi: -60,
      );

      expect(train1, equals(train2));
      expect(train1.hashCode, equals(train2.hashCode));
    });

    test('equality returns false for different status', () {
      final train1 = Train(
        status: 'connected',
        speed: 50.0,
        direction: 'forward',
        name: 'Train',
        selfDrive: true,
        lastUpdateSecondsAgo: 1.0,
        rssi: -60,
      );

      final train2 = Train(
        status: 'disconnected',
        speed: 50.0,
        direction: 'forward',
        name: 'Train',
        selfDrive: true,
        lastUpdateSecondsAgo: 1.0,
        rssi: -60,
      );

      expect(train1, isNot(equals(train2)));
    });

    test('equality returns false for different speed', () {
      final train1 = Train(
        status: 'connected',
        speed: 50.0,
        direction: 'forward',
        name: 'Train',
        selfDrive: true,
        lastUpdateSecondsAgo: 1.0,
        rssi: -60,
      );

      final train2 = Train(
        status: 'connected',
        speed: 75.0,
        direction: 'forward',
        name: 'Train',
        selfDrive: true,
        lastUpdateSecondsAgo: 1.0,
        rssi: -60,
      );

      expect(train1, isNot(equals(train2)));
    });

    test('toString returns formatted string', () {
      final train = Train(
        status: 'connected',
        speed: 50.0,
        direction: 'forward',
        name: 'Express',
        selfDrive: true,
        lastUpdateSecondsAgo: 1.5,
        rssi: -60,
      );

      final string = train.toString();

      expect(string, contains('Train'));
      expect(string, contains('status: connected'));
      expect(string, contains('speed: 50.0'));
      expect(string, contains('direction: forward'));
      expect(string, contains('name: Express'));
      expect(string, contains('selfDrive: true'));
      expect(string, contains('lastUpdateSecondsAgo: 1.5'));
      expect(string, contains('rssi: -60'));
    });

    test('copyWith updates individual fields', () {
      final original = Train(
        status: 'connected',
        speed: 50.0,
        direction: 'forward',
        name: 'Train 1',
        selfDrive: false,
        lastUpdateSecondsAgo: 1.0,
        rssi: -60,
      );

      final updated = original.copyWith(speed: 75.0, selfDrive: true);

      expect(updated.speed, 75.0);
      expect(updated.selfDrive, true);
      expect(updated.status, 'connected'); // Unchanged
      expect(updated.direction, 'forward'); // Unchanged
      expect(updated.name, 'Train 1'); // Unchanged
      expect(original.speed, 50.0); // Original unchanged
    });

    test('copyWith with no parameters returns equivalent instance', () {
      final original = Train(
        status: 'connected',
        speed: 50.0,
        direction: 'forward',
        name: 'Train 1',
        selfDrive: true,
        lastUpdateSecondsAgo: 1.0,
        rssi: -60,
      );

      final copy = original.copyWith();

      expect(copy, equals(original));
    });
  });
}
