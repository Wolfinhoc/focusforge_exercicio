import 'dart:convert';
import '../models/cycle.dart';
import '../models/cycle_dto.dart';
import '../models/cycle_mapper.dart';
import '../services/prefs_service.dart';
import 'cycle_repository.dart';

/// Implementação do [CycleRepository] que usa [SharedPreferences] para persistência local.
///
/// Os ciclos são armazenados como uma lista de JSONs em uma única chave.
class SharedPreferencesCycleRepository implements CycleRepository {
  static const String _cyclesKey = 'focus_cycles_v1';

  /// Cache em memória para evitar leituras repetidas do disco.
  List<Cycle>? _cyclesCache;

  /// Trava para evitar múltiplas leituras concorrentes do disco.
  bool _isLoading = false;

  @override
  Future<void> add(Cycle cycle) async {
    // Garante que o cache esteja carregado
    await getAll();
    _cyclesCache!.add(cycle);
    await _saveCache();
  }
  @override
  Future<void> delete(String cycleId) async {
    await getAll();
    _cyclesCache!.removeWhere((c) => c.id == cycleId);
    await _saveCache();
  }

  @override
  Future<List<Cycle>> getAll() async {
    // Se o cache ainda não foi carregado, carrega do SharedPreferences.
    // A trava _isLoading previne chamadas concorrentes a _loadCache.
    if (_cyclesCache == null && !_isLoading) {
      _isLoading = true;
      await _loadCache();
      _isLoading = false;
    } else if (_isLoading) {
      // Se já estiver carregando, aguarda um pouco para retornar o cache populado.
      await Future.delayed(const Duration(milliseconds: 100));
    }
    // Retorna uma cópia da lista para evitar modificações externas no cache.
    return List.from(_cyclesCache!);
  }

  @override
  Future<List<Cycle>> getCyclesToSync(DateTime lastSync) async {
    await getAll();
    return _cyclesCache!.where((c) => c.updatedAt.isAfter(lastSync)).toList();
  }

  @override
  Future<void> update(Cycle cycle) async {
    await getAll();
    final index = _cyclesCache!.indexWhere((c) => c.id == cycle.id);
    if (index != -1) {
      _cyclesCache![index] = cycle;
      await _saveCache();
    }
  }

  @override
  Future<void> syncIncremental(List<Cycle> remoteCycles) async {
    if (remoteCycles.isEmpty) return;

    await getAll(); // Garante que o cache local está carregado.

    for (final remoteCycle in remoteCycles) {
      final localIndex = _cyclesCache!.indexWhere((c) => c.id == remoteCycle.id);

      if (localIndex != -1) {
        // O ciclo já existe localmente, verifica se o remoto é mais novo.
        final localCycle = _cyclesCache![localIndex];
        if (remoteCycle.updatedAt.isAfter(localCycle.updatedAt)) {
          _cyclesCache![localIndex] = remoteCycle; // Atualiza
        }
      } else {
        // O ciclo não existe localmente, adiciona.
        _cyclesCache!.add(remoteCycle);
      }
    }

    await _saveCache();
    PrefsService.lastSync = DateTime.now(); // Atualiza a data da última sincronização
  }

  /// Carrega a lista de ciclos do SharedPreferences e a popula no cache.
  Future<void> _loadCache() async {
    final jsonString = PrefsService.getString(_cyclesKey);
    if (jsonString != null) {
      try {
        final List<dynamic> jsonList = jsonDecode(jsonString);
        // Desserializa a lista de mapas para uma lista de Entities
        _cyclesCache = jsonList
            .map((json) => CycleMapper.toEntity(CycleDTO.fromMap(json)))
            .toList();
      } catch (e) {
        // Em caso de JSON inválido, começa com uma lista vazia.
        _cyclesCache = [];
      }
    } else {
      // Se não houver nada salvo, inicializa o cache com uma lista vazia.
      _cyclesCache = [];
    }
  }

  /// Salva o conteúdo atual do cache no SharedPreferences.
  Future<void> _saveCache() async {
    if (_cyclesCache == null) return;
    // Serializa a lista de Entities para uma lista de mapas
    final jsonList = _cyclesCache!.map((c) => CycleMapper.toMap(c)).toList();
    await PrefsService.setString(_cyclesKey, jsonEncode(jsonList));
  }
}