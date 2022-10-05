import 'package:flutter/material.dart';
import 'data.dart';
import 'charts.dart';

void main() {
  runApp(const Home());
}

class Home extends StatelessWidget {
  const Home({key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: DefaultTabController(
        length: 2,
        child: Scaffold(
          appBar: AppBar(
            bottom: const TabBar(
              tabs: [
                Tab(icon: Icon(Icons.sensors)),
                Tab(icon: Icon(Icons.show_chart_rounded)),
              ],
            ),
            title: const Text('DSS: Demo app'),
            backgroundColor: Colors.redAccent,
          ),
          body: const TabBarView(
            children: [
              DataStream(), //Icon(Icons.sensors),
              //Icon(Icons.sensors),
              Charts(), //Icon(Icons.show_chart_rounded),
              //Icon(Icons.show_chart_rounded),
            ],
          ),
        ),
      ),
    );
  }
}