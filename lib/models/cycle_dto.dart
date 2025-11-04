/// Data Transfer Object para a entidade Cycle.
///
/// Representa o formato de dados como ele seria trafegado pela rede (JSON)
/// ou salvo em um armazenamento persistente. Usa tipos simples e snake_case.
class CycleDTO {
  final String id;
  final String goal;
  final String createdAt; // ISO 8601 String
  final String updatedAt; // ISO 8601 String
  final String status;

  CycleDTO({
    required this.id,
    required this.goal,
    required this.createdAt,
    required this.updatedAt,
    required this.status,
  });

  // Construtor de fábrica para criar a partir de um Map (deserialização de JSON)
  factory CycleDTO.fromMap(Map<String, dynamic> map) {
    return CycleDTO(
      id: map['id'],
      goal: map['goal'],
      createdAt: map['created_at'],
      updatedAt: map['updated_at'],
      status: map['status'],
    );
  }
}