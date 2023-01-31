import 'dart:async';
import 'package:flutter/material.dart';
import 'widgets/home.dart';
import 'package:provider/provider.dart';

Future<void> main() async {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => MyAppState(),
      child: MaterialApp(
        title: 'Namer App',
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.lightGreenAccent),
        ),
        home: Home(),
      ),
    );
  }
}

class MyAppState extends ChangeNotifier {
  var isStarted = false;

  void startStopRecording() {
    isStarted = !isStarted;

    notifyListeners();

  }
}
