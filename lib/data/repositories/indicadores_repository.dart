import '../../domain/models/indicador.dart';
import '../api/clima_api.dart';
import '../local/local_store.dart';
import '../seed/territorios_seed.dart';
import '../synthetic/gerador_sintetico.dart';

class DadosCarregados {
  final List<Indicador> indicadores;
  final bool climaDoCache; // true = sem internet, usando o último clima salvo

  const DadosCarregados(this.indicadores, {required this.climaDoCache});
}

class IndicadoresRepository {
  final ClimaApi _api;
  final LocalStore _store;
  final GeradorSintetico _gerador;

  IndicadoresRepository(this._api, this._store, this._gerador);

  Future<DadosCarregados> carregar() async {
    final sinteticos = [
      for (final t in territoriosSeed) ..._gerador.gerar(t),
    ];

    List<Indicador> clima;
    var doCache = false;
    try {
      final listas = await Future.wait(territoriosSeed.map(_api.buscar));
      clima = listas.expand((l) => l).toList();
      await _store.salvarClima(clima);
    } catch (_) {
      clima = _store.lerClima();
      doCache = true;
    }

    return DadosCarregados([...clima, ...sinteticos], climaDoCache: doCache);
  }
}