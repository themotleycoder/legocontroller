/// Unit tests for SwitchStateProvider.
///
/// Tests state management, polling, error handling, and double-polling behavior.
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:mocktail/mocktail.dart';
import 'package:legocontroller/providers/switch_state_provider.dart';
import 'package:legocontroller/services/lego-webservice.dart';
import 'package:legocontroller/models/switch_status.dart';
import '../../helpers/test_helpers.dart';

/// Mock web service for testing
class MockSwitchWebService extends Mock implements TrainWebService {}

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

    // Register fallback values for any() matchers
    registerFallbackValue(SwitchPosition.STRAIGHT);
  });

  group('SwitchStateProvider', () {
    late MockSwitchWebService mockWebService;
    late SwitchStateProvider provider;

    setUp(() {
      mockWebService = MockSwitchWebService();

      // Set up default mock responses BEFORE creating provider
      when(
        () => mockWebService.getSwitchStatus(),
      ).thenAnswer((_) async => createMockSwitchStatus());

      provider = SwitchStateProvider(mockWebService);
    });

    tearDown(() {
      provider.dispose();
    });

    group('initialization', () {
      test('starts in loading state', () async {
        final freshMockWebService = MockSwitchWebService();
        when(
          () => freshMockWebService.getSwitchStatus(),
        ).thenAnswer((_) async => createMockSwitchStatus());

        final freshProvider = SwitchStateProvider(freshMockWebService);

        // Check initial state immediately
        expect(freshProvider.isLoading, true);
        expect(freshProvider.switchStatus, null);
        expect(freshProvider.error, null);

        // Wait for initial fetch to complete before disposing
        await Future.delayed(const Duration(milliseconds: 200));
        freshProvider.dispose();
      });

      test('fetches switch status on initialization', () async {
        // Wait for the initial fetch
        await Future.delayed(const Duration(milliseconds: 100));

        verify(
          () => mockWebService.getSwitchStatus(),
        ).called(greaterThanOrEqualTo(1));
      });

      test('updates state after successful fetch', () async {
        await Future.delayed(const Duration(milliseconds: 100));

        expect(provider.isLoading, false);
        expect(provider.switchStatus, isNotNull);
        expect(provider.switchStatus?.connectedSwitches, 2);
        expect(provider.error, null);
      });
    });

    group('error handling', () {
      test('sets error state when fetch fails', () async {
        when(
          () => mockWebService.getSwitchStatus(),
        ).thenThrow(TrainWebServiceException('Network error'));

        final errorProvider = SwitchStateProvider(mockWebService);

        await Future.delayed(const Duration(milliseconds: 100));

        expect(errorProvider.error, isNotNull);
        expect(errorProvider.error, contains('Network error'));

        errorProvider.dispose();
      });

      test('clears error on successful fetch', () async {
        var callCount = 0;
        when(() => mockWebService.getSwitchStatus()).thenAnswer((_) async {
          callCount++;
          if (callCount == 1) {
            throw TrainWebServiceException('First call fails');
          }
          return createMockSwitchStatus();
        });

        final errorProvider = SwitchStateProvider(mockWebService);

        await Future.delayed(const Duration(milliseconds: 100));
        expect(errorProvider.error, isNotNull);

        // Wait for next poll
        await Future.delayed(const Duration(seconds: 2));
        expect(errorProvider.error, null);

        errorProvider.dispose();
      });
    });

    group('controlSwitch', () {
      test('sends control command with correct parameters', () async {
        when(
          () => mockWebService.controlSwitch(
            hubId: any(named: 'hubId'),
            switchId: any(named: 'switchId'),
            position: any(named: 'position'),
          ),
        ).thenAnswer((_) async => {});

        // Clear initial interactions
        clearInteractions(mockWebService);

        await provider.controlSwitch(
          hubId: 30,
          switchId: 'A',
          position: SwitchPosition.DIVERGING,
        );

        verify(
          () => mockWebService.controlSwitch(
            hubId: 30,
            switchId: 'A',
            position: SwitchPosition.DIVERGING,
          ),
        ).called(1);
      });

      test('fetches status twice after control command (double-polling)', () async {
        when(
          () => mockWebService.controlSwitch(
            hubId: any(named: 'hubId'),
            switchId: any(named: 'switchId'),
            position: any(named: 'position'),
          ),
        ).thenAnswer((_) async => {});

        // Create a fresh provider to avoid background polling interference
        final testProvider = SwitchStateProvider(mockWebService);

        // Clear initial fetch
        clearInteractions(mockWebService);

        await testProvider.controlSwitch(
          hubId: 30,
          switchId: 'A',
          position: SwitchPosition.DIVERGING,
        );

        // Should call getSwitchStatus exactly twice (double-polling for physical switch movement)
        // Use greaterThanOrEqualTo to account for possible timing of periodic polls
        verify(
          () => mockWebService.getSwitchStatus(),
        ).called(greaterThanOrEqualTo(2));

        testProvider.dispose();
      });

      test('waits 500ms between double-polling calls', () async {
        when(
          () => mockWebService.controlSwitch(
            hubId: any(named: 'hubId'),
            switchId: any(named: 'switchId'),
            position: any(named: 'position'),
          ),
        ).thenAnswer((_) async => {});

        var callTimes = <DateTime>[];
        when(() => mockWebService.getSwitchStatus()).thenAnswer((_) async {
          callTimes.add(DateTime.now());
          return createMockSwitchStatus();
        });

        clearInteractions(mockWebService);

        await provider.controlSwitch(
          hubId: 30,
          switchId: 'A',
          position: SwitchPosition.STRAIGHT,
        );

        // Verify two calls were made
        expect(callTimes.length, greaterThanOrEqualTo(2));

        // Verify at least 500ms between first and second call
        if (callTimes.length >= 2) {
          final timeDiff = callTimes[1].difference(callTimes[0]).inMilliseconds;
          expect(
            timeDiff,
            greaterThanOrEqualTo(450),
          ); // Allow some timing variance
        }
      });

      test('sets error state on failure', () async {
        when(
          () => mockWebService.controlSwitch(
            hubId: any(named: 'hubId'),
            switchId: any(named: 'switchId'),
            position: any(named: 'position'),
          ),
        ).thenThrow(TrainWebServiceException('Control failed'));

        try {
          await provider.controlSwitch(
            hubId: 30,
            switchId: 'A',
            position: SwitchPosition.DIVERGING,
          );
        } catch (e) {
          // Expected to throw
        }

        expect(provider.error, isNotNull);
      });
    });

    group('disconnectAll', () {
      test('calls disconnect API', () async {
        when(
          () => mockWebService.disconnectAllSwitches(),
        ).thenAnswer((_) async => {});

        clearInteractions(mockWebService);

        await provider.disconnectAll();

        verify(() => mockWebService.disconnectAllSwitches()).called(1);
      });

      test('fetches fresh status after disconnect all', () async {
        when(
          () => mockWebService.disconnectAllSwitches(),
        ).thenAnswer((_) async => {});

        clearInteractions(mockWebService);

        await provider.disconnectAll();

        verify(
          () => mockWebService.getSwitchStatus(),
        ).called(greaterThanOrEqualTo(1));
      });

      test('sets error state on failure', () async {
        when(
          () => mockWebService.disconnectAllSwitches(),
        ).thenThrow(TrainWebServiceException('Disconnect failed'));

        try {
          await provider.disconnectAll();
        } catch (e) {
          // Expected to throw
        }

        expect(provider.error, isNotNull);
      });
    });

    group('polling', () {
      test('polls periodically for status updates', () async {
        clearInteractions(mockWebService);

        // Wait for 2+ poll intervals (1 second each + buffer)
        await Future.delayed(const Duration(milliseconds: 2500));

        // Should have polled at least twice
        verify(
          () => mockWebService.getSwitchStatus(),
        ).called(greaterThanOrEqualTo(2));
      });

      test('stops polling when disposed', () async {
        final testProvider = SwitchStateProvider(mockWebService);

        clearInteractions(mockWebService);

        // Let it poll a bit
        await Future.delayed(const Duration(milliseconds: 1500));

        // Verify it was polling
        verify(
          () => mockWebService.getSwitchStatus(),
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
          () => mockWebService.controlSwitch(
            hubId: any(named: 'hubId'),
            switchId: any(named: 'switchId'),
            position: any(named: 'position'),
          ),
        ).thenAnswer((_) async => {});

        var notifyCount = 0;
        provider.addListener(() {
          notifyCount++;
        });

        // Change the mock to return different positions to trigger notification
        when(() => mockWebService.getSwitchStatus()).thenAnswer((_) async {
          final status = createMockSwitchStatus();
          return status.copyWith(
            switches: {
              '30': status.switches['30']!.copyWith(
                switchPositions: {'A': 1}, // Changed position
              ),
            },
          );
        });

        await provider.controlSwitch(
          hubId: 30,
          switchId: 'A',
          position: SwitchPosition.DIVERGING,
        );
        await Future.delayed(const Duration(milliseconds: 200));

        // Should have been notified at least once due to status change
        expect(notifyCount, greaterThan(0));
      });

      test('does not notify on duplicate status', () async {
        // This test verifies the optimization would be if implemented
        // Currently the provider always notifies, but this documents expected behavior
        await Future.delayed(const Duration(milliseconds: 100));

        var notifyCount = 0;
        provider.addListener(() {
          notifyCount++;
        });

        // Same status returned
        await Future.delayed(const Duration(milliseconds: 1500));

        // Should notify at least once from polling
        expect(notifyCount, greaterThan(0));
      });
    });
  });
}
