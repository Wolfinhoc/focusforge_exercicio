import 'package:flutter/material.dart';
import '../widgets/dots_indicator.dart';
import '../services/prefs_service.dart';

class OnboardingPage extends StatefulWidget {
  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final PageController _controller = PageController();
  int page = 0;

  void _onNext() {
    if (page < 2) {
      _controller.nextPage(duration: Duration(milliseconds: 300), curve: Curves.easeInOut);
    }
  }

  void _onSkip() {
    Navigator.pushReplacementNamed(context, '/policy-viewer');
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      _buildWelcome(),
      _buildHowItWorks(),
      _buildConsentIntro(),
    ];
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView(
                controller: _controller,
                onPageChanged: (i) => setState(() => page = i),
                children: pages,
              ),
            ),
            DotsIndicator(count: pages.length, position: page),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  if (page < 2)
                    TextButton(onPressed: _onSkip, child: Text('Pular')),
                  Spacer(),
                  ElevatedButton(onPressed: _onNext, child: Text(page == 2 ? 'Concordo' : 'Avançar')),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildWelcome() {
    return Padding(
      padding: EdgeInsets.all(24),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        SizedBox(height: 24),
        Text('Bem‑vindo ao FocusForge', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w600)),
        SizedBox(height: 12),
        Text('Ciclos Pomodoro com metas de sessão para manter seu foco.')
      ]),
    );
  }

  Widget _buildHowItWorks() {
    return Padding(
      padding: EdgeInsets.all(24),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        SizedBox(height: 24),
        Text('Como funciona', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w600)),
        SizedBox(height: 12),
        Text('25 minutos de foco, 5 minutos de pausa. Crie uma meta curta e comece seu primeiro ciclo.')
      ]),
    );
  }

  Widget _buildConsentIntro() {
    return Padding(
      padding: EdgeInsets.all(24),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        SizedBox(height: 24),
        Text('Privacidade e Consentimento', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w600)),
        SizedBox(height: 12),
        Text('Antes de começar, leia nossas políticas e aceite para persistir seus consentimentos.'),
        SizedBox(height: 24),
        ElevatedButton(
          onPressed: () {
            Navigator.pushReplacementNamed(context, '/policy-viewer');
          },
          child: Text('Ler políticas e aceitar'),
        )
      ]),
    );
  }
}
