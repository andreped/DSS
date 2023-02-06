import 'package:flutter/material.dart';
import 'package:sw_app/widgets/recording_database.dart';
import 'package:sw_app/widgets/recording_model.dart';

class RecordingStoragePage extends StatefulWidget {
  @override
  _RecordingStoragePageState createState() => _RecordingStoragePageState();
}

class _RecordingStoragePageState extends State<RecordingStoragePage> {
  late List<RecordingList> recordingList;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();

    refreshNotes();
  }

  @override
  void dispose() {
    RecordingDatabase.instance.close();

    super.dispose();
  }

  Future refreshNotes() async {
    setState(() => isLoading = true);

    this.recordingList =
        (await RecordingDatabase.instance.readRecordingList())!;

    setState(() => isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    var style = theme.textTheme.displaySmall!.copyWith(fontSize: 30);

    return Scaffold(
        body: Center(
      child: Padding(
        padding: const EdgeInsets.all(14.0),
        child: Column(
          children: <Widget>[
            const SizedBox(
              height: 20,
              width: 20,
            ),
            Container(
              //alignment: Alignment.center,
              //padding: const EdgeInsets.all(30),
              width: 380,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text('Recorded Data',
                  textAlign: TextAlign.center, style: style),
            ),
            const SizedBox(
              height: 20,
              width: 20,
            ),
            ElevatedButton(
                onPressed: () async {
                  await RecordingDatabase.instance.deleteDatabase();
                },
                child: Text('Delete Database'))
          ],
        ),
      ),
    ));
  }
}
