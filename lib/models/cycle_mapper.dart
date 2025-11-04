import 'cycle.dart';
import 'cycle_dto.dart';

/// Classe responsável por mapear a conversão entre a Entity [Cycle] e o DTO [CycleDTO].
class CycleMapper {
  /// Converte um [CycleDTO] (vindo do backend/storage) para uma [Cycle] (entidade de domínio).
  static Cycle toEntity(CycleDTO dto) {
    return Cycle(
      id: dto.id,
      goal: dto.goal,
      createdAt: DateTime.parse(dto.createdAt),
      updatedAt: DateTime.parse(dto.updatedAt),
      status: _statusFromString(dto.status),
    );
  }

  /// Converte uma [Cycle] (entidade de domínio) para um [CycleDTO] (para enviar ao backend/storage).
  static Map<String, dynamic> toMap(Cycle entity) {
    return {
      'id': entity.id,
      'goal': entity.goal,
      'created_at': entity.createdAt.toIso8601String(),
      'updated_at': entity.updatedAt.toIso8601String(),
      'status': _statusToString(entity.status),
    };
  }

  static CycleStatus _statusFromString(String status) {
    return CycleStatus.values.firstWhere(
      (e) => e.toString().split('.').last == status,
      orElse: () => CycleStatus.active, // Fallback seguro
    );
  }

  static String _statusToString(CycleStatus status) {
    return status.toString().split('.').last;
  }
}