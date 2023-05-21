import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';
// import 'test.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Average Speed',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: SpeedCalculatorApp(),
    );
  }
}

class SpeedCalculatorApp extends StatefulWidget {
  @override
  _SpeedCalculatorAppState createState() => _SpeedCalculatorAppState();
}

class _SpeedCalculatorAppState extends State<SpeedCalculatorApp> {
  // final Geolocator _geolocator = Geolocator();
  bool _isCalculating = false;
  double _averageSpeed = 0;

  @override
  void initState() {
    super.initState();
    // Request location permission when the app starts
    _requestLocationPermission();
  }

  Future<void> _requestLocationPermission() async {
    PermissionStatus permission = await Permission.location.request();
    if (permission != PermissionStatus.granted) {
      // If permission is not granted, show an error message
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Location permission denied'),
            content: Text('Please grant location permission to use this app.'),
            actions: <Widget>[
              TextButton(
                child: Text('OK'),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          );
        },
      );
    }
  }

  Future<void> _calculateAverageSpeed() async {
    // Set the _isCalculating flag to true to indicate that we're calculating the average speed
    setState(() {
      _isCalculating = true;
    });

    try {
      // Get the current position
      Position currentPosition = await Geolocator.getCurrentPosition();

      // Wait for 30 seconds
      await Future.delayed(Duration(seconds: 30));

      // Get the position again after 30 seconds
      Position newPosition = await Geolocator.getCurrentPosition();

      // Calculate the distance traveled
      double distance = await Geolocator.distanceBetween(
          currentPosition.latitude,
          currentPosition.longitude,
          newPosition.latitude,
          newPosition.longitude);

      // Calculate the average speed
      double speed = distance / 30;

      // Set the _averageSpeed variable to the calculated speed
      setState(() {
        _averageSpeed = speed;
      });
    } catch (e) {
      // If an error occurs, show an error message
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Error'),
            content:
                Text('An error occurred while calculating the average speed.'),
            actions: <Widget>[
              TextButton(
                child: Text('OK'),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          );
        },
      );
    } finally {
      // Set the _isCalculating flag to false to indicate that we're done calculating the average speed
      setState(() {
        _isCalculating = false;
      });
    }
  }

  List<Color> colors = [Colors.blue, Colors.amber, Colors.pink];
  Widget _getRadialGauge(
    String valtxt,
    double val,
  ) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Container(
        decoration: const BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(25)),
            gradient: LinearGradient(colors: [
              Colors.black26,
              Colors.black87,
            ])),
        child: SfRadialGauge(
            title: GaugeTitle(
                text: 'Average Speed',
                textStyle: const TextStyle(
                    fontSize: 20.0,
                    fontWeight: FontWeight.bold,
                    color: Colors.white)),
            axes: <RadialAxis>[
              RadialAxis(
                  minimum: 0,
                  maximum: 150,
                  axisLabelStyle: GaugeTextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14),
                  majorTickStyle: MajorTickStyle(
                      length: 6, thickness: 4, color: Colors.white),
                  minorTickStyle: MinorTickStyle(
                      length: 3, thickness: 3, color: Colors.white),
                  ranges: <GaugeRange>[
                    GaugeRange(
                        startValue: 0,
                        endValue: 150,
                        sizeUnit: GaugeSizeUnit.factor,
                        startWidth: 0.03,
                        endWidth: 0.03,
                        gradient: SweepGradient(colors: const <Color>[
                          Colors.green,
                          Colors.yellow,
                          Colors.red
                        ], stops: const <double>[
                          0.0,
                          0.5,
                          1
                        ]))
                  ],
                  pointers: <GaugePointer>[
                    NeedlePointer(
                      value: val,
                      needleLength: 0.95,
                      enableAnimation: true,
                      animationType: AnimationType.ease,
                      needleStartWidth: 1.5,
                      needleEndWidth: 6,
                      needleColor: Colors.red,
                      knobStyle: KnobStyle(knobRadius: 0.09),
                    )
                  ],
                  annotations: <GaugeAnnotation>[
                    GaugeAnnotation(
                        widget: Container(
                            child: Text(valtxt,
                                style: TextStyle(
                                    fontSize: 21,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white))),
                        angle: 90,
                        positionFactor: 0.8)
                  ])
            ]),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Calc Average Speed'),
        backgroundColor: Color.fromARGB(255, 56, 56, 56),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.only(top: 30.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                if (_isCalculating) ...[
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0, bottom: 5),
                    child: CircularProgressIndicator(
                      color: Colors.greenAccent,
                    ),
                  ),
                  _getRadialGauge("0", 0)
                ] else ...[
                  _getRadialGauge(
                      "${(_averageSpeed * 3.6).toStringAsFixed(2)}  km/h",
                      (_averageSpeed * 3.6)),
                ],
                SizedBox(height: 16),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 50),
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color.fromARGB(255, 75, 78, 75),
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    child: Text('Calculate',
                        style: TextStyle(
                            fontSize: 23, fontWeight: FontWeight.bold)),
                    onPressed: _calculateAverageSpeed,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
