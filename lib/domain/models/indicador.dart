import 'enums.dart';

class Indicador {
  final String id;
  final String territorioId;
  final Tema tema;
  final String metrica; // ex: 'chuva_mm', 'consumo_l_hab_dia', 'coleta_ton'
  final double valor;
  final String unidade;
  final DateTime timestamp;
  final Origem origem;

  const Indicador({
    required this.id,
    required this.territorioId,
    required this.tema,
    required this.metrica,
    required this.valor,
    required this.unidade,
    required this.timestamp,
    required this.origem,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'territorioId': territorioId,
        'tema': tema.name,
        'metrica': metrica,
        'valor': valor,
        'unidade': unidade,
        'timestamp': timestamp.toIso8601String(),
        'origem': origem.name,
      };

  factory Indicador.fromMap(Map<String, dynamic> m) => Indicador(
        id: m['id'] as String,
        territorioId: m['territorioId'] as String,
        tema: Tema.values.byName(m['tema'] as String),
        metrica: m['metrica'] as String,
        valor: (m['valor'] as num).toDouble(),
        unidade: m['unidade'] as String,
        timestamp: DateTime.parse(m['timestamp'] as String),
        origem: Origem.values.byName(m['origem'] as String),
      );
}