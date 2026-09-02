/// Represents the meal plan for a single day.
/// [weekday] uses Dart's DateTime.weekday convention: 1 = Monday … 7 = Sunday.
class DayPlan {
  final int weekday;
  String meal1;
  String meal2;
  String tea;

  DayPlan({
    required this.weekday,
    required this.meal1,
    required this.meal2,
    required this.tea,
  });

  // ──────────────────────────────── serialisation ────────────────────────────

  Map<String, dynamic> toJson() => {
        'weekday': weekday,
        'meal1': meal1,
        'meal2': meal2,
        'tea': tea,
      };

  factory DayPlan.fromJson(Map<String, dynamic> json) => DayPlan(
        weekday: (json['weekday'] as num).toInt(),
        meal1: json['meal1'] as String? ?? '',
        meal2: json['meal2'] as String? ?? '',
        tea: json['tea'] as String? ?? '',
      );

  // ──────────────────────────────── helpers ──────────────────────────────────

  /// Returns a human-readable day name for [weekday].
  String get dayName {
    const names = {
      1: 'Monday',
      2: 'Tuesday',
      3: 'Wednesday',
      4: 'Thursday',
      5: 'Friday',
      6: 'Saturday',
      7: 'Sunday',
    };
    return names[weekday] ?? 'Unknown';
  }

  /// Short 3-letter day abbreviation.
  String get shortName => dayName.substring(0, 3);

  /// Creates a copy of this [DayPlan] with optional field overrides.
  DayPlan copyWith({
    int? weekday,
    String? meal1,
    String? meal2,
    String? tea,
  }) =>
      DayPlan(
        weekday: weekday ?? this.weekday,
        meal1: meal1 ?? this.meal1,
        meal2: meal2 ?? this.meal2,
        tea: tea ?? this.tea,
      );
}
