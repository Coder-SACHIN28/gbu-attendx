// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'hive_models.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class AttendanceRecordAdapter extends TypeAdapter<AttendanceRecord> {
  @override
  final int typeId = 0;

  @override
  AttendanceRecord read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return AttendanceRecord(
      id: fields[0] as String,
      studentId: fields[1] as String,
      classId: fields[2] as String,
      subjectId: fields[3] as String,
      timestamp: fields[4] as DateTime,
      status: fields[5] as AttendanceStatus,
      biometricSignature: fields[6] as String?,
      faceRecognitionData: fields[7] as String?,
      locationData: fields[8] as String?,
      isSynced: fields[9] as bool,
      createdAt: fields[10] as DateTime,
      syncedAt: fields[11] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, AttendanceRecord obj) {
    writer
      ..writeByte(12)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.studentId)
      ..writeByte(2)
      ..write(obj.classId)
      ..writeByte(3)
      ..write(obj.subjectId)
      ..writeByte(4)
      ..write(obj.timestamp)
      ..writeByte(5)
      ..write(obj.status)
      ..writeByte(6)
      ..write(obj.biometricSignature)
      ..writeByte(7)
      ..write(obj.faceRecognitionData)
      ..writeByte(8)
      ..write(obj.locationData)
      ..writeByte(9)
      ..write(obj.isSynced)
      ..writeByte(10)
      ..write(obj.createdAt)
      ..writeByte(11)
      ..write(obj.syncedAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AttendanceRecordAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class TimetableEntryAdapter extends TypeAdapter<TimetableEntry> {
  @override
  final int typeId = 1;

  @override
  TimetableEntry read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return TimetableEntry(
      id: fields[0] as String,
      classId: fields[1] as String,
      subjectId: fields[2] as String,
      subjectName: fields[3] as String,
      teacherId: fields[4] as String,
      teacherName: fields[5] as String,
      room: fields[6] as String,
      dayOfWeek: fields[7] as int,
      startTime: fields[8] as TimeSlot,
      endTime: fields[9] as TimeSlot,
      description: fields[10] as String?,
      isActive: fields[11] as bool,
      createdAt: fields[12] as DateTime,
      updatedAt: fields[13] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, TimetableEntry obj) {
    writer
      ..writeByte(14)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.classId)
      ..writeByte(2)
      ..write(obj.subjectId)
      ..writeByte(3)
      ..write(obj.subjectName)
      ..writeByte(4)
      ..write(obj.teacherId)
      ..writeByte(5)
      ..write(obj.teacherName)
      ..writeByte(6)
      ..write(obj.room)
      ..writeByte(7)
      ..write(obj.dayOfWeek)
      ..writeByte(8)
      ..write(obj.startTime)
      ..writeByte(9)
      ..write(obj.endTime)
      ..writeByte(10)
      ..write(obj.description)
      ..writeByte(11)
      ..write(obj.isActive)
      ..writeByte(12)
      ..write(obj.createdAt)
      ..writeByte(13)
      ..write(obj.updatedAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TimetableEntryAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class TimeSlotAdapter extends TypeAdapter<TimeSlot> {
  @override
  final int typeId = 2;

  @override
  TimeSlot read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return TimeSlot(
      hour: fields[0] as int,
      minute: fields[1] as int,
    );
  }

  @override
  void write(BinaryWriter writer, TimeSlot obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.hour)
      ..writeByte(1)
      ..write(obj.minute);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TimeSlotAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class StudentProfileAdapter extends TypeAdapter<StudentProfile> {
  @override
  final int typeId = 3;

  @override
  StudentProfile read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return StudentProfile(
      id: fields[0] as String,
      name: fields[1] as String,
      email: fields[2] as String,
      rollNumber: fields[3] as String,
      classId: fields[4] as String,
      className: fields[5] as String,
      photoUrl: fields[6] as String?,
      phoneNumber: fields[7] as String?,
      isActive: fields[8] as bool,
      createdAt: fields[9] as DateTime,
      updatedAt: fields[10] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, StudentProfile obj) {
    writer
      ..writeByte(11)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.email)
      ..writeByte(3)
      ..write(obj.rollNumber)
      ..writeByte(4)
      ..write(obj.classId)
      ..writeByte(5)
      ..write(obj.className)
      ..writeByte(6)
      ..write(obj.photoUrl)
      ..writeByte(7)
      ..write(obj.phoneNumber)
      ..writeByte(8)
      ..write(obj.isActive)
      ..writeByte(9)
      ..write(obj.createdAt)
      ..writeByte(10)
      ..write(obj.updatedAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is StudentProfileAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class ClassScheduleAdapter extends TypeAdapter<ClassSchedule> {
  @override
  final int typeId = 4;

  @override
  ClassSchedule read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ClassSchedule(
      id: fields[0] as String,
      classId: fields[1] as String,
      className: fields[2] as String,
      timetable: (fields[3] as List).cast<TimetableEntry>(),
      createdAt: fields[4] as DateTime,
      updatedAt: fields[5] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, ClassSchedule obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.classId)
      ..writeByte(2)
      ..write(obj.className)
      ..writeByte(3)
      ..write(obj.timetable)
      ..writeByte(4)
      ..write(obj.createdAt)
      ..writeByte(5)
      ..write(obj.updatedAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ClassScheduleAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class AttendanceSummaryAdapter extends TypeAdapter<AttendanceSummary> {
  @override
  final int typeId = 6;

  @override
  AttendanceSummary read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return AttendanceSummary(
      studentId: fields[0] as String,
      subjectId: fields[1] as String,
      totalClasses: fields[2] as int,
      attendedClasses: fields[3] as int,
      lateClasses: fields[4] as int,
      excusedClasses: fields[5] as int,
      attendancePercentage: fields[6] as double,
      lastUpdated: fields[7] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, AttendanceSummary obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.studentId)
      ..writeByte(1)
      ..write(obj.subjectId)
      ..writeByte(2)
      ..write(obj.totalClasses)
      ..writeByte(3)
      ..write(obj.attendedClasses)
      ..writeByte(4)
      ..write(obj.lateClasses)
      ..writeByte(5)
      ..write(obj.excusedClasses)
      ..writeByte(6)
      ..write(obj.attendancePercentage)
      ..writeByte(7)
      ..write(obj.lastUpdated);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AttendanceSummaryAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class AttendanceStatusAdapter extends TypeAdapter<AttendanceStatus> {
  @override
  final int typeId = 5;

  @override
  AttendanceStatus read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return AttendanceStatus.present;
      case 1:
        return AttendanceStatus.absent;
      case 2:
        return AttendanceStatus.late;
      case 3:
        return AttendanceStatus.excused;
      default:
        return AttendanceStatus.present;
    }
  }

  @override
  void write(BinaryWriter writer, AttendanceStatus obj) {
    switch (obj) {
      case AttendanceStatus.present:
        writer.writeByte(0);
        break;
      case AttendanceStatus.absent:
        writer.writeByte(1);
        break;
      case AttendanceStatus.late:
        writer.writeByte(2);
        break;
      case AttendanceStatus.excused:
        writer.writeByte(3);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AttendanceStatusAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AttendanceRecord _$AttendanceRecordFromJson(Map<String, dynamic> json) =>
    AttendanceRecord(
      id: json['id'] as String,
      studentId: json['studentId'] as String,
      classId: json['classId'] as String,
      subjectId: json['subjectId'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      status: $enumDecode(_$AttendanceStatusEnumMap, json['status']),
      biometricSignature: json['biometricSignature'] as String?,
      faceRecognitionData: json['faceRecognitionData'] as String?,
      locationData: json['locationData'] as String?,
      isSynced: json['isSynced'] as bool? ?? false,
      createdAt: DateTime.parse(json['createdAt'] as String),
      syncedAt: json['syncedAt'] == null
          ? null
          : DateTime.parse(json['syncedAt'] as String),
    );

Map<String, dynamic> _$AttendanceRecordToJson(AttendanceRecord instance) =>
    <String, dynamic>{
      'id': instance.id,
      'studentId': instance.studentId,
      'classId': instance.classId,
      'subjectId': instance.subjectId,
      'timestamp': instance.timestamp.toIso8601String(),
      'status': _$AttendanceStatusEnumMap[instance.status]!,
      'biometricSignature': instance.biometricSignature,
      'faceRecognitionData': instance.faceRecognitionData,
      'locationData': instance.locationData,
      'isSynced': instance.isSynced,
      'createdAt': instance.createdAt.toIso8601String(),
      'syncedAt': instance.syncedAt?.toIso8601String(),
    };

const _$AttendanceStatusEnumMap = {
  AttendanceStatus.present: 'present',
  AttendanceStatus.absent: 'absent',
  AttendanceStatus.late: 'late',
  AttendanceStatus.excused: 'excused',
};

TimetableEntry _$TimetableEntryFromJson(Map<String, dynamic> json) =>
    TimetableEntry(
      id: json['id'] as String,
      classId: json['classId'] as String,
      subjectId: json['subjectId'] as String,
      subjectName: json['subjectName'] as String,
      teacherId: json['teacherId'] as String,
      teacherName: json['teacherName'] as String,
      room: json['room'] as String,
      dayOfWeek: (json['dayOfWeek'] as num).toInt(),
      startTime: TimeSlot.fromJson(json['startTime'] as Map<String, dynamic>),
      endTime: TimeSlot.fromJson(json['endTime'] as Map<String, dynamic>),
      description: json['description'] as String?,
      isActive: json['isActive'] as bool? ?? true,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] == null
          ? null
          : DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$TimetableEntryToJson(TimetableEntry instance) =>
    <String, dynamic>{
      'id': instance.id,
      'classId': instance.classId,
      'subjectId': instance.subjectId,
      'subjectName': instance.subjectName,
      'teacherId': instance.teacherId,
      'teacherName': instance.teacherName,
      'room': instance.room,
      'dayOfWeek': instance.dayOfWeek,
      'startTime': instance.startTime,
      'endTime': instance.endTime,
      'description': instance.description,
      'isActive': instance.isActive,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt?.toIso8601String(),
    };

TimeSlot _$TimeSlotFromJson(Map<String, dynamic> json) => TimeSlot(
      hour: (json['hour'] as num).toInt(),
      minute: (json['minute'] as num).toInt(),
    );

Map<String, dynamic> _$TimeSlotToJson(TimeSlot instance) => <String, dynamic>{
      'hour': instance.hour,
      'minute': instance.minute,
    };

StudentProfile _$StudentProfileFromJson(Map<String, dynamic> json) =>
    StudentProfile(
      id: json['id'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
      rollNumber: json['rollNumber'] as String,
      classId: json['classId'] as String,
      className: json['className'] as String,
      photoUrl: json['photoUrl'] as String?,
      phoneNumber: json['phoneNumber'] as String?,
      isActive: json['isActive'] as bool? ?? true,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] == null
          ? null
          : DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$StudentProfileToJson(StudentProfile instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'email': instance.email,
      'rollNumber': instance.rollNumber,
      'classId': instance.classId,
      'className': instance.className,
      'photoUrl': instance.photoUrl,
      'phoneNumber': instance.phoneNumber,
      'isActive': instance.isActive,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt?.toIso8601String(),
    };

ClassSchedule _$ClassScheduleFromJson(Map<String, dynamic> json) =>
    ClassSchedule(
      id: json['id'] as String,
      classId: json['classId'] as String,
      className: json['className'] as String,
      timetable: (json['timetable'] as List<dynamic>)
          .map((e) => TimetableEntry.fromJson(e as Map<String, dynamic>))
          .toList(),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] == null
          ? null
          : DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$ClassScheduleToJson(ClassSchedule instance) =>
    <String, dynamic>{
      'id': instance.id,
      'classId': instance.classId,
      'className': instance.className,
      'timetable': instance.timetable,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt?.toIso8601String(),
    };

AttendanceSummary _$AttendanceSummaryFromJson(Map<String, dynamic> json) =>
    AttendanceSummary(
      studentId: json['studentId'] as String,
      subjectId: json['subjectId'] as String,
      totalClasses: (json['totalClasses'] as num).toInt(),
      attendedClasses: (json['attendedClasses'] as num).toInt(),
      lateClasses: (json['lateClasses'] as num).toInt(),
      excusedClasses: (json['excusedClasses'] as num).toInt(),
      attendancePercentage: (json['attendancePercentage'] as num).toDouble(),
      lastUpdated: DateTime.parse(json['lastUpdated'] as String),
    );

Map<String, dynamic> _$AttendanceSummaryToJson(AttendanceSummary instance) =>
    <String, dynamic>{
      'studentId': instance.studentId,
      'subjectId': instance.subjectId,
      'totalClasses': instance.totalClasses,
      'attendedClasses': instance.attendedClasses,
      'lateClasses': instance.lateClasses,
      'excusedClasses': instance.excusedClasses,
      'attendancePercentage': instance.attendancePercentage,
      'lastUpdated': instance.lastUpdated.toIso8601String(),
    };
