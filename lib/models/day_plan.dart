/// Represents a single day's full meal plan.
class DayPlan {
  int weekday; // 1=Monday … 7=Sunday
  
  // ── Daily Config ────────────────────────────────────────────────────────
  int memberCount;        // Number of people eating today
  String riceType;        // "Rice" | "Pulao" (applies to whole day)

  // ── Meal 1 · Afternoon (dry vegetables) ─────────────────────────────────
  String meal1Sabzi;      // Dry vegetable, e.g. "Aloo Gobi"
  String meal1BreadType;  // "Roti" | "Parantha"
  int meal1BreadCount;    // Number of rotis/paranthas

  // ── Meal 2 · Night (gravy vegetable or dal) ──────────────────────────────
  String meal2Main;       // Gravy sabzi or dal, e.g. "Dal Tadka"
  int meal2BreadCount;    // Number of rotis (always Roti at night)

  // ── Tea ──────────────────────────────────────────────────────────────────
  String tea;

  DayPlan({
    required this.weekday,
    this.memberCount = 4,
    this.riceType = 'Rice',
    this.meal1Sabzi = 'Aloo Gobi',
    this.meal1BreadType = 'Roti',
    this.meal1BreadCount = 16,
    this.meal2Main = 'Dal Tadka',
    this.meal2BreadCount = 16,
    this.tea = 'Masala Chai',
  });

  /// Sunday special: Meal 1 is always Aloo Puri (locked).
  bool get isSunday => weekday == 7;

  static const List<String> _dayNames = [
    '', 'Monday', 'Tuesday', 'Wednesday',
    'Thursday', 'Friday', 'Saturday', 'Sunday',
  ];

  static const List<String> _shortNames = [
    '', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun',
  ];

  String get dayName  => _dayNames[weekday];
  String get shortName => _shortNames[weekday];

  // ── Serialization ─────────────────────────────────────────────────────────

  Map<String, dynamic> toJson() => {
    'weekday': weekday,
    'memberCount': memberCount,
    'riceType': riceType,
    'meal1Sabzi': meal1Sabzi,
    'meal1BreadType': meal1BreadType,
    'meal1BreadCount': meal1BreadCount,
    'meal2Main': meal2Main,
    'meal2BreadCount': meal2BreadCount,
    'tea': tea,
  };

  factory DayPlan.fromJson(Map<String, dynamic> json) => DayPlan(
    weekday: json['weekday'] as int,
    memberCount: json['memberCount'] as int? ?? 4,
    riceType: json['riceType'] ?? json['meal2RiceType'] ?? json['meal1RiceType'] as String? ?? 'Rice', // fallback for old data
    meal1Sabzi: json['meal1Sabzi'] as String? ?? 'Aloo Gobi',
    meal1BreadType: json['meal1BreadType'] as String? ?? 'Roti',
    meal1BreadCount: json['meal1BreadCount'] as int? ?? 16,
    meal2Main: json['meal2Main'] as String? ?? 'Dal Tadka',
    meal2BreadCount: json['meal2BreadCount'] as int? ?? 16,
    tea: json['tea'] as String? ?? 'Masala Chai',
  );
}
