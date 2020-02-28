import 'dart:convert';
import 'dart:math' as math;
import 'package:latlong/latlong.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hay_hub/model.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'HayHub',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'HayHub Demo'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String result = '';
  var _latController = TextEditingController();
  var _lonController = TextEditingController();
  var _accuracyController = TextEditingController();

  Future<String> _loadAStudentAsset() async {
    return await rootBundle.loadString('assets/hub.json');
  }

  Future<HayHubModel> loadStudent() async {
    String jsonString = await _loadAStudentAsset();

    print('jsonString: $jsonString');

    final jsonResponse = json.decode(jsonString);
    print('jsonResponse: $jsonResponse');

    return HayHubModel.fromJson(jsonResponse);
  }

  Future getPolygon() async {
    List<List> polygon = [];

    HayHubModel hayHubModel = await loadStudent();

    hayHubModel.geometry.forEach((items) {
      items.lat;
      polygon.add([items.lat, items.lon]);
    });
    print('polygon: $polygon');
    return polygon;
  }

  bool checkGeoFence(List point, List polygon){

    int j = 0;
    bool isMatching = false;
    double x = point[1];
    double y = point[0];
    int n = polygon.length;
    for (var i = 0; i < n; i++)
    {
      j++;
      if (j == n)
      {
        j = 0;
      }
      print("polygon[i][0]: " + polygon[i][0].toString());
      print("polygon[j][0]: " + polygon[j][0].toString());
      print("y: " + y.toString());
      if (((polygon[i][0] < y) && (polygon[j][0] >= y)) || ((polygon[j][0] < y) && (polygon[i][0] >=
          y)))
      {
        if (polygon[i][1] + (y - polygon[i][0]) / (polygon[j][0] - polygon[i][0]) * (polygon[j][1] -
            polygon[i][1]) < x)
        {
          isMatching = !isMatching;
        }
      }
    }
    return isMatching;
  }

  void getResult({String lat = '0.0', String long = '0.0', String accuracy = '0'})async{

    getPolygon().then((val){
      List coordinates = [double.parse(lat), double.parse(long)];

      print('Cordinates: $coordinates');
      print('Poly value is: $val');
      bool _result = checkGeoFence(coordinates,val);

      print('result is: $result');

      if(_result){
        setState(() {
          result = 'TRUE';
        });
      }else{
        final Distance distance = const Distance();
        final num distanceInMeter = (EARTH_RADIUS * math.pi / 4).round();

        final p1 = LatLng(double.parse(lat), double.parse(long));
        final p2 = distance.offset(p1, distanceInMeter, int.parse(accuracy));

        List coordinates = [p2.latitude, p2.longitude];
        print('p2: $p2');

        bool _result = checkGeoFence(coordinates,val);

        setState(() {
          result = _result?'TRUE':'FALSE';
        });
      }

    });


  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
        ),
        body: Column(
          children: <Widget>[
            TextField(
              controller: _latController,
              keyboardType: TextInputType.numberWithOptions(),
              decoration: InputDecoration(labelText: 'Enter Latitude'),
            ),
            TextField(
              controller: _lonController,
              keyboardType: TextInputType.numberWithOptions(),
              decoration: InputDecoration(labelText: 'Enter Longitude'),
            ),
            TextField(
              controller: _accuracyController,
              keyboardType: TextInputType.numberWithOptions(),
              decoration: InputDecoration(labelText: 'Enter Accuracy'),
            ),
            MaterialButton(
              onPressed: () => getResult(
                lat: _latController.text,
                long: _lonController.text,
                accuracy: _accuracyController.text
              ),
              child: Text('Get Result'),
              color: Colors.blue,
            ),

            Text('Result is: $result', style: TextStyle(
              fontSize: 30.0,
            ),)
          ],
        ));
  }
}
