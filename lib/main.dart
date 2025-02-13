import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:legocontroller/screens/home-screen.dart';
import 'package:legocontroller/style/app_style.dart';
import 'package:legocontroller/providers/train_state_provider.dart';
import 'package:legocontroller/providers/switch_state_provider.dart';
import 'package:legocontroller/services/lego-webservice.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
    DeviceOrientation.portraitUp
  ]).then((_) {
    runApp(const MyApp());
  });
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final webService = TrainWebService();
    
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => TrainStateProvider(webService),
        ),
        ChangeNotifierProvider(
          create: (_) => SwitchStateProvider(webService),
        ),
      ],
      child: MaterialApp(
        title: 'LEGO Controller',
        theme: AppStyle.theme,
        home: const HomeScreen(),
      ),
    );
  }
}
