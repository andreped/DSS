import 'package:flutter/material.dart';
import 'package:flutter_sensors/flutter_sensors.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:sw_app/widgets/recording_database.dart';
import 'package:sw_app/widgets/recording_model.dart';
import 'dart:math';
import '../utils/datatypes.dart';
import '../utils/constants.dart' as _constants;

class DataRecordingPage extends StatefulWidget {
  @override
  State<DataRecordingPage> createState() => _DataRecordingPageState();
}

class _DataRecordingPageState extends State<DataRecordingPage> {
  double x = 0, y = 0, z = 0;
  String direction = "none";

  // chart plotter variables
  var xPoints = <FlSpot>[const FlSpot(0, 0)];
  var yPoints = <FlSpot>[const FlSpot(0, 0)];
  var zPoints = <FlSpot>[const FlSpot(0, 0)];

  double xValue = 0;
  double step = 0.05;

  var accelSubscription;
  var isStarted = false;
  var startTime;
  late int latestListId;
  var duration;

  void stream_accelerometer_data(listId) async {
    final _stream = await SensorManager().sensorUpdates(
      sensorId: Sensors.ACCELEROMETER,
      interval: Sensors.SENSOR_DELAY_GAME,
    );

    accelSubscription = _stream.listen((sensorEvent) {
      final _accelData = sensorEvent.data;

      // update counter
      xValue++;

      // get coordinates
      x = _accelData[0];
      y = _accelData[1];
      z = _accelData[2];

      // store result in history
      xPoints.add(FlSpot(xValue, x));
      yPoints.add(FlSpot(xValue, y));
      zPoints.add(FlSpot(xValue, z));

      while ((xPoints.length > _constants.limitCount) && (xPoints.isNotEmpty)) {
        xPoints.removeAt(0);
        yPoints.removeAt(0);
        zPoints.removeAt(0);
      }

      setState(() {});

      var recording = Recording(
          listId: listId + 1,
          timeStamp: DateTime.now(),
          xAccel: x,
          yAccel: y,
          zAccel: z);
      RecordingDatabase.instance.create(recording);
    });
  }

  void reset_variables() {
    accelSubscription.cancel();

    this.xValue = 0;
    this.step = 0.05;

    this.x = 0;
    this.y = 0;
    this.z = 0;
    this.direction = "none";

    // chart plotter variables
    this.xPoints = <FlSpot>[const FlSpot(0, 0)];
    this.yPoints = <FlSpot>[const FlSpot(0, 0)];
    this.zPoints = <FlSpot>[const FlSpot(0, 0)];
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
  }

  @override
  Widget build(BuildContext context) {
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
              onPressed: () async {
                this.isStarted = !this.isStarted;
                if (this.isStarted) {
                  this.startTime = DateTime.now();

                  this.latestListId =
                      await RecordingDatabase.instance.getLatestListId();
                  print(this.latestListId);

                  stream_accelerometer_data(this.latestListId);
                } else {
                  this.duration =
                      DateTime.now().difference(startTime).inSeconds;
                  var recordingList = RecordingList(
                      timeStamp: startTime, duration: this.duration);
                  RecordingDatabase.instance.createList(recordingList);
                  reset_variables();
                }

                setState(() {});
              },
              style: ElevatedButton.styleFrom(
                  backgroundColor: this.isStarted ? Colors.red : Colors.green,
                  padding: EdgeInsets.symmetric(horizontal: 50, vertical: 20),
                  textStyle:
                      TextStyle(fontSize: 30, fontWeight: FontWeight.bold)),
              child: this.isStarted
                  ? Text('Stop recording')
                  : Text('Start Recording'))
        ],
      ),
    );
  }

  @override
  void dispose() {
    // need to close listener when class is inactive
    accelSubscription.cancel();

    super.dispose();
  }
}
