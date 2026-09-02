import 'dart:convert';
import 'day_plan.dart';

/// Holds the meal plan for a full week (Monday–Sunday).
class WeekPlan {
  final List<DayPlan> days;

  WeekPlan({required this.days})
      : assert(days.length == 7, 'WeekPlan must contain exactly 7 days');

  // ──────────────────────────────── factory ──────────────────────────────────

  /// Builds a default week plan with sample dishes.
  factory WeekPlan.defaultPlan() {
    final defaultMeals = [
      ('Dal Tadka', 'Paneer Butter Masala', 'Masala Chai'),
      ('Rajma', 'Aloo Gobi', 'Ginger Tea'),
      ('Chole', 'Mix Veg', 'Cardamom Tea'),
      ('Poha', 'Palak Paneer', 'Masala Chai'),
      ('Upma', 'Dal Tadka', 'Ginger Tea'),
      ('Paratha', 'Rajma', 'Masala Chai'),
      ('Aloo Gobi', 'Chole', 'Cardamom Tea'),
    ];

    return WeekPlan(
      days: List.generate(7, (i) {
        final (m1, m2, t) = defaultMeals[i];
        return DayPlan(weekday: i + 1, meal1: m1, meal2: m2, tea: t);
      }),
    );
  }

  // ──────────────────────────────── helpers ──────────────────────────────────

  /// Returns the [DayPlan] matching today's weekday.
  DayPlan get todaysPlan {
    final todayWeekday = DateTime.now().weekday; // 1=Mon … 7=Sun
    return days.firstWhere(
      (d) => d.weekday == todayWeekday,
      orElse: () => days.first,
    );
  }

  /// Returns a new [WeekPlan] with a specific day replaced.
  WeekPlan withUpdatedDay(DayPlan updated) {
    return WeekPlan(
      days: days.map((d) => d.weekday == updated.weekday ? updated : d).toList(),
    );
  }

  // ──────────────────────────────── serialisation ────────────────────────────

  Map<String, dynamic> toJson() => {
        'days': days.map((d) => d.toJson()).toList(),
      };

  factory WeekPlan.fromJson(Map<String, dynamic> json) {
    final rawDays = json['days'] as List<dynamic>? ?? [];
    final parsedDays =
        rawDays.map((d) => DayPlan.fromJson(d as Map<String, dynamic>)).toList();

    // Ensure exactly 7 days (fill missing ones with defaults if needed).
    if (parsedDays.length == 7) {
      return WeekPlan(days: parsedDays);
    }
    final defaultPlan = WeekPlan.defaultPlan();
    final Map<int, DayPlan> byWeekday = {
      for (final d in parsedDays) d.weekday: d,
    };
    return WeekPlan(
      days: defaultPlan.days.map((d) => byWeekday[d.weekday] ?? d).toList(),
    );
  }

  String toJsonString() => jsonEncode(toJson());

  factory WeekPlan.fromJsonString(String raw) =>
      WeekPlan.fromJson(jsonDecode(raw) as Map<String, dynamic>);
}
