import 'package:flutter/material.dart';

class KpiCard extends StatelessWidget {
  final String titulo;
  final String valor;
  final String? detalhe;
  final IconData icone;
  final Color cor;

  const KpiCard({
    super.key,
    required this.titulo,
    required this.valor,
    this.detalhe,
    required this.icone,
    required this.cor,
  });

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context).textTheme;
    return Semantics(
      container: true,
      label: '$titulo: $valor${detalhe != null ? ', $detalhe' : ''}',
      child: ExcludeSemantics(
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(icone, color: cor, size: 20),
                    const SizedBox(width: 8),
                    Expanded(child: Text(titulo, style: tema.labelLarge)),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  valor,
                  style: tema.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
                if (detalhe != null) Text(detalhe!, style: tema.bodySmall),
              ],
            ),
          ),
        ),
      ),
    );
  }
}