import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sensors/flutter_sensors.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'dart:math';
import '../utils/math_addons.dart';


class Home extends StatefulWidget{
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final _modelFile = 'model.tflite';
  double x = 0,
      y = 0,
      z = 0;
  int classPred = 0;
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

  // to track FPS
  Stopwatch stopwatch = Stopwatch()..start();

  // TensorFlow Lite Interpreter object
  late Interpreter _interpreter;

  void _loadModel() async {
    // Creating the interpreter using Interpreter.fromAsset
    _interpreter = await Interpreter.fromAsset(_modelFile);
    if (kDebugMode) {
      print('Interpreter loaded successfully');
    }
  }

  void _run() async {
    final _stream = await SensorManager().sensorUpdates(
      sensorId: Sensors.ACCELEROMETER,
      interval: Sensors.SENSOR_DELAY_GAME,
    );

    _stream.listen((sensorEvent) {
      setState(() {
        final _accelData = sensorEvent.data;

        // update counter - relevant for FPS counter
        count++;

        // get coordinates
        x = _accelData[0];
        y = _accelData[1];
        z = _accelData[2];

        // add accelerator data to tensor and remove oldest sample
        input[0].insert(0, [x, y, z]);
        input[0].removeAt(maxLen);

        // initialize zeros list container to store result from interpreter
        var output = List<double>.filled(20, 0).reshape([1, 20]);

        // run model and store result in output
        _interpreter.run(input, output);

        // get final class prediction by argmax the softmax output
        classPred = argmax(output[0]);

        // update FPS counter every second
        if (stopwatch.elapsedMilliseconds > 1000) {
          double currFreq = count / (stopwatch.elapsedMilliseconds / 1000);
          fpsValue = (fpsValue * smoothing) + currFreq * (1 - smoothing);

          // reset stopwatch
          stopwatch.reset();

          // reset counter
          count = 0;
        }
      });
    });
  }

  @override
  void initState() {
    // load model
    _loadModel();

    // run model using accelerometer data
    _run();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("DSWS: Demo app"),
        backgroundColor: Colors.redAccent,
      ),
      body: Center(
        child: Container(
          child: Padding(
            padding: const EdgeInsets.all(14.0),
            child: Column(
              children: <Widget>[
                SizedBox(
                  height: 20,
                  width: 20,
                ),
                Container(
                  //alignment: Alignment.center,
                  //padding: const EdgeInsets.all(30),
                  width: 380,
                  //height: 250,
                  child: Column(
                      children: [
                        const Text("\nAccelerometer data:",
                          style: TextStyle(fontSize: 30, color: Colors.white),),
                        Text("x: " + x.toStringAsFixed(4),
                          style: const TextStyle(
                              fontSize: 30, color: Colors.white),),
                        Text("y: " + y.toStringAsFixed(4),
                          style: const TextStyle(
                              fontSize: 30, color: Colors.white),),
                        Text("z: " + z.toStringAsFixed(4) + "\n",
                          style: const TextStyle(
                              fontSize: 30, color: Colors.white),),
                      ]
                  ),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: Colors.blueGrey
                  ),
                ),
                SizedBox(
                  height: 20,
                  width: 20,
                ),
                Container(
                  width: 380,
                  //height: 200,
                  child: Column(
                      children: [
                        Text("\nClass pred: " + classPred.toString(),
                          style: const TextStyle(
                              fontSize: 30, color: Colors.white),),
                        Text("\nFPS: " + fpsValue.toStringAsFixed(1) + "\n",
                          style: const TextStyle(
                              fontSize: 30, color: Colors.white),),
                      ]
                  ),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: Colors.black38
                  ), //BoxDecoration
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
