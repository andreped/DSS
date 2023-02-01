import 'package:flutter/material.dart';
import 'data.dart';
import 'charts.dart';
import 'datarecording.dart';


class Home extends StatelessWidget {
  const Home({key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: DefaultTabController(
        length: 3,
        child: Scaffold(
          appBar: AppBar(
            bottom: const TabBar(
              tabs: [
                Tab(icon: Icon(Icons.sensors)),
                Tab(icon: Icon(Icons.show_chart_rounded)),
                Tab(icon: Icon(Icons.access_alarm)),
              ],
            ),
            title: const Text('DSS: Demo app'),
            backgroundColor: Colors.redAccent,
          ),
          body:  TabBarView(
            children: [
              const DataStream(),
              const Charts(),
              DataRecordingPage(),
            ],
          ),
        ),
      ),
    );
  }
}

