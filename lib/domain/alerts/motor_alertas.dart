import 'dart:math';

import '../models/alerta.dart';
import '../models/enums.dart';
import '../models/indicador.dart';
import '../models/territorio.dart';

/// Motor de alertas por regras estatísticas simples e explicáveis.
/// Gera sugestões para o gestor; nunca executa ações.
class MotorAlertas {
  final DateTime Function() _agora;

  MotorAlertas({DateTime Function()? agora}) : _agora = agora ?? DateTime.now;

  List<Alerta> avaliar(
      List<Territorio> territorios, List<Indicador> indicadores) {
    final out = <Alerta>[];
    for (final t in territorios) {
      final ind = indicadores.where((i) => i.territorioId == t.id).toList()
        ..sort((a, b) => a.timestamp.compareTo(b.timestamp));
      out
        ..addAll(_chuva(t, ind))
        ..addAll(_consumoAgua(t, ind))
        ..addAll(_coleta(t, ind));
    }
    out.sort((a, b) {
      final c = b.severidade.index.compareTo(a.severidade.index);
      return c != 0 ? c : b.confianca.compareTo(a.confianca);
    });
    return out;
  }

  // ---------- Regra 1: chuva forte prevista ----------
  List<Alerta> _chuva(Territorio t, List<Indicador> ind) {
    final hoje = DateTime(_agora().year, _agora().month, _agora().day);
    final prev = _serie(ind, 'chuva_mm')
        .where((i) => !i.timestamp.isBefore(hoje))
        .toList();
    if (prev.isEmpty) return [];

    final pico = prev.reduce((a, b) => a.valor >= b.valor ? a : b);
    final sev = pico.valor >= 50
        ? Severidade.alta
        : pico.valor >= 35
            ? Severidade.media
            : pico.valor >= 20
                ? Severidade.baixa
                : null;
    if (sev == null) return [];

    final diasAFrente = pico.timestamp.difference(hoje).inDays;
    final conf = (0.75 - 0.1 * diasAFrente + min((pico.valor - 20) / 100, 0.1))
        .clamp(0.3, 0.85)
        .toDouble();

    return [
      Alerta(
        id: '${t.id}-chuva-${_iso(pico.timestamp)}',
        territorioId: t.id,
        tema: Tema.clima,
        severidade: sev,
        titulo: 'Risco de alagamento em ${t.nome}',
        justificativa:
            'A previsão aponta ${pico.valor.toStringAsFixed(1)} mm de chuva em '
            '${_fmt(pico.timestamp)}, acima do limiar de atenção de 20 mm/dia.',
        confianca: conf,
        limitacoes:
            'Baseado em previsão numérica (Open-Meteo), com incerteza que cresce '
            'com o prazo. Não considera drenagem local, relevo nem histórico de '
            'alagamentos do ponto. Limiares (20/35/50 mm) são de referência deste '
            'projeto, não valores oficiais da Defesa Civil.',
        criadoEm: _agora(),
      ),
    ];
  }

  // ---------- Regra 2: consumo de água fora do padrão ----------
  List<Alerta> _consumoAgua(Territorio t, List<Indicador> ind) {
    final s = _serie(ind, 'consumo_l_hab_dia');
    if (s.length < 10) return [];

    // baseline = tudo, menos os 3 últimos dias (para a anomalia não contaminar)
    final base = s.sublist(0, s.length - 3).map((e) => e.valor).toList();
    final media = base.reduce((a, b) => a + b) / base.length;
    final variancia =
        base.map((x) => pow(x - media, 2)).reduce((a, b) => a + b) /
            base.length;
    final desvio = sqrt(variancia);
    if (desvio == 0) return [];

    final ultimo = s.last;
    final z = (ultimo.valor - media) / desvio;
    if (z < 2) return [];

    final sev = z >= 4
        ? Severidade.alta
        : z >= 3
            ? Severidade.media
            : Severidade.baixa;
    final conf =
        (0.4 + 0.3 * min(base.length / 30, 1) + 0.03 * min(z, 6)).clamp(0.3, 0.88);

    return [
      Alerta(
        id: '${t.id}-agua-${_iso(ultimo.timestamp)}',
        territorioId: t.id,
        tema: Tema.agua,
        severidade: sev,
        titulo: 'Consumo de água anormal em ${t.nome}',
        justificativa:
            'O consumo de ${ultimo.valor.toStringAsFixed(0)} L/hab/dia em '
            '${_fmt(ultimo.timestamp)} está ${z.toStringAsFixed(1)} desvios padrão '
            'acima da média dos dias anteriores (${media.toStringAsFixed(0)} L/hab/dia).',
        confianca: conf.toDouble(),
        limitacoes:
            'Dados sintéticos de demonstração. A regra detecta desvio estatístico, '
            'não a causa: pode ser vazamento, evento pontual ou mudança sazonal. '
            'Verificar em campo antes de qualquer ação.',
        criadoEm: _agora(),
      ),
    ];
  }

  // ---------- Regra 3: coleta de resíduos abaixo do esperado ----------
  List<Alerta> _coleta(Territorio t, List<Indicador> ind) {
    final s = _serie(ind, 'taxa_coleta_pct');
    if (s.length < 5) return [];

    var dias = 0;
    for (var i = s.length - 1; i >= 0 && s[i].valor < 85; i--) {
      dias++;
    }
    if (dias < 2) return [];

    final recentes = s.sublist(s.length - dias).map((e) => e.valor);
    final media = recentes.reduce((a, b) => a + b) / dias;
    final sev = media < 75
        ? Severidade.alta
        : media < 80
            ? Severidade.media
            : Severidade.baixa;
    final conf = (0.5 + 0.1 * dias).clamp(0.5, 0.85).toDouble();

    return [
      Alerta(
        id: '${t.id}-residuos-${_iso(s.last.timestamp)}',
        territorioId: t.id,
        tema: Tema.residuos,
        severidade: sev,
        titulo: 'Coleta de resíduos abaixo do esperado em ${t.nome}',
        justificativa:
            'A taxa de coleta está abaixo de 85% há $dias dias seguidos '
            '(média de ${media.toStringAsFixed(1)}%), com risco de acúmulo de resíduos.',
        confianca: conf,
        limitacoes:
            'Dados sintéticos de demonstração. Não distingue a causa (falha de '
            'frota, feriado, greve, acesso bloqueado). Média de poucos dias, '
            'sensível a oscilações curtas.',
        criadoEm: _agora(),
      ),
    ];
  }

  List<Indicador> _serie(List<Indicador> ind, String metrica) =>
      ind.where((i) => i.metrica == metrica).toList();

  String _iso(DateTime d) => d.toIso8601String().substring(0, 10);

  String _fmt(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}';
}