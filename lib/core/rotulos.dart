import '../domain/models/enums.dart';

String rotuloTema(Tema t) => switch (t) {
      Tema.clima => 'Clima',
      Tema.agua => 'Água',
      Tema.residuos => 'Resíduos',
    };

String rotuloSeveridade(Severidade s) => switch (s) {
      Severidade.baixa => 'Baixa',
      Severidade.media => 'Média',
      Severidade.alta => 'Alta',
    };

String rotuloAcao(AcaoDecisao a) => switch (a) {
      AcaoDecisao.aceitar => 'Aceitar e encaminhar',
      AcaoDecisao.descartar => 'Descartar',
      AcaoDecisao.pedirDados => 'Pedir mais dados',
    };

String formatarData(DateTime d) =>
    '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';