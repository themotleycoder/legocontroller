import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:legocontroller/services/settings_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('SettingsService', () {
    late SharedPreferences prefs;
    late SettingsService service;

    setUp(() async {
      // Set up dotenv with test values
      dotenv.testLoad(fileInput: '''
BACKEND_URL=http://192.168.86.39:8000
API_KEY=test-api-key
''');

      // Initialize with empty preferences
      SharedPreferences.setMockInitialValues({});
      prefs = await SharedPreferences.getInstance();
      service = SettingsService(prefs);
    });

    group('getHost', () {
      test('returns saved host from SharedPreferences', () async {
        await prefs.setString('backend_host', '10.0.0.1');
        expect(service.getHost(), '10.0.0.1');
      });

      test('falls back to .env BACKEND_URL when no saved host', () {
        expect(service.getHost(), '192.168.86.39');
      });

      test('parses hostname from BACKEND_URL', () {
        dotenv.testLoad(fileInput: 'BACKEND_URL=http://localhost:3000');
        final newService = SettingsService(prefs);
        expect(newService.getHost(), 'localhost');
      });
    });

    group('getPort', () {
      test('returns saved port from SharedPreferences', () async {
        await prefs.setInt('backend_port', 9000);
        expect(service.getPort(), 9000);
      });

      test('falls back to .env BACKEND_URL when no saved port', () {
        expect(service.getPort(), 8000);
      });

      test('uses default port 8000 when URL has no port', () {
        dotenv.testLoad(fileInput: 'BACKEND_URL=http://192.168.1.1');
        final newService = SettingsService(prefs);
        expect(newService.getPort(), 8000);
      });
    });

    group('getApiKey', () {
      test('returns saved API key from SharedPreferences', () async {
        await prefs.setString('api_key', 'saved-key');
        expect(service.getApiKey(), 'saved-key');
      });

      test('falls back to .env API_KEY when no saved key', () {
        expect(service.getApiKey(), 'test-api-key');
      });

      test('returns null when no API key in preferences or .env', () {
        dotenv.testLoad(fileInput: 'BACKEND_URL=http://192.168.86.39:8000');
        final newService = SettingsService(prefs);
        expect(newService.getApiKey(), isNull);
      });
    });

    group('saveSettings', () {
      test('saves host, port, and API key to SharedPreferences', () async {
        await service.saveSettings(
          host: '192.168.1.100',
          port: 3000,
          apiKey: 'my-api-key',
        );

        expect(prefs.getString('backend_host'), '192.168.1.100');
        expect(prefs.getInt('backend_port'), 3000);
        expect(prefs.getString('api_key'), 'my-api-key');
      });

      test('saves host and port without API key', () async {
        await service.saveSettings(
          host: '10.0.0.1',
          port: 8080,
        );

        expect(prefs.getString('backend_host'), '10.0.0.1');
        expect(prefs.getInt('backend_port'), 8080);
        expect(prefs.getString('api_key'), isNull);
      });

      test('removes API key when saving empty string', () async {
        await prefs.setString('api_key', 'existing-key');

        await service.saveSettings(
          host: '192.168.1.1',
          port: 8000,
          apiKey: '',
        );

        expect(prefs.getString('api_key'), isNull);
      });
    });

    group('resetToDefaults', () {
      test('clears all saved settings', () async {
        await prefs.setString('backend_host', '192.168.1.1');
        await prefs.setInt('backend_port', 9000);
        await prefs.setString('api_key', 'saved-key');

        await service.resetToDefaults();

        expect(prefs.getString('backend_host'), isNull);
        expect(prefs.getInt('backend_port'), isNull);
        expect(prefs.getString('api_key'), isNull);
      });

      test('getHost returns .env value after reset', () async {
        await prefs.setString('backend_host', '192.168.1.1');
        await service.resetToDefaults();

        expect(service.getHost(), '192.168.86.39');
      });
    });

    group('isValidHost', () {
      test('accepts valid IP addresses', () {
        expect(SettingsService.isValidHost('192.168.1.1'), isTrue);
        expect(SettingsService.isValidHost('10.0.0.1'), isTrue);
        expect(SettingsService.isValidHost('127.0.0.1'), isTrue);
        expect(SettingsService.isValidHost('255.255.255.255'), isTrue);
        expect(SettingsService.isValidHost('0.0.0.0'), isTrue);
      });

      test('accepts valid hostnames', () {
        expect(SettingsService.isValidHost('localhost'), isTrue);
        expect(SettingsService.isValidHost('server.local'), isTrue);
        expect(SettingsService.isValidHost('my-server'), isTrue);
        expect(SettingsService.isValidHost('api.example.com'), isTrue);
        expect(SettingsService.isValidHost('sub.domain.example.co.uk'), isTrue);
      });

      test('rejects invalid IP addresses', () {
        expect(SettingsService.isValidHost('256.1.1.1'), isFalse);
        expect(SettingsService.isValidHost('192.168.1'), isFalse);
        expect(SettingsService.isValidHost('192.168.1.1.1'), isFalse);
        expect(SettingsService.isValidHost('192.168.-1.1'), isFalse);
      });

      test('rejects invalid hostnames', () {
        expect(SettingsService.isValidHost(''), isFalse);
        expect(SettingsService.isValidHost('-invalid'), isFalse);
        expect(SettingsService.isValidHost('invalid-'), isFalse);
        expect(SettingsService.isValidHost('in valid'), isFalse);
        expect(SettingsService.isValidHost('invalid..com'), isFalse);
      });
    });

    group('isValidPort', () {
      test('accepts valid port numbers', () {
        expect(SettingsService.isValidPort(1), isTrue);
        expect(SettingsService.isValidPort(80), isTrue);
        expect(SettingsService.isValidPort(8000), isTrue);
        expect(SettingsService.isValidPort(65535), isTrue);
      });

      test('rejects invalid port numbers', () {
        expect(SettingsService.isValidPort(0), isFalse);
        expect(SettingsService.isValidPort(-1), isFalse);
        expect(SettingsService.isValidPort(65536), isFalse);
        expect(SettingsService.isValidPort(100000), isFalse);
      });
    });

    group('constructUrl', () {
      test('constructs URL from host and port', () {
        expect(
          SettingsService.constructUrl('192.168.1.1', 8000),
          'http://192.168.1.1:8000',
        );
        expect(
          SettingsService.constructUrl('localhost', 3000),
          'http://localhost:3000',
        );
      });
    });
  });
}
