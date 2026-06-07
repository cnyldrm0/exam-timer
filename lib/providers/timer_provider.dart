import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// The centralized time state
final currentTimeProvider = StateNotifierProvider<TimerNotifier, DateTime>((ref) {
  return TimerNotifier();
});

class TimerNotifier extends StateNotifier<DateTime> {
  Timer? _timer;

  TimerNotifier() : super(DateTime.now()) {
    _startTimer();
  }

  void _startTimer() {
    // Fire exactly every second to keep high fidelity.
    // 60fps animations will be handled by the UI interpolating or just letting the timer trigger a rebuild.
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      state = DateTime.now();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}

// Utility to calculate countdown
class CountdownEngine {
  static Duration calculateDifference(DateTime targetDate, DateTime currentTime) {
    if (currentTime.isAfter(targetDate)) {
      return Duration.zero; // Completed
    }
    return targetDate.difference(currentTime);
  }

  static bool isCompleted(DateTime targetDate, DateTime currentTime) {
    return currentTime.isAfter(targetDate);
  }
}
