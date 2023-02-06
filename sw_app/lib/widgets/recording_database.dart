import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sw_app/widgets/recording_model.dart';

var version = 1;

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

    return await openDatabase(path, version: version, onCreate: _createDB);
  }

  Future _createDB(Database db, int version) async {
    final idType = 'INTEGER PRIMARY KEY AUTOINCREMENT';
    final textType = 'TEXT  NOT NULL ';
    final integerType = 'INTEGER NOT NULL ';

    await db.execute('''
CREATE TABLE $tableRecordings ( 
  ${RecordingFields.id} $idType, 
  ${RecordingFields.listId} $integerType,
  ${RecordingFields.timeStamp} $textType,
  ${RecordingFields.xAccel} $integerType,
  ${RecordingFields.yAccel} $integerType,
  ${RecordingFields.zAccel} $integerType
  )''');

    await db.execute('''
 CREATE TABLE $tableRecordingsList ( 
  ${RecordingListFields.id} $idType, 
  ${RecordingListFields.timeStamp} $textType,
  ${RecordingListFields.duration} $integerType
  )''');
  }

  Future<Recording> create(Recording recording) async {
    final db = await instance.database;

    final id = await db.insert(tableRecordings, recording.toJson());
    return recording.copy(id: id);
  }

  Future<RecordingList> createList(RecordingList recordingList) async {
    final db = await instance.database;

    final id = await db.insert(tableRecordingsList, recordingList.toJson());
    return recordingList.copy(id: id);
  }

  Future<RecordingList> updateList(
      RecordingList recordingList, DateTime time) async {
    final db = await instance.database;

    final id = await db.insert(tableRecordingsList, recordingList.toJson());
    return recordingList.copy(id: id);
  }

  Future<List<Recording>> readRecording(int id) async {
    final db = await instance.database;
    final orderBy = '${RecordingFields.timeStamp} ASC';

    final maps = await db.query(
      tableRecordings,
      columns: RecordingFields.values,
      orderBy: orderBy,
      where: '${RecordingFields.listId} = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return maps.map((json) => Recording.fromJson(json)).toList();
    } else {
      throw Exception('No recording with ID $id found');
    }
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

    if (result.isNotEmpty) {
      int last = result.last['_id'] as int;
      return last;
    } else {
      return 0;
    }
  }

  // Future<int> update(Recording note) async {
  //   final db = await instance.database;
  //
  //   return db.update(
  //     tableNotes,
  //     note.toJson(),
  //     where: '${NoteFields.id} = ?',
  //     whereArgs: [note.id],
  //   );
  // }

  Future<int> delete(int id) async {
    final db = await instance.database;

    return await db.delete(
      tableRecordingsList,
      where: '${RecordingListFields.id} = ?',
      whereArgs: [id],
    );
  }

  Future close() async {
    final db = await instance.database;

    db.close();
  }

//TODO implement delete button for whole data base but still be able to record data afterwards without reopening the app
  Future<void> deleteDatabase() async {
    var db = await instance.database;

    await db.delete(tableRecordingsList);
    await db.delete(tableRecordings);
  }
}
