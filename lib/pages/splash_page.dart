import 'package:flutter/material.dart';
import '../services/prefs_service.dart';

class SplashPage extends StatefulWidget {
  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();
    _decideRoute();
  }

  Future<void> _decideRoute() async {
    await Future.delayed(Duration(milliseconds: 500));
    final accepted = PrefsService.policiesVersion != null;
    if (accepted) {
      Navigator.pushReplacementNamed(context, '/home');
    } else {
      Navigator.pushReplacementNamed(context, '/onboarding');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF0F172A),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.timer, size: 96, color: Color(0xFF7C3AED)),
            SizedBox(height: 12),
            Text('FocusForge', style: TextStyle(color: Colors.white, fontSize: 24))
          ],
        ),
      ),
    );
  }
}
