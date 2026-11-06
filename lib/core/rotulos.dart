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