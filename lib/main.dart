import 'package:CalculatriceImpact/models/row_grille_model.dart';
import 'package:CalculatriceImpact/services/grille_service.dart';
import 'package:CalculatriceImpact/services/villes_services.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:package_info/package_info.dart';
import 'models/ville_model.dart';

List<Ville> _villes;
List<RowGrille> _rowsGrille;
String _version = 'Version 1.8.6';
const double _TPS_QC = 1.14975;
const double _TVQ_QC = 1.05;
const double _TPS_ON = 1.13;
const double _TVQ_ON = 0.13;
const double _FRAIS_TRANSPORT_NKCTT = 1300.0;
const double _FRAIS_DOUANES = 2600.0;
const double _FRAIS_NON_DEALER_QC = 50.0;
const double _FRAIS_NON_DEALER_ON = 75.0;
const double _TAUX = 300.0;
const String _QC = 'QC';
const String _ON = 'ON';
double _montant_min_mro =0;
const double _MONTANT_MIN = 30000;

void main() {
  runApp(MyHomePage());
  PackageInfo.fromPlatform().then((PackageInfo packageInfo) {
    if (kReleaseMode) {
      _version = 'Version ' + packageInfo.version;
    }
  });
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String _currentSelectedValue = 'Québec';
  double _fraisMTL = 200.0;
  var _fraisImpact;
  bool _fraisMTLChecked = false;
  bool _fraisNkctChecked = false;
  bool _fraisDouanesChecked = false;
  bool _validate = true;

  TextStyle _styleLblResult =
      TextStyle(fontSize: 16, fontWeight: FontWeight.bold);
  TextStyle _styleLblCkb = TextStyle(fontSize: 16);

  Text _lblCkbFraisMTRL =
      Text("Transport à Montréal (200 \$)", style: TextStyle(fontSize: 16));
  Text _lblCkbFraisNkct =
      Text("Frais d'exportation (1300 \$)", style: TextStyle(fontSize: 16));
  Text _lblCkbFraisDouanes =
      Text('Frais de douanes (2600 \$)', style: TextStyle(fontSize: 16));
  Text _lblFraisImpact = Text("Frais d'impact :",
      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold));
  Text _lblPrixTotCAD = Text("Prix total en \$ : ",
      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold));
  Text _lblPrixTotMRO = Text("Prix total en MRO :",
      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold));
  String _msgValidation = '';
  TextStyle labelStyle = TextStyle(color: Colors.black, fontSize: 20.0);

  var _tps;
  var _tvq;
  var _province;
  var _totalCAD;
  var _totalMRO;
  int _radioValue1 = 0;
  double _fraisMRO = 0.0;

  TextEditingController prixController = new TextEditingController();
  EdgeInsets _contentPadding =
      EdgeInsets.symmetric(vertical: 3, horizontal: 10);
  @override
  void initState() {
    loadVilles().then((List<Ville> result) {
      _villes = result;
    });
    loadGrille().then((List<RowGrille> result) {
      _rowsGrille = result;
    });

    super.initState();
  }

  @override
  void dispose() {
    prixController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      debugShowCheckedModeBanner: false,
      home: new Scaffold(
        appBar: new AppBar(
          title: new Text("Calculatrice Impact"),
          backgroundColor: Colors.blueGrey,
        ),
        resizeToAvoidBottomInset: false,
        body: new Container(
          child: Center(
            child: Column(
              children: <Widget>[
                /// Ville
                Padding(
                  padding:
                      const EdgeInsets.only(top: 25.0, left: 8.0, right: 8.0),
                  child: FormField<String>(
                    builder: (FormFieldState<String> state) {
                      return InputDecorator(
                          decoration: InputDecoration(
                            labelText: "Ville",
                            contentPadding: _contentPadding,
                            border: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.blue),
                            ),
                            labelStyle: labelStyle,
                          ),
                          child: DropdownButtonHideUnderline(
                            child: FutureBuilder<List<Ville>>(
                                future: loadVilles(),
                                builder: (context, snapshot) {
                                  if (snapshot.connectionState ==
                                      ConnectionState.done) {
                                    if (snapshot.hasError) {
                                      return Text("Erreur");
                                    }
                                    return new ButtonTheme(
                                        alignedDropdown: true,
                                        height: 5,
                                        child: DropdownButton<String>(
                                            isExpanded: true,
                                            value: _currentSelectedValue,
                                            isDense: true,
                                            onChanged: (newValue) {
                                              setState(() {
                                                _currentSelectedValue =
                                                    newValue;
                                                _fraisMTL =
                                                    getFraisMontreal(newValue);
                                                setFraisMTL();
                                                calculerPrix();
                                              });
                                            },
                                            items: snapshot.data.map((fc) {
                                              return DropdownMenuItem<String>(
                                                child: Text(fc.name),
                                                value: fc.name,
                                              );
                                            }).toList()));
                                  } else
                                    return CircularProgressIndicator();
                                }),
                          ));
                    },
                  ),
                ),

                ///Prix
                Padding(
                    padding:
                        const EdgeInsets.only(top: 8.0, left: 8.0, right: 8.0),
                    child: TextFormField(
                      controller: prixController,
                      onChanged: (text) {
                        calculerPrix();
                      },
                      decoration: InputDecoration(
                        contentPadding: _contentPadding,
                        border: OutlineInputBorder(),
                        labelText: "Prix",
                        labelStyle: labelStyle,
                        errorText: _validate == false ? _msgValidation : null,
                      ),
                      keyboardType: TextInputType.numberWithOptions(signed: true, decimal: true),
                      inputFormatters: [
                        // ThousandsFormatter(allowFraction: true)
                      ],
                    )),

                ///Monaie
                Padding(
                    padding:
                        const EdgeInsets.only(top: 8.0, left: 8.0, right: 8.0),
                    child: FormField<String>(
                        builder: (FormFieldState<String> state) {
                      return InputDecorator(
                          decoration: InputDecoration(
                              labelText: "Monaie",
                              contentPadding: _contentPadding,
                              border: OutlineInputBorder(),
                              labelStyle: labelStyle),
                          child: new Row(
                              //crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                new Radio(
                                  value: 0,
                                  groupValue: _radioValue1,
                                  onChanged: _handleRadioValueChange,
                                  materialTapTargetSize:
                                      MaterialTapTargetSize.shrinkWrap,
                                ),
                                new Text(
                                  'CAD',
                                  style: new TextStyle(fontSize: 16.0),
                                ),
                                new Radio(
                                  value: 1,
                                  groupValue: _radioValue1,
                                  onChanged: _handleRadioValueChange,
                                  materialTapTargetSize:
                                      MaterialTapTargetSize.shrinkWrap,
                                ),
                                new Text(
                                  'MRO',
                                  style: new TextStyle(fontSize: 16.0),
                                )
                              ]));
                    })),

                ///Options
                Padding(
                    padding:
                        const EdgeInsets.only(top: 8.0, left: 8.0, right: 8.0),
                    child: FormField<String>(
                        builder: (FormFieldState<String> state) {
                      return InputDecorator(
                          decoration: InputDecoration(
                              labelText: "Options",
                              border: OutlineInputBorder(
                                borderSide:
                                    BorderSide(color: Colors.blue, width: 4.0),
                              ),
                              labelStyle: labelStyle),
                          child: Column(children: [
                            CheckboxListTile(
                              title: _lblCkbFraisMTRL,
                              value: _fraisMTLChecked,
                              onChanged: (bool value) {
                                setState(() {
                                  _fraisMTLChecked = value;
                                  calculerPrix();
                                });
                              },
                              controlAffinity: ListTileControlAffinity.leading,
                            ),
                            CheckboxListTile(
                              title: _lblCkbFraisNkct,
                              value: _fraisNkctChecked,
                              onChanged: (bool value) {
                                setState(() {
                                  _fraisNkctChecked = value;
                                  calculerPrix();
                                });
                              },
                              controlAffinity: ListTileControlAffinity.leading,
                            ),
                            CheckboxListTile(
                              title: _lblCkbFraisDouanes,
                              value: _fraisDouanesChecked,
                              onChanged: (bool value) {
                                setState(() {
                                  _fraisDouanesChecked = value;
                                  calculerPrix();
                                });
                              },
                              controlAffinity: ListTileControlAffinity.leading,
                            ),
                          ]));
                    })),
                Padding(
                    padding:
                        const EdgeInsets.only(top: 8.0, left: 8.0, right: 8.0),
                    child: FormField<String>(
                        builder: (FormFieldState<String> state) {
                      return InputDecorator(
                          decoration: InputDecoration(
                            labelText: "Resultats",
                            errorStyle: TextStyle(
                                color: Colors.redAccent, fontSize: 12.0),
                            border: OutlineInputBorder(
                              borderSide:
                                  BorderSide(color: Colors.blue, width: 4.0),
                            ),
                            labelStyle: labelStyle,
                          ),
                          child: Column(
                            children: [
                              _lblFraisImpact,
                              // _espace10,
                              _lblPrixTotCAD,
                              //_espace10,
                              _lblPrixTotMRO
                            ],
                          ));
                    })),
              ],
            ),
          ),
        ),
        bottomNavigationBar: new Container(
            height: 40.0,
            color: Colors.blueGrey,
            child: Center(
              child: Text(_version +
                  ' Copyright \u00a9 ' +
                  DateTime.now().year.toString() +
                  ' S & S Brothers '),
            )),
      ),
    );
  }

  double getTpsPrix(String name) {
    return _villes.where((x) => x.name == name).first.tps;
  }

  String getProvince(String name) {
    return _villes.where((x) => x.name == name).first.province;
  }

  double getTvqPrix(String name) {
    return _villes.where((x) => x.name == name).first.tvq;
  }

  double getFraisSite(double prix) {
    return _rowsGrille
        .where((i) => (i.from <= prix && i.to >= prix))
        .first
        .value;
  }

  double getFraisMontreal(String name) {
    return _villes.where((x) => x.name == name).first.fraisMTRL;
  }

  void _handleRadioValueChange(int value) {
    setState(() {
      _radioValue1 = value;
      _validatePrix(prixController.text);
      calculerPrix();
    });
  }

  calculerPrix() {
    _validatePrix(prixController.text);
    if (_validate) {
      _province = getProvince(_currentSelectedValue);
      if (_radioValue1 == 0) {
        _tps = 0;
        _tvq = 0;
        _fraisImpact = 0;
        _totalMRO = 0;
        _totalCAD = 0;
        _tps = getTpsPrix(_currentSelectedValue);
        _tvq = getTvqPrix(_currentSelectedValue);
        _fraisImpact = getFraisSite(double.parse(prixController.text));

        if (_province == _QC)
          _fraisImpact = _fraisImpact + _FRAIS_NON_DEALER_QC;
        if (_province == _ON)
          _fraisImpact = _fraisImpact + _FRAIS_NON_DEALER_ON;
        _fraisImpact =
            _fraisImpact * _tps + double.parse(prixController.text) * _tvq;
        _totalCAD += _fraisImpact + double.parse(prixController.text);
        if (_fraisMTLChecked) _totalCAD += _fraisMTL;
        if (_fraisNkctChecked) _totalCAD += _FRAIS_TRANSPORT_NKCTT;
        if (_fraisDouanesChecked) _totalCAD += _FRAIS_DOUANES;
        _totalMRO = _totalCAD * _TAUX;

        _fraisImpact = _fraisImpact.toStringAsFixed(2);
        _totalCAD = _totalCAD.toStringAsFixed(2);
        _totalMRO = _totalMRO.toStringAsFixed(0);
      } else {
        double _frais_sup = 0.0;
        if (_fraisMTLChecked) _frais_sup += _fraisMTL;
        if (_fraisNkctChecked) _frais_sup += _FRAIS_TRANSPORT_NKCTT;
        if (_fraisDouanesChecked) _frais_sup += _FRAIS_DOUANES;

        setState(() {
          double _prixDolar =
              double.parse(prixController.text) / _TAUX - _frais_sup;
          _totalCAD = _getPrix(_prixDolar);

          _fraisImpact = _fraisMRO.toStringAsFixed(2);
          _totalMRO = _totalCAD * _TAUX;
          _totalMRO = _totalMRO.toStringAsFixed(2);
          _totalCAD = _totalCAD.toStringAsFixed(2);
        });
      }
      setState(() {
        chargerValues();
      });
    } else
      resetValues();
  }

  int calc_ranks(ranks) {
    double multiplier = .5;
    return (multiplier * ranks).round() * 2;
  }

  setFraisMTL() {
    String _frais = _fraisMTL != null ? calc_ranks(_fraisMTL).toString() : '';
    _lblCkbFraisMTRL =
        Text("Transport à Montréal ($_frais \$ )", style: _styleLblCkb);
  }

  resetValues() {
    setState(() {
      switch (_radioValue1) {
        case 0:
        case -1:
          _lblFraisImpact =
              Text("Frais d'impact en \$ : ", style: _styleLblResult);
          _lblPrixTotCAD = Text("Prix total en \$ : ", style: _styleLblResult);
          _lblPrixTotMRO = Text("Prix total en MRO : ", style: _styleLblResult);
          break;
        case 1:
          _lblFraisImpact =
              Text("Frais d'impact en \$ : ", style: _styleLblResult);
          _lblPrixTotCAD = Text("Mise max en \$ : ", style: _styleLblResult);
          _lblPrixTotMRO = Text("Mise max en MRO : ", style: _styleLblResult);

          break;
      }
    });
  }

  chargerValues() {
    setState(() {
      switch (_radioValue1) {
        case 0:
          _lblFraisImpact = Text("Frais d'impact en \$ : $_fraisImpact \$",
              style: _styleLblResult);
          _lblPrixTotCAD =
              Text("Prix total en \$ :  $_totalCAD \$", style: _styleLblResult);
          _lblPrixTotMRO = Text("Prix total en MRO : $_totalMRO  MRO",
              style: _styleLblResult);

          break;
        case 1:
          _lblFraisImpact = Text("Frais d'impact en \$ : $_fraisImpact MRO",
              style: _styleLblResult);
          _lblPrixTotCAD =
              Text("Mise max en \$ :  $_totalCAD \$", style: _styleLblResult);
          _lblPrixTotMRO =
              Text("Mise max en MRO : $_totalMRO  MRO", style: _styleLblResult);

          break;
      }
    });
  }

  bool _isNumeric(String s) {
    bool isNum = true;
    double result;

    if (_fraisMTLChecked) _montant_min_mro += _fraisMTL * _TAUX;
    if (_fraisNkctChecked) _montant_min_mro += _FRAIS_TRANSPORT_NKCTT * _TAUX;
    if (_fraisDouanesChecked) _montant_min_mro += _FRAIS_DOUANES * _TAUX;
    if (s.isEmpty) {
      _msgValidation = 'Le prix est obligatoire !';
      isNum = false;
    } else {
      try {
        result = double.parse(s, (e) => null);

        if (_radioValue1 == 0) {
          if (result > 100000.0) {
            isNum = false;
            _msgValidation = 'Le montant doit être inférieur de 100 000 ';
          }
        } else {
          print(_montant_min_mro);
          if (result < _montant_min_mro) {
            isNum = false;
            _msgValidation = 'Le montant doit être supérieur de '+_montant_min_mro.toStringAsFixed(0) ;
          }
        }
      } catch (Exception) {
        _msgValidation = 'Format invalid !';
        isNum = false;
      }
    }
    return isNum;
  }

  _validatePrix(String value) {
    setState(() {
      _montant_min_mro=_MONTANT_MIN;
      _validate = _isNumeric(value);
    });
  }

  double _getPrix(double prixCAD) {
    double _value = 0;
    _fraisMRO = 0.0;

    for (int i = 0; i < _rowsGrille.length; i++) {
      _fraisMRO = _rowsGrille[i].value;
      var _from = _rowsGrille[i].from;
      var _to = _rowsGrille[i].to;

      if (_province == _QC) {
        setState(() {
          _fraisMRO = (_fraisMRO + _FRAIS_NON_DEALER_QC) * _TPS_QC;
          _value = (prixCAD - _fraisMRO) / _TVQ_QC;
          _fraisMRO += _value * 0.05;
        });
      } else if (_province == _ON) {
        _fraisMRO = (_fraisMRO + _FRAIS_NON_DEALER_ON) * _TPS_ON;
        _value = (prixCAD - _fraisMRO) / _TPS_ON;
        _fraisMRO += _value * _TVQ_ON;
      }
      if (_value < 0) _value = _from;
      if (_value >= _from && _value <= _to) break;
    }

    return _value;
  }
}
