import 'package:flutter/material.dart';

import '../../domain/models/enums.dart';
import '../theme/app_colors.dart';

/// Selo de severidade: cor + ícone + texto (nunca só cor).
class SeveridadeBadge extends StatelessWidget {
  final Severidade severidade;

  const SeveridadeBadge(this.severidade, {super.key});

  @override
  Widget build(BuildContext context) {
    final (cor, icone, rotulo) = switch (severidade) {
      Severidade.baixa => (
          AppColors.severidadeBaixa,
          Icons.info_outline,
          'Baixa'
        ),
      Severidade.media => (
          AppColors.severidadeMedia,
          Icons.warning_amber,
          'Média'
        ),
      Severidade.alta => (
          AppColors.severidadeAlta,
          Icons.error_outline,
          'Alta'
        ),
    };

    return Semantics(
      label: 'Severidade $rotulo',
      child: ExcludeSemantics(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: cor.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: cor),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icone, size: 16, color: cor),
              const SizedBox(width: 4),
              Text(
                rotulo,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}