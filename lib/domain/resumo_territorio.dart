import 'models/indicador.dart';

/// Valores-resumo de um território, usados nos KPIs da Home.
class ResumoTerritorio {
  final double? consumoAgua; // L/hab/dia, último dia
  final double? taxaColeta; // %, último dia
  final double? chuvaMax3d; // mm, maior previsão nos próximos 3 dias

  const ResumoTerritorio({this.consumoAgua, this.taxaColeta, this.chuvaMax3d});

  factory ResumoTerritorio.de(
      List<Indicador> todos, String territorioId, DateTime agora) {
    final meus = todos.where((i) => i.territorioId == territorioId).toList()
      ..sort((a, b) => a.timestamp.compareTo(b.timestamp));
    final hoje = DateTime(agora.year, agora.month, agora.day);

    double? ultimo(String metrica) {
      final s = meus
          .where((i) => i.metrica == metrica && !i.timestamp.isAfter(agora))
          .toList();
      return s.isEmpty ? null : s.last.valor;
    }

    final proximas = meus
        .where((i) =>
            i.metrica == 'chuva_mm' &&
            !i.timestamp.isBefore(hoje) &&
            i.timestamp.isBefore(hoje.add(const Duration(days: 3))))
        .map((i) => i.valor)
        .toList();

    return ResumoTerritorio(
      consumoAgua: ultimo('consumo_l_hab_dia'),
      taxaColeta: ultimo('taxa_coleta_pct'),
      chuvaMax3d:
          proximas.isEmpty ? null : proximas.reduce((a, b) => a > b ? a : b),
    );
  }
}