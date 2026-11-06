import 'package:flutter_test/flutter_test.dart';
import 'package:painel_territorial/data/seed/territorios_seed.dart';
import 'package:painel_territorial/data/synthetic/gerador_sintetico.dart';
import 'package:painel_territorial/domain/alerts/motor_alertas.dart';
import 'package:painel_territorial/domain/models/enums.dart';

void main() {
  test('detecta as anomalias injetadas nos dados sintéticos', () {
    final agora = DateTime(2026, 11, 6);
    final indicadores = [
      for (final t in territoriosSeed)
        ...GeradorSintetico().gerar(t, agora: agora),
    ];

    final alertas =
        MotorAlertas(agora: () => agora).avaliar(territoriosSeed, indicadores);

    expect(
      alertas.any((a) =>
          a.territorioId == 'capao-redondo' && a.tema == Tema.agua),
      isTrue,
    );
    expect(
      alertas.any((a) =>
          a.territorioId == 'parelheiros' && a.tema == Tema.residuos),
      isTrue,
    );
  });
}