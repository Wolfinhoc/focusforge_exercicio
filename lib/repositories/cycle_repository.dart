import '../models/cycle.dart';

/// A interface para a camada de dados dos ciclos de foco.
///
/// Define um contrato para operações CRUD (Create, Read, Update, Delete)
/// que pode ser implementado por diferentes fontes de dados (local, remota, etc.).
abstract class CycleRepository {
  /// Retorna todos os ciclos de foco.
  Future<List<Cycle>> getAll();

  /// Adiciona um novo ciclo.
  Future<void> add(Cycle cycle);

  /// Atualiza um ciclo existente.
  Future<void> update(Cycle cycle);

  /// Deleta um ciclo pelo seu ID.
  Future<void> delete(String cycleId);

  /// Retorna os ciclos modificados desde a última sincronização.
  Future<List<Cycle>> getCyclesToSync(DateTime lastSync);

  /// Sincroniza os dados locais com uma lista de ciclos (geralmente de uma fonte remota).
  /// Atualiza ou adiciona ciclos com base no ID e `updatedAt`.
  Future<void> syncIncremental(List<Cycle> remoteCycles);
}