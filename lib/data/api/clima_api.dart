import 'package:dio/dio.dart';

import '../../domain/models/enums.dart';
import '../../domain/models/indicador.dart';
import '../../domain/models/territorio.dart';

/// Clima real via Open-Meteo (gratuita, sem chave).
/// Traz 14 dias de histórico + 3 dias de previsão por território.
class ClimaApi {
  final Dio _dio;

  ClimaApi([Dio? dio])
      : _dio = dio ??
            Dio(BaseOptions(
              baseUrl: 'https://api.open-meteo.com/v1',
              connectTimeout: const Duration(seconds: 10),
              receiveTimeout: const Duration(seconds: 10),
            ));

  Future<List<Indicador>> buscar(Territorio t) async {
    final res = await _dio.get('/forecast', queryParameters: {
      'latitude': t.lat,
      'longitude': t.lon,
      'daily': 'precipitation_sum,temperature_2m_max',
      'past_days': 14,
      'forecast_days': 3,
      'timezone': 'America/Sao_Paulo',
    });

    final daily = res.data['daily'] as Map<String, dynamic>;
    final dias = (daily['time'] as List).cast<String>();
    final chuva = daily['precipitation_sum'] as List;
    final temp = daily['temperature_2m_max'] as List;

    final out = <Indicador>[];
    for (var i = 0; i < dias.length; i++) {
      final ts = DateTime.parse(dias[i]);
      if (chuva[i] != null) {
        out.add(Indicador(
          id: '${t.id}-chuva_mm-${dias[i]}',
          territorioId: t.id,
          tema: Tema.clima,
          metrica: 'chuva_mm',
          valor: (chuva[i] as num).toDouble(),
          unidade: 'mm',
          timestamp: ts,
          origem: Origem.api,
        ));
      }
      if (temp[i] != null) {
        out.add(Indicador(
          id: '${t.id}-temp_max_c-${dias[i]}',
          territorioId: t.id,
          tema: Tema.clima,
          metrica: 'temp_max_c',
          valor: (temp[i] as num).toDouble(),
          unidade: '°C',
          timestamp: ts,
          origem: Origem.api,
        ));
      }
    }
    return out;
  }
}