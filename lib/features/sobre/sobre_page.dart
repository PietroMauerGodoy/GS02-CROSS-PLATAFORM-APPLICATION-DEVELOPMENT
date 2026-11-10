import 'package:flutter/material.dart';

class SobrePage extends StatelessWidget {
  const SobrePage({super.key});

  static const _equipe = [
    ('Patrick Mansour', '562970'),
    ('Pietro Mauer', '564345'),
    ('Samir Assad', '561562'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Fontes e limitações')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: const [
          _Secao(
            titulo: 'O que é o painel',
            linhas: [
              'Painel de Inteligência Territorial: apoia o gestor público a '
                  'antecipar problemas de clima, água e resíduos em bairros e '
                  'comunidades de São Paulo.',
              'O painel apenas sugere. Nenhuma ação é executada '
                  'automaticamente: toda decisão é registrada por uma pessoa.',
            ],
          ),
          _Secao(
            titulo: 'Fontes de dados',
            linhas: [
              'Clima: Open-Meteo (API pública, dados reais). Chuva e '
                  'temperatura dos últimos 14 dias e previsão de 3 dias.',
              'Água e resíduos: dados sintéticos de demonstração, gerados no '
                  'próprio app, pois não há API pública por bairro. Incluem '
                  'anomalias propositais para demonstrar os alertas.',
            ],
          ),
          _Secao(
            titulo: 'Como os alertas são calculados',
            linhas: [
              'Chuva: previsão a partir de 20 mm/dia (35 mm = média, 50 mm = alta).',
              'Água: consumo 2 ou mais desvios padrão acima da média dos dias '
                  'anteriores.',
              'Coleta: taxa abaixo de 85% por 2 dias seguidos ou mais.',
              'A confiança depende da distância até o limiar, do tamanho do '
                  'histórico e do prazo da previsão.',
            ],
          ),
          _Secao(
            titulo: 'Limitações',
            linhas: [
              'Os limiares são valores de referência do projeto, não valores '
                  'oficiais da Defesa Civil ou de órgãos de saneamento.',
              'A previsão de chuva tem incerteza que cresce com o prazo e não '
                  'considera drenagem, relevo nem histórico de alagamentos.',
              'Os alertas detectam desvios estatísticos, não a causa. É '
                  'preciso verificar em campo antes de agir.',
              'O identificador do alerta inclui a data do último dado: no dia '
                  'seguinte, o mesmo problema pode reaparecer como um alerta '
                  'novo.',
              'Os dados ficam apenas no aparelho (sem servidor).',
            ],
          ),
          _Secao(
            titulo: 'ODS relacionados',
            linhas: [
              'ODS 11: Cidades e comunidades sustentáveis (gestão de resíduos '
                  'e serviços urbanos).',
              'ODS 13: Ação contra a mudança global do clima (alertas de '
                  'chuvas extremas e adaptação).',
              'ODS 9: Indústria, inovação e infraestrutura (uso de dados para '
                  'decisões sobre infraestrutura).',
            ],
          ),
          _Equipe(),
        ],
      ),
    );
  }
}

class _Secao extends StatelessWidget {
  final String titulo;
  final List<String> linhas;

  const _Secao({required this.titulo, required this.linhas});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(titulo, style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          for (final l in linhas)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('• '),
                  Expanded(child: Text(l)),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _Equipe extends StatelessWidget {
  const _Equipe();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Equipe', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 8),
        const Text('FIAP · Global Solution 2026 · Cross-Platform Application Development'),
        const SizedBox(height: 8),
        for (final (nome, rm) in SobrePage._equipe)
          Text('$nome · RM $rm'),
      ],
    );
  }
}