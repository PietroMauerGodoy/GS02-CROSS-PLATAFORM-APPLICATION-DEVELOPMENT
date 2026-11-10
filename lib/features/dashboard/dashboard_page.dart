import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/providers.dart';
import '../../core/rotulos.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/alerta_card.dart';
import '../../core/widgets/serie_chart.dart';
import '../../data/seed/territorios_seed.dart';
import '../../domain/models/enums.dart';
import '../../domain/models/indicador.dart';

class _Spec {
  final String metrica;
  final String titulo;
  final String unidade;
  final TipoGrafico tipo;
  final Color cor;
  final double? ref;
  final String? refRotulo;
  final bool refMedia;

  const _Spec({
    required this.metrica,
    required this.titulo,
    required this.unidade,
    required this.tipo,
    required this.cor,
    this.ref,
    this.refRotulo,
    this.refMedia = false,
  });
}

List<_Spec> _specsDe(Tema t) => switch (t) {
      Tema.clima => const [
          _Spec(
            metrica: 'chuva_mm',
            titulo: 'Chuva diária',
            unidade: 'mm',
            tipo: TipoGrafico.barras,
            cor: AppColors.clima,
            ref: 20,
            refRotulo: 'Atenção (20 mm)',
          ),
          _Spec(
            metrica: 'temp_max_c',
            titulo: 'Temperatura máxima',
            unidade: '°C',
            tipo: TipoGrafico.linha,
            cor: Colors.deepOrange,
          ),
        ],
      Tema.agua => const [
          _Spec(
            metrica: 'consumo_l_hab_dia',
            titulo: 'Consumo de água',
            unidade: 'L/hab/dia',
            tipo: TipoGrafico.linha,
            cor: AppColors.agua,
            refMedia: true,
            refRotulo: 'Média do período',
          ),
          _Spec(
            metrica: 'perdas_pct',
            titulo: 'Perdas na rede',
            unidade: '%',
            tipo: TipoGrafico.linha,
            cor: AppColors.agua,
          ),
        ],
      Tema.residuos => const [
          _Spec(
            metrica: 'taxa_coleta_pct',
            titulo: 'Taxa de coleta',
            unidade: '%',
            tipo: TipoGrafico.linha,
            cor: AppColors.residuos,
            ref: 85,
            refRotulo: 'Mínimo esperado (85%)',
          ),
          _Spec(
            metrica: 'coleta_ton',
            titulo: 'Resíduos coletados',
            unidade: 't',
            tipo: TipoGrafico.barras,
            cor: AppColors.residuos,
          ),
        ],
    };

class DashboardPage extends ConsumerStatefulWidget {
  final Tema tema;

  const DashboardPage({super.key, required this.tema});

  @override
  ConsumerState<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends ConsumerState<DashboardPage> {
  int _dias = 14;

  String _fmt(double v) => v.toStringAsFixed(v.abs() >= 100 ? 0 : 1);

  List<Indicador> _serie(
      List<Indicador> todos, String territorioId, String metrica) {
    final hoje = DateTime.now();
    final inicio = DateTime(hoje.year, hoje.month, hoje.day)
        .subtract(Duration(days: _dias - 1));
    return todos
        .where((i) =>
            i.territorioId == territorioId &&
            i.metrica == metrica &&
            !i.timestamp.isBefore(inicio))
        .toList()
      ..sort((a, b) => a.timestamp.compareTo(b.timestamp));
  }

  @override
  Widget build(BuildContext context) {
    final selecionado = ref.watch(territorioSelecionadoProvider);
    final dados = ref.watch(dadosProvider);
    final alertas = ref.watch(alertasProvider).valueOrNull ?? [];
    final estilo = Theme.of(context).textTheme;
    final nomeTerritorio =
        territoriosSeed.firstWhere((t) => t.id == selecionado).nome;

    final alertasDoTema = alertas
        .where((a) =>
            a.territorioId == selecionado &&
            a.tema == widget.tema &&
            a.status == StatusAlerta.ativo)
        .toList();

    return Scaffold(
      appBar: AppBar(title: Text('Dashboard: ${rotuloTema(widget.tema)}')),
      body: dados.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Erro ao carregar dados: $e')),
        data: (d) => ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final t in territoriosSeed)
                  ChoiceChip(
                    label: Text(t.nome),
                    selected: t.id == selecionado,
                    onSelected: (_) => ref
                        .read(territorioSelecionadoProvider.notifier)
                        .selecionar(t.id),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            SegmentedButton<int>(
              segments: const [
                ButtonSegment(value: 7, label: Text('7 dias')),
                ButtonSegment(value: 14, label: Text('14 dias')),
                ButtonSegment(value: 30, label: Text('30 dias')),
              ],
              selected: {_dias},
              onSelectionChanged: (s) => setState(() => _dias = s.first),
            ),
            const SizedBox(height: 16),
            for (final spec in _specsDe(widget.tema))
              _bloco(context, spec, nomeTerritorio,
                  _serie(d.indicadores, selecionado, spec.metrica)),
            const SizedBox(height: 8),
            Text('Alertas deste tema', style: estilo.titleLarge),
            const SizedBox(height: 8),
            if (alertasDoTema.isEmpty)
              const Text('Nenhum alerta ativo deste tema neste território.')
            else
              for (final a in alertasDoTema)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: AlertaCard(
                    alerta: a,
                    onTap: () => context.go('/alertas/${a.id}'),
                  ),
                ),
          ],
        ),
      ),
    );
  }

  Widget _bloco(BuildContext context, _Spec spec, String territorio,
      List<Indicador> serie) {
    final estilo = Theme.of(context).textTheme;

    if (serie.isEmpty) {
      return Card(
        margin: const EdgeInsets.only(bottom: 16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Text('${spec.titulo}: sem dados para o período.'),
        ),
      );
    }

    final valores = serie.map((e) => e.valor).toList();
    final minV = valores.reduce((a, b) => a < b ? a : b);
    final maxV = valores.reduce((a, b) => a > b ? a : b);
    final media = valores.reduce((a, b) => a + b) / valores.length;
    final origem = serie.first.origem == Origem.api
        ? 'Open-Meteo (dados reais)'
        : 'dados sintéticos de demonstração';
    final resumo =
        'Mín ${_fmt(minV)} · Média ${_fmt(media)} · Máx ${_fmt(maxV)} ${spec.unidade}';

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(spec.titulo,
                style: estilo.titleMedium
                    ?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(resumo, style: estilo.bodyMedium),
            const SizedBox(height: 16),
            SerieChart(
              serie: serie,
              tipo: spec.tipo,
              cor: spec.cor,
              unidade: spec.unidade,
              referencia: spec.refMedia ? media : spec.ref,
              rotuloReferencia: spec.refRotulo,
              descricao:
                  '${spec.titulo} em $territorio nos últimos $_dias dias. $resumo.',
            ),
            const SizedBox(height: 8),
            if (spec.tipo == TipoGrafico.barras && widget.tema == Tema.clima)
              Text('Barras mais claras = previsão.', style: estilo.bodySmall),
            Text('Fonte: $origem', style: estilo.bodySmall),
          ],
        ),
      ),
    );
  }
}