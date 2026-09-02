import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/day_plan.dart';
import '../models/week_plan.dart';

class StorageService {
  static const _weekPlanKey = 'week_plan_v2';
  static const _drySabziKey = 'dry_sabzi_list';
  static const _gravyDalKey  = 'gravy_dal_list';

  // ── Default dish lists ─────────────────────────────────────────────────────

  static const List<String> defaultDrySabzis = [
    'Aloo Gobi', 'Bhindi', 'Aloo Matar', 'Aloo Jeera',
    'Gobhi Matar', 'Tinda', 'Lauki', 'Karela',
    'Shimla Mirch Aloo', 'Baingan Bharta', 'Aloo Puri',
  ];

  static const List<String> defaultGravyDals = [
    'Dal Tadka', 'Dal Makhani', 'Rajma', 'Chole',
    'Palak Paneer', 'Paneer Butter Masala', 'Mix Veg Gravy',
    'Kadhi Pakoda', 'Chana Dal', 'Moong Dal', 'Arhar Dal',
  ];

  // ── Default week plan ──────────────────────────────────────────────────────

  static WeekPlan get defaultWeekPlan => WeekPlan(days: [
    DayPlan(weekday: 1, meal1Sabzi: 'Aloo Gobi',       meal2Main: 'Dal Tadka',           tea: 'Masala Chai'),
    DayPlan(weekday: 2, meal1Sabzi: 'Bhindi',           meal2Main: 'Rajma',               tea: 'Masala Chai'),
    DayPlan(weekday: 3, meal1Sabzi: 'Aloo Matar',       meal2Main: 'Chole',               tea: 'Ginger Tea'),
    DayPlan(weekday: 4, meal1Sabzi: 'Tinda',            meal2Main: 'Dal Makhani',         tea: 'Masala Chai'),
    DayPlan(weekday: 5, meal1Sabzi: 'Gobhi Matar',      meal2Main: 'Palak Paneer',        tea: 'Cardamom Tea'),
    DayPlan(weekday: 6, meal1Sabzi: 'Aloo Jeera',       meal2Main: 'Mix Veg Gravy',
            meal1BreadType: 'Parantha', meal1RiceType: 'Pulao',   tea: 'Masala Chai'),
    DayPlan(weekday: 7, meal1Sabzi: 'Aloo Puri',        meal2Main: 'Chana Dal',           tea: 'Masala Chai'),
  ]);

  // ── Week plan ──────────────────────────────────────────────────────────────

  Future<WeekPlan> loadWeekPlan() async {
    final prefs = await SharedPreferences.getInstance();
    final json = prefs.getString(_weekPlanKey);
    if (json == null) return defaultWeekPlan;
    try {
      return WeekPlan.fromJson(jsonDecode(json) as Map<String, dynamic>);
    } catch (_) {
      return defaultWeekPlan;
    }
  }

  Future<void> saveWeekPlan(WeekPlan plan) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_weekPlanKey, jsonEncode(plan.toJson()));
  }

  // ── Dry sabzi list (Meal 1) ────────────────────────────────────────────────

  Future<List<String>> loadDrySabzis() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_drySabziKey) ?? List.from(defaultDrySabzis);
  }

  Future<void> saveDrySabzis(List<String> list) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_drySabziKey, list);
  }

  // ── Gravy / Dal list (Meal 2) ──────────────────────────────────────────────

  Future<List<String>> loadGravyDals() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_gravyDalKey) ?? List.from(defaultGravyDals);
  }

  Future<void> saveGravyDals(List<String> list) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_gravyDalKey, list);
  }

  // ── Legacy single-list fallback (keep for old installations) ──────────────
  Future<List<String>> loadDishList() async => loadDrySabzis();
  Future<void> saveDishList(List<String> list) async => saveDrySabzis(list);
}
