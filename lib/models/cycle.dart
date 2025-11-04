import 'package:flutter/foundation.dart';

/// Enum para representar o estado de um ciclo de foco.
enum CycleStatus {
  active,
  paused,
  completed,
}

/// A entidade principal do domínio do aplicativo.
///
/// Representa um ciclo de foco com uma meta específica.
/// Contém validações e getters para facilitar o uso na camada de negócio e UI.
@immutable
class Cycle {
  final String id;
  final String goal;
  final DateTime createdAt;
  final DateTime updatedAt;
  final CycleStatus status;

  Cycle({
    required this.id,
    required this.goal,
    required this.createdAt,
    required this.updatedAt,
    this.status = CycleStatus.active,
  }) {
    // Validação de contrato: uma meta não pode ser vazia.
    if (goal.trim().isEmpty) {
      throw ArgumentError.value(goal, 'goal', 'A meta não pode ser vazia.');
    }
  }

  /// Construtor de fábrica para criar um novo ciclo com valores padrão.
  /// Centraliza a lógica de criação, como a geração de ID e timestamps.
  factory Cycle.create({required String id, required String goal}) {
    return Cycle(
      id: id,
      goal: goal,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  // Getters convenientes
  bool get isCompleted => status == CycleStatus.completed;
  bool get isActive => status == CycleStatus.active;
}