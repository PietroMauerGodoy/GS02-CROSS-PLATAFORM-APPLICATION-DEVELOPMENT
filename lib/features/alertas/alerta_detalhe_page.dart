import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/providers.dart';
import '../../core/rotulos.dart';
import '../../core/widgets/severidade_badge.dart';
import '../../data/seed/territorios_seed.dart';
import '../../domain/models/enums.dart';

class AlertaDetalhePage extends ConsumerWidget {
  final String id;

  const AlertaDetalhePage({super.key, required this.id});

  String _data(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';

  String _rotuloConfianca(double c) =>
      c >= 0.75 ? 'Alta' : (c >= 0.55 ? 'Moderada' : 'Baixa');

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final alertas = ref.watch(alertasProvider);
    final estilo = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Detalhe do alerta')),
      body: alertas.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Erro ao carregar dados: $e')),
        data: (lista) {
          final a = lista.where((x) => x.id == id).firstOrNull;
          if (a == null) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Text(
                  'Alerta não encontrado. Ele pode ter deixado de valer com '
                  'os dados mais recentes.',
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }
          final territorio =
              territoriosSeed.firstWhere((t) => t.id == a.territorioId).nome;

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Row(
                children: [
                  SeveridadeBadge(a.severidade),
                  const SizedBox(width: 8),
                  if (a.status == StatusAlerta.decidido)
                    const Chip(label: Text('Decidido')),
                ],
              ),
              const SizedBox(height: 12),
              Text(a.titulo, style: estilo.headlineSmall),
              const SizedBox(height: 4),
              Text(
                '$territorio · ${rotuloTema(a.tema)} · gerado em ${_data(a.criadoEm)}',
                style: estilo.bodyMedium,
              ),
              const SizedBox(height: 24),
              _Secao(titulo: 'Por que este alerta?', child: Text(a.justificativa)),
              _Secao(
                titulo: 'Nível de confiança',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('${_rotuloConfianca(a.confianca)} · ${a.confiancaPct}%'),
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: LinearProgressIndicator(
                        value: a.confianca,
                        minHeight: 10,
                        semanticsLabel: 'Confiança de ${a.confiancaPct}%',
                      ),
                    ),
                  ],
                ),
              ),
              _Secao(titulo: 'Limitações', child: Text(a.limitacoes)),
              const Card(
                child: ListTile(
                  leading: Icon(Icons.info_outline),
                  title: Text('Apoio à decisão'),
                  subtitle: Text(
                    'Este alerta é uma sugestão. Nenhuma ação é executada '
                    'automaticamente: a decisão é sempre do gestor.',
                  ),
                ),
              ),
              const SizedBox(height: 16),
              if (a.status == StatusAlerta.ativo)
                FilledButton.icon(
                  onPressed: () => context.go('/alertas/${a.id}/decisao'),
                  icon: const Icon(Icons.fact_check),
                  label: const Text('Registrar decisão'),
                )
              else
                const Text('Este alerta já tem uma decisão registrada.'),
            ],
          );
        },
      ),
    );
  }
}

class _Secao extends StatelessWidget {
  final String titulo;
  final Widget child;

  const _Secao({required this.titulo, required this.child});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            titulo,
            style: Theme.of(context)
                .textTheme
                .titleMedium
                ?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 6),
          child,
        ],
      ),
    );
  }
}