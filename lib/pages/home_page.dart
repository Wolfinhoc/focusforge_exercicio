import 'package:flutter/material.dart';
import '../services/prefs_service.dart';

class HomePage extends StatefulWidget {
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String _meta = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('FocusForge'),
        actions: [
          IconButton(
            icon: Icon(Icons.settings),
            onPressed: () async {
              // simple revocation flow
              final revoke = await showDialog<bool>(
                context: context,
                builder: (_) => AlertDialog(
                  title: Text('Revogar consentimento?'),
                  content: Text('Confirmar revogação de políticas.'),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(context, false), child: Text('Cancelar')),
                    ElevatedButton(onPressed: () => Navigator.pop(context, true), child: Text('Revogar')),
                  ],
                ),
              );
              if (revoke ?? false) {
                PrefsService.policiesVersion = null;
                PrefsService.acceptedAt = null;
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Consentimento revogado.'), action: SnackBarAction(label: 'Desfazer', onPressed: () {
                  // simple undo
                  PrefsService.policiesVersion = 'v1';
                })));
                Navigator.pushReplacementNamed(context, '/onboarding');
              }
            },
          )
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            Card(
              child: ListTile(
                title: Text('Primeiros Passos'),
                subtitle: Text('Crie sua primeira meta e inicie um ciclo de 25 minutos.'),
              ),
            ),
            SizedBox(height: 12),
            TextField(
              decoration: InputDecoration(labelText: 'Meta curta'),
              onChanged: (v) => setState(() => _meta = v),
            ),
            SizedBox(height: 12),
            ElevatedButton(
              onPressed: _meta.trim().isEmpty ? null : () {
                // start a fake cycle (placeholder)
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Ciclo iniciado: ' + _meta)));
              },
              child: Text('Iniciar ciclo 25/5'),
            )
          ],
        ),
      ),
    );
  }
}
