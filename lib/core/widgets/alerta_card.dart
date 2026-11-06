import 'package:flutter/material.dart';

import '../../domain/models/alerta.dart';
import 'severidade_badge.dart';

class AlertaCard extends StatelessWidget {
  final Alerta alerta;
  final String? territorio;
  final VoidCallback? onTap;

  const AlertaCard({
    super.key,
    required this.alerta,
    this.territorio,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context).textTheme;
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  SeveridadeBadge(alerta.severidade),
                  const Spacer(),
                  Text('Confiança ${alerta.confiancaPct}%',
                      style: tema.labelLarge),
                ],
              ),
              const SizedBox(height: 8),
              if (territorio != null)
                Text(territorio!, style: tema.labelMedium),
              Text(
                alerta.titulo,
                style: tema.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Text(
                alerta.justificativa,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}