import 'dart:convert';
import 'dart:io';
import 'package:csv/csv.dart';
import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../constants/app_constants.dart';
import '../../data/models/hive_models.dart';
import 'offline_storage_service.dart';

class TimetableService {
  static final TimetableService _instance = TimetableService._internal();
  factory TimetableService() => _instance;
  TimetableService._internal();

  final Dio _dio = Dio();
  final OfflineStorageService _storage = OfflineStorageService();
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  // Time window configuration
  static const int _attendanceToleranceMinutes = 10;
  static const int _lateThresholdMinutes = 10;

  /// Initialize service
  Future<void> initialize() async {
    await _storage.initialize();
    _configureDio();
  }

  /// Configure Dio client
  void _configureDio() {
    _dio.options.baseUrl = AppConstants.baseUrl;
    _dio.options.connectTimeout = Duration(seconds: AppConstants.networkTimeout);
    _dio.options.receiveTimeout = Duration(seconds: AppConstants.networkTimeout);
    _dio.options.sendTimeout = Duration(seconds: AppConstants.networkTimeout);

    // Add interceptors
    _dio.interceptors.add(LogInterceptor(
      requestBody: true,
      responseBody: true,
      logPrint: (obj) {
        // Only log in debug mode
        if (AppConstants.isDebugMode) {
          print(obj);
        }
      },
    ));

    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        // Add authentication token if available
        final token = await _secureStorage.read(key: 'auth_token');
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        handler.next(options);
      },
      onError: (error, handler) {
        // Handle network errors
        if (error.type == DioExceptionType.connectionTimeout ||
            error.type == DioExceptionType.connectionError) {
          // Fallback to offline data
          print('Network error, falling back to offline data');
        }
        handler.next(error);
      },
    ));
  }

  // TIMETABLE FETCHING

  /// Fetch timetable from college portal API
  Future<TimetableResult> fetchTimetableFromPortal(String classId) async {
    try {
      final response = await _dio.get('/api/timetable/$classId');
      
      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        final entries = <TimetableEntry>[];
        
        for (final item in data['timetable'] as List) {
          entries.add(TimetableEntry.fromJson(item));
        }
        
        // Save to offline storage
        await _storage.saveTimetableEntries(entries);
        
        return TimetableResult(
          success: true,
          entries: entries,
          message: 'Timetable fetched successfully from portal',
        );
      } else {
        throw Exception('Failed to fetch timetable: ${response.statusMessage}');
      }
    } on DioException catch (e) {
      // Fallback to offline data
      final offlineEntries = await _storage.getTimetable(classId);
      
      return TimetableResult(
        success: offlineEntries.isNotEmpty,
        entries: offlineEntries,
        message: offlineEntries.isNotEmpty
            ? 'Using offline timetable data'
            : 'No timetable data available offline',
        isOffline: true,
      );
    } catch (e) {
      return TimetableResult(
        success: false,
        entries: [],
        message: 'Failed to fetch timetable: $e',
      );
    }
  }

  /// Import timetable from CSV file
  Future<TimetableResult> importTimetableFromCsv() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['csv'],
        allowMultiple: false,
      );

      if (result == null || result.files.single.path == null) {
        return TimetableResult(
          success: false,
          entries: [],
          message: 'No file selected',
        );
      }

      final file = File(result.files.single.path!);
      final csvContent = await file.readAsString();
      
      return await _parseCsvContent(csvContent);
    } catch (e) {
      return TimetableResult(
        success: false,
        entries: [],
        message: 'Failed to import CSV: $e',
      );
    }
  }

  /// Parse CSV content and create timetable entries
  Future<TimetableResult> _parseCsvContent(String csvContent) async {
    try {
      final List<List<dynamic>> csvData = const CsvToListConverter().convert(csvContent);
      
      if (csvData.isEmpty) {
        throw Exception('CSV file is empty');
      }

      final entries = <TimetableEntry>[];
      final headers = csvData.first.map((e) => e.toString().toLowerCase()).toList();

      // Validate required columns
      final requiredColumns = [
        'subject_id', 'subject_name', 'teacher_id', 'teacher_name', 
        'room', 'day_of_week', 'start_time', 'end_time'
      ];

      for (final column in requiredColumns) {
        if (!headers.contains(column)) {
          throw Exception('Missing required column: $column');
        }
      }

      // Parse data rows
      for (int i = 1; i < csvData.length; i++) {
        final row = csvData[i];
        if (row.isEmpty) continue;

        try {
          final entry = _createTimetableEntryFromRow(row, headers, i);
          entries.add(entry);
        } catch (e) {
          print('Error parsing row $i: $e');
          continue;
        }
      }

      if (entries.isEmpty) {
        throw Exception('No valid timetable entries found in CSV');
      }

      // Save to offline storage
      await _storage.saveTimetableEntries(entries);

      return TimetableResult(
        success: true,
        entries: entries,
        message: 'Successfully imported ${entries.length} timetable entries from CSV',
      );
    } catch (e) {
      return TimetableResult(
        success: false,
        entries: [],
        message: 'Failed to parse CSV: $e',
      );
    }
  }

  /// Create timetable entry from CSV row
  TimetableEntry _createTimetableEntryFromRow(
    List<dynamic> row,
    List<String> headers,
    int index,
  ) {
    final Map<String, dynamic> data = {};
    
    for (int i = 0; i < headers.length && i < row.length; i++) {
      data[headers[i]] = row[i];
    }

    return TimetableEntry(
      id: 'csv_entry_$index',
      classId: data['class_id']?.toString() ?? 'default_class',
      subjectId: data['subject_id']?.toString() ?? '',
      subjectName: data['subject_name']?.toString() ?? '',
      teacherId: data['teacher_id']?.toString() ?? '',
      teacherName: data['teacher_name']?.toString() ?? '',
      room: data['room']?.toString() ?? '',
      dayOfWeek: _parseDayOfWeek(data['day_of_week']?.toString()),
      startTime: _parseTimeFromString(data['start_time']?.toString()),
      endTime: _parseTimeFromString(data['end_time']?.toString()),
      description: data['description']?.toString(),
      createdAt: DateTime.now(),
    );
  }

  /// Parse day of week from string
  int _parseDayOfWeek(String? dayStr) {
    if (dayStr == null) return 1;
    
    final dayMap = {
      'monday': 1, 'mon': 1, '1': 1,
      'tuesday': 2, 'tue': 2, '2': 2,
      'wednesday': 3, 'wed': 3, '3': 3,
      'thursday': 4, 'thu': 4, '4': 4,
      'friday': 5, 'fri': 5, '5': 5,
      'saturday': 6, 'sat': 6, '6': 6,
      'sunday': 7, 'sun': 7, '7': 7,
    };
    
    final day = dayMap[dayStr.toLowerCase()];
    return day ?? int.tryParse(dayStr) ?? 1;
  }

  /// Parse time from string (supports multiple formats)
  TimeSlot _parseTimeFromString(String? timeStr) {
    if (timeStr == null || timeStr.isEmpty) {
      return TimeSlot(hour: 0, minute: 0);
    }

    // Handle different time formats
    final cleanTime = timeStr.trim().toLowerCase();
    
    // Format: HH:MM AM/PM
    final amPmRegex = RegExp(r'^(\d{1,2}):(\d{2})\s*(am|pm)$');
    final amPmMatch = amPmRegex.firstMatch(cleanTime);
    
    if (amPmMatch != null) {
      int hour = int.parse(amPmMatch.group(1)!);
      final minute = int.parse(amPmMatch.group(2)!);
      final period = amPmMatch.group(3)!;
      
      if (period == 'pm' && hour != 12) hour += 12;
      if (period == 'am' && hour == 12) hour = 0;
      
      return TimeSlot(hour: hour, minute: minute);
    }

    // Format: HH:MM (24-hour)
    final time24Regex = RegExp(r'^(\d{1,2}):(\d{2})$');
    final time24Match = time24Regex.firstMatch(cleanTime);
    
    if (time24Match != null) {
      final hour = int.parse(time24Match.group(1)!);
      final minute = int.parse(time24Match.group(2)!);
      return TimeSlot(hour: hour, minute: minute);
    }

    // Default fallback
    return TimeSlot(hour: 0, minute: 0);
  }

  // TIME WINDOW ENFORCEMENT

  /// Check if attendance marking is allowed for a class
  Future<AttendanceWindowResult> checkAttendanceWindow(
    String classId,
    String subjectId,
  ) async {
    try {
      final currentClass = await _storage.getCurrentClass(classId);
      
      if (currentClass == null) {
        return AttendanceWindowResult(
          allowed: false,
          status: AttendanceWindowStatus.noActiveClass,
          message: 'No active class found at this time',
        );
      }

      if (currentClass.subjectId != subjectId) {
        return AttendanceWindowResult(
          allowed: false,
          status: AttendanceWindowStatus.differentSubject,
          message: 'Different subject is currently scheduled',
          currentClass: currentClass,
        );
      }

      final now = DateTime.now();
      final currentTime = TimeSlot(hour: now.hour, minute: now.minute);
      
      // Check if within tolerance window
      final toleranceWindow = await _storage.getActiveClassesWithTolerance(
        classId,
        _attendanceToleranceMinutes,
      );

      final activeClass = toleranceWindow.firstWhere(
        (entry) => entry.subjectId == subjectId,
        orElse: () => throw Exception('Class not found'),
      );

      // Check if student is late
      final isLate = _isStudentLate(currentTime, activeClass.startTime);

      return AttendanceWindowResult(
        allowed: true,
        status: isLate
            ? AttendanceWindowStatus.lateAllowed
            : AttendanceWindowStatus.onTime,
        message: isLate
            ? 'You are ${_getMinutesLate(currentTime, activeClass.startTime)} minutes late'
            : 'On time for attendance',
        currentClass: activeClass,
        isLate: isLate,
        minutesLate: isLate ? _getMinutesLate(currentTime, activeClass.startTime) : 0,
      );
    } catch (e) {
      return AttendanceWindowResult(
        allowed: false,
        status: AttendanceWindowStatus.error,
        message: 'Error checking attendance window: $e',
      );
    }
  }

  /// Check if student is late
  bool _isStudentLate(TimeSlot currentTime, TimeSlot classStartTime) {
    final currentMinutes = currentTime.hour * 60 + currentTime.minute;
    final startMinutes = classStartTime.hour * 60 + classStartTime.minute;
    
    return currentMinutes > (startMinutes + _lateThresholdMinutes);
  }

  /// Get minutes late
  int _getMinutesLate(TimeSlot currentTime, TimeSlot classStartTime) {
    final currentMinutes = currentTime.hour * 60 + currentTime.minute;
    final startMinutes = classStartTime.hour * 60 + classStartTime.minute;
    
    return (currentMinutes - startMinutes).clamp(0, double.infinity).toInt();
  }

  /// Get today's schedule for a class
  Future<List<TimetableEntry>> getTodaySchedule(String classId) async {
    final schedule = await _storage.getTodayTimetable(classId);
    
    // Sort by start time
    schedule.sort((a, b) {
      final aMinutes = a.startTime.hour * 60 + a.startTime.minute;
      final bMinutes = b.startTime.hour * 60 + b.startTime.minute;
      return aMinutes.compareTo(bMinutes);
    });
    
    return schedule;
  }

  /// Get current active class
  Future<TimetableEntry?> getCurrentActiveClass(String classId) async {
    return await _storage.getCurrentClass(classId);
  }

  /// Get next upcoming class
  Future<TimetableEntry?> getNextClass(String classId) async {
    final todaySchedule = await getTodaySchedule(classId);
    final now = DateTime.now();
    final currentTime = TimeSlot(hour: now.hour, minute: now.minute);
    
    for (final entry in todaySchedule) {
      if (currentTime.isBefore(entry.startTime)) {
        return entry;
      }
    }
    
    return null; // No more classes today
  }

  /// Get attendance statistics for time windows
  Future<AttendanceTimeStats> getAttendanceTimeStats(
    String studentId,
    String subjectId,
    {DateTime? fromDate, DateTime? toDate}
  ) async {
    final records = await _storage.getAttendanceRecords(studentId);
    final filteredRecords = records.where((record) {
      if (record.subjectId != subjectId) return false;
      
      if (fromDate != null && record.timestamp.isBefore(fromDate)) return false;
      if (toDate != null && record.timestamp.isAfter(toDate)) return false;
      
      return true;
    }).toList();

    int onTimeCount = 0;
    int lateCount = 0;
    int totalPresent = 0;

    for (final record in filteredRecords) {
      if (record.status == AttendanceStatus.present) {
        totalPresent++;
        onTimeCount++;
      } else if (record.status == AttendanceStatus.late) {
        totalPresent++;
        lateCount++;
      }
    }

    return AttendanceTimeStats(
      totalRecords: filteredRecords.length,
      presentCount: totalPresent,
      onTimeCount: onTimeCount,
      lateCount: lateCount,
      absentCount: filteredRecords.length - totalPresent,
      onTimePercentage: totalPresent > 0 ? (onTimeCount / totalPresent) * 100 : 0,
      latePercentage: totalPresent > 0 ? (lateCount / totalPresent) * 100 : 0,
    );
  }

  /// Sync timetable with portal (background)
  Future<void> syncTimetableInBackground(String classId) async {
    try {
      await fetchTimetableFromPortal(classId);
    } catch (e) {
      // Silent failure for background sync
      print('Background timetable sync failed: $e');
    }
  }

  /// Export timetable to CSV
  Future<String?> exportTimetableToCsv(String classId) async {
    try {
      final entries = await _storage.getTimetable(classId);
      
      if (entries.isEmpty) {
        return null;
      }

      final csvData = <List<dynamic>>[
        // Header
        [
          'Subject ID',
          'Subject Name',
          'Teacher ID',
          'Teacher Name',
          'Room',
          'Day of Week',
          'Start Time',
          'End Time',
          'Description',
        ],
        // Data rows
        ...entries.map((entry) => [
          entry.subjectId,
          entry.subjectName,
          entry.teacherId,
          entry.teacherName,
          entry.room,
          _dayOfWeekToString(entry.dayOfWeek),
          entry.startTime.format24Hour(),
          entry.endTime.format24Hour(),
          entry.description ?? '',
        ]),
      ];

      return const ListToCsvConverter().convert(csvData);
    } catch (e) {
      throw Exception('Failed to export timetable to CSV: $e');
    }
  }

  /// Convert day of week number to string
  String _dayOfWeekToString(int dayOfWeek) {
    const days = [
      '', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 
      'Friday', 'Saturday', 'Sunday'
    ];
    return days[dayOfWeek] ?? 'Unknown';
  }
}

/// Result of timetable operation
class TimetableResult {
  final bool success;
  final List<TimetableEntry> entries;
  final String message;
  final bool isOffline;

  TimetableResult({
    required this.success,
    required this.entries,
    required this.message,
    this.isOffline = false,
  });

  @override
  String toString() {
    return 'TimetableResult(success: $success, entries: ${entries.length}, message: $message, isOffline: $isOffline)';
  }
}

/// Result of attendance window check
class AttendanceWindowResult {
  final bool allowed;
  final AttendanceWindowStatus status;
  final String message;
  final TimetableEntry? currentClass;
  final bool isLate;
  final int minutesLate;

  AttendanceWindowResult({
    required this.allowed,
    required this.status,
    required this.message,
    this.currentClass,
    this.isLate = false,
    this.minutesLate = 0,
  });

  @override
  String toString() {
    return 'AttendanceWindowResult(allowed: $allowed, status: $status, message: $message, isLate: $isLate, minutesLate: $minutesLate)';
  }
}

/// Attendance window status
enum AttendanceWindowStatus {
  onTime,
  lateAllowed,
  tooLate,
  noActiveClass,
  differentSubject,
  error,
}

/// Attendance time statistics
class AttendanceTimeStats {
  final int totalRecords;
  final int presentCount;
  final int onTimeCount;
  final int lateCount;
  final int absentCount;
  final double onTimePercentage;
  final double latePercentage;

  AttendanceTimeStats({
    required this.totalRecords,
    required this.presentCount,
    required this.onTimeCount,
    required this.lateCount,
    required this.absentCount,
    required this.onTimePercentage,
    required this.latePercentage,
  });

  double get attendancePercentage =>
      totalRecords > 0 ? (presentCount / totalRecords) * 100 : 0;

  @override
  String toString() {
    return 'AttendanceTimeStats(total: $totalRecords, present: $presentCount, onTime: $onTimeCount, late: $lateCount)';
  }
}