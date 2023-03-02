import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_sensors/flutter_sensors.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sw_app/widgets/recording_database.dart';
import 'package:sw_app/widgets/recording_model.dart';
import 'dart:math';
import '../utils/datatypes.dart';
import '../utils/constants.dart' as _constants;
import 'package:csv/csv.dart';
class DataRecordingPage extends StatefulWidget {
  @override
  State<DataRecordingPage> createState() => _DataRecordingPageState();
}

class _DataRecordingPageState extends State<DataRecordingPage> {
  double x_accel = 0, y_accel = 0, z_accel = 0;
  double x_gyro = 0, y_gyro = 0, z_gyro = 0;
  double x_rot = 0, y_rot = 0, z_rot = 0;
  String direction = "none";
  var accel_finished = false;
  var gyro_finished = false;
  var rot_finished = false;


  // chart plotter variables
  var xPoints = <FlSpot>[const FlSpot(0, 0)];
  var yPoints = <FlSpot>[const FlSpot(0, 0)];
  var zPoints = <FlSpot>[const FlSpot(0, 0)];

  double xValue_accel = 0;
  double step = 0.05;

  var accelSubscription;
  var gyroSubscription;
  var rotSubscription;
  var isStarted = false;
  var recordingList;

  List<List<dynamic>> sensor_data_list = [];





// https://github.com/LJaraCastillo/flutter_sensors/blob/master/lib/src/sensors.dart

  void stream_sensor_data() async {

    List<dynamic> header = [];
    header.add("Time Stamp");
    header.add("xAccel");
    header.add("yAccel");
    header.add("zAccel");
    header.add("xGyro");
    header.add("yGyro");
    header.add("zGyro");
    header.add("xRot");
    header.add("yRot");
    header.add("zRot");

    sensor_data_list.add(header);

    final _stream_accel = await SensorManager().sensorUpdates(
      sensorId: Sensors.ACCELEROMETER,
      interval: Sensors.SENSOR_DELAY_GAME,
    );

    final _stream_gyro = await SensorManager().sensorUpdates(
      sensorId: Sensors.GYROSCOPE,
      interval: Sensors.SENSOR_DELAY_GAME,
    );

    final _stream_rot = await SensorManager().sensorUpdates(
      sensorId: Sensors.ROTATION,
      interval: Sensors.SENSOR_DELAY_GAME,
    );

    rotSubscription = _stream_rot.listen((sensorEvent) {
      final _rotData = sensorEvent.data;

      // get coordinates
      try {
        x_rot = _rotData[0];
        y_rot = _rotData[1];
        z_rot = _rotData[2];}
      catch(e) {
        x_rot = _rotData[0];
        y_rot = "" as double;
        z_rot = "" as double;
      }

      setState(() {});

      // write datapoints to list
      List<dynamic> row_rot = [];
      row_rot.add(DateTime.now());
      row_rot.add("");
      row_rot.add("");
      row_rot.add("");
      row_rot.add("");
      row_rot.add("");
      row_rot.add("");
      row_rot.add(x_rot);
      row_rot.add(y_rot);
      row_rot.add(z_rot);

      sensor_data_list.add(row_rot);

    });

    gyroSubscription = _stream_gyro.listen((sensorEvent) {
      final _gyroData = sensorEvent.data;

      // get coordinates
      x_gyro = _gyroData[0];
      y_gyro = _gyroData[1];
      z_gyro = _gyroData[2];

      setState(() {});

      // write datapoints to list
      List<dynamic> row_gyro = [];
      row_gyro.add(DateTime.now());
      row_gyro.add("");
      row_gyro.add("");
      row_gyro.add("");
      row_gyro.add(x_gyro);
      row_gyro.add(y_gyro);
      row_gyro.add(z_gyro);
      row_gyro.add("");
      row_gyro.add("");
      row_gyro.add("");

      sensor_data_list.add(row_gyro);

    });


    accelSubscription = _stream_accel.listen((sensorEvent) {
      final _accelData = sensorEvent.data;

      // update counter
      xValue_accel++;

      // get coordinates
      x_accel = _accelData[0];
      y_accel = _accelData[1];
      z_accel = _accelData[2];

      // store result in history
      xPoints.add(FlSpot(xValue_accel, x_accel));
      yPoints.add(FlSpot(xValue_accel, y_accel));
      zPoints.add(FlSpot(xValue_accel, z_accel));

      while ((xPoints.length > _constants.limitCount) && (xPoints.isNotEmpty)) {
        xPoints.removeAt(0);
        yPoints.removeAt(0);
        zPoints.removeAt(0);
      }

      setState(() {});

      // write datapoints to list
      List<dynamic> row_accel = [];
      row_accel.add(DateTime.now());
      row_accel.add(x_accel);
      row_accel.add(y_accel);
      row_accel.add(z_accel);
      row_accel.add("");
      row_accel.add("");
      row_accel.add("");
      row_accel.add("");
      row_accel.add("");
      row_accel.add("");

      sensor_data_list.add(row_accel);

    });



  }
  void save_csv (sensor_data_list, listId) async{

    String csv = const ListToCsvConverter().convert(sensor_data_list);

    Directory? appDocDir = await getExternalStorageDirectory();
    var appDocPath = appDocDir?.path;


    File f = File(appDocPath! + "/" + listId.toString()+ ".csv");
    print(f);

    f.writeAsString(csv);
    print('CSV File saved in ' + f.path.toString());

  }

  void reset_variables(listId) {

    save_csv(sensor_data_list, listId);
    accelSubscription.cancel();
    rotSubscription.cancel();
    gyroSubscription.cancel();


    this.xValue_accel = 0;
    this.step = 0.05;

    this.direction = "none";

    accel_finished = false;
    gyro_finished = false;
    rot_finished = false;

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
                  recordingList = RecordingList(
                      timeStamp: DateTime.now(), duration: 0);
                  RecordingDatabase.instance.createList(recordingList);

                  stream_sensor_data();

                } else {
                  int latestListId = await RecordingDatabase.instance.getLatestListId();

                  RecordingDatabase.instance.update();
                  reset_variables(latestListId);

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
