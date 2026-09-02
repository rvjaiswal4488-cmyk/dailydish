import 'day_plan.dart';

/// Holds the full 7-day meal plan (Monday → Sunday).
class WeekPlan {
  final List<DayPlan> days;

  const WeekPlan({required this.days});

  /// Returns today's plan based on current weekday.
  DayPlan get todaysPlan {
    final weekday = DateTime.now().weekday;
    return days.firstWhere(
      (d) => d.weekday == weekday,
      orElse: () => days.first,
    );
  }

  /// Returns a new WeekPlan with one day replaced.
  WeekPlan withUpdatedDay(DayPlan updated) => WeekPlan(
    days: days.map((d) => d.weekday == updated.weekday ? updated : d).toList(),
  );

  Map<String, dynamic> toJson() => {
    'days': days.map((d) => d.toJson()).toList(),
  };

  factory WeekPlan.fromJson(Map<String, dynamic> json) => WeekPlan(
    days: (json['days'] as List)
        .map((d) => DayPlan.fromJson(d as Map<String, dynamic>))
        .toList(),
  );
}
