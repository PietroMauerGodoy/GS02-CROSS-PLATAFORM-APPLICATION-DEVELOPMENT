import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../domain/models/decisao.dart';
import '../../domain/models/indicador.dart';

/// Persistência local (shared_preferences, em JSON).
class LocalStore {
  final SharedPreferences _p;
  LocalStore(this._p);

  static const _kDecisoes = 'decisoes';
  static const _kClima = 'clima_cache';
  static const _kTerritorio = 'territorio_id';
  static const _kTema = 'cfg_tema';
  static const _kFonte = 'cfg_fonte';
  static const _kContraste = 'cfg_contraste';

  // Decisões do gestor
  List<Decisao> lerDecisoes() =>
      _lerLista(_kDecisoes).map(Decisao.fromMap).toList();

  Future<void> salvarDecisoes(List<Decisao> l) =>
      _p.setString(_kDecisoes, jsonEncode(l.map((d) => d.toMap()).toList()));

  // Cache do clima (para funcionar sem conexão)
  List<Indicador> lerClima() =>
      _lerLista(_kClima).map(Indicador.fromMap).toList();

  Future<void> salvarClima(List<Indicador> l) =>
      _p.setString(_kClima, jsonEncode(l.map((i) => i.toMap()).toList()));

  // Território selecionado
  String? lerTerritorio() => _p.getString(_kTerritorio);

  Future<void> salvarTerritorio(String id) => _p.setString(_kTerritorio, id);

  // Configurações de acessibilidade e aparência
  String? lerTema() => _p.getString(_kTema);
  Future<void> salvarTema(String v) => _p.setString(_kTema, v);

  double? lerEscalaFonte() => _p.getDouble(_kFonte);
  Future<void> salvarEscalaFonte(double v) => _p.setDouble(_kFonte, v);

  bool? lerAltoContraste() => _p.getBool(_kContraste);
  Future<void> salvarAltoContraste(bool v) => _p.setBool(_kContraste, v);

  /// Apaga decisões, cache de clima e território. Mantém as configurações.
  Future<void> limparDados() async {
    await _p.remove(_kDecisoes);
    await _p.remove(_kClima);
    await _p.remove(_kTerritorio);
  }

  List<Map<String, dynamic>> _lerLista(String chave) {
    final raw = _p.getString(chave);
    if (raw == null) return [];
    return (jsonDecode(raw) as List).cast<Map<String, dynamic>>();
  }
}