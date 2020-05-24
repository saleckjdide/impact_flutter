
class RowGrille{
  int id;
  double from;
  double to;
  double value;
  RowGrille({this.id,this.from,this.to,this.value});
  factory RowGrille.fromJson(Map<String,dynamic> grilleJson){
    return new RowGrille(
      id: grilleJson['id'] as int,
      from: grilleJson['from'] as double,
      to: grilleJson['to'] as double,
      value: grilleJson['value'] as double
    );
  }

}
class RowGrilleList{
  final List<RowGrille> rows;
  RowGrilleList({
    this.rows,
  });
factory RowGrilleList.fromJson(List<dynamic> parsedJson) {

    List<RowGrille> grille = new List<RowGrille>();
    grille= parsedJson.map((i)=>RowGrille.fromJson(i)).toList();
    return new RowGrilleList(
       rows:grille,
    );
  }
}
