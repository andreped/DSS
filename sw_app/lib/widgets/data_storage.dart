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

    return Column(
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
          child:
              Text('Recorded Data', textAlign: TextAlign.center, style: style),
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
            } else if (snapshot.hasData) {
              if (snapshot.data != null) {
                return Container(
                  child: ListView.builder(
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
                  ),
                );
              }
              return const Center(
                child: Text('No recordings yet'),
              );
            }
            return const SizedBox.shrink();
          },
        ),
        ElevatedButton(
            onPressed: () async {
              await RecordingDatabase.instance.deleteDatabase();
              setState(() {

              });
            },
            style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                padding: EdgeInsets.symmetric(horizontal: 50, vertical: 20),
                textStyle:
                    TextStyle(fontSize: 30, fontWeight: FontWeight.bold)),
            child: Text('Delete Database'))
      ],
    );
  }
}
