import 'package:hive/hive.dart';
import 'package:json_annotation/json_annotation.dart';

part 'hive_models.g.dart';

@HiveType(typeId: 0)
@JsonSerializable()
class AttendanceRecord extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String studentId;

  @HiveField(2)
  final String classId;

  @HiveField(3)
  final String subjectId;

  @HiveField(4)
  final DateTime timestamp;

  @HiveField(5)
  final AttendanceStatus status;

  @HiveField(6)
  final String? biometricSignature;

  @HiveField(7)
  final String? faceRecognitionData;

  @HiveField(8)
  final String? locationData;

  @HiveField(9)
  final bool isSynced;

  @HiveField(10)
  final DateTime createdAt;

  @HiveField(11)
  final DateTime? syncedAt;

  AttendanceRecord({
    required this.id,
    required this.studentId,
    required this.classId,
    required this.subjectId,
    required this.timestamp,
    required this.status,
    this.biometricSignature,
    this.faceRecognitionData,
    this.locationData,
    this.isSynced = false,
    required this.createdAt,
    this.syncedAt,
  });

  factory AttendanceRecord.fromJson(Map<String, dynamic> json) =>
      _$AttendanceRecordFromJson(json);

  Map<String, dynamic> toJson() => _$AttendanceRecordToJson(this);

  AttendanceRecord copyWith({
    String? id,
    String? studentId,
    String? classId,
    String? subjectId,
    DateTime? timestamp,
    AttendanceStatus? status,
    String? biometricSignature,
    String? faceRecognitionData,
    String? locationData,
    bool? isSynced,
    DateTime? createdAt,
    DateTime? syncedAt,
  }) {
    return AttendanceRecord(
      id: id ?? this.id,
      studentId: studentId ?? this.studentId,
      classId: classId ?? this.classId,
      subjectId: subjectId ?? this.subjectId,
      timestamp: timestamp ?? this.timestamp,
      status: status ?? this.status,
      biometricSignature: biometricSignature ?? this.biometricSignature,
      faceRecognitionData: faceRecognitionData ?? this.faceRecognitionData,
      locationData: locationData ?? this.locationData,
      isSynced: isSynced ?? this.isSynced,
      createdAt: createdAt ?? this.createdAt,
      syncedAt: syncedAt ?? this.syncedAt,
    );
  }
}

@HiveType(typeId: 1)
@JsonSerializable()
class TimetableEntry extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String classId;

  @HiveField(2)
  final String subjectId;

  @HiveField(3)
  final String subjectName;

  @HiveField(4)
  final String teacherId;

  @HiveField(5)
  final String teacherName;

  @HiveField(6)
  final String room;

  @HiveField(7)
  final int dayOfWeek; // 1-7 (Monday-Sunday)

  @HiveField(8)
  final TimeSlot startTime;

  @HiveField(9)
  final TimeSlot endTime;

  @HiveField(10)
  final String? description;

  @HiveField(11)
  final bool isActive;

  @HiveField(12)
  final DateTime createdAt;

  @HiveField(13)
  final DateTime? updatedAt;

  TimetableEntry({
    required this.id,
    required this.classId,
    required this.subjectId,
    required this.subjectName,
    required this.teacherId,
    required this.teacherName,
    required this.room,
    required this.dayOfWeek,
    required this.startTime,
    required this.endTime,
    this.description,
    this.isActive = true,
    required this.createdAt,
    this.updatedAt,
  });

  factory TimetableEntry.fromJson(Map<String, dynamic> json) =>
      _$TimetableEntryFromJson(json);

  Map<String, dynamic> toJson() => _$TimetableEntryToJson(this);

  bool isCurrentlyActive() {
    final now = DateTime.now();
    final currentTime = TimeSlot(hour: now.hour, minute: now.minute);
    final currentDayOfWeek = now.weekday;

    return dayOfWeek == currentDayOfWeek &&
        currentTime.isAfter(startTime) &&
        currentTime.isBefore(endTime) &&
        isActive;
  }

  bool isWithinTimeWindow(int toleranceMinutes) {
    final now = DateTime.now();
    final currentTime = TimeSlot(hour: now.hour, minute: now.minute);
    final currentDayOfWeek = now.weekday;

    if (dayOfWeek != currentDayOfWeek || !isActive) return false;

    final startWithTolerance = startTime.subtractMinutes(toleranceMinutes);
    final endWithTolerance = endTime.addMinutes(toleranceMinutes);

    return currentTime.isAfter(startWithTolerance) &&
        currentTime.isBefore(endWithTolerance);
  }
}

@HiveType(typeId: 2)
@JsonSerializable()
class TimeSlot {
  @HiveField(0)
  final int hour;

  @HiveField(1)
  final int minute;

  TimeSlot({
    required this.hour,
    required this.minute,
  });

  factory TimeSlot.fromJson(Map<String, dynamic> json) =>
      _$TimeSlotFromJson(json);

  Map<String, dynamic> toJson() => _$TimeSlotToJson(this);

  bool isAfter(TimeSlot other) {
    return hour > other.hour || (hour == other.hour && minute > other.minute);
  }

  bool isBefore(TimeSlot other) {
    return hour < other.hour || (hour == other.hour && minute < other.minute);
  }

  TimeSlot addMinutes(int minutes) {
    int totalMinutes = hour * 60 + minute + minutes;
    return TimeSlot(
      hour: (totalMinutes ~/ 60) % 24,
      minute: totalMinutes % 60,
    );
  }

  TimeSlot subtractMinutes(int minutes) {
    int totalMinutes = hour * 60 + minute - minutes;
    if (totalMinutes < 0) totalMinutes += 24 * 60;
    return TimeSlot(
      hour: (totalMinutes ~/ 60) % 24,
      minute: totalMinutes % 60,
    );
  }

  String format24Hour() {
    return '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';
  }

  String format12Hour() {
    final period = hour >= 12 ? 'PM' : 'AM';
    final displayHour = hour == 0 ? 12 : (hour > 12 ? hour - 12 : hour);
    return '${displayHour.toString()}:${minute.toString().padLeft(2, '0')} $period';
  }
}

@HiveType(typeId: 3)
@JsonSerializable()
class StudentProfile extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final String email;

  @HiveField(3)
  final String rollNumber;

  @HiveField(4)
  final String classId;

  @HiveField(5)
  final String className;

  @HiveField(6)
  final String? photoUrl;

  @HiveField(7)
  final String? phoneNumber;

  @HiveField(8)
  final bool isActive;

  @HiveField(9)
  final DateTime createdAt;

  @HiveField(10)
  final DateTime? updatedAt;

  StudentProfile({
    required this.id,
    required this.name,
    required this.email,
    required this.rollNumber,
    required this.classId,
    required this.className,
    this.photoUrl,
    this.phoneNumber,
    this.isActive = true,
    required this.createdAt,
    this.updatedAt,
  });

  factory StudentProfile.fromJson(Map<String, dynamic> json) =>
      _$StudentProfileFromJson(json);

  Map<String, dynamic> toJson() => _$StudentProfileToJson(this);
}

@HiveType(typeId: 4)
@JsonSerializable()
class ClassSchedule extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String classId;

  @HiveField(2)
  final String className;

  @HiveField(3)
  final List<TimetableEntry> timetable;

  @HiveField(4)
  final DateTime createdAt;

  @HiveField(5)
  final DateTime? updatedAt;

  ClassSchedule({
    required this.id,
    required this.classId,
    required this.className,
    required this.timetable,
    required this.createdAt,
    this.updatedAt,
  });

  factory ClassSchedule.fromJson(Map<String, dynamic> json) =>
      _$ClassScheduleFromJson(json);

  Map<String, dynamic> toJson() => _$ClassScheduleToJson(this);

  List<TimetableEntry> getTodaySchedule() {
    final today = DateTime.now().weekday;
    return timetable.where((entry) => entry.dayOfWeek == today).toList();
  }

  TimetableEntry? getCurrentClass() {
    final today = DateTime.now().weekday;
    final todayClasses = timetable.where((entry) => entry.dayOfWeek == today);
    
    for (final entry in todayClasses) {
      if (entry.isCurrentlyActive()) {
        return entry;
      }
    }
    return null;
  }

  List<TimetableEntry> getActiveClassesWithTolerance(int toleranceMinutes) {
    final today = DateTime.now().weekday;
    return timetable
        .where((entry) => 
            entry.dayOfWeek == today && 
            entry.isWithinTimeWindow(toleranceMinutes))
        .toList();
  }
}

@HiveType(typeId: 5)
enum AttendanceStatus {
  @HiveField(0)
  present,

  @HiveField(1)
  absent,

  @HiveField(2)
  late,

  @HiveField(3)
  excused,
}

@HiveType(typeId: 6)
@JsonSerializable()
class AttendanceSummary extends HiveObject {
  @HiveField(0)
  final String studentId;

  @HiveField(1)
  final String subjectId;

  @HiveField(2)
  final int totalClasses;

  @HiveField(3)
  final int attendedClasses;

  @HiveField(4)
  final int lateClasses;

  @HiveField(5)
  final int excusedClasses;

  @HiveField(6)
  final double attendancePercentage;

  @HiveField(7)
  final DateTime lastUpdated;

  AttendanceSummary({
    required this.studentId,
    required this.subjectId,
    required this.totalClasses,
    required this.attendedClasses,
    required this.lateClasses,
    required this.excusedClasses,
    required this.attendancePercentage,
    required this.lastUpdated,
  });

  factory AttendanceSummary.fromJson(Map<String, dynamic> json) =>
      _$AttendanceSummaryFromJson(json);

  Map<String, dynamic> toJson() => _$AttendanceSummaryToJson(this);

  bool isAttendanceLow(double threshold) {
    return attendancePercentage < threshold;
  }
}