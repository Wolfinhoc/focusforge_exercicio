import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import '../services/prefs_service.dart';
import '../widgets/app_drawer.dart';

class PolicyViewerPage extends StatefulWidget {
  @override
  State<PolicyViewerPage> createState() => _PolicyViewerPageState();
}

class _PolicyViewerPageState extends State<PolicyViewerPage> {
  String privacy = '';
  String terms = '';
  bool privacyRead = false;
  bool termsRead = false;
  bool accepted = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    privacy = await rootBundle.loadString('assets/privacy.md');
    terms = await rootBundle.loadString('assets/terms.md');
    setState((){});
  }

  void _markPrivacyRead() {
    setState(() {
      privacyRead = true;
      // persist minimal flag
      PrefsService.privacyRead = true;
    });
  }

  void _markTermsRead() {
    setState(() {
      termsRead = true;
      PrefsService.termsRead = true;
    });
  }

  Future<void> _acceptAll() async {
    if (privacyRead && termsRead) {
      PrefsService.policiesVersion = 'v1';
      PrefsService.acceptedAt = DateTime.now().toIso8601String();
      PrefsService.onboardingCompleted = true;
      // after accept, ask for notifications opt-in (simplified)
      final optIn = await showDialog<bool>(
        context: context,
        builder: (_) => AlertDialog(
          title: Text('Notificações'),
          content: Text('Deseja receber notificações para iniciar/pausar ciclos?'),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context, false), child: Text('Não')),
            ElevatedButton(onPressed: () => Navigator.pop(context, true), child: Text('Sim')),
          ],
        ),
      );
      PrefsService.notificationsOptIn = optIn ?? false;
      Navigator.pushReplacementNamed(context, '/home');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Leia ambos os documentos antes de aceitar.')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: AppDrawer(),
      appBar: AppBar(title: Text('Políticas')),
      body: ListView(
        padding: EdgeInsets.all(16),
        children: [
          Text('Leia a política de privacidade e os termos. Use os botões abaixo quando terminar de ler.'),
          SizedBox(height: 12),
          ElevatedButton(onPressed: _markPrivacyRead, child: Text('Marcar privacidade como lida')),
          ElevatedButton(onPressed: _markTermsRead, child: Text('Marcar termos como lidos')),
          SizedBox(height: 24),
          ElevatedButton(onPressed: _acceptAll, child: Text('Concordo')),
        ],
      ),
    );
  }
}
