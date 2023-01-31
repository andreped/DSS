
import 'package:flutter/material.dart';
import 'package:flutter_sensors/flutter_sensors.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import '../main.dart';
import 'package:fl_chart/fl_chart.dart';
import 'dart:math';
import '../utils/datatypes.dart';
import '../utils/constants.dart' as _constants;
import 'package:provider/provider.dart';

class DataRecordingPage extends StatefulWidget {
  @override
  State<DataRecordingPage> createState() => _DataRecordingPageState();
}

class _DataRecordingPageState extends State<DataRecordingPage> {
  double x = 0, y = 0, z = 0;
  String direction = "none";
  int maxLen = 50;
  var input = List<double>.filled(150, 0).reshape([1, 50, 3]);

  // initialize FPS
  double fpsValue = 0.0;
  int count = 0;
  double timer = 0.0;
  double smoothing = 0.1;
  double val = 0.0;
  int elapsedFrames = 0;

  // chart plotter variables
  final xPoints = <FlSpot>[const FlSpot(0, 0)];
  final yPoints = <FlSpot>[const FlSpot(0, 0)];
  final zPoints = <FlSpot>[const FlSpot(0, 0)];
  final fpsPoints = <FlSpot>[const FlSpot(0, 25)];
  double xValue = 0;
  double step = 0.05;

  // to track FPS
  Stopwatch stopwatch = Stopwatch()..start();

  late final _accelSubscription;

  void _run() async {
    final _stream = await SensorManager().sensorUpdates(
      sensorId: Sensors.ACCELEROMETER,
      interval: Sensors.SENSOR_DELAY_GAME,
    );

    _accelSubscription = _stream.listen((sensorEvent) {
      final _accelData = sensorEvent.data;

      // update counter - relevant for FPS counter
      count++;
      xValue++;

      // get coordinates
      x = _accelData[0];
      y = _accelData[1];
      z = _accelData[2];

      // add accelerator data to tensor and remove oldest sample
      input[0].insert(0, [x, y, z]);
      input[0].removeAt(maxLen);


      // update FPS counter N milliseconds
      //if (stopwatch.elapsedMilliseconds > 10) {
      double currFreq = count / (stopwatch.elapsedMilliseconds / 1000);
      fpsValue = (fpsValue * smoothing) + currFreq * (1 - smoothing);

      // store result in history
      xPoints.add(FlSpot(xValue, x));
      yPoints.add(FlSpot(xValue, y));
      zPoints.add(FlSpot(xValue, z));
      fpsPoints.add(FlSpot(xValue, fpsValue));

      while ((fpsPoints.length > _constants.limitCount) &&
          (fpsPoints.isNotEmpty)) {
        xPoints.removeAt(0);
        yPoints.removeAt(0);
        zPoints.removeAt(0);
        fpsPoints.removeAt(0);
      }

      // reset stopwatch
      stopwatch.reset();

      // reset counter
      count = 0;

      setState(() {});
    });
  }

  SizedBox makeLineChart(List<FlSpot> points, Color currColor) {
    return SizedBox(
      width: 350,
      height: 150,
      child: LineChart(
        LineChartData(
          minY: points.map((abc) => abc.y).reduce(min) - 0.05,
          maxY: points.map((abc) => abc.y).reduce(max) + 0.05,
          minX: points.first.x,
          maxX: points.last.x,
          lineTouchData: LineTouchData(enabled: false),
          clipData: FlClipData.all(),
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
          ),
          lineBarsData: [
            historyLine(points, currColor),
          ],
          titlesData: FlTitlesData(
            show: true,
          ),
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();

    // run model using accelerometer data
    _run();
  }

  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();
    return SingleChildScrollView(
      child: Column(
        children: <Widget>[
          const SizedBox(
            height: 30,
            width: 20,
          ),
          SizedBox(
            width: double.infinity,
            child: RichText(
              textAlign: TextAlign.center,
              text: const TextSpan(
                style: TextStyle(
                  fontSize: 20.0,
                  color: Colors.black,
                ),
                children: <TextSpan>[
                  TextSpan(text: "Real time charts: "),
                  TextSpan(
                      text: 'x ', style: TextStyle(color: _constants.xColor)),
                  TextSpan(
                      text: 'y ', style: TextStyle(color: _constants.yColor)),
                  TextSpan(
                      text: 'z ', style: TextStyle(color: _constants.zColor)),
                ],
              ),
            ),
          ),
          const SizedBox(
            height: 10,
            width: 20,
          ),
          makeLineChart(xPoints, _constants.xColor),
          makeLineChart(yPoints, _constants.yColor),
          makeLineChart(zPoints, _constants.zColor),
          ElevatedButton(
              onPressed: () {
                appState.startStopRecording();
              },
              style: ElevatedButton.styleFrom(
                  backgroundColor: appState.isStarted? Colors.green : Colors.red,
                  padding: EdgeInsets.symmetric(horizontal: 50, vertical: 20),
                  textStyle:
                      TextStyle(fontSize: 30, fontWeight: FontWeight.bold)),
              child: appState.isStarted
                  ? Text('Start recording')
                  : Text('Stop Recording'))
        ],
      ),
    );
  }

  @override
  void dispose() {
    // need to close listener when class is inactive
    _accelSubscription.cancel();

    super.dispose();
  }
}
