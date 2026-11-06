import 'enums.dart';

class Territorio {
  final String id;
  final String nome;
  final TipoTerritorio tipo;
  final double lat;
  final double lon;
  final int populacaoEstimada;

  const Territorio({
    required this.id,
    required this.nome,
    required this.tipo,
    required this.lat,
    required this.lon,
    required this.populacaoEstimada,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'nome': nome,
        'tipo': tipo.name,
        'lat': lat,
        'lon': lon,
        'populacaoEstimada': populacaoEstimada,
      };

  factory Territorio.fromMap(Map<String, dynamic> m) => Territorio(
        id: m['id'] as String,
        nome: m['nome'] as String,
        tipo: TipoTerritorio.values.byName(m['tipo'] as String),
        lat: (m['lat'] as num).toDouble(),
        lon: (m['lon'] as num).toDouble(),
        populacaoEstimada: m['populacaoEstimada'] as int,
      );
}