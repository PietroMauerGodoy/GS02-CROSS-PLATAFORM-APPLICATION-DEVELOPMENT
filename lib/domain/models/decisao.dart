import 'enums.dart';

class Decisao {
  final String id;
  final String alertaId;
  final AcaoDecisao acao;
  final String justificativa;
  final String responsavel;
  final DateTime prazo;
  final DateTime criadoEm;

  const Decisao({
    required this.id,
    required this.alertaId,
    required this.acao,
    required this.justificativa,
    required this.responsavel,
    required this.prazo,
    required this.criadoEm,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'alertaId': alertaId,
        'acao': acao.name,
        'justificativa': justificativa,
        'responsavel': responsavel,
        'prazo': prazo.toIso8601String(),
        'criadoEm': criadoEm.toIso8601String(),
      };

  factory Decisao.fromMap(Map<String, dynamic> m) => Decisao(
        id: m['id'] as String,
        alertaId: m['alertaId'] as String,
        acao: AcaoDecisao.values.byName(m['acao'] as String),
        justificativa: m['justificativa'] as String,
        responsavel: m['responsavel'] as String,
        prazo: DateTime.parse(m['prazo'] as String),
        criadoEm: DateTime.parse(m['criadoEm'] as String),
      );
}