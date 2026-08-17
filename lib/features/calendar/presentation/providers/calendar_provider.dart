import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/calendar_event.dart';

class CalendarState {
  final List<CalendarEvent> events;
  final DateTime selectedDate;
  final bool isLoading;
  final String? error;

  const CalendarState({
    this.events = const [],
    required this.selectedDate,
    this.isLoading = true,
    this.error,
  });

  CalendarState copyWith({
    List<CalendarEvent>? events,
    DateTime? selectedDate,
    bool? isLoading,
    String? error,
  }) {
    return CalendarState(
      events: events ?? this.events,
      selectedDate: selectedDate ?? this.selectedDate,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

final calendarProvider = StateNotifierProvider<CalendarNotifier, CalendarState>((ref) {
  return CalendarNotifier();
});

class CalendarNotifier extends StateNotifier<CalendarState> {
  CalendarNotifier() : super(CalendarState(selectedDate: DateTime.now())) {
    loadEvents();
  }

  Future<void> loadEvents() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      // TODO: Get repository from DI
      // final repo = ref.read(calendarRepositoryProvider);
      // final start = DateTime(state.selectedDate.year, state.selectedDate.month, 1);
      // final end = DateTime(state.selectedDate.year, state.selectedDate.month + 1);
      // final events = await GetEventsUseCase(repo).call(start, end);
      // state = state.copyWith(events: events, isLoading: false);

      // Temporary mock data
      state = state.copyWith(
        events: _mockEvents(),
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(error: e.toString(), isLoading: false);
    }
  }

  List<CalendarEvent> _mockEvents() {
    return [
      CalendarEvent(
        id: '1',
        title: 'Team Standup',
        description: 'Daily sync with the team',
        startTime: DateTime.now().add(const Duration(hours: 9)),
        endTime: DateTime.now().add(const Duration(hours: 9, minutes: 30)),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      CalendarEvent(
        id: '2',
        title: 'Design Review',
        description: 'Review new notebook UI',
        startTime: DateTime.now().add(const Duration(hours: 14)),
        endTime: DateTime.now().add(const Duration(hours: 15)),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
    ];
  }

  void setSelectedDate(DateTime date) {
    state = state.copyWith(selectedDate: date);
    loadEvents();
  }
}
