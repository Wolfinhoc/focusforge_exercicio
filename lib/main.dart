import 'package:flutter/material.dart';
import 'pages/splash_page.dart';
import 'pages/home_page.dart';
import 'pages/onboarding_page.dart';
import 'pages/policy_viewer_page.dart';
import 'services/prefs_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await PrefsService.init();
  runApp(FocusForgeApp());
}

class FocusForgeApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FocusForge',
      theme: ThemeData(useMaterial3: true, colorSchemeSeed: Color(0xFF7C3AED)),
      initialRoute: '/',
      routes: {
        '/': (context) => SplashPage(),
        '/onboarding': (context) => OnboardingPage(),
        '/policy-viewer': (context) => PolicyViewerPage(),
        '/home': (context) => HomePage(),
      },
    );
  }
}
