import 'dart:convert';

import 'package:CalculatriceImpact/models/row_grille_model.dart';
import 'package:flutter/services.dart';

Future<String> _loadAGrilleAsset() async {
  return await rootBundle.loadString('data/grille.json');
}

Future <List<RowGrille>> loadGrille() async {
  String jsonString = await _loadAGrilleAsset();
  final jsonResponse = json.decode(jsonString);
  RowGrilleList liste = RowGrilleList.fromJson(jsonResponse);
  //print("premier element : " + liste.rows[0].value);
  return liste.rows;
}

/*Future<double> getFraisSite(double prix) async {
  String jsonString = await _loadAGrilleAsset();
  final jsonResponse = json.decode(jsonString);
  RowGrilleList liste = RowGrilleList.fromJson(jsonResponse);
  return liste.rows.where((i) => (i.from <= prix && i.to >= prix)).first.value;
}*/
