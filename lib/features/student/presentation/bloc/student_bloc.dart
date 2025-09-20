import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

// Events
abstract class StudentEvent extends Equatable {
  const StudentEvent();

  @override
  List<Object> get props => [];
}

class StudentLoadDashboardEvent extends StudentEvent {}

class StudentMarkAttendanceEvent extends StudentEvent {
  final String classId;
  final String subjectId;

  const StudentMarkAttendanceEvent({
    required this.classId,
    required this.subjectId,
  });

  @override
  List<Object> get props => [classId, subjectId];
}

class StudentLoadTimetableEvent extends StudentEvent {}

class StudentLoadAttendanceHistoryEvent extends StudentEvent {}

// States
abstract class StudentState extends Equatable {
  const StudentState();

  @override
  List<Object> get props => [];
}

class StudentInitialState extends StudentState {}

class StudentLoadingState extends StudentState {}

class StudentDashboardLoadedState extends StudentState {
  final Map<String, dynamic> dashboardData;

  const StudentDashboardLoadedState(this.dashboardData);

  @override
  List<Object> get props => [dashboardData];
}

class StudentTimetableLoadedState extends StudentState {
  final List<Map<String, dynamic>> timetable;

  const StudentTimetableLoadedState(this.timetable);

  @override
  List<Object> get props => [timetable];
}

class StudentAttendanceHistoryLoadedState extends StudentState {
  final List<Map<String, dynamic>> attendanceHistory;

  const StudentAttendanceHistoryLoadedState(this.attendanceHistory);

  @override
  List<Object> get props => [attendanceHistory];
}

class StudentAttendanceMarkedState extends StudentState {
  final String message;

  const StudentAttendanceMarkedState(this.message);

  @override
  List<Object> get props => [message];
}

class StudentErrorState extends StudentState {
  final String message;

  const StudentErrorState(this.message);

  @override
  List<Object> get props => [message];
}

// BLoC
class StudentBloc extends Bloc<StudentEvent, StudentState> {
  StudentBloc() : super(StudentInitialState()) {
    on<StudentLoadDashboardEvent>(_onLoadDashboard);
    on<StudentMarkAttendanceEvent>(_onMarkAttendance);
    on<StudentLoadTimetableEvent>(_onLoadTimetable);
    on<StudentLoadAttendanceHistoryEvent>(_onLoadAttendanceHistory);
  }

  void _onLoadDashboard(StudentLoadDashboardEvent event, Emitter<StudentState> emit) async {
    emit(StudentLoadingState());
    try {
      // TODO: Implement dashboard loading logic
      await Future.delayed(const Duration(seconds: 1));
      
      // Mock dashboard data
      final dashboardData = {
        'totalClasses': 120,
        'attendedClasses': 85,
        'attendancePercentage': 70.8,
        'upcomingClasses': [
          {
            'subject': 'Mathematics',
            'time': '10:00 AM',
            'room': 'Room 101',
          },
          {
            'subject': 'Physics',
            'time': '2:00 PM',
            'room': 'Lab 205',
          },
        ],
      };
      
      emit(StudentDashboardLoadedState(dashboardData));
    } catch (e) {
      emit(StudentErrorState(e.toString()));
    }
  }

  void _onMarkAttendance(StudentMarkAttendanceEvent event, Emitter<StudentState> emit) async {
    emit(StudentLoadingState());
    try {
      // TODO: Implement attendance marking logic
      await Future.delayed(const Duration(milliseconds: 800));
      
      emit(const StudentAttendanceMarkedState('Attendance marked successfully!'));
    } catch (e) {
      emit(StudentErrorState(e.toString()));
    }
  }

  void _onLoadTimetable(StudentLoadTimetableEvent event, Emitter<StudentState> emit) async {
    emit(StudentLoadingState());
    try {
      // TODO: Implement timetable loading logic
      await Future.delayed(const Duration(milliseconds: 800));
      
      // Mock timetable data
      final timetable = [
        {
          'day': 'Monday',
          'subjects': [
            {'name': 'Mathematics', 'time': '9:00-10:00', 'room': '101'},
            {'name': 'Physics', 'time': '10:00-11:00', 'room': '205'},
          ],
        },
        {
          'day': 'Tuesday',
          'subjects': [
            {'name': 'Chemistry', 'time': '9:00-10:00', 'room': '301'},
            {'name': 'English', 'time': '11:00-12:00', 'room': '102'},
          ],
        },
      ];
      
      emit(StudentTimetableLoadedState(timetable));
    } catch (e) {
      emit(StudentErrorState(e.toString()));
    }
  }

  void _onLoadAttendanceHistory(StudentLoadAttendanceHistoryEvent event, Emitter<StudentState> emit) async {
    emit(StudentLoadingState());
    try {
      // TODO: Implement attendance history loading logic
      await Future.delayed(const Duration(milliseconds: 800));
      
      // Mock attendance history
      final history = [
        {
          'date': '2024-01-15',
          'subject': 'Mathematics',
          'status': 'Present',
        },
        {
          'date': '2024-01-14',
          'subject': 'Physics',
          'status': 'Absent',
        },
      ];
      
      emit(StudentAttendanceHistoryLoadedState(history));
    } catch (e) {
      emit(StudentErrorState(e.toString()));
    }
  }
}