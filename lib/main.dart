import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:legocontroller/screens/home-screen.dart';
import 'package:legocontroller/style/app_style.dart';
import 'package:legocontroller/providers/train_state_provider.dart';
import 'package:legocontroller/providers/switch_state_provider.dart';
import 'package:legocontroller/services/lego-webservice.dart';
import 'package:legocontroller/services/settings_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  late SettingsService settingsService;

  try {
    // Load environment variables
    await dotenv.load(fileName: ".env");
    print('✓ Environment variables loaded');
  } catch (e) {
    print('⚠ Error loading .env file: $e');
    // Continue with defaults if .env fails to load
  }

  try {
    // Initialize settings service
    print('Initializing SharedPreferences...');
    final prefs = await SharedPreferences.getInstance();
    settingsService = SettingsService(prefs);
    print('✓ Settings service initialized');

    // Get the singleton and configure with saved settings
    final webService = TrainWebService();
    final host = settingsService.getHost();
    final port = settingsService.getPort();
    final apiKey = settingsService.getApiKey();

    print('Configuring web service: $host:$port');
    webService.configure(
      customBaseUrl: SettingsService.constructUrl(host, port),
      apiKey: apiKey,
    );
    print('✓ Web service configured');
  } catch (e) {
    print('⚠ Error during initialization: $e');
    // Create a minimal settings service if initialization fails
    final prefs = await SharedPreferences.getInstance();
    settingsService = SettingsService(prefs);
  }

  // Set preferred orientations for both landscape and portrait
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
    DeviceOrientation.portraitUp,
  ]);

  print('Starting app...');
  runApp(MyApp(settingsService: settingsService));
}

class MyApp extends StatelessWidget {
  final SettingsService settingsService;

  const MyApp({super.key, required this.settingsService});

  @override
  Widget build(BuildContext context) {
    final webService = TrainWebService();

    return MultiProvider(
      providers: [
        // Core state providers
        ChangeNotifierProvider(create: (_) => TrainStateProvider(webService)),
        ChangeNotifierProvider(create: (_) => SwitchStateProvider(webService)),
        // Settings service provider
        Provider<SettingsService>.value(value: settingsService),
      ],
      child: MaterialApp(
        title: 'LEGO Train Controller',
        theme: ThemeData(
          useMaterial3: true,
          brightness: Brightness.light,
          colorScheme: ColorScheme.fromSeed(
            seedColor: AppStyle.primaryColor,
            brightness: Brightness.light,
          ),
          appBarTheme: const AppBarTheme(
            backgroundColor: Color(0xFF006CB7),
            foregroundColor: Colors.white,
            centerTitle: false,
          ),
          scaffoldBackgroundColor: Colors.white,
          cardColor: Colors.white,
        ),
        home: const HomeScreen(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
