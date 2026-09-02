import 'package:shared_preferences/shared_preferences.dart';
import '../models/week_plan.dart';

/// Handles all SharedPreferences persistence for DailyDish.
class StorageService {
  // ──────────────────────────────── keys ────────────────────────────────────
  static const _weekPlanKey = 'week_plan_v1';
  static const _dishListKey = 'dish_list_v1';

  // ──────────────────────────────── default data ────────────────────────────

  static const List<String> defaultDishes = [
    'Dal Tadka',
    'Paneer Butter Masala',
    'Aloo Gobi',
    'Rajma',
    'Chole',
    'Mix Veg',
    'Palak Paneer',
    'Poha',
    'Upma',
    'Paratha',
    'Masala Chai',
    'Ginger Tea',
    'Cardamom Tea',
  ];

  // ──────────────────────────────── week plan ───────────────────────────────

  /// Persists the full week plan as JSON.
  Future<void> saveWeekPlan(WeekPlan plan) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_weekPlanKey, plan.toJsonString());
  }

  /// Loads the week plan from storage. Returns defaults when nothing is saved.
  Future<WeekPlan> loadWeekPlan() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_weekPlanKey);
    if (raw == null || raw.isEmpty) return WeekPlan.defaultPlan();
    try {
      return WeekPlan.fromJsonString(raw);
    } catch (_) {
      return WeekPlan.defaultPlan();
    }
  }

  // ──────────────────────────────── dish list ───────────────────────────────

  /// Persists the custom dish library.
  Future<void> saveDishList(List<String> dishes) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_dishListKey, dishes);
  }

  /// Loads the dish library. Returns [defaultDishes] if nothing saved yet.
  Future<List<String>> loadDishList() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getStringList(_dishListKey);
    if (saved == null || saved.isEmpty) return List<String>.from(defaultDishes);
    return saved;
  }
}
