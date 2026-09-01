import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'screens/home_screen.dart';
import 'services/storage_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await StorageService.init();
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  runApp(
    const ProviderScope(
      child: ScrewJamApp(),
    ),
  );
}

class ScrewJamApp extends StatelessWidget {
  const ScrewJamApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Screw Jam',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: Colors.black,
        colorScheme: const ColorScheme.dark(
          surface: Color(0xFF121212),
          primary: Colors.white,
          onPrimary: Colors.black,
          onSurface: Colors.white,
          outline: Color(0xFF333333),
        ),
        useMaterial3: true,
        fontFamily: 'Fredoka',
      ),
      home: const HomeScreen(),
    );
  }
}
