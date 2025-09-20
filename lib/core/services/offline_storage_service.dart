import 'package:hive_flutter/hive_flutter.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../constants/app_constants.dart';
import '../../data/models/hive_models.dart';

class OfflineStorageService {
  static final OfflineStorageService _instance = OfflineStorageService._internal();
  factory OfflineStorageService() => _instance;
  OfflineStorageService._internal();

  // Hive boxes
  Box<AttendanceRecord>? _attendanceBox;
  Box<TimetableEntry>? _timetableBox;
  Box<ClassSchedule>? _scheduleBox;
  Box<StudentProfile>? _studentBox;
  Box<AttendanceSummary>? _summaryBox;
  Box<dynamic>? _cacheBox;

  final Connectivity _connectivity = Connectivity();
  bool _isInitialized = false;

  /// Initialize offline storage
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      await Hive.initFlutter();

      // Register adapters
      _registerAdapters();

      // Open boxes
      await _openBoxes();

      _isInitialized = true;
    } catch (e) {
      throw Exception('Failed to initialize offline storage: $e');
    }
  }

  /// Register Hive adapters
  void _registerAdapters() {
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(AttendanceRecordAdapter());
    }
    if (!Hive.isAdapterRegistered(1)) {
      Hive.registerAdapter(TimetableEntryAdapter());
    }
    if (!Hive.isAdapterRegistered(2)) {
      Hive.registerAdapter(TimeSlotAdapter());
    }
    if (!Hive.isAdapterRegistered(3)) {
      Hive.registerAdapter(StudentProfileAdapter());
    }
    if (!Hive.isAdapterRegistered(4)) {
      Hive.registerAdapter(ClassScheduleAdapter());
    }
    if (!Hive.isAdapterRegistered(5)) {
      Hive.registerAdapter(AttendanceStatusAdapter());
    }
    if (!Hive.isAdapterRegistered(6)) {
      Hive.registerAdapter(AttendanceSummaryAdapter());
    }
  }

  /// Open Hive boxes
  Future<void> _openBoxes() async {
    _attendanceBox = await Hive.openBox<AttendanceRecord>('attendance');
    _timetableBox = await Hive.openBox<TimetableEntry>('timetable');
    _scheduleBox = await Hive.openBox<ClassSchedule>('schedules');
    _studentBox = await Hive.openBox<StudentProfile>('students');
    _summaryBox = await Hive.openBox<AttendanceSummary>('summaries');
    _cacheBox = await Hive.openBox<dynamic>('cache');
  }

  /// Check if device is online
  Future<bool> isOnline() async {
    try {
    final connectivityResults = await _connectivity.checkConnectivity();
    return !connectivityResults.contains(ConnectivityResult.none);
    } catch (e) {
      return false;
    }
  }

  // ATTENDANCE OPERATIONS

  /// Save attendance record offline
  Future<void> saveAttendanceRecord(AttendanceRecord record) async {
    await _ensureInitialized();
    await _attendanceBox!.put(record.id, record);
  }

  /// Get all unsynced attendance records
  Future<List<AttendanceRecord>> getUnsyncedAttendanceRecords() async {
    await _ensureInitialized();
    return _attendanceBox!.values
        .where((record) => !record.isSynced)
        .toList();
  }

  /// Get attendance records for a student
  Future<List<AttendanceRecord>> getAttendanceRecords(String studentId) async {
    await _ensureInitialized();
    return _attendanceBox!.values
        .where((record) => record.studentId == studentId)
        .toList();
  }

  /// Mark attendance record as synced
  Future<void> markAttendanceSynced(String recordId) async {
    await _ensureInitialized();
    final record = _attendanceBox!.get(recordId);
    if (record != null) {
      final updatedRecord = record.copyWith(
        isSynced: true,
        syncedAt: DateTime.now(),
      );
      await _attendanceBox!.put(recordId, updatedRecord);
    }
  }

  /// Delete attendance record
  Future<void> deleteAttendanceRecord(String recordId) async {
    await _ensureInitialized();
    await _attendanceBox!.delete(recordId);
  }

  // TIMETABLE OPERATIONS

  /// Save timetable entries
  Future<void> saveTimetableEntries(List<TimetableEntry> entries) async {
    await _ensureInitialized();
    for (final entry in entries) {
      await _timetableBox!.put(entry.id, entry);
    }
  }

  /// Get timetable for a class
  Future<List<TimetableEntry>> getTimetable(String classId) async {
    await _ensureInitialized();
    return _timetableBox!.values
        .where((entry) => entry.classId == classId && entry.isActive)
        .toList();
  }

  /// Get today's timetable
  Future<List<TimetableEntry>> getTodayTimetable(String classId) async {
    await _ensureInitialized();
    final today = DateTime.now().weekday;
    return _timetableBox!.values
        .where((entry) => 
            entry.classId == classId && 
            entry.dayOfWeek == today && 
            entry.isActive)
        .toList();
  }

  /// Get current active class
  Future<TimetableEntry?> getCurrentClass(String classId) async {
    await _ensureInitialized();
    final todayEntries = await getTodayTimetable(classId);
    
    for (final entry in todayEntries) {
      if (entry.isCurrentlyActive()) {
        return entry;
      }
    }
    return null;
  }

  /// Get classes within time window
  Future<List<TimetableEntry>> getActiveClassesWithTolerance(
    String classId,
    int toleranceMinutes,
  ) async {
    await _ensureInitialized();
    final todayEntries = await getTodayTimetable(classId);
    
    return todayEntries
        .where((entry) => entry.isWithinTimeWindow(toleranceMinutes))
        .toList();
  }

  /// Clear old timetable data
  Future<void> clearOldTimetable(String classId) async {
    await _ensureInitialized();
    final keysToDelete = <String>[];
    
    for (final entry in _timetableBox!.values) {
      if (entry.classId == classId) {
        keysToDelete.add(entry.id);
      }
    }
    
    await _timetableBox!.deleteAll(keysToDelete);
  }

  // SCHEDULE OPERATIONS

  /// Save class schedule
  Future<void> saveClassSchedule(ClassSchedule schedule) async {
    await _ensureInitialized();
    await _scheduleBox!.put(schedule.id, schedule);
    
    // Also save individual timetable entries
    await saveTimetableEntries(schedule.timetable);
  }

  /// Get class schedule
  Future<ClassSchedule?> getClassSchedule(String classId) async {
    await _ensureInitialized();
    return _scheduleBox!.values
        .where((schedule) => schedule.classId == classId)
        .firstOrNull;
  }

  // STUDENT PROFILE OPERATIONS

  /// Save student profile
  Future<void> saveStudentProfile(StudentProfile profile) async {
    await _ensureInitialized();
    await _studentBox!.put(profile.id, profile);
  }

  /// Get student profile
  Future<StudentProfile?> getStudentProfile(String studentId) async {
    await _ensureInitialized();
    return _studentBox!.get(studentId);
  }

  /// Update student profile
  Future<void> updateStudentProfile(StudentProfile profile) async {
    await _ensureInitialized();
    await _studentBox!.put(profile.id, profile);
  }

  // ATTENDANCE SUMMARY OPERATIONS

  /// Save attendance summary
  Future<void> saveAttendanceSummary(AttendanceSummary summary) async {
    await _ensureInitialized();
    final key = '${summary.studentId}_${summary.subjectId}';
    await _summaryBox!.put(key, summary);
  }

  /// Get attendance summary
  Future<AttendanceSummary?> getAttendanceSummary(
    String studentId,
    String subjectId,
  ) async {
    await _ensureInitialized();
    final key = '${studentId}_$subjectId';
    return _summaryBox!.get(key);
  }

  /// Get all attendance summaries for student
  Future<List<AttendanceSummary>> getStudentAttendanceSummaries(
    String studentId,
  ) async {
    await _ensureInitialized();
    return _summaryBox!.values
        .where((summary) => summary.studentId == studentId)
        .toList();
  }

  // CACHE OPERATIONS

  /// Cache data with expiry
  Future<void> cacheData(String key, dynamic data, Duration expiry) async {
    await _ensureInitialized();
    final cacheItem = {
      'data': data,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
      'expiry': expiry.inMilliseconds,
    };
    await _cacheBox!.put(key, cacheItem);
  }

  /// Get cached data
  Future<T?> getCachedData<T>(String key) async {
    await _ensureInitialized();
    final cacheItem = _cacheBox!.get(key);
    
    if (cacheItem == null) return null;
    
    final timestamp = cacheItem['timestamp'] as int;
    final expiry = cacheItem['expiry'] as int;
    final now = DateTime.now().millisecondsSinceEpoch;
    
    if (now - timestamp > expiry) {
      await _cacheBox!.delete(key);
      return null;
    }
    
    return cacheItem['data'] as T?;
  }

  /// Clear expired cache
  Future<void> clearExpiredCache() async {
    await _ensureInitialized();
    final now = DateTime.now().millisecondsSinceEpoch;
    final keysToDelete = <String>[];
    
    for (final entry in _cacheBox!.toMap().entries) {
      final key = entry.key as String;
      final value = entry.value;
      
      if (value is Map) {
        final timestamp = value['timestamp'] as int?;
        final expiry = value['expiry'] as int?;
        
        if (timestamp != null && expiry != null) {
          if (now - timestamp > expiry) {
            keysToDelete.add(key);
          }
        }
      }
    }
    
    await _cacheBox!.deleteAll(keysToDelete);
  }

  // SYNC OPERATIONS

  /// Sync unsynced data to Firestore
  Future<SyncResult> syncToFirestore() async {
    if (!await isOnline()) {
      return SyncResult(
        success: false,
        message: 'Device is offline',
        syncedCount: 0,
      );
    }

    try {
      final unsyncedRecords = await getUnsyncedAttendanceRecords();
      int syncedCount = 0;
      final errors = <String>[];

      for (final record in unsyncedRecords) {
        try {
          await FirebaseFirestore.instance
              .collection(AppConstants.attendanceCollection)
              .doc(record.id)
              .set(record.toJson());

          await markAttendanceSynced(record.id);
          syncedCount++;
        } catch (e) {
          errors.add('Failed to sync record ${record.id}: $e');
        }
      }

      return SyncResult(
        success: errors.isEmpty,
        message: errors.isEmpty
            ? 'Successfully synced $syncedCount records'
            : 'Synced $syncedCount records with ${errors.length} errors',
        syncedCount: syncedCount,
        errors: errors,
      );
    } catch (e) {
      return SyncResult(
        success: false,
        message: 'Sync failed: $e',
        syncedCount: 0,
      );
    }
  }

  /// Background sync with retry logic
  Future<void> backgroundSync() async {
    int retryCount = 0;
    const maxRetries = 3;
    
    while (retryCount < maxRetries) {
      final result = await syncToFirestore();
      
      if (result.success) {
        break;
      }
      
      retryCount++;
      if (retryCount < maxRetries) {
        await Future.delayed(Duration(seconds: retryCount * 2));
      }
    }
  }

  // UTILITY METHODS

  /// Import timetable from CSV
  Future<void> importTimetableFromCsv(String csvContent, String classId) async {
    try {
      final lines = csvContent.split('\n');
      final entries = <TimetableEntry>[];
      
      for (int i = 1; i < lines.length; i++) { // Skip header
        final line = lines[i].trim();
        if (line.isEmpty) continue;
        
        final columns = line.split(',');
        if (columns.length >= 7) {
          final entry = TimetableEntry(
            id: '${classId}_${i}',
            classId: classId,
            subjectId: columns[0].trim(),
            subjectName: columns[1].trim(),
            teacherId: columns[2].trim(),
            teacherName: columns[3].trim(),
            room: columns[4].trim(),
            dayOfWeek: int.tryParse(columns[5].trim()) ?? 1,
            startTime: _parseTimeSlot(columns[6].trim()),
            endTime: _parseTimeSlot(columns[7].trim()),
            description: columns.length > 8 ? columns[8].trim() : null,
            createdAt: DateTime.now(),
          );
          entries.add(entry);
        }
      }
      
      await saveTimetableEntries(entries);
    } catch (e) {
      throw Exception('Failed to import timetable from CSV: $e');
    }
  }

  /// Parse time slot from string (HH:MM format)
  TimeSlot _parseTimeSlot(String timeStr) {
    final parts = timeStr.split(':');
    if (parts.length != 2) {
      throw Exception('Invalid time format: $timeStr');
    }
    
    return TimeSlot(
      hour: int.parse(parts[0]),
      minute: int.parse(parts[1]),
    );
  }

  /// Get storage statistics
  Future<StorageStats> getStorageStats() async {
    await _ensureInitialized();
    
    return StorageStats(
      attendanceRecords: _attendanceBox!.length,
      timetableEntries: _timetableBox!.length,
      classSchedules: _scheduleBox!.length,
      studentProfiles: _studentBox!.length,
      attendanceSummaries: _summaryBox!.length,
      cacheItems: _cacheBox!.length,
      unsyncedRecords: (await getUnsyncedAttendanceRecords()).length,
    );
  }

  /// Clear all data
  Future<void> clearAllData() async {
    await _ensureInitialized();
    await _attendanceBox!.clear();
    await _timetableBox!.clear();
    await _scheduleBox!.clear();
    await _studentBox!.clear();
    await _summaryBox!.clear();
    await _cacheBox!.clear();
  }

  /// Ensure storage is initialized
  Future<void> _ensureInitialized() async {
    if (!_isInitialized) {
      await initialize();
    }
  }

  /// Dispose resources
  Future<void> dispose() async {
    await _attendanceBox?.close();
    await _timetableBox?.close();
    await _scheduleBox?.close();
    await _studentBox?.close();
    await _summaryBox?.close();
    await _cacheBox?.close();
    _isInitialized = false;
  }
}

/// Result of sync operation
class SyncResult {
  final bool success;
  final String message;
  final int syncedCount;
  final List<String> errors;

  SyncResult({
    required this.success,
    required this.message,
    required this.syncedCount,
    this.errors = const [],
  });

  @override
  String toString() {
    return 'SyncResult(success: $success, message: $message, syncedCount: $syncedCount, errors: ${errors.length})';
  }
}

/// Storage statistics
class StorageStats {
  final int attendanceRecords;
  final int timetableEntries;
  final int classSchedules;
  final int studentProfiles;
  final int attendanceSummaries;
  final int cacheItems;
  final int unsyncedRecords;

  StorageStats({
    required this.attendanceRecords,
    required this.timetableEntries,
    required this.classSchedules,
    required this.studentProfiles,
    required this.attendanceSummaries,
    required this.cacheItems,
    required this.unsyncedRecords,
  });

  int get totalItems =>
      attendanceRecords +
      timetableEntries +
      classSchedules +
      studentProfiles +
      attendanceSummaries +
      cacheItems;

  @override
  String toString() {
    return 'StorageStats(total: $totalItems, unsynced: $unsyncedRecords)';
  }
}