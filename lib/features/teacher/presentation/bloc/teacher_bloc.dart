import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

// Events
abstract class TeacherEvent extends Equatable {
  const TeacherEvent();

  @override
  List<Object> get props => [];
}

class TeacherLoadDashboardEvent extends TeacherEvent {}

class TeacherStartAttendanceEvent extends TeacherEvent {
  final String classId;
  final String subjectId;

  const TeacherStartAttendanceEvent({
    required this.classId,
    required this.subjectId,
  });

  @override
  List<Object> get props => [classId, subjectId];
}

class TeacherLoadStudentsEvent extends TeacherEvent {
  final String classId;

  const TeacherLoadStudentsEvent(this.classId);

  @override
  List<Object> get props => [classId];
}

class TeacherGenerateReportEvent extends TeacherEvent {
  final String classId;
  final String subjectId;
  final String reportType;

  const TeacherGenerateReportEvent({
    required this.classId,
    required this.subjectId,
    required this.reportType,
  });

  @override
  List<Object> get props => [classId, subjectId, reportType];
}

// States
abstract class TeacherState extends Equatable {
  const TeacherState();

  @override
  List<Object> get props => [];
}

class TeacherInitialState extends TeacherState {}

class TeacherLoadingState extends TeacherState {}

class TeacherDashboardLoadedState extends TeacherState {
  final Map<String, dynamic> dashboardData;

  const TeacherDashboardLoadedState(this.dashboardData);

  @override
  List<Object> get props => [dashboardData];
}

class TeacherAttendanceStartedState extends TeacherState {
  final String sessionId;
  final String message;

  const TeacherAttendanceStartedState({
    required this.sessionId,
    required this.message,
  });

  @override
  List<Object> get props => [sessionId, message];
}

class TeacherStudentsLoadedState extends TeacherState {
  final List<Map<String, dynamic>> students;

  const TeacherStudentsLoadedState(this.students);

  @override
  List<Object> get props => [students];
}

class TeacherReportGeneratedState extends TeacherState {
  final Map<String, dynamic> reportData;

  const TeacherReportGeneratedState(this.reportData);

  @override
  List<Object> get props => [reportData];
}

class TeacherErrorState extends TeacherState {
  final String message;

  const TeacherErrorState(this.message);

  @override
  List<Object> get props => [message];
}

// BLoC
class TeacherBloc extends Bloc<TeacherEvent, TeacherState> {
  TeacherBloc() : super(TeacherInitialState()) {
    on<TeacherLoadDashboardEvent>(_onLoadDashboard);
    on<TeacherStartAttendanceEvent>(_onStartAttendance);
    on<TeacherLoadStudentsEvent>(_onLoadStudents);
    on<TeacherGenerateReportEvent>(_onGenerateReport);
  }

  void _onLoadDashboard(TeacherLoadDashboardEvent event, Emitter<TeacherState> emit) async {
    emit(TeacherLoadingState());
    try {
      // TODO: Implement dashboard loading logic
      await Future.delayed(const Duration(seconds: 1));
      
      // Mock dashboard data
      final dashboardData = {
        'totalClasses': 6,
        'totalStudents': 150,
        'todayClasses': [
          {
            'subject': 'Mathematics',
            'class': 'B.Tech 1st Year',
            'time': '10:00 AM',
            'room': 'Room 101',
            'students': 45,
          },
          {
            'subject': 'Physics',
            'class': 'B.Tech 1st Year',
            'time': '2:00 PM', 
            'room': 'Lab 205',
            'students': 40,
          },
        ],
        'recentActivity': [
          {
            'type': 'Attendance',
            'class': 'B.Tech 1st Year',
            'subject': 'Mathematics',
            'date': '2024-01-15',
            'present': 38,
            'total': 45,
          },
        ],
      };
      
      emit(TeacherDashboardLoadedState(dashboardData));
    } catch (e) {
      emit(TeacherErrorState(e.toString()));
    }
  }

  void _onStartAttendance(TeacherStartAttendanceEvent event, Emitter<TeacherState> emit) async {
    emit(TeacherLoadingState());
    try {
      // TODO: Implement attendance session start logic
      await Future.delayed(const Duration(milliseconds: 800));
      
      emit(const TeacherAttendanceStartedState(
        sessionId: 'session_12345',
        message: 'Attendance session started successfully!',
      ));
    } catch (e) {
      emit(TeacherErrorState(e.toString()));
    }
  }

  void _onLoadStudents(TeacherLoadStudentsEvent event, Emitter<TeacherState> emit) async {
    emit(TeacherLoadingState());
    try {
      // TODO: Implement students loading logic
      await Future.delayed(const Duration(milliseconds: 800));
      
      // Mock student data
      final students = [
        {
          'id': 'student_1',
          'name': 'John Doe',
          'rollNumber': 'BT21001',
          'attendancePercentage': 85.5,
          'lastAttendance': '2024-01-15',
        },
        {
          'id': 'student_2',
          'name': 'Jane Smith',
          'rollNumber': 'BT21002',
          'attendancePercentage': 92.3,
          'lastAttendance': '2024-01-15',
        },
        {
          'id': 'student_3',
          'name': 'Mike Johnson',
          'rollNumber': 'BT21003',
          'attendancePercentage': 78.9,
          'lastAttendance': '2024-01-14',
        },
      ];
      
      emit(TeacherStudentsLoadedState(students));
    } catch (e) {
      emit(TeacherErrorState(e.toString()));
    }
  }

  void _onGenerateReport(TeacherGenerateReportEvent event, Emitter<TeacherState> emit) async {
    emit(TeacherLoadingState());
    try {
      // TODO: Implement report generation logic
      await Future.delayed(const Duration(seconds: 2));
      
      // Mock report data
      final reportData = {
        'reportType': event.reportType,
        'classId': event.classId,
        'subjectId': event.subjectId,
        'generatedAt': DateTime.now().toIso8601String(),
        'summary': {
          'totalStudents': 45,
          'averageAttendance': 82.4,
          'totalClasses': 20,
        },
        'studentDetails': [
          {
            'name': 'John Doe',
            'rollNumber': 'BT21001',
            'attendancePercentage': 85.5,
            'classesAttended': 17,
            'totalClasses': 20,
          },
        ],
      };
      
      emit(TeacherReportGeneratedState(reportData));
    } catch (e) {
      emit(TeacherErrorState(e.toString()));
    }
  }
}