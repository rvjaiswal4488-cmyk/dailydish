import 'dart:math';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/day_plan.dart';
import '../models/week_plan.dart';

/// Handles the Saturday auto-rotation logic.
///
/// Every Saturday the week plan shifts: what was Monday becomes Sunday's slot,
/// and each subsequent day shifts back by one. The first day (Monday) gets a
/// freshly picked random dish from the supplied [dishList].
class RotationService {
  static const _lastRotationKey = 'last_rotation_date';

  /// Checks whether a rotation is due and, if so, performs it.
  ///
  /// Returns the (potentially updated) [WeekPlan].
  Future<WeekPlan> checkAndRotate(
    WeekPlan plan,
    List<String> dishList,
  ) async {
    final now = DateTime.now();
    // Only rotate on Saturday (weekday == 6).
    if (now.weekday != DateTime.saturday) return plan;

    final prefs = await SharedPreferences.getInstance();
    final lastRotation = prefs.getString(_lastRotationKey);
    final todayStr = _dateKey(now);

    // Already rotated today — skip.
    if (lastRotation == todayStr) return plan;

    final rotated = _rotate(plan, dishList, now);
    await prefs.setString(_lastRotationKey, todayStr);
    return rotated;
  }

  // ──────────────────────────────── internal ────────────────────────────────

  /// Rotates the days: day[n] takes the dishes from day[n+1], and the last
  /// day gets a new random dish from [dishList].
  WeekPlan _rotate(WeekPlan plan, List<String> dishList, DateTime now) {
    final rng = Random();

    String _randomDish(List<String> excludes) {
      final candidates = dishList.where((d) => !excludes.contains(d)).toList();
      if (candidates.isEmpty) return dishList[rng.nextInt(dishList.length)];
      return candidates[rng.nextInt(candidates.length)];
    }

    final newDays = <DayPlan>[];

    for (var i = 0; i < plan.days.length; i++) {
      final current = plan.days[i];
      if (i < plan.days.length - 1) {
        // Shift forward: take next day's dishes.
        final next = plan.days[i + 1];
        newDays.add(DayPlan(
          weekday: current.weekday,
          meal1: next.meal1,
          meal2: next.meal2,
          tea: next.tea,
        ));
      } else {
        // Last day: assign fresh random dishes.
        final usedMeals = newDays.map((d) => d.meal1).toList();
        final usedMeals2 = newDays.map((d) => d.meal2).toList();
        final usedTeas = newDays.map((d) => d.tea).toList();

        newDays.add(DayPlan(
          weekday: current.weekday,
          meal1: _randomDish(usedMeals),
          meal2: _randomDish(usedMeals2),
          tea: _randomDish(usedTeas),
        ));
      }
    }

    return WeekPlan(days: newDays);
  }

  String _dateKey(DateTime dt) => '${dt.year}-${dt.month}-${dt.day}';
}
