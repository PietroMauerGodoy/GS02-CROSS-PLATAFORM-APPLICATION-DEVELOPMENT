import 'dart:math';

import '../../domain/models/enums.dart';
import '../../domain/models/indicador.dart';
import '../../domain/models/territorio.dart';

/// Dados SINTÉTICOS de água e resíduos (não há API pública por bairro).
/// Determinístico: o mesmo território gera sempre a mesma série.
/// Injeta duas anomalias de propósito, para o motor de alertas ter o que detectar:
///  - Capão Redondo: pico de consumo de água nos últimos 3 dias
///  - Parelheiros: queda na taxa de coleta nos últimos 4 dias
class GeradorSintetico {
  static const dias = 30;

  List<Indicador> gerar(Territorio t, {DateTime? agora}) {
    final hoje = agora ?? DateTime.now();
    final rnd = Random(_seed(t.id));
    final urbano = t.tipo == TipoTerritorio.urbano;
    final baseAgua = urbano ? 150.0 : 110.0; // L/hab/dia
    final baseColeta = t.populacaoEstimada * 0.0009; // ton/dia
    final out = <Indicador>[];

    for (var i = dias - 1; i >= 0; i--) {
      final dia = DateTime(hoje.year, hoje.month, hoje.day - i);

      var consumo = baseAgua * (1 + (rnd.nextDouble() - 0.5) * 0.10);
      if (t.id == 'capao-redondo' && i < 3) consumo *= 1.35;

      final perdas = 28 + (rnd.nextDouble() - 0.5) * 4;

      var taxa = 94 + (rnd.nextDouble() - 0.5) * 4;
      if (t.id == 'parelheiros' && i < 4) taxa -= 18;

      final coleta =
          baseColeta * (taxa / 100) * (1 + (rnd.nextDouble() - 0.5) * 0.06);

      out.addAll([
        _ind(t, Tema.agua, 'consumo_l_hab_dia', consumo, 'L/hab/dia', dia),
        _ind(t, Tema.agua, 'perdas_pct', perdas, '%', dia),
        _ind(t, Tema.residuos, 'coleta_ton', coleta, 't', dia),
        _ind(t, Tema.residuos, 'taxa_coleta_pct', taxa, '%', dia),
      ]);
    }
    return out;
  }

  Indicador _ind(Territorio t, Tema tema, String metrica, double valor,
      String unidade, DateTime dia) {
    final d = dia.toIso8601String().substring(0, 10);
    return Indicador(
      id: '${t.id}-$metrica-$d',
      territorioId: t.id,
      tema: tema,
      metrica: metrica,
      valor: double.parse(valor.toStringAsFixed(2)),
      unidade: unidade,
      timestamp: dia,
      origem: Origem.sintetico,
    );
  }

  // Hash simples e estável (String.hashCode pode variar entre plataformas).
  int _seed(String s) => s.codeUnits.fold(7, (h, c) => (h * 31 + c) & 0x7fffffff);
}