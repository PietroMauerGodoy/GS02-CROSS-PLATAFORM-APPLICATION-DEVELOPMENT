import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/providers.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/alerta_card.dart';
import '../../core/widgets/kpi_card.dart';
import '../../data/seed/territorios_seed.dart';
import '../../domain/models/enums.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  String _n(double? v, {int casas = 0}) =>
      v == null ? '—' : v.toStringAsFixed(casas);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selecionado = ref.watch(territorioSelecionadoProvider);
    final dados = ref.watch(dadosProvider);
    final todosAlertas = ref.watch(alertasProvider).valueOrNull ?? [];
    final resumo = ref.watch(resumoProvider).valueOrNull;

    final doTerritorio = todosAlertas
        .where((a) =>
            a.territorioId == selecionado && a.status == StatusAlerta.ativo)
        .toList();
    final outros = todosAlertas
        .where((a) =>
            a.territorioId != selecionado && a.status == StatusAlerta.ativo)
        .length;

    final larguraCard =
        min((MediaQuery.sizeOf(context).width - 32 - 12) / 2, 260.0);

    return Scaffold(
      appBar: AppBar(title: const Text('Visão Geral')),
      body: dados.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Erro ao carregar dados: $e')),
        data: (d) => ListView(
          padding: const EdgeInsets.all(16),
          children: [
            if (d.climaDoCache) const _AvisoOffline(),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final t in territoriosSeed)
                  ChoiceChip(
                    avatar: Icon(
                      t.tipo == TipoTerritorio.rural
                          ? Icons.agriculture
                          : Icons.location_city,
                      size: 18,
                    ),
                    label: Text(t.nome),
                    selected: t.id == selecionado,
                    onSelected: (_) => ref
                        .read(territorioSelecionadoProvider.notifier)
                        .selecionar(t.id),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                SizedBox(
                  width: larguraCard,
                  child: KpiCard(
                    titulo: 'Consumo de água',
                    valor: '${_n(resumo?.consumoAgua)} L/hab/dia',
                    detalhe: 'último dia',
                    icone: Icons.water_drop,
                    cor: AppColors.agua,
                  ),
                ),
                SizedBox(
                  width: larguraCard,
                  child: KpiCard(
                    titulo: 'Coleta de resíduos',
                    valor: '${_n(resumo?.taxaColeta, casas: 1)}%',
                    detalhe: 'taxa de coleta',
                    icone: Icons.recycling,
                    cor: AppColors.residuos,
                  ),
                ),
                SizedBox(
                  width: larguraCard,
                  child: KpiCard(
                    titulo: 'Chuva prevista',
                    valor: '${_n(resumo?.chuvaMax3d, casas: 1)} mm',
                    detalhe: 'máx. nos próximos 3 dias',
                    icone: Icons.cloud,
                    cor: AppColors.clima,
                  ),
                ),
                SizedBox(
                  width: larguraCard,
                  child: KpiCard(
                    titulo: 'Alertas ativos',
                    valor: '${doTerritorio.length}',
                    detalhe: 'neste território',
                    icone: Icons.notifications_active,
                    cor: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Clima: Open-Meteo (dados reais). Água e resíduos: dados '
              'sintéticos de demonstração.',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 24),
            Text('Alertas ativos',
                style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            if (doTerritorio.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 16),
                child: Text('Nenhum alerta ativo neste território.'),
              )
            else
              for (final a in doTerritorio)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: AlertaCard(
                    alerta: a,
                    onTap: () => context.go('/alertas/${a.id}'),
                  ),
                ),
            if (outros > 0)
              Text(
                '$outros alerta(s) ativo(s) em outros territórios.',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
          ],
        ),
      ),
    );
  }
}

class _AvisoOffline extends StatelessWidget {
  const _AvisoOffline();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.only(bottom: 12),
      child: Card(
        child: ListTile(
          leading: Icon(Icons.wifi_off),
          title: Text('Sem conexão'),
          subtitle: Text('Usando o último clima salvo no aparelho.'),
        ),
      ),
    );
  }
}