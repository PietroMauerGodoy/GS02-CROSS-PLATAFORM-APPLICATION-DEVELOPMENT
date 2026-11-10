import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'providers.dart';

class ConfigApp {
  final ThemeMode tema;
  final double escalaFonte;
  final bool altoContraste;

  const ConfigApp({
    this.tema = ThemeMode.system,
    this.escalaFonte = 1.0,
    this.altoContraste = false,
  });

  ConfigApp copyWith({
    ThemeMode? tema,
    double? escalaFonte,
    bool? altoContraste,
  }) =>
      ConfigApp(
        tema: tema ?? this.tema,
        escalaFonte: escalaFonte ?? this.escalaFonte,
        altoContraste: altoContraste ?? this.altoContraste,
      );
}

class ConfigNotifier extends Notifier<ConfigApp> {
  @override
  ConfigApp build() {
    final s = ref.read(localStoreProvider);
    return ConfigApp(
      tema: ThemeMode.values.where((t) => t.name == s.lerTema()).firstOrNull ??
          ThemeMode.system,
      escalaFonte: s.lerEscalaFonte() ?? 1.0,
      altoContraste: s.lerAltoContraste() ?? false,
    );
  }

  void definirTema(ThemeMode t) {
    state = state.copyWith(tema: t);
    ref.read(localStoreProvider).salvarTema(t.name);
  }

  void definirEscalaFonte(double v) {
    state = state.copyWith(escalaFonte: v);
    ref.read(localStoreProvider).salvarEscalaFonte(v);
  }

  void definirAltoContraste(bool v) {
    state = state.copyWith(altoContraste: v);
    ref.read(localStoreProvider).salvarAltoContraste(v);
  }
}

final configProvider =
    NotifierProvider<ConfigNotifier, ConfigApp>(ConfigNotifier.new);