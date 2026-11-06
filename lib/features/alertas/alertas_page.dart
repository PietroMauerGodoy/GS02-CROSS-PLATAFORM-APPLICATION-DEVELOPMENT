import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/providers.dart';
import '../../core/rotulos.dart';
import '../../core/widgets/alerta_card.dart';
import '../../data/seed/territorios_seed.dart';
import '../../domain/models/enums.dart';

class AlertasPage extends ConsumerStatefulWidget {
  const AlertasPage({super.key});

  @override
  ConsumerState<AlertasPage> createState() => _AlertasPageState();
}

class _AlertasPageState extends ConsumerState<AlertasPage> {
  Tema? _tema;
  Severidade? _severidade;
  bool _mostrarDecididos = false;

  String _nomeTerritorio(String id) =>
      territoriosSeed.firstWhere((t) => t.id == id).nome;

  @override
  Widget build(BuildContext context) {
    final alertas = ref.watch(alertasProvider);
    final estilo = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Alertas')),
      body: alertas.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Erro ao carregar dados: $e')),
        data: (lista) {
          final filtrados = lista
              .where((a) =>
                  (_tema == null || a.tema == _tema) &&
                  (_severidade == null || a.severidade == _severidade) &&
                  (_mostrarDecididos || a.status == StatusAlerta.ativo))
              .toList();

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text('Tema', style: estilo.labelLarge),
              const SizedBox(height: 4),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  ChoiceChip(
                    label: const Text('Todos'),
                    selected: _tema == null,
                    onSelected: (_) => setState(() => _tema = null),
                  ),
                  for (final t in Tema.values)
                    ChoiceChip(
                      label: Text(rotuloTema(t)),
                      selected: _tema == t,
                      onSelected: (_) => setState(() => _tema = t),
                    ),
                ],
              ),
              const SizedBox(height: 12),
              Text('Severidade', style: estilo.labelLarge),
              const SizedBox(height: 4),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  ChoiceChip(
                    label: const Text('Todas'),
                    selected: _severidade == null,
                    onSelected: (_) => setState(() => _severidade = null),
                  ),
                  for (final s in Severidade.values)
                    ChoiceChip(
                      label: Text(rotuloSeveridade(s)),
                      selected: _severidade == s,
                      onSelected: (_) => setState(() => _severidade = s),
                    ),
                ],
              ),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Mostrar alertas já decididos'),
                value: _mostrarDecididos,
                onChanged: (v) => setState(() => _mostrarDecididos = v),
              ),
              const SizedBox(height: 8),
              Text('${filtrados.length} alerta(s)', style: estilo.titleMedium),
              const SizedBox(height: 8),
              if (filtrados.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 24),
                  child: Text('Nenhum alerta com esses filtros.'),
                )
              else
                for (final a in filtrados)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: AlertaCard(
                      alerta: a,
                      territorio: _nomeTerritorio(a.territorioId),
                      onTap: () => context.go('/alertas/${a.id}'),
                    ),
                  ),
            ],
          );
        },
      ),
    );
  }
}