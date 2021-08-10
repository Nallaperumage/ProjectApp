//import 'dart:io';

//import 'dart:html';

import 'package:csv/csv.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sklite/ensemble/forest.dart';
import 'package:sklite/utils/io.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
//import 'package:df/df.dart';
import 'package:flutter/foundation.dart';
import 'dart:async' show Future;

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key, required this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

Future<Map<String, dynamic>> _getPrediction(List<String> symptoms) async {
  final Uri apiUrl = Uri.parse("http://127.0.0.1:5000/predict");

  final response = await http.post(apiUrl, headers: {
    "Accept": "application/json",
    "Access-Control-Allow-Origin": "*", // Required for CORS support to work
    "Access-Control-Allow-Headers":
        "Origin,Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token,locale",
    "Access-Control-Allow-Methods": "POST, OPTIONS"
  }, body: {
    "symptoms": jsonEncode(symptoms)
  });

  if (response.statusCode == 200) {
    Map<String, dynamic> resultResponse = jsonDecode(response.body);
    return resultResponse;
  } else {
    return {'prediction': 'Not Recognised'};
  }
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;
  late RandomForestClassifier rf;
  String disease = 'Wait';
  var concatenate = StringBuffer();
  Map<String, dynamic> result = {'prediction': 'Wait'};

  List<List<dynamic>> data = [];
  Future<List<String>?> loadAsset() async {
    final myData = await rootBundle.loadString("assets/diseasedf.csv");
    List<List<dynamic>> csvTable = CsvToListConverter().convert(myData);
    print(csvTable);
    data = csvTable;
    setState(() {});
    return null;
  }

  void _displayDisease() async {
    result = await _getPrediction(
        ["itching", "skin rash", "nodal skin eruptions", "dischromic patches"]);

    setState(() {
      disease = result['prediction'];
    });
  }

  void _incrementCounter() {
    setState(() {
      // This call to setState tells the Flutter framework that something has
      // changed in this State, which causes it to rerun the build method below
      // so that the display can reflect the updated values. If we changed
      // _counter without calling setState(), then the build method would not be
      // called again, and so nothing would appear to happen.
      _counter = _counter + 2;
    });
  }

  //void _getcolumns() async {
  //  debugPrint('haththikkeee');
  //  final df = await DataFrame.fromCsv('assets/diseasedf.csv');
  //  debugPrint('fuckya');
  //  test = df.columnsNames;

  //  test.forEach((item) {
  //    concatenate.write(item);
  //  });
  //  print(concatenate);
  //  print(test);
  //  debugPrint('movieTitle: $concatenate');
  //}

  // void _readCsv() async {
  //   List<String> testing = [];
  //   final input = new File(testing,'assets/diseasedf.csv');
  //   final fields = await input
  //       .transform(utf8.decoder)
  //       .transform(new CsvToListConverter())
  //       .toList();

  //   debugPrint('movieTitle: $fields');
  //   debugPrint('movieTitle: $testing');
  // }

  // void _readCsv() async {
  //   List<String> testing = [];
  //   final input = new File('assets/diseasedf.csv').openRead();
  //   final fields = await input
  //       .transform(utf8.decoder)
  //       .transform(new CsvToListConverter())
  //       .toList();

  //   debugPrint('movieTitle: $fields');
  //   debugPrint('movieTitle: $testing');
  // }

  void _homePageState() {
    List<double> X = [];

    loadModel("assets/diseaserf.json").then((x) {
      this.rf = RandomForestClassifier.fromMap(json.decode(x));
    });
    rf.predict(X);
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: Column(
          // Column is also a layout widget. It takes a list of children and
          // arranges them vertically. By default, it sizes itself to fit its
          // children horizontally, and tries to be as tall as its parent.
          //
          // Invoke "debug painting" (press "p" in the console, choose the
          // "Toggle Debug Paint" action from the Flutter Inspector in Android
          // Studio, or the "Toggle Debug Paint" command in Visual Studio Code)
          // to see the wireframe for each widget.
          //
          // Column has various properties to control how it sizes itself and
          // how it positions its children. Here we use mainAxisAlignment to
          // center the children vertically; the main axis here is the vertical
          // axis because Columns are vertical (the cross axis would be
          // horizontal).
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'You have pushed the button this many times:',
            ),
            Text(
              '$disease',
              style: Theme.of(context).textTheme.headline4,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _displayDisease,
        tooltip: 'Increment',
        child: Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
