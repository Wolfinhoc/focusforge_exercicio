import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:focusforge/models/cycle.dart';
import 'package:focusforge/repositories/shared_preferences_cycle_repository.dart';
import 'package:focusforge/services/prefs_service.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Mock para a dependência SharedPreferences
class MockSharedPreferences extends Mock implements SharedPreferences {}

void main() {
  late SharedPreferencesCycleRepository repository;
  late MockSharedPreferences mockPrefs;

  // Dados de exemplo para os testes
  final now = DateTime.now();
  final cycle1 = Cycle(id: '1', goal: 'Test 1', createdAt: now, updatedAt: now);
  final cycle2 = Cycle(id: '2', goal: 'Test 2', createdAt: now, updatedAt: now);

  // Representação JSON dos dados de exemplo
  final cycle1Map = {'id': '1', 'goal': 'Test 1', 'created_at': now.toIso8601String(), 'updated_at': now.toIso8601String(), 'status': 'active'};
  final cycle2Map = {'id': '2', 'goal': 'Test 2', 'created_at': now.toIso8601String(), 'updated_at': now.toIso8601String(), 'status': 'active'};
  final cyclesJsonString = jsonEncode([cycle1Map, cycle2Map]);

  setUp(() async {
    mockPrefs = MockSharedPreferences();
    // Inicializa o PrefsService com o mock
    await PrefsService.init(mockPrefs);
    repository = SharedPreferencesCycleRepository();

    // Configura o mock para retornar uma lista de ciclos ao ler a chave
    when(() => mockPrefs.getString('focus_cycles_v1')).thenReturn(cyclesJsonString);
    // Configura o mock para chamadas de escrita
    when(() => mockPrefs.setString(any(), any())).thenAnswer((_) async => true);
  });

  group('SharedPreferencesCycleRepository Tests', () {
    
    test('getAll deve carregar e desserializar ciclos do SharedPreferences', () async {
      // Ação
      final cycles = await repository.getAll();

      // Verificação
      expect(cycles.length, 2);
      expect(cycles[0].id, '1');
      expect(cycles[1].goal, 'Test 2');
      // Verifica se a leitura do SharedPreferences foi chamada
      verify(() => mockPrefs.getString('focus_cycles_v1')).called(1);
    });

    test('getAll deve usar o cache na segunda chamada', async () {
      // Primeira chamada para popular o cache
      await repository.getAll();
      // Segunda chamada
      await repository.getAll();

      // Verificação: getString só deve ser chamado uma vez
      verify(() => mockPrefs.getString('focus_cycles_v1')).called(1);
    });

    test('add deve adicionar um novo ciclo e salvar no SharedPreferences', () async {
      final newCycle = Cycle(id: '3', goal: 'New Cycle', createdAt: now, updatedAt: now);
      final expectedMapList = [cycle1Map, cycle2Map, {'id': '3', 'goal': 'New Cycle', 'created_at': now.toIso8601String(), 'updated_at': now.toIso8601String(), 'status': 'active'}];
      final expectedJson = jsonEncode(expectedMapList);

      // Ação
      await repository.add(newCycle);

      // Verificação
      final cycles = await repository.getAll();
      expect(cycles.length, 3);
      expect(cycles.last.id, '3');
      // Verifica se setString foi chamado com o JSON correto
      verify(() => mockPrefs.setString('focus_cycles_v1', expectedJson)).called(1);
    });

    test('update deve modificar um ciclo existente e salvar', () async {
      final updatedCycle = Cycle(id: '1', goal: 'Updated Goal', createdAt: cycle1.createdAt, updatedAt: now.add(Duration(minutes: 1)));
      
      // Ação
      await repository.update(updatedCycle);

      // Verificação
      final cycles = await repository.getAll();
      expect(cycles.first.goal, 'Updated Goal');
      expect(cycles.first.updatedAt, updatedCycle.updatedAt);
      verify(() => mockPrefs.setString(any(), any())).called(1);
    });

    test('delete deve remover um ciclo e salvar', () async {
      final expectedMapList = [cycle2Map];
      final expectedJson = jsonEncode(expectedMapList);

      // Ação
      await repository.delete('1');

      // Verificação
      final cycles = await repository.getAll();
      expect(cycles.length, 1);
      expect(cycles.first.id, '2');
      verify(() => mockPrefs.setString('focus_cycles_v1', expectedJson)).called(1);
    });

    group('syncIncremental', () {
      test('deve adicionar novos ciclos remotos', () async {
        final remoteCycle = Cycle(id: '4', goal: 'Remote', createdAt: now, updatedAt: now);
        when(() => mockPrefs.getString('focus_cycles_v1')).thenReturn(cyclesJsonString);
        when(() => mockPrefs.setString(any(), any())).thenAnswer((_) async => true);

        await repository.syncIncremental([remoteCycle]);

        final cycles = await repository.getAll();
        expect(cycles.length, 3);
        expect(cycles.last.id, '4');
      });

      test('deve atualizar ciclos locais se o remoto for mais novo', () async {
        final remoteUpdate = Cycle(id: '1', goal: 'Remote Update', createdAt: now, updatedAt: now.add(Duration(days: 1)));
        when(() => mockPrefs.getString('focus_cycles_v1')).thenReturn(cyclesJsonString);
        when(() => mockPrefs.setString(any(), any())).thenAnswer((_) async => true);

        await repository.syncIncremental([remoteUpdate]);

        final cycles = await repository.getAll();
        expect(cycles.first.goal, 'Remote Update');
      });

      test('deve ignorar ciclos remotos se o local for mais novo', () async {
        final remoteOld = Cycle(id: '1', goal: 'Old Remote', createdAt: now, updatedAt: now.subtract(Duration(days: 1)));
        when(() => mockPrefs.getString('focus_cycles_v1')).thenReturn(cyclesJsonString);
        when(() => mockPrefs.setString(any(), any())).thenAnswer((_) async => true);

        await repository.syncIncremental([remoteOld]);

        final cycles = await repository.getAll();
        expect(cycles.first.goal, 'Test 1'); // Não deve ter atualizado
      });

      test('deve atualizar o lastSync timestamp após a sincronização', () async {
        final remoteCycle = Cycle(id: '4', goal: 'Remote', createdAt: now, updatedAt: now);
        when(() => mockPrefs.getString('focus_cycles_v1')).thenReturn(cyclesJsonString);
        when(() => mockPrefs.setString(any(), any())).thenAnswer((_) async => true);

        await repository.syncIncremental([remoteCycle]);

        // Verifica se a data de sincronização foi salva
        verify(() => mockPrefs.setString(PrefsService.keyLastSync, any())).called(1);
      });
    });
  });
}

```

### 2. Testes de Widget para `HomePage`

Para testar a `HomePage`, precisamos primeiro refatorá-la para aceitar o `CycleRepository` via construtor (Injeção de Dependência). Isso nos permite fornecer um *mock* do repositório durante os testes.

#### 2.1. Refatoração da `HomePage`

```diff
--- a/c/Users/Wolfinho/Documents/GitHub/focusforge_exercicio/lib/pages/home_page.dart
+++ b/c/Users/Wolfinho/Documents/GitHub/focusforge_exercicio/lib/pages/home_page.dart