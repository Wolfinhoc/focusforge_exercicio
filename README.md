# focusforge
Aluno: Bruno Rocco Wolfardt

PRD — FocusForge: Primeira Execução, Consentimento e Identidade 
Versão: v1.0 
Responsável: Bruno Rocco Wolfardt 
1) Visão Geral 
Resumo: FocusForge é um app de gestão de foco baseado em ciclos Pomodoro com 
metas de 
sessão. 
Na primeira execução, guia o usuário pelo onboarding, apresentação do ciclo padrão 
(25/5), leitura das políticas e opt-in de notificações. 
Problemas que ataca: - Desorientação na primeira execução - Falta de persistência de consentimentos - Sobrecarga de decisões antes do usuário entender o fluxo 
Resultado desejado: experiência inicial curta, guiada e memorável; consentimentos 
persistidos e editáveis; usuário pronto para iniciar o primeiro ciclo. 
2) Persona Principal 
Estudante com rotina dividida que precisa de sessões focadas e previsíveis. 
3) Identidade Visual 
Paleta: - Violet #7C3AED (Primária) - Slate #0F172A (Texto/Superfície escuro) - Cyan #06B6D4 (Acento) 
Direção: minimalista, alto contraste, useMaterial3: true 
Ícone: timer minimalista (prompt: 'timer minimal flat vector, circular, transparent 
background, violet/cyan accents, 1024x1024') 
4) Jornada de Primeira Execução 
Fluxo base: 
Splash -> Onboarding (PageView 3 telas: Bem-vindo, Como funciona, 
Consentimento) -> Visualizador de Políticas (Markdown) -> Opt-in Notificações -> Home 
(Primeiro ciclo e meta textual) 
Detalhes: - Ciclo padrão ensinado: 25 min foco / 5 min pausa - Primeiro passo: criar uma meta curta (texto) - Após consentimento, solicitar opt-in de notificações com explicação breve 
5) Requisitos Funcionais (RF) - RF-1: PageView de onboarding com Dots sincronizados; Dots ocultos na última página.- 
RF-2: Navegação contextual: Pular direciona ao consentimento; Voltar/Avançar onde 
aplicável. - RF-3: Visualizador de políticas em Markdown com barra de progresso e 'Marcar como lido' 
só após scroll completo. 
- RF-4: Aceite opt-in (checkbox) habilitado somente após leitura dos dois documentos. - RF-5: Splash decide rota por flags de versão de políticas aceitas. - RF-6: Opt-in de notificações solicitado após aceite, com persistência da escolha. - RF-7: Revogação de consentimento disponível em Configurações com confirmação e 
SnackBar de desfazer. - RF-8: Persistência das chaves: privacy_read_v1, terms_read_v1, 
policies_version_accepted, accepted_at (ISO8601), onboarding_completed, 
notifications_opt_in 
6) Requisitos Não Funcionais (RNF) - A11Y: alvos >=48dp, foco visível, Semantics, contraste AA, text scaling >=1.3 - Privacidade (LGPD): registro de aceite, facilidade de revogação, políticas como assets- 
Arquitetura: UI -> Service -> Storage (PrefsService). UI não acessa SharedPreferences 
diretamente. - Performance: animações ~300ms, evitar rebuilds desnecessários. 
7) Dados & Persistência (chaves) - privacy_read_v1 : bool - terms_read_v1 : bool - policies_version_accepted : string (ex: v1) - accepted_at : string (ISO8601) - onboarding_completed : bool - notifications_opt_in : bool 
8) Roteamento 
/ -> Splash 
/onboarding -> PageView 
/policy-viewer -> viewer markdown 
/home -> Home 
9) Critérios de Aceite - Onboarding conclui com Dots e navegação correta. - Visualizador de políticas exige leitura completa para habilitar 'Marcar como lido'. - Aceite só habilita após leitura dupla e checkbox marcado. - Splash leva a Home se policies_version_accepted existir e for atual. - Opt-in de notificações persiste e pode ser revogado em Configurações. 
10) Protocolo de QA (testes manuais mínimos) - Fluxo completo: abrir app -> onboarding -> políticas -> aceite -> opt-in notificações -> 
home. - Reabrir app com accepted_at presente vai direto à home. - Revogação: confirma e permite desfazer (SnackBar). 
11) Riscos & Decisões- Risco: acoplamento UI -Storage. Mitigação: PrefsService e injeção de dependência. - Decisão: políticas mantidas como assets para versionamento offline. 
12) Entregáveis - Implementação Flutter do fluxo de primeira execução + PrefsService. - Evidências (prints) dos estados de onboarding/consentimento/revogação. - Ícone gerado (comando/resultado). 
Checklist de conformidade: - [ ] Dots sincronizados e ocultos na última tela - [ ] Pular -> consentimento; Voltar/Avançar contextuais - [ ] Viewer com progresso + 'Marcar como lido' - [ ] Aceite habilita somente após leitura dupla + checkbox - [ ] Splash decide rota por versão aceita - [ ] Revogação com confirmação + Desfazer - [ ] Sem SharedPreferences direto na UI (usar PrefsService) - [ ] Opt-in de notificações implementado - [ ] A11Y (48dp, contraste, Semantics, text scaling)
