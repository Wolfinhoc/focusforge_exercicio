import 'dart:async';
import 'package:flutter/material.dart';
import 'package:focusforge/models/cycle.dart';
import 'package:focusforge/repositories/cycle_repository.dart';
import 'package:focusforge/repositories/shared_preferences_cycle_repository.dart';
import 'package:focusforge/services/prefs_service.dart';
import 'package:uuid/uuid.dart';
import '../widgets/app_drawer.dart';
import 'package:flutter_ringtone_player/flutter_ringtone_player.dart';

class HomePage extends StatefulWidget {
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final CycleRepository _cycleRepository = SharedPreferencesCycleRepository();
  final Uuid _uuid = Uuid();
  List<Cycle> _cycles = [];
  Timer? _timer;
  int _remainingSeconds = 25 * 60;
  bool _isTimerRunning = false;
  String _meta = '';

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  @override
  void dispose() {
    _timer?.cancel(); // Cancela o timer para evitar memory leaks
    super.dispose();
  }

  Future<void> _initializeData() async {
    // Passo 2: Inicia a sincronização em segundo plano.
    // A ausência de 'await' aqui é intencional (padrão "fire-and-forget").
    // Isso permite que o código continue executando enquanto a sincronização acontece.
    _runBackgroundSync();

    // Passo 1: Carrega os dados locais imediatamente para renderizar a UI.
    // O usuário vê o conteúdo instantaneamente, sem esperar pela rede.
    _loadCyclesFromRepository();
  }

  Future<void> _runBackgroundSync() async {
    try {
      // Simula uma chamada de API para buscar dados novos desde a última sincronização.
      // Em um app real, a chamada seria algo como: api.getCycles(since: PrefsService.lastSync)
      await Future.delayed(const Duration(seconds: 2)); // Simula latência de rede
      
      // Para este exemplo, simulamos que o backend retornou uma lista vazia.
      final remoteCycles = <Cycle>[]; 

      // Executa a lógica de sincronização incremental no repositório.
      await _cycleRepository.syncIncremental(remoteCycles);

      // Passo 3: Atualiza a UI após a sincronização.
      if (mounted) _loadCyclesFromRepository();
    } catch (e) {
      // Em um app real, aqui você usaria um serviço de logging (ex: Sentry, Firebase Crashlytics)
      debugPrint("Falha na sincronização em segundo plano: $e");
    }
  }

  Future<void> _addCycle(String goal) async {
    final newCycle = Cycle(
        id: _uuid.v4(),
        goal: goal,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now());
    setState(() => _cycles = [..._cycles, newCycle]); // UI Otimista
    await _cycleRepository.add(newCycle);
  }

  Future<void> _startTimer() async {
    if (_isTimerRunning) return;

    if (_meta.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Por favor, defina uma meta.')));
      return;
    }
    // Adiciona o novo ciclo
    await _addCycle(_meta);

    setState(() {
      _isTimerRunning = true;
      _remainingSeconds = 25 * 60;
    });

    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      if (_remainingSeconds > 0) {
        setState(() => _remainingSeconds--);
      } else {
        _timer?.cancel();
        setState(() => _isTimerRunning = false);
        FlutterRingtonePlayer().playNotification();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text('Ciclo concluído: $_meta! Hora de uma pausa.')));
        }
      }
    });
  }

  String get _timerText {
    final minutes = (_remainingSeconds / 60).floor().toString().padLeft(2, '0');
    final seconds = (_remainingSeconds % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  Future<void> _loadCyclesFromRepository() async {
    final localCycles = await _cycleRepository.getAll();
    // Garante que o widget ainda está na árvore antes de chamar setState.
    if (mounted) {
      setState(() {
        _cycles = localCycles;
      });
    }
  }

  Future<void> _deleteCycle(String cycleId) async {
    // UI Otimista: remove da lista local primeiro
    final updatedCycles = _cycles.where((c) => c.id != cycleId).toList();
    setState(() => _cycles = updatedCycles);

    // Persiste a mudança em segundo plano
    await _cycleRepository.delete(cycleId);
    if (mounted)
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Ciclo removido.')));
  }

  Future<void> _updateCycle(Cycle cycle, String newGoal) async {
    final updatedCycle = Cycle(
      id: cycle.id,
      goal: newGoal,
      createdAt: cycle.createdAt,
      updatedAt: DateTime.now(), // Atualiza o timestamp
      status: cycle.status,
    );

    // UI Otimista: atualiza a lista local
    final index = _cycles.indexWhere((c) => c.id == cycle.id);
    setState(() {
      if (index != -1) {
        _cycles = List.from(_cycles)..[index] = updatedCycle;
      }
    });

    // Persiste em segundo plano
    await _cycleRepository.update(updatedCycle);
  }

  void _showEditDialog(Cycle cycle) {
    final textController = TextEditingController(text: cycle.goal);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Editar Meta'),
        content: TextField(
            controller: textController,
            autofocus: true,
            decoration: const InputDecoration(labelText: 'Nova meta')),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar')),
          ElevatedButton(onPressed: () {
            if (textController.text.trim().isNotEmpty) {
              _updateCycle(cycle, textController.text);
              Navigator.pop(context);
            }
          }, child: const Text('Salvar')),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: AppDrawer(),
      appBar: AppBar(
        title: const Text('FocusForge'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column( // O Column foi mantido para a estrutura geral
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: _cycles.length,
                itemBuilder: (context, index) {
                  final cycle = _cycles[index];
                  return Dismissible(
                    key: Key(cycle.id),
                    background: Container(
                      color: Colors.red.withOpacity(0.8),
                      alignment: Alignment.centerLeft,
                      padding: const EdgeInsets.only(left: 20.0),
                      child: const Icon(Icons.delete, color: Colors.white),
                    ),
                    direction: DismissDirection.startToEnd,
                    onDismissed: (_) => _deleteCycle(cycle.id),
                    child: ListTile(
                      title: Text(cycle.goal),
                      subtitle: Text(
                          'Criado em: ${cycle.createdAt.day}/${cycle.createdAt.month}'),
                      onTap: () => _showEditDialog(cycle),
                    ),
                  );
                },
              ),
            ), 
            // Seção do timer e controle movida para um Card
            Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    if (!_isTimerRunning)
                      TextField(
                        decoration: const InputDecoration(
                            labelText: 'Meta curta para o próximo ciclo'),
                        onChanged: (v) => setState(() => _meta = v),
                      ),
                    const SizedBox(height: 12),
                    Text(_timerText,
                        style: const TextStyle(
                            fontSize: 72, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          minimumSize: const Size(double.infinity, 48)),
                      onPressed: _meta.trim().isEmpty || _isTimerRunning
                          ? null
                          : _startTimer,
                      child: const Text('Iniciar ciclo 25/5'),
                    ),
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
