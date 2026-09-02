import '../models/week_plan.dart';
import '../models/day_plan.dart';

class RotationService {
  /// Rotates the week plan: shifts days forward by 1.
  /// (e.g. what was on Monday moves to Tuesday, Sunday moves to Monday)
  /// EXCEPT for Sunday's meal 1 which is locked to Aloo Puri.
  static WeekPlan rotateWeek(WeekPlan currentPlan) {
    final oldDays = currentPlan.days;
    final newDays = <DayPlan>[];

    for (int i = 0; i < 7; i++) {
      // Find the source day (the one before this one, wrapping around)
      final sourceIdx = (i - 1 + 7) % 7;
      final sourceDay = oldDays[sourceIdx];

      // Target weekday is 1-indexed (1=Mon, 7=Sun)
      final targetWeekday = i + 1;

      // Copy the source day's data, but update the weekday to the new slot
      final rotatedDay = DayPlan(
        weekday: targetWeekday,
        memberCount: sourceDay.memberCount,
        riceType: sourceDay.riceType,
        // Meal 1
        meal1Sabzi: sourceDay.meal1Sabzi,
        meal1BreadType: sourceDay.meal1BreadType,
        meal1BreadCount: sourceDay.meal1BreadCount,
        // Meal 2
        meal2Main: sourceDay.meal2Main,
        meal2BreadCount: sourceDay.meal2BreadCount,
        // Tea
        tea: sourceDay.tea,
      );
      
      // If the target day is Sunday, enforce the Meal 1 Aloo Puri lock
      if (rotatedDay.isSunday) {
        rotatedDay.meal1Sabzi = 'Aloo Puri';
      }

      newDays.add(rotatedDay);
    }

    return WeekPlan(days: newDays);
  }
}
