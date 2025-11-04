import 'package:flutter/material.dart';
import '../services/prefs_service.dart';
import 'user_avatar.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          UserAccountsDrawerHeader(
            accountName: Text('FocusForge',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600)),
            accountEmail: Text('Gerencie ciclos e políticas'),
            currentAccountPicture: UserAvatar(name: PrefsService.userName ?? 'Usuário'),
          ),
          ListTile(
            leading: Icon(Icons.home),
            title: Text('Início'),
            onTap: () {
              // Apenas fecha o drawer, pois já estamos na home.
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: Icon(Icons.help_outline),
            title: Text('Onboarding'),
            onTap: () {
              Navigator.pushNamed(context, '/onboarding');
            },
          ),
          ListTile(
            leading: Icon(Icons.description),
            title: Text('Políticas'),
            onTap: () {
              Navigator.pushNamed(context, '/policy-viewer');
            },
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.settings),
            title: Text('Configurações'),
            onTap: () async {
              Navigator.pop(context);
              final revoke = await showDialog<bool>(
                context: context,
                builder: (_) => AlertDialog(
                  title: Text('Revogar consentimento?'),
                  content: Text('Revogar aceitação das políticas (mantém outros dados).'),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(context, false), child: Text('Cancelar')),
                    ElevatedButton(onPressed: () => Navigator.pop(context, true), child: Text('Revogar')),
                  ],
                ),
              );
              if (revoke ?? false) {
                // Salva os valores atuais para permitir o "desfazer"
                final oldVersion = PrefsService.policiesVersion;
                final oldAcceptedAt = PrefsService.acceptedAt;

                // Revoga o consentimento
                PrefsService.policiesVersion = null;
                PrefsService.acceptedAt = null;
                PrefsService.onboardingCompleted = false;

                // Exibe a SnackBar com a opção de desfazer
                final snackBar = SnackBar(
                  content: Text('Consentimento revogado.'),
                  action: SnackBarAction(
                    label: 'Desfazer',
                    onPressed: () {
                      // Restaura os valores antigos
                      PrefsService.policiesVersion = oldVersion;
                      PrefsService.acceptedAt = oldAcceptedAt;
                      PrefsService.onboardingCompleted = true;
                    },
                  ),
                );

                if (!context.mounted) return;

                ScaffoldMessenger.of(context).showSnackBar(snackBar).closed.then((reason) {
                  // Se a SnackBar foi fechada sem o usuário clicar em "Desfazer",
                  // navega para o onboarding.
                  if (reason != SnackBarClosedReason.action) {
                    if (context.mounted) Navigator.pushReplacementNamed(context, '/onboarding');
                  }
                });
              }
            },
          ),
          ListTile(
            leading: Icon(Icons.exit_to_app),
            title: Text('Sair / Limpar dados'),
            onTap: () async {
              Navigator.pop(context);
              final confirm = await showDialog<bool>(
                context: context,
                builder: (_) => AlertDialog(
                  title: Text('Limpar todos os dados?'),
                  content: Text('Isto removerá todas as preferências salvas e retornará ao onboarding.'),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(context, false), child: Text('Cancelar')),
                    ElevatedButton(onPressed: () => Navigator.pop(context, true), child: Text('Confirmar')),
                  ],
                ),
              );
              if (confirm ?? false) {
                await PrefsService.clearAll();
                if (!context.mounted) return;
                Navigator.pushReplacementNamed(context, '/onboarding');
              }
            },
          ),
        ],
      ),
    );
  }
}
