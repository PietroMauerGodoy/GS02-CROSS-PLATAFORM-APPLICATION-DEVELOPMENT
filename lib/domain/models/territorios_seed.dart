import '../../domain/models/enums.dart';
import '../../domain/models/territorio.dart';

/// Territórios monitorados. Coordenadas aproximadas (centro do distrito).
/// População: estimativa arredondada, ilustrativa. Conferir no IBGE antes do README.
const territoriosSeed = <Territorio>[
  Territorio(
    id: 'itaquera',
    nome: 'Itaquera',
    tipo: TipoTerritorio.urbano,
    lat: -23.5403,
    lon: -46.4569,
    populacaoEstimada: 200000,
  ),
  Territorio(
    id: 'capao-redondo',
    nome: 'Capão Redondo',
    tipo: TipoTerritorio.urbano,
    lat: -23.6597,
    lon: -46.7794,
    populacaoEstimada: 270000,
  ),
  Territorio(
    id: 'santana',
    nome: 'Santana',
    tipo: TipoTerritorio.urbano,
    lat: -23.4986,
    lon: -46.6264,
    populacaoEstimada: 130000,
  ),
  Territorio(
    id: 'parelheiros',
    nome: 'Parelheiros',
    tipo: TipoTerritorio.rural,
    lat: -23.8286,
    lon: -46.7289,
    populacaoEstimada: 140000,
  ),
];