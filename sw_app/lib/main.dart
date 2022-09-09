import 'dart:async';
import 'package:flutter/material.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:tflite_flutter/tflite_flutter.dart';


Future<void> main() async {
  runApp(MyApp());
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
  int class_pred = 0;
  String direction = "none";
  int maxlen = 50;
  int nb_features = 3;
  var input = List<double>.filled(150, 0).reshape([1, 50, 3]);

  final _modelFile = 'model.tflite';

  // TensorFlow Lite Interpreter object
  late Interpreter _interpreter;

  void _loadModel() async {
    // Creating the interpreter using Interpreter.fromAsset
    _interpreter = await Interpreter.fromAsset(_modelFile);
    print('Interpreter loaded successfully');
  }

  int argmax(List<dynamic> X) {
    int idx = 0;
    int l = X.length;
    for (int i = 0; i < l; i++) {
      idx = X[i] > X[idx] ? i : idx;
    }
    return idx;
  }

  @override
  void initState() {
    // load model
    _loadModel();

    //gyroscopeEvents.listen((GyroscopeEvent event) {
    accelerometerEvents.listen((AccelerometerEvent event) {
      // print(event);

      x = event.x;
      y = event.y;
      z = event.z;

      // add accelerator data to tensor and remove oldest sample
      input[0].insert(0, [x, y, z]);
      input[0].removeAt(maxlen);

      // if output tensor shape [1,2] and type is float32
      //var output = List.filled(1 * 2, 0).reshape([1, 2]);
      var output = List<double>.filled(20, 0).reshape([1, 20]);

      // The run method will run inference and
      // store the resulting values in output.
      _interpreter.run(input, output);

      class_pred = argmax(output[0]);

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
                Text("x: " + x.toString(), style: const TextStyle(fontSize: 30),),
                Text("y: " + y.toString(), style: const TextStyle(fontSize: 30),),
                Text("z: " + z.toString(), style: const TextStyle(fontSize: 30),),
                Text("\nClass pred: " + class_pred.toString(), style: const TextStyle(fontSize: 30),),
              ]
          )
      ),

    );
  }
}