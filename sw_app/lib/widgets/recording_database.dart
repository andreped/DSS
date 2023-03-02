import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sw_app/widgets/recording_model.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';


class RecordingDatabase {
  static late final RecordingDatabase instance = RecordingDatabase._init();

  static Database? _database;

  RecordingDatabase._init();

  Future<Database> get database async {
    if (_database != null) return _database!;

    _database = await _initDB('recordings.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future _createDB(Database db, int version) async {
    final idType = 'INTEGER PRIMARY KEY AUTOINCREMENT';
    final textType = 'TEXT  NOT NULL ';
    final integerType = 'INTEGER NOT NULL ';


    await db.execute('''
 CREATE TABLE $tableRecordingsList ( 
  ${RecordingListFields.id} $idType, 
  ${RecordingListFields.timeStamp} $textType,
  ${RecordingListFields.duration} $integerType
  )''');
  }


  Future<RecordingList> createList(RecordingList recordingList) async {
    final db = await instance.database;

    final id = await db.insert(tableRecordingsList, recordingList.toJson());
    return recordingList.copy(id: id);
  }

  Future<void> update() async {
    // Get a reference to the database.
    final db = await database;

    final orderBy = '${RecordingListFields.timeStamp} ASC';
    final result = await db.query(tableRecordingsList, orderBy: orderBy);

    var last = RecordingList.fromJson(result.last);

    var duration = DateTime.now().difference(last.timeStamp).inSeconds;
    var recordingList = RecordingList(
        id: last.id, timeStamp: last.timeStamp, duration: duration);

    await db.update(
      tableRecordingsList,
      recordingList.toJson(),
      where: "${RecordingListFields.id} = ?",
      whereArgs: [last.id],
    );
  }

  Future<List<RecordingList>?> readRecordingList() async {
    final db = await instance.database;
    final orderBy = '${RecordingListFields.timeStamp} ASC';

    final result = await db.query(tableRecordingsList, orderBy: orderBy);

    if (result.isNotEmpty) {
      return result.map((json) => RecordingList.fromJson(json)).toList();
    } else {
      return null;
    }
  }

  Future<int> getLatestListId() async {
    final db = await instance.database;
    final orderBy = '${RecordingListFields.timeStamp} ASC';

    final result = await db.query(tableRecordingsList, orderBy: orderBy);

    int last = result.last['_id'] as int;
    return last;
  }

  Future<void> delete(int? id) async {
    final db = await instance.database;

    await db.delete(
      tableRecordingsList,
      where: '${RecordingListFields.id} = ?',
      whereArgs: [id],
    );

    Directory? appDocDir = await getExternalStorageDirectory();
    var appDocPath = appDocDir?.path;


    File f = File("$appDocPath/$id.csv");
    await f.delete();
  }

  Future close() async {
    final db = await instance.database;

    db.close();
  }

  Future<void> deleteDatabase() async {
    var db = await instance.database;

    await db.delete(tableRecordingsList);
    Directory? appDocDir = await getExternalStorageDirectory();

    appDocDir?.list(recursive: true).listen((file) {
      if (file is File && file.path.endsWith('.csv')) file.deleteSync();
    });


  }
}
