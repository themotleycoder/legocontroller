import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'package:legocontroller/screens/home-screen.dart';
import 'package:legocontroller/style/app_style.dart';
import 'package:legocontroller/providers/train_state_provider.dart';
import 'package:legocontroller/providers/switch_state_provider.dart';
import 'package:legocontroller/services/lego-webservice.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load environment variables
  await dotenv.load(fileName: ".env");

  // Set preferred orientations for both landscape and portrait
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
    DeviceOrientation.portraitUp,
  ]);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final webService = TrainWebService();

    return MultiProvider(
      providers: [
        // Core state providers
        ChangeNotifierProvider(
          create: (_) => TrainStateProvider(webService),
        ),
        ChangeNotifierProvider(
          create: (_) => SwitchStateProvider(webService),
        ),
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
