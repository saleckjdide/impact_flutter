import 'dart:convert';
import 'package:CalculatriceImpact/models/ville_model.dart';
import 'package:flutter/services.dart';

Future<String> _loadAVilles() async {
  return await rootBundle.loadString('data/villes.json');
}

Future<List<Ville>> loadVilles() async {
  String jsonString = await _loadAVilles();
  final jsonResponse = json.decode(jsonString);
  VillesList liste = VillesList.fromJson(jsonResponse);
  return liste.villes;
}

Future<double> getFraisMTRL(String name) async {
  String jsonString = await _loadAVilles();
  final jsonResponse = json.decode(jsonString);
  VillesList liste = VillesList.fromJson(jsonResponse);
  return liste.villes.where((i) => i.name == name).first.fraisMTRL;
}
/*
Future<double> getTPS(String name) async {
  String jsonString = await _loadAVilles();
  final jsonResponse = json.decode(jsonString);
  VillesList liste = VillesList.fromJson(jsonResponse);
  return liste.villes.where((i) => i.name == name).first.tps;
}

Future<double> getTVQ(String name) async {
  String jsonString = await _loadAVilles();
  final jsonResponse = json.decode(jsonString);
  VillesList liste = VillesList.fromJson(jsonResponse);
  return liste.villes.where((i) => i.name == name).first.tvq;
}

Future<String> getProvince(String name) async {
  String jsonString = await _loadAVilles();
  final jsonResponse = json.decode(jsonString);
  VillesList liste = VillesList.fromJson(jsonResponse);
  return liste.villes.where((i) => i.name == name).first.province;
}*/
