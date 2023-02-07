import 'package:flutter/material.dart';
import 'package:sw_app/widgets/recording_database.dart';
import 'package:sw_app/widgets/recording_model.dart';
import 'package:intl/intl.dart';

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

    return SingleChildScrollView(
      //physics: AlwaysScrollableScrollPhysics(),
      primary: false,
      child: Column(
        children: [
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
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Text('Recorded Data', textAlign: TextAlign.center, style: style),
                ElevatedButton.icon(
                  onPressed: () async {
                    await RecordingDatabase.instance.deleteDatabase();
                    setState(() {});
                  },
                  label: Text('Delete all'),
                  icon: Icon(Icons.delete),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                ),
              ],
            ),
          ),
          const SizedBox(
            height: 20,
            width: 20,
          ),
          FutureBuilder<List<RecordingList>?>(
            future: RecordingDatabase.instance.readRecordingList(),
            builder: (context, AsyncSnapshot<List<RecordingList>?> snapshot) {
              if (snapshot.hasError) {
                return Center(child: Text(snapshot.error.toString()));
              }
              if (snapshot.data != null) {
                return ListView.builder(
                  physics: NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  itemCount: snapshot.data?.length,
                  itemBuilder: (context, index) {
                    final item = snapshot.data![index];
                    return ListTile(
                      leading: Icon(Icons.edgesensor_high),
                      title: Text(
                          '''Start time: ${DateFormat('dd-MM-yyyy- – kk:mm').format(item.timeStamp)}
                            Duration: ${item.duration} sec'''),
                      trailing: IconButton(
                          onPressed: () {
                            RecordingDatabase.instance.delete(item.id);
                            setState(() {});
                          },
                          icon: Icon(Icons.delete)),
                    );
                  },
                );
              } else {
                return Container(
                    height: 300,
                    child: const Center(
                      child: Text(
                        'No recordings yet',
                        style: TextStyle(fontSize: 20),
                      ),
                    ));
              }
            },
          ),
        ],
      ),
    );
  }
}
