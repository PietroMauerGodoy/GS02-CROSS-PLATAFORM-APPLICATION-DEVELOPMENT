import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../data/api/clima_api.dart';
import '../data/local/local_store.dart';
import '../data/repositories/indicadores_repository.dart';
import '../data/seed/territorios_seed.dart';
import '../data/synthetic/gerador_sintetico.dart';
import '../domain/alerts/motor_alertas.dart';
import '../domain/models/alerta.dart';
import '../domain/models/decisao.dart';
import '../domain/models/enums.dart';

/// Sobrescrito no main.dart com a instância real.
final sharedPrefsProvider =
    Provider<SharedPreferences>((ref) => throw UnimplementedError());

final localStoreProvider =
    Provider((ref) => LocalStore(ref.watch(sharedPrefsProvider)));

final indicadoresRepoProvider = Provider((ref) => IndicadoresRepository(
      ClimaApi(),
      ref.watch(localStoreProvider),
      GeradorSintetico(),
    ));

final dadosProvider = FutureProvider<DadosCarregados>(
    (ref) => ref.watch(indicadoresRepoProvider).carregar());

/// Território selecionado (persistido).
class TerritorioSelecionado extends Notifier<String> {
  @override
  String build() =>
      ref.read(localStoreProvider).lerTerritorio() ?? territoriosSeed.first.id;

  void selecionar(String id) {
    state = id;
    ref.read(localStoreProvider).salvarTerritorio(id);
  }
}

final territorioSelecionadoProvider =
    NotifierProvider<TerritorioSelecionado, String>(TerritorioSelecionado.new);

/// Histórico de decisões do gestor (persistido).
class DecisoesNotifier extends Notifier<List<Decisao>> {
  @override
  List<Decisao> build() => ref.read(localStoreProvider).lerDecisoes();

  Future<void> registrar(Decisao d) async {
    state = [d, ...state];
    await ref.read(localStoreProvider).salvarDecisoes(state);
  }
}

final decisoesProvider =
    NotifierProvider<DecisoesNotifier, List<Decisao>>(DecisoesNotifier.new);

/// Alertas calculados; os que já têm decisão ficam como "decidido".
final alertasProvider = Provider<AsyncValue<List<Alerta>>>((ref) {
  final dados = ref.watch(dadosProvider);
  final decididos = ref.watch(decisoesProvider).map((d) => d.alertaId).toSet();

  return dados.whenData((d) {
    final alertas = MotorAlertas().avaliar(territoriosSeed, d.indicadores);
    return [
      for (final a in alertas)
        decididos.contains(a.id)
            ? a.copyWith(status: StatusAlerta.decidido)
            : a,
    ];
  });
});