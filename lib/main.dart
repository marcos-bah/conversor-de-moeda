import "package:flutter/material.dart";
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';

const req = "https://api.hgbrasil.com/finance?format=json&key=b8456468";

void main() async {
  runApp(
    MaterialApp(
      home: Home(),
      theme: ThemeData(
        hintColor: Colors.amber,
        primaryColor: Colors.white,
        inputDecorationTheme: InputDecorationTheme(
          enabledBorder:
              OutlineInputBorder(borderSide: BorderSide(color: Colors.white)),
          focusedBorder:
              OutlineInputBorder(borderSide: BorderSide(color: Colors.amber)),
          hintStyle: TextStyle(color: Colors.amber),
        ),
      ),
      debugShowCheckedModeBanner: false,
    ),
  );
}

Future<Map> getData() async {
  http.Response res = await http.get(req);
  return json.decode(res.body);
}

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final realController = TextEditingController();
  final dolarController = TextEditingController();
  final euroController = TextEditingController();
  final opMoedaController = TextEditingController();

  double dolar;
  double euro;
  double btc;
  double ars;
  double op;

  String nomeMoeda = "";
  String sMoeda = "";

  void _realChanged(String text) {
    if (text.isEmpty) {
      _clearAll();
      return;
    }
    double real = double.parse(text);
    dolarController.text = (real / dolar).toStringAsFixed(2);
    euroController.text = (real / euro).toStringAsFixed(2);
    opMoedaController.text = (real / op).toStringAsFixed(3);
  }

  void _dolarChanged(String text) {
    if (text.isEmpty) {
      _clearAll();
      return;
    }
    double dolar = double.parse(text);
    realController.text = (dolar * this.dolar).toStringAsFixed(2);
    euroController.text = (dolar * this.dolar / euro).toStringAsFixed(2);
    opMoedaController.text = (dolar * this.dolar / op).toStringAsFixed(3);
  }

  void _euroChanged(String text) {
    if (text.isEmpty) {
      _clearAll();
      return;
    }
    double euro = double.parse(text);
    realController.text = (euro * this.euro).toStringAsFixed(2);
    dolarController.text = (euro * this.euro / dolar).toStringAsFixed(2);
    opMoedaController.text = (euro * this.euro / op).toStringAsFixed(3);
  }

  void _opMoedaChanged(String text) {
    if (text.isEmpty) {
      _clearAll();
      return;
    }
    double opMoeda = double.parse(text);
    print(op);
    realController.text = (opMoeda * op).toStringAsFixed(2);
    dolarController.text = (opMoeda * op / dolar).toStringAsFixed(2);
    euroController.text = (opMoeda * op / euro).toStringAsFixed(2);
  }

  void _clearAll() {
    realController.text = "";
    dolarController.text = "";
    euroController.text = "";
    opMoedaController.text = "";
  }

  var lista = [
    DropdownMenuItem(
      child: Text("Bitcoins"),
      value: [
        "Bitcoin",
        "BT\$",
      ],
    ),
    DropdownMenuItem(
      child: Text("Pesos Argentinos"),
      value: [
        "Peso Argentino",
        "\$",
      ],
    ),
  ].toList();

  Widget dpdOptions(var lista) {
    return DropdownButton(
      items: lista,
      style: TextStyle(color: Colors.white, fontSize: 18),
      dropdownColor: Colors.amber,
      underline: Container(
        height: 2,
        color: Colors.amber,
      ),
      hint: Text("Escolha uma outra moeda"),
      onChanged: (value) {
        setState(
          () {
            nomeMoeda = value[0];
            sMoeda = value[1];
            op = (nomeMoeda == "Bitcoin") ? btc : ars;
            _clearAll();
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text("\$ Conversor \$"),
        backgroundColor: Colors.amber,
        centerTitle: true,
      ),
      body: FutureBuilder(
        future: getData(),
        builder: (ctx, snp) {
          switch (snp.connectionState) {
            case ConnectionState.none:
            case ConnectionState.waiting:
              return Center(
                child: Text(
                  "Carregando Dados...",
                  style: TextStyle(
                    color: Colors.amber,
                    fontSize: 25.0,
                  ),
                  textAlign: TextAlign.center,
                ),
              );
            default:
              if (snp.hasError) {
                return Center(
                  child: Text(
                    "Erro ao Carregar Dados",
                    style: TextStyle(
                      color: Colors.amber,
                      fontSize: 25.0,
                    ),
                    textAlign: TextAlign.center,
                  ),
                );
              } else {
                dolar = snp.data["results"]["currencies"]["USD"]["buy"];
                euro = snp.data["results"]["currencies"]["EUR"]["buy"];
                ars = snp.data["results"]["currencies"]["ARS"]["buy"];
                btc = snp.data["results"]["currencies"]["BTC"]["buy"];

                return SingleChildScrollView(
                  padding: EdgeInsets.all(10.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      Icon(
                        Icons.monetization_on,
                        size: 150.0,
                        color: Colors.amber,
                      ),
                      buildTextField(
                          "Reais", "R\$", realController, _realChanged),
                      Divider(),
                      buildTextField(
                          "Dólares", "USD", dolarController, _dolarChanged),
                      Divider(),
                      buildTextField(
                          "Euros", "€", euroController, _euroChanged),
                      Divider(),
                      dpdOptions(lista),
                      Divider(),
                      buildTextField(nomeMoeda, sMoeda, opMoedaController,
                          _opMoedaChanged),
                    ],
                  ),
                );
              }
          }
        },
      ),
    );
  }
}

Widget buildTextField(
    String label, String prefix, TextEditingController c, Function f) {
  return TextField(
    controller: c,
    decoration: InputDecoration(
      labelText: label,
      labelStyle: TextStyle(
        color: Colors.amber,
      ),
      border: OutlineInputBorder(),
      prefixText: prefix,
    ),
    style: TextStyle(
      color: Colors.amber,
      fontSize: 25.0,
    ),
    onChanged: f,
    keyboardType: TextInputType.number,
  );
}
