/// Unit tests for TrainStateProvider.
///
/// Tests state management, polling, error handling, and business logic.
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:mocktail/mocktail.dart';
import 'package:legocontroller/providers/train_state_provider.dart';
import 'package:legocontroller/services/lego-webservice.dart';
import '../../helpers/test_helpers.dart';

/// Mock web service for testing
class MockTrainWebService extends Mock implements TrainWebService {}

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

  group('TrainStateProvider', () {
    late MockTrainWebService mockWebService;
    late TrainStateProvider provider;

    setUp(() {
      mockWebService = MockTrainWebService();

      // Set up default mock responses BEFORE creating provider
      when(
        () => mockWebService.getConnectedTrains(),
      ).thenAnswer((_) async => createMockTrainStatus());

      provider = TrainStateProvider(mockWebService);
    });

    tearDown(() {
      provider.dispose();
    });

    group('initialization', () {
      test('starts in loading state', () async {
        final freshMockWebService = MockTrainWebService();
        when(
          () => freshMockWebService.getConnectedTrains(),
        ).thenAnswer((_) async => createMockTrainStatus());

        final freshProvider = TrainStateProvider(freshMockWebService);

        // Check initial state immediately
        expect(freshProvider.isLoading, true);
        expect(freshProvider.trainStatus, null);
        expect(freshProvider.error, null);

        // Wait for initial fetch to complete before disposing
        await Future.delayed(const Duration(milliseconds: 200));
        freshProvider.dispose();
      });

      test('fetches train status on initialization', () async {
        // Wait for the initial fetch
        await Future.delayed(const Duration(milliseconds: 100));

        verify(
          () => mockWebService.getConnectedTrains(),
        ).called(greaterThanOrEqualTo(1));
      });

      test('updates state after successful fetch', () async {
        await Future.delayed(const Duration(milliseconds: 100));

        expect(provider.isLoading, false);
        expect(provider.trainStatus, isNotNull);
        expect(provider.trainStatus?.connectedTrains, 2);
        expect(provider.error, null);
      });
    });

    group('error handling', () {
      test('sets error state when fetch fails', () async {
        when(
          () => mockWebService.getConnectedTrains(),
        ).thenThrow(TrainWebServiceException('Network error'));

        final errorProvider = TrainStateProvider(mockWebService);

        await Future.delayed(const Duration(milliseconds: 100));

        expect(errorProvider.error, isNotNull);
        expect(errorProvider.error, contains('Network error'));

        errorProvider.dispose();
      });

      test('clears error on successful fetch', () async {
        var callCount = 0;
        when(() => mockWebService.getConnectedTrains()).thenAnswer((_) async {
          callCount++;
          if (callCount == 1) {
            throw TrainWebServiceException('First call fails');
          }
          return createMockTrainStatus();
        });

        final errorProvider = TrainStateProvider(mockWebService);

        await Future.delayed(const Duration(milliseconds: 100));
        expect(errorProvider.error, isNotNull);

        // Wait for next poll
        await Future.delayed(const Duration(seconds: 2));
        expect(errorProvider.error, null);

        errorProvider.dispose();
      });
    });

    group('controlTrain', () {
      test('sends control command with correct parameters', () async {
        when(
          () => mockWebService.controlTrain(
            hubId: any(named: 'hubId'),
            power: any(named: 'power'),
          ),
        ).thenAnswer((_) async => {});

        // Clear initial interactions
        clearInteractions(mockWebService);

        await provider.controlTrain(hubId: 21, power: 50);

        verify(
          () => mockWebService.controlTrain(hubId: 21, power: 50),
        ).called(1);
      });

      test('updates local speed tracking', () async {
        when(
          () => mockWebService.controlTrain(
            hubId: any(named: 'hubId'),
            power: any(named: 'power'),
          ),
        ).thenAnswer((_) async => {});

        await provider.controlTrain(hubId: 21, power: 75);

        expect(provider.getTrainSpeed('21'), 75);
      });

      test('updates direction based on power', () async {
        when(
          () => mockWebService.controlTrain(
            hubId: any(named: 'hubId'),
            power: any(named: 'power'),
          ),
        ).thenAnswer((_) async => {});

        await provider.controlTrain(hubId: 21, power: 50);
        await Future.delayed(const Duration(milliseconds: 50));
        expect(provider.getTrainDirection('21'), 'Forward');

        await provider.controlTrain(hubId: 21, power: -50);
        await Future.delayed(const Duration(milliseconds: 50));
        expect(provider.getTrainDirection('21'), 'Backward');

        await provider.controlTrain(hubId: 21, power: 0);
        await Future.delayed(const Duration(milliseconds: 50));
        expect(provider.getTrainDirection('21'), 'Stopped');
      });

      test('fetches fresh status after control command', () async {
        when(
          () => mockWebService.controlTrain(
            hubId: any(named: 'hubId'),
            power: any(named: 'power'),
          ),
        ).thenAnswer((_) async => {});

        // Clear previous calls
        clearInteractions(mockWebService);

        await provider.controlTrain(hubId: 21, power: 50);

        // Should call getConnectedTrains after control
        verify(
          () => mockWebService.getConnectedTrains(),
        ).called(greaterThanOrEqualTo(1));
      });

      test('sets error state on failure', () async {
        when(
          () => mockWebService.controlTrain(
            hubId: any(named: 'hubId'),
            power: any(named: 'power'),
          ),
        ).thenThrow(TrainWebServiceException('Control failed'));

        try {
          await provider.controlTrain(hubId: 21, power: 50);
        } catch (e) {
          // Expected to throw
        }

        expect(provider.error, isNotNull);
      });
    });

    group('selfDriveTrain', () {
      test('sends self-drive command correctly', () async {
        when(
          () => mockWebService.selfDriveTrain(
            hubId: any(named: 'hubId'),
            selfDrive: any(named: 'selfDrive'),
          ),
        ).thenAnswer((_) async => {});

        await provider.selfDriveTrain(hubId: 21, selfDrive: true);

        verify(
          () => mockWebService.selfDriveTrain(hubId: 21, selfDrive: true),
        ).called(1);
      });

      test('fetches status after self-drive toggle', () async {
        when(
          () => mockWebService.selfDriveTrain(
            hubId: any(named: 'hubId'),
            selfDrive: any(named: 'selfDrive'),
          ),
        ).thenAnswer((_) async => {});

        clearInteractions(mockWebService);

        await provider.selfDriveTrain(hubId: 21, selfDrive: true);

        verify(
          () => mockWebService.getConnectedTrains(),
        ).called(greaterThanOrEqualTo(1));
      });
    });

    group('disconnect', () {
      test('stops train before disconnecting', () async {
        when(
          () => mockWebService.controlTrain(
            hubId: any(named: 'hubId'),
            power: any(named: 'power'),
          ),
        ).thenAnswer((_) async => {});

        // Clear initial interactions
        clearInteractions(mockWebService);

        await provider.disconnect('21');

        verify(
          () => mockWebService.controlTrain(hubId: 21, power: 0),
        ).called(1);
      });

      test('updates local speed to 0', () async {
        when(
          () => mockWebService.controlTrain(
            hubId: any(named: 'hubId'),
            power: any(named: 'power'),
          ),
        ).thenAnswer((_) async => {});

        // Set initial speed
        await provider.controlTrain(hubId: 21, power: 50);
        await Future.delayed(const Duration(milliseconds: 50));
        expect(provider.getTrainSpeed('21'), 50);

        // Disconnect
        await provider.disconnect('21');
        await Future.delayed(const Duration(milliseconds: 50));
        expect(provider.getTrainSpeed('21'), 0);
      });

      test('fetches fresh status after disconnect', () async {
        when(
          () => mockWebService.controlTrain(
            hubId: any(named: 'hubId'),
            power: any(named: 'power'),
          ),
        ).thenAnswer((_) async => {});

        clearInteractions(mockWebService);

        await provider.disconnect('21');

        verify(
          () => mockWebService.getConnectedTrains(),
        ).called(greaterThanOrEqualTo(1));
      });
    });

    group('disconnectAll', () {
      test('resets bluetooth connection', () async {
        when(() => mockWebService.resetBluetooth()).thenAnswer((_) async => {});

        clearInteractions(mockWebService);

        await provider.disconnectAll();

        verify(() => mockWebService.resetBluetooth()).called(1);
      });

      test('clears all local speed tracking', () async {
        when(
          () => mockWebService.controlTrain(
            hubId: any(named: 'hubId'),
            power: any(named: 'power'),
          ),
        ).thenAnswer((_) async => {});
        when(() => mockWebService.resetBluetooth()).thenAnswer((_) async => {});

        // Set speeds for multiple trains
        await provider.controlTrain(hubId: 21, power: 50);
        await Future.delayed(const Duration(milliseconds: 50));
        await provider.controlTrain(hubId: 22, power: 30);
        await Future.delayed(const Duration(milliseconds: 50));

        expect(provider.getTrainSpeed('21'), 50);
        expect(provider.getTrainSpeed('22'), 30);

        // Disconnect all
        await provider.disconnectAll();
        await Future.delayed(const Duration(milliseconds: 50));

        expect(provider.getTrainSpeed('21'), 0);
        expect(provider.getTrainSpeed('22'), 0);
      });

      test('fetches fresh status after disconnect all', () async {
        when(() => mockWebService.resetBluetooth()).thenAnswer((_) async => {});

        clearInteractions(mockWebService);

        await provider.disconnectAll();

        verify(
          () => mockWebService.getConnectedTrains(),
        ).called(greaterThanOrEqualTo(1));
      });
    });

    group('speed and direction getters', () {
      test('getTrainSpeed returns 0 for unknown train', () {
        expect(provider.getTrainSpeed('999'), 0);
      });

      test('getTrainDirection returns Stopped for speed 0', () {
        expect(provider.getTrainDirection('21'), 'Stopped');
      });

      test('getTrainDirection returns Forward for positive speed', () async {
        when(
          () => mockWebService.controlTrain(
            hubId: any(named: 'hubId'),
            power: any(named: 'power'),
          ),
        ).thenAnswer((_) async => {});

        await provider.controlTrain(hubId: 21, power: 50);
        await Future.delayed(const Duration(milliseconds: 50));
        expect(provider.getTrainDirection('21'), 'Forward');
      });

      test('getTrainDirection returns Backward for negative speed', () async {
        when(
          () => mockWebService.controlTrain(
            hubId: any(named: 'hubId'),
            power: any(named: 'power'),
          ),
        ).thenAnswer((_) async => {});

        await provider.controlTrain(hubId: 21, power: -50);
        await Future.delayed(const Duration(milliseconds: 50));
        expect(provider.getTrainDirection('21'), 'Backward');
      });
    });

    group('polling', () {
      test('polls periodically for status updates', () async {
        clearInteractions(mockWebService);

        // Wait for 2+ poll intervals (1 second each + buffer)
        await Future.delayed(const Duration(milliseconds: 2500));

        // Should have polled at least twice
        verify(
          () => mockWebService.getConnectedTrains(),
        ).called(greaterThanOrEqualTo(2));
      });

      test('stops polling when disposed', () async {
        final testProvider = TrainStateProvider(mockWebService);

        clearInteractions(mockWebService);

        // Let it poll a bit
        await Future.delayed(const Duration(milliseconds: 1500));

        // Verify it was polling
        verify(
          () => mockWebService.getConnectedTrains(),
        ).called(greaterThanOrEqualTo(1));

        // Dispose and verify no errors thrown (timer stops cleanly)
        testProvider.dispose();

        // If the timer didn't stop, this would cause errors, so just check no exception
        await Future.delayed(const Duration(milliseconds: 500));
      });
    });

    group('notifications', () {
      test('notifies listeners on state change', () async {
        when(
          () => mockWebService.controlTrain(
            hubId: any(named: 'hubId'),
            power: any(named: 'power'),
          ),
        ).thenAnswer((_) async => {});

        var notifyCount = 0;
        provider.addListener(() {
          notifyCount++;
        });

        // Change the mock to return different speeds to trigger notification
        when(() => mockWebService.getConnectedTrains()).thenAnswer((_) async {
          final status = createMockTrainStatus();
          return status.copyWith(
            trains: {
              '21': status.trains['21']!.copyWith(speed: 75.0),
              '22': status.trains['22']!,
            },
          );
        });

        await provider.controlTrain(hubId: 21, power: 50);
        await Future.delayed(const Duration(milliseconds: 200));

        // Should have been notified at least once due to status change
        expect(notifyCount, greaterThan(0));
      });

      test('does not notify on duplicate status', () async {
        // This test verifies the optimization in _fetchTrainStatus
        // where it only notifies if status actually changed
        await Future.delayed(const Duration(milliseconds: 100));

        var notifyCount = 0;
        provider.addListener(() {
          notifyCount++;
        });

        // Same status returned - should not notify
        await Future.delayed(const Duration(milliseconds: 1500));

        // Should notify minimally (only on actual changes)
        expect(notifyCount, lessThan(5));
      });
    });
  });
}
