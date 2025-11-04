import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:focusforge/widgets/user_avatar.dart';

void main() {
  // Função auxiliar para encapsular o widget em um MaterialApp
  Widget buildTestableWidget(Widget widget) => MaterialApp(home: Scaffold(body: widget));

  group('UserAvatar Initials Logic', () {
    testWidgets('deve exibir as iniciais para nome composto', (tester) async {
      await tester.pumpWidget(buildTestableWidget(const UserAvatar(name: 'Bruno Rocco')));
      expect(find.text('BR'), findsOneWidget);
    });

    testWidgets('deve exibir a inicial para nome único', (tester) async {
      await tester.pumpWidget(buildTestableWidget(const UserAvatar(name: 'Wolfardt')));
      expect(find.text('W'), findsOneWidget);
    });

    testWidgets('deve ignorar espaços extras', (tester) async {
      await tester.pumpWidget(buildTestableWidget(const UserAvatar(name: '  Bruno   Rocco  ')));
      expect(find.text('BR'), findsOneWidget);
    });

    testWidgets('deve exibir as iniciais do primeiro e último nome', (tester) async {
      await tester.pumpWidget(buildTestableWidget(const UserAvatar(name: 'Bruno da Silva Rocco')));
      expect(find.text('BR'), findsOneWidget);
    });

    testWidgets('deve exibir vazio para nome nulo', (tester) async {
      await tester.pumpWidget(buildTestableWidget(const UserAvatar(name: null)));
      expect(find.text(''), findsOneWidget);
    });

    testWidgets('deve exibir vazio para nome em branco', (tester) async {
      await tester.pumpWidget(buildTestableWidget(const UserAvatar(name: '   ')));
      expect(find.text(''), findsOneWidget);
    });
  });
}