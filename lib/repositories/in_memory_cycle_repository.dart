import 'package:uuid/uuid.dart';
import '../models/cycle.dart';
import 'cycle_repository.dart';

/// Implementação em memória do [CycleRepository] para testes e desenvolvimento.
class InMemoryCycleRepository implements CycleRepository {
  final List<Cycle> _cycles = [];
  final Uuid _uuid = Uuid();

  @override
  Future<void> add(Cycle cycle) async {
    final newCycle = Cycle(
      id: _uuid.v4(),
      goal: cycle.goal,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      status: cycle.status,
    );
    _cycles.add(newCycle);
  }

  @override
  Future<void> delete(String cycleId) async {
    _cycles.removeWhere((c) => c.id == cycleId);
  }

  @override
  Future<List<Cycle>> getAll() async {
    return List.from(_cycles);
  }

  @override
  Future<List<Cycle>> getCyclesToSync(DateTime lastSync) async {
    return _cycles.where((c) => c.updatedAt.isAfter(lastSync)).toList();
  }

  @override
  Future<void> update(Cycle cycle) async {
    final index = _cycles.indexWhere((c) => c.id == cycle.id);
    if (index != -1) {
      _cycles[index] = cycle;
    }
  }
}