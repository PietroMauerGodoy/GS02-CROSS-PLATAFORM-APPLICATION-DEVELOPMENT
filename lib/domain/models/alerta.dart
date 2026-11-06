import 'enums.dart';

class Alerta {
  final String id;
  final String territorioId;
  final Tema tema;
  final Severidade severidade;
  final String titulo;
  final String justificativa;
  final double confianca; // 0.0 a 1.0
  final String limitacoes;
  final DateTime criadoEm;
  final StatusAlerta status;

  const Alerta({
    required this.id,
    required this.territorioId,
    required this.tema,
    required this.severidade,
    required this.titulo,
    required this.justificativa,
    required this.confianca,
    required this.limitacoes,
    required this.criadoEm,
    this.status = StatusAlerta.ativo,
  });

  int get confiancaPct => (confianca * 100).round();

  Alerta copyWith({StatusAlerta? status}) => Alerta(
        id: id,
        territorioId: territorioId,
        tema: tema,
        severidade: severidade,
        titulo: titulo,
        justificativa: justificativa,
        confianca: confianca,
        limitacoes: limitacoes,
        criadoEm: criadoEm,
        status: status ?? this.status,
      );

  Map<String, dynamic> toMap() => {
        'id': id,
        'territorioId': territorioId,
        'tema': tema.name,
        'severidade': severidade.name,
        'titulo': titulo,
        'justificativa': justificativa,
        'confianca': confianca,
        'limitacoes': limitacoes,
        'criadoEm': criadoEm.toIso8601String(),
        'status': status.name,
      };

  factory Alerta.fromMap(Map<String, dynamic> m) => Alerta(
        id: m['id'] as String,
        territorioId: m['territorioId'] as String,
        tema: Tema.values.byName(m['tema'] as String),
        severidade: Severidade.values.byName(m['severidade'] as String),
        titulo: m['titulo'] as String,
        justificativa: m['justificativa'] as String,
        confianca: (m['confianca'] as num).toDouble(),
        limitacoes: m['limitacoes'] as String,
        criadoEm: DateTime.parse(m['criadoEm'] as String),
        status: StatusAlerta.values.byName(m['status'] as String),
      );
}