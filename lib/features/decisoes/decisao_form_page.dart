import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/providers.dart';
import '../../core/rotulos.dart';
import '../../core/widgets/severidade_badge.dart';
import '../../domain/models/alerta.dart';
import '../../domain/models/decisao.dart';
import '../../domain/models/enums.dart';

class DecisaoFormPage extends ConsumerStatefulWidget {
  final String alertaId;

  const DecisaoFormPage({super.key, required this.alertaId});

  @override
  ConsumerState<DecisaoFormPage> createState() => _DecisaoFormPageState();
}

class _DecisaoFormPageState extends ConsumerState<DecisaoFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _justificativa = TextEditingController();
  final _responsavel = TextEditingController();
  final _prazoCtrl = TextEditingController();
  AcaoDecisao? _acao;
  DateTime? _prazo;
  bool _salvando = false;

  @override
  void dispose() {
    _justificativa.dispose();
    _responsavel.dispose();
    _prazoCtrl.dispose();
    super.dispose();
  }

  Future<void> _escolherPrazo() async {
    final hoje = DateTime.now();
    final base = DateTime(hoje.year, hoje.month, hoje.day);
    final r = await showDatePicker(
      context: context,
      initialDate: _prazo ?? base.add(const Duration(days: 7)),
      firstDate: base,
      lastDate: base.add(const Duration(days: 365)),
      helpText: 'Prazo para a ação',
    );
    if (r != null) {
      setState(() {
        _prazo = r;
        _prazoCtrl.text = formatarData(r);
      });
    }
  }

  Future<void> _salvar(Alerta alerta) async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _salvando = true);

    final agora = DateTime.now();
    await ref.read(decisoesProvider.notifier).registrar(Decisao(
          id: agora.microsecondsSinceEpoch.toString(),
          alertaId: alerta.id,
          alertaTitulo: alerta.titulo,
          acao: _acao!,
          justificativa: _justificativa.text.trim(),
          responsavel: _responsavel.text.trim(),
          prazo: _prazo!,
          criadoEm: agora,
        ));

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Decisão registrada.')),
    );
    context.go('/decisoes');
  }

  @override
  Widget build(BuildContext context) {
    final alertas = ref.watch(alertasProvider);
    final estilo = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Decisão do gestor')),
      body: alertas.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Erro ao carregar dados: $e')),
        data: (lista) {
          final alerta =
              lista.where((a) => a.id == widget.alertaId).firstOrNull;

          if (alerta == null) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Text('Alerta não encontrado.',
                    textAlign: TextAlign.center),
              ),
            );
          }
          if (alerta.status == StatusAlerta.decidido) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Text('Este alerta já tem uma decisão registrada.',
                    textAlign: TextAlign.center),
              ),
            );
          }

          return Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SeveridadeBadge(alerta.severidade),
                        const SizedBox(height: 8),
                        Text(alerta.titulo, style: estilo.titleMedium),
                        const SizedBox(height: 4),
                        Text('Confiança ${alerta.confiancaPct}%',
                            style: estilo.bodyMedium),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<AcaoDecisao>(
                  value: _acao,
                  decoration: const InputDecoration(labelText: 'Ação'),
                  items: [
                    for (final a in AcaoDecisao.values)
                      DropdownMenuItem(value: a, child: Text(rotuloAcao(a))),
                  ],
                  onChanged: (v) => setState(() => _acao = v),
                  validator: (v) => v == null ? 'Escolha uma ação' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _justificativa,
                  decoration: const InputDecoration(
                    labelText: 'Justificativa',
                    helperText:
                        'Não inclua dados pessoais de cidadãos (nome, CPF, endereço).',
                    helperMaxLines: 2,
                    alignLabelWithHint: true,
                  ),
                  minLines: 3,
                  maxLines: 5,
                  maxLength: 500,
                  textCapitalization: TextCapitalization.sentences,
                  validator: (v) => (v == null || v.trim().length < 20)
                      ? 'Explique a decisão em pelo menos 20 caracteres'
                      : null,
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _responsavel,
                  decoration: const InputDecoration(
                    labelText: 'Responsável',
                    helperText: 'Quem vai conduzir a ação',
                  ),
                  textCapitalization: TextCapitalization.words,
                  validator: (v) => (v == null || v.trim().length < 3)
                      ? 'Informe o nome do responsável'
                      : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _prazoCtrl,
                  readOnly: true,
                  onTap: _escolherPrazo,
                  decoration: const InputDecoration(
                    labelText: 'Prazo',
                    suffixIcon: Icon(Icons.calendar_today),
                  ),
                  validator: (_) => _prazo == null ? 'Escolha um prazo' : null,
                ),
                const SizedBox(height: 24),
                FilledButton.icon(
                  onPressed: _salvando ? null : () => _salvar(alerta),
                  icon: const Icon(Icons.check),
                  label: const Text('Registrar decisão'),
                ),
                const SizedBox(height: 8),
                OutlinedButton(
                  onPressed: () => context.go('/alertas/${alerta.id}'),
                  child: const Text('Cancelar'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}