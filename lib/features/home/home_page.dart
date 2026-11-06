import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/providers.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final alertas = ref.watch(alertasProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Visão Geral')),
      body: alertas.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Erro ao carregar dados: $e')),
        data: (lista) {
          if (lista.isEmpty) {
            return const Center(child: Text('Nenhum alerta ativo'));
          }
          return ListView.builder(
            itemCount: lista.length,
            itemBuilder: (_, i) {
              final a = lista[i];
              return ListTile(
                title: Text(a.titulo),
                subtitle: Text(
                  '${a.severidade.name} · confiança ${a.confiancaPct}%\n'
                  '${a.justificativa}',
                ),
                isThreeLine: true,
              );
            },
          );
        },
      ),
    );
  }
}