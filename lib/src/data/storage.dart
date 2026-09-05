import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/models.dart';

class Storage {
 Storage._();

 static const _especialidades = '@consultas:especialidades';
 static const _medicos = '@consultas:medicos';
 static const _consultas = '@consultas:consultas';

 static Future<void> salvarEspecialidades(
 List<Especialidade> especialidades,
 ) async {
 await _salvarLista(
 _especialidades,
 especialidades.map((item) => item.toJson()).toList(),
 );
 }

 static Future<List<Especialidade>> obterEspecialidades() async {
 return _obterLista(_especialidades, Especialidade.fromJson);
 }

 static Future<void> salvarMedicos(List<Medico> medicos) async {
 await _salvarLista(_medicos, medicos.map((item) => item.toJson()).toList());
 }

 static Future<List<Medico>> obterMedicos() async {
 return _obterLista(_medicos, Medico.fromJson);
 }

 static Future<void> salvarConsultas(List<Consulta> consultas) async {
 await _salvarLista(
 _consultas,
 consultas.map((item) => item.toJson()).toList(),
 );
 }

 static Future<List<Consulta>> obterConsultas() async {
 return _obterLista(_consultas, Consulta.fromJson);
 }

 static Future<void> _salvarLista(
 String chave,
 List<Map<String, dynamic>> itens,
 ) async {
 try {
 final prefs = await SharedPreferences.getInstance();
 await prefs.setString(chave, jsonEncode(itens));
 } catch (erro) {
 debugPrint('Erro ao salvar $chave: $erro');
 }
 }

 static Future<List<T>> _obterLista<T>(
 String chave,
 T Function(Map<String, dynamic> json) fromJson,
 ) async {
 try {
 final prefs = await SharedPreferences.getInstance();
 final json = prefs.getString(chave);
 if (json == null || json.isEmpty) {
 return [];
 }
 final lista = jsonDecode(json) as List<dynamic>;
 return lista
 .map((item) => fromJson(item as Map<String, dynamic>))
 .toList();
 } catch (erro) {
 debugPrint('Erro ao obter $chave: $erro');
 return [];
 }
 }
}
