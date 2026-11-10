import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/config_provider.dart';
import '../../core/providers.dart';

class ConfiguracoesPage extends ConsumerWidget {
  const ConfiguracoesPage({super.key});

  Future<void> _apagar(BuildContext context, WidgetRef ref) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Apagar dados locais?'),
        content: const Text(
          'Isso remove o histórico de decisões e o clima salvo neste '
          'aparelho. Não pode ser desfeito.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Apagar'),
          ),
        ],
      ),
    );
    if (ok != true) return;

    await ref.read(localStoreProvider).limparDados();
    ref.invalidate(decisoesProvider);
    ref.invalidate(territorioSelecionadoProvider);
    ref.invalidate(dadosProvider);

    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Dados locais apagados.')),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cfg = ref.watch(configProvider);
    final notifier = ref.read(configProvider.notifier);
    final estilo = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Configurações')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text('Aparência', style: estilo.titleLarge),
          const SizedBox(height: 8),
          SegmentedButton<ThemeMode>(
            segments: const [
              ButtonSegment(
                  value: ThemeMode.system,
                  label: Text('Sistema'),
                  icon: Icon(Icons.brightness_auto)),
              ButtonSegment(
                  value: ThemeMode.light,
                  label: Text('Claro'),
                  icon: Icon(Icons.light_mode)),
              ButtonSegment(
                  value: ThemeMode.dark,
                  label: Text('Escuro'),
                  icon: Icon(Icons.dark_mode)),
            ],
            selected: {cfg.tema},
            onSelectionChanged: (s) => notifier.definirTema(s.first),
          ),
          const SizedBox(height: 24),
          Text('Acessibilidade', style: estilo.titleLarge),
          const SizedBox(height: 8),
          Text('Tamanho do texto', style: estilo.labelLarge),
          const SizedBox(height: 8),
          SegmentedButton<double>(
            segments: const [
              ButtonSegment(value: 1.0, label: Text('Normal')),
              ButtonSegment(value: 1.15, label: Text('Grande')),
              ButtonSegment(value: 1.3, label: Text('Muito grande')),
            ],
            selected: {cfg.escalaFonte},
            onSelectionChanged: (s) => notifier.definirEscalaFonte(s.first),
          ),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Alto contraste'),
            subtitle: const Text('Cores e bordas mais fortes'),
            value: cfg.altoContraste,
            onChanged: notifier.definirAltoContraste,
          ),
          const SizedBox(height: 16),
          Text('Privacidade', style: estilo.titleLarge),
          const SizedBox(height: 8),
          const Card(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                'O painel trabalha apenas com dados agregados por território '
                '(bairro ou zona). Ele não coleta nem armazena dados pessoais '
                'de cidadãos. O histórico de decisões fica somente neste '
                'aparelho. Evite incluir nomes, CPF ou endereços nas '
                'justificativas.',
              ),
            ),
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: () => _apagar(context, ref),
            icon: const Icon(Icons.delete_outline),
            label: const Text('Apagar dados locais'),
          ),
          const SizedBox(height: 24),
          Text('Sobre', style: estilo.titleLarge),
          const SizedBox(height: 8),
          Card(
            child: ListTile(
              leading: const Icon(Icons.info_outline),
              title: const Text('Fontes de dados e limitações'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => context.push('/sobre'),
            ),
          ),
        ],
      ),
    );
  }
}