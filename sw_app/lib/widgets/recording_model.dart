final String tableRecordings = 'recordings';
final String tableRecordingsList = 'recordingsList';

class RecordingFields {
  static final List<String> values = [
    /// Add all fields
    id, listId, timeStamp, xAccel, yAccel, zAccel,
  ];

  static final String id = '_id';
  static final String listId = 'listId';
  static final String timeStamp = 'timeStamp';
  static final String xAccel = 'xAccel';
  static final String yAccel = 'yAccel';
  static final String zAccel = 'zAccel';
}

class Recording {
  final int? id;
  final int listId;
  final DateTime timeStamp;
  final double xAccel;
  final double yAccel;
  final double zAccel;

  const Recording({
    this.id,
    required this.listId,
    required this.timeStamp,
    required this.xAccel,
    required this.yAccel,
    required this.zAccel,
  });

  Recording copy({
    int? id,
    int? listId,
    DateTime? timeStamp,
    double? xAccel,
    double? yAccel,
    double? zAccel,
  }) =>
      Recording(
        id: id ?? this.id,
        listId: listId ?? this.listId,
        timeStamp: timeStamp ?? this.timeStamp,
        xAccel: xAccel ?? this.xAccel,
        yAccel: yAccel ?? this.yAccel,
        zAccel: zAccel ?? this.zAccel,
      );

  static Recording fromJson(Map<String, Object?> json) => Recording(
        id: json[RecordingFields.id] as int?,
        listId: json[RecordingFields.listId] as int,
        timeStamp: DateTime.parse(json[RecordingFields.timeStamp] as String),
        xAccel: json[RecordingFields.xAccel] as double,
        yAccel: json[RecordingFields.yAccel] as double,
        zAccel: json[RecordingFields.zAccel] as double,
      );

  Map<String, Object?> toJson() => {
        RecordingFields.id: id,
        RecordingFields.listId: listId,
        RecordingFields.timeStamp: timeStamp.toIso8601String(),
        RecordingFields.xAccel: xAccel,
        RecordingFields.yAccel: yAccel,
        RecordingFields.zAccel: zAccel,
      };
}

class RecordingListFields {
  static final List<String> values = [
    /// Add all fields
    id, timeStamp, duration
  ];

  static final String id = '_id';
  static final String timeStamp = 'timeStamp';
  static final String duration = 'duration';
}

class RecordingList {
  final int? id;
  final DateTime timeStamp;
  int duration;

  RecordingList({
    this.id,
    required this.timeStamp,
    required this.duration,
  });

  RecordingList copy({
    int? id,
    DateTime? timeStamp,
    int? duration,
  }) =>
      RecordingList(
        id: id ?? this.id,
        timeStamp: timeStamp ?? this.timeStamp,
        duration: duration ?? this.duration,
      );

  static RecordingList fromJson(Map<String, Object?> json) => RecordingList(
        id: json[RecordingListFields.id] as int?,
        timeStamp:
            DateTime.parse(json[RecordingListFields.timeStamp] as String),
        duration: json[RecordingListFields.duration] as int,
      );

  Map<String, Object?> toJson() => {
        RecordingListFields.id: id,
        RecordingListFields.timeStamp: timeStamp.toIso8601String(),
        RecordingListFields.duration: duration,
      };
}
