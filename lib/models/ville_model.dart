
import 'dart:convert';

class Ville{
  int id;
  String name;
  double fraisMTRL;
  String province;
  double tps;
  double tvq;

 
  Ville({this.id,this.name,this.fraisMTRL,this.province,this.tps,this.tvq});
  factory Ville.fromJson(Map<String,dynamic> villeJson){
    return new Ville(
      id: villeJson['id'] as int,
      name: villeJson['name'],
      fraisMTRL: villeJson['fraisMTRL'] as double, 
      province: villeJson['province'],
      tps: villeJson['TPS'] as double,
      tvq: villeJson['TVQ'] as double,
    );
  }

}
List<Ville> allVillesFromJson(String str) {
  final jsonData = json.decode(str);
  return new List<Ville>.from(jsonData.map((x) => Ville.fromJson(x)));
}
class VillesList{
  final List<Ville> villes;
  VillesList({
    this.villes,
  });
  
factory VillesList.fromJson(List<dynamic> parsedJson) {

    List<Ville> listeVilles = new List<Ville>();
    listeVilles= parsedJson.map((i)=>Ville.fromJson(i)).toList();
    return new VillesList(
       villes:listeVilles,
    );
  }
}

