import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'screens/start_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Set system navigation & status bar transparent for immersive neon aesthetic
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Color(0xFF07090F),
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );

  runApp(const GotchaApp());
}

class GotchaApp extends StatelessWidget {
  const GotchaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Gotcha Game',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF07090F),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF00F0FF),
          secondary: Color(0xFFFF007F),
          surface: Color(0xFF131728),
        ),
        fontFamily: 'Roboto',
        useMaterial3: true,
      ),
      home: const StartScreen(),
    );
  }
}

