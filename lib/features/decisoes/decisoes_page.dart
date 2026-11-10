import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/providers.dart';
import '../../core/rotulos.dart';
import '../../domain/models/enums.dart';

class DecisoesPage extends ConsumerWidget {
  const DecisoesPage({super.key});

  IconData _icone(AcaoDecisao a) => switch (a) {
        AcaoDecisao.aceitar => Icons.check_circle_outline,
        AcaoDecisao.descartar => Icons.cancel_outlined,
        AcaoDecisao.pedirDados => Icons.help_outline,
      };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final decisoes = ref.watch(decisoesProvider);
    final estilo = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Histórico de decisões')),
      body: decisoes.isEmpty
          ? const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Text(
                  'Nenhuma decisão registrada ainda.\n'
                  'Abra um alerta e use "Registrar decisão".',
                  textAlign: TextAlign.center,
                ),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: decisoes.length,
              itemBuilder: (_, i) {
                final d = decisoes[i];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(_icone(d.acao), size: 20),
                            const SizedBox(width: 8),
                            Text(rotuloAcao(d.acao),
                                style: estilo.labelLarge),
                            const Spacer(),
                            Text(formatarData(d.criadoEm),
                                style: estilo.bodySmall),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          d.alertaTitulo.isEmpty ? d.alertaId : d.alertaTitulo,
                          style: estilo.titleMedium
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 4),
                        Text(d.justificativa),
                        const SizedBox(height: 8),
                        Text(
                          'Responsável: ${d.responsavel} · Prazo: ${formatarData(d.prazo)}',
                          style: estilo.bodySmall,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}