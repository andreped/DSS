import 'dart:async';
import 'package:flutter/material.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'dart:math';


Future<void> main() async {
  runApp(MyApp());
}

int argmax(List<dynamic> X) {
  int idx = 0;
  int l = X.length;
  for (int i = 0; i < l; i++) {
    idx = X[i] > X[idx] ? i : idx;
  }
  return idx;
}

class MyApp extends StatelessWidget{
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Home(),
    );
  }
}

class Home extends StatefulWidget{
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {

  double x = 0, y = 0, z = 0;
  int classPred = 0;
  String direction = "none";
  int maxLen = 50;
  var input = List<double>.filled(150, 0).reshape([1, 50, 3]);

  // initialize FPS
  double fpsValue = 0.0;
  int count = 0;
  double timer = 0.0;
  double smoothing = 10;
  double val = 0.0;

  final _modelFile = 'model.tflite';

  // TensorFlow Lite Interpreter object
  late Interpreter _interpreter;

  void _loadModel() async {
    // Creating the interpreter using Interpreter.fromAsset
    _interpreter = await Interpreter.fromAsset(_modelFile);
    print('Interpreter loaded successfully');
  }

  @override
  void initState() {
    // load model
    _loadModel();

    // to track FPS
    Stopwatch stopwatch = Stopwatch()..start();

    //gyroscopeEvents.listen((GyroscopeEvent event) {
    accelerometerEvents.listen((AccelerometerEvent event) {
      // update counter - relevant for FPS counter
      count++;

      // get coordinates
      x = event.x;
      y = event.y;
      z = event.z;

      // add accelerator data to tensor and remove oldest sample
      input[0].insert(0, [x, y, z]);
      input[0].removeAt(maxLen);

      // if output tensor shape [1,2] and type is float32
      //var output = List.filled(1 * 2, 0).reshape([1, 2]);
      var output = List<double>.filled(20, 0).reshape([1, 20]);

      // The run method will run inference and
      // store the resulting values in output.
      _interpreter.run(input, output);

      classPred = argmax(output[0]);

      // exponential weighted moving average
      fpsValue += (1.0 / (stopwatch.elapsedMilliseconds / 1000) - fpsValue) /
          min(count, smoothing);

      // reset stopwatch
      stopwatch.reset();

      // notify the framework that the internal state of this object has changed.
      setState(() {
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return  Scaffold(
      appBar: AppBar(
        title: const Text("DSWS: Demo app"),
        backgroundColor: Colors.redAccent,
      ),
      body: Container(
          alignment: Alignment.center,
          padding: const EdgeInsets.all(30),
          child: Column(
              children:[
                const Text("Accelerometer data:", style: TextStyle(fontSize: 30),),
                Text("x: " + x.toStringAsFixed(4), style: const TextStyle(fontSize: 30),),
                Text("y: " + y.toStringAsFixed(4), style: const TextStyle(fontSize: 30),),
                Text("z: " + z.toStringAsFixed(4), style: const TextStyle(fontSize: 30),),
                Text("\nClass pred: " + classPred.toString(), style: const TextStyle(fontSize: 30),),
                Text("\nFPS: " + fpsValue.toStringAsFixed(1), style: const TextStyle(fontSize: 30),),
              ]
          )
      ),
    );
  }
}