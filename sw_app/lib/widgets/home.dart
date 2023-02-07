import 'package:flutter/material.dart';
import 'data.dart';
import 'charts.dart';
import 'data_storage.dart';
import 'datarecording.dart';

class HomePage extends StatefulWidget {
  HomePage({key});

  @override
  _HomePageState createState() => new _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = new TabController(vsync: this, length: 5);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var style = TextStyle(fontSize: 35, color: Colors.white);

    return MaterialApp(
      home: DefaultTabController(
        length: 5,
        child: Scaffold(
          appBar: AppBar(
            bottom: TabBar(
              controller: _tabController,
              tabs: const [
                Tab(icon: Icon(Icons.home)),
                Tab(icon: Icon(Icons.sensors)),
                Tab(icon: Icon(Icons.show_chart_rounded)),
                Tab(icon: Icon(Icons.access_alarm)),
                Tab(icon: Icon(Icons.save_alt)),
              ],
            ),
            title: const Text('DSS: Demo app'),
            backgroundColor: Theme.of(context).colorScheme.secondary,
          ),
          body: TabBarView(
            controller: _tabController,
            children: [
              Container(
                  child: SingleChildScrollView(
                    child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                    SizedBox(
                      height: 150, //height of button
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          _tabController.animateTo(1);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(context).colorScheme.primary,
                        ),
                        child: Container(
                          child: RichText(
                              text: TextSpan(
                                text: 'Show AI Model\n ',
                                style: style,
                                children: const <TextSpan>[
                                  TextSpan(
                                      text:
                                          'Here the absolute values of the accelerometer in x, y and z direction can be found, as well as the predicted class und FPS rate',
                                      style: TextStyle(
                                          fontSize: 15, color: Colors.white)),
                                ],
                              ),
                              textAlign: TextAlign.center),
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 20,
                      width: 20,
                    ),
                    SizedBox(
                      height: 150, //height of button
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          _tabController.animateTo(2);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(context).colorScheme.primary,
                        ),
                        child: Container(
                          child: RichText(
                              text: TextSpan(
                                text: 'Visualize Data\n ',
                                style: style,
                                children: const <TextSpan>[
                                  TextSpan(
                                      text:
                                          'Here a real-time chart of the accelerometer values in x, y and z direction, as well as the FPS rate, can be found.',
                                      style: TextStyle(
                                          fontSize: 15, color: Colors.white)),
                                ],
                              ),
                              textAlign: TextAlign.center),
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 20,
                      width: 20,
                    ),
                    SizedBox(
                      height: 150, //height of button
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          _tabController.animateTo(3);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(context).colorScheme.primary,
                        ),
                        child: Container(
                          child: RichText(
                              text: TextSpan(
                                text: 'Record Data\n ',
                                style: style,
                                children: const <TextSpan>[
                                  TextSpan(
                                      text:
                                          'Here the accelerometer data can be recorded and afterward sent to a server ',
                                      style: TextStyle(
                                          fontSize: 15, color: Colors.white)),
                                ],
                              ),
                              textAlign: TextAlign.center),
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 20,
                      width: 20,
                    ),
                    SizedBox(
                      height: 150, //height of button
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          _tabController.animateTo(4);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(context).colorScheme.primary,
                        ),
                        child: Container(
                          child: RichText(
                              text: TextSpan(
                                text: 'Data Overview\n ',
                                style: style,
                                children: const <TextSpan>[
                                  TextSpan(
                                      text:
                                          'Here the different recordings are stored and can be deleted.',
                                      style: TextStyle(
                                          fontSize: 15, color: Colors.white)),
                                ],
                              ),
                              textAlign: TextAlign.center),
                        ),
                      ),
                    ),
                ],
              ),
                  )),
              const DataStream(),
              const Charts(),
              DataRecordingPage(),
              RecordingStoragePage(),
            ],
          ),
        ),
      ),
    );
  }
}
