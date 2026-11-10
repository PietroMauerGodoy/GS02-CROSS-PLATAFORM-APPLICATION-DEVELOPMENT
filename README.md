# Painel de Inteligência Territorial

Global Solution FIAP 2026 · tema **CitizenTech** · disciplina **Cross-Platform Application Development**

Aplicativo Flutter de apoio à decisão para **gestores públicos**. Ele cruza dados de clima, água e resíduos de territórios de São Paulo, antecipa problemas com **alertas explicáveis** (justificativa, nível de confiança e limitações) e registra as decisões de uma pessoa. O app **nunca executa ações automaticamente**.

## Integrantes

| Nome | RM |
|---|---|
| Patrick Mansour | 562970 |
| Pietro Mauer | 564345 |
| Samir Assad | 561562 |

## O que o app faz

- **Visão geral** por território (Itaquera, Capão Redondo, Santana e Parelheiros, que é rural), com indicadores e alertas ativos.
- **Dashboards** por tema (Clima, Água e Resíduos): gráficos de linha e barras, filtro de período (7, 14 ou 30 dias), linhas de referência e valores ao tocar.
- **Alertas preditivos** com severidade (baixa, média, alta), justificativa, nível de confiança e limitações. Filtros por tema e severidade.
- **Decisão do gestor**: formulário validado (ação, justificativa, responsável e prazo) que marca o alerta como decidido.
- **Histórico de decisões**, persistido no aparelho.
- **Configurações**: tema claro/escuro, tamanho do texto, alto contraste e botão para apagar os dados locais.
- **Fontes e limitações** dentro do próprio app.

## Fontes de dados

| Tema | Fonte | Tipo |
|---|---|---|
| Clima (chuva e temperatura) | [Open-Meteo](https://open-meteo.com/) (API pública, sem chave) | **Real**: 14 dias de histórico e 3 de previsão |
| Água (consumo e perdas na rede) | Gerador interno | **Sintético** (demonstração) |
| Resíduos (coleta e taxa de coleta) | Gerador interno | **Sintético** (demonstração) |

Não existe API pública de água e resíduos por bairro, então esses dados são gerados no app de forma determinística, com anomalias propositais (pico de consumo em Capão Redondo e queda de coleta em Parelheiros) para demonstrar os alertas. O app avisa na tela quando o dado é sintético. Se a API de clima falhar, o app usa o último clima salvo no aparelho.

## Como os alertas funcionam

Regras estatísticas simples e explicáveis (sem modelo opaco):

| Regra | Dispara quando | Severidade |
|---|---|---|
| Chuva | previsão de 20 mm/dia ou mais em até 3 dias | 20 baixa, 35 média, 50 alta |
| Água | consumo do último dia com 2 ou mais desvios padrão acima da média dos dias anteriores | 2σ baixa, 3σ média, 4σ alta |
| Coleta | taxa abaixo de 85% por 2 dias seguidos ou mais | 85 baixa, 80 média, 75 alta |

A **confiança** depende da distância até o limiar, do tamanho do histórico e do prazo da previsão.

## Limitações

- Os limiares são valores de referência do projeto, **não** valores oficiais de Defesa Civil ou de órgãos de saneamento.
- A previsão de chuva tem incerteza que cresce com o prazo e não considera drenagem, relevo nem histórico de alagamentos.
- Os alertas detectam desvios estatísticos, não a causa. É preciso verificar em campo antes de agir.
- Água e resíduos são dados sintéticos.
- O identificador do alerta inclui a data do último dado. No dia seguinte, o mesmo problema pode reaparecer como um alerta novo.
- Os dados ficam apenas no aparelho (sem servidor).

## ODS relacionados

- **ODS 11**: Cidades e comunidades sustentáveis (gestão de resíduos e serviços urbanos).
- **ODS 13**: Ação contra a mudança global do clima (alertas de chuvas extremas).
- **ODS 9**: Indústria, inovação e infraestrutura (dados para decisões sobre infraestrutura).

## Acessibilidade e privacidade

- Severidade sempre com **ícone e texto**, nunca só com cor.
- Gráficos e indicadores com descrição para leitores de tela (`Semantics`).
- Tema claro/escuro, tamanho de texto ajustável e modo de alto contraste.
- Apenas **dados agregados por território**. Nenhum dado pessoal de cidadão é coletado.
- O histórico de decisões fica só no aparelho e pode ser apagado nas configurações. O formulário orienta a não incluir dados pessoais.

## Tecnologias

Flutter (Dart) · Riverpod (estado) · go_router (rotas) · dio (HTTP) · fl_chart (gráficos) · shared_preferences (persistência local)

## Estrutura

```
lib/
  core/        tema, rotas, providers, componentes reutilizáveis
  data/        API de clima, gerador sintético, repositório, armazenamento local
  domain/      modelos e motor de alertas
  features/    home, alertas, dashboard, decisoes, configuracoes, sobre
test/          testes do motor de alertas
```

## Requisitos da disciplina

| Requisito | Onde |
|---|---|
| Navegação entre telas | `go_router`, barra inferior e rotas aninhadas (`core/router`) |
| Gerenciamento de estado | Riverpod (`core/providers.dart`) |
| Consumo de API REST | Open-Meteo via `dio` (`data/api/clima_api.dart`) |
| Persistência de dados | `shared_preferences` (`data/local/local_store.dart`) |
| Formulários com validação | Formulário de decisão (`features/decisoes`) |
| Componentes reutilizáveis e identidade visual | `core/widgets` e `core/theme` |
| Acessibilidade e privacidade | Ver seção acima |

## Como rodar

```bash
flutter pub get
flutter run            # escolha o dispositivo (Android, Edge, etc.)
flutter test           # testes do motor de alertas
```