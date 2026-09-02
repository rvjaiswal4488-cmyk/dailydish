import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../models/week_plan.dart';
import '../services/storage_service.dart';
import '../widgets/meal_card.dart';
import '../widgets/slot_edit_sheet.dart';

/// The "Today" tab — shows today's 3 meal slots in beautiful gradient cards.
class HomeScreen extends StatefulWidget {
  final WeekPlan weekPlan;
  final List<String> dishes;
  final void Function(WeekPlan) onPlanUpdated;

  const HomeScreen({
    super.key,
    required this.weekPlan,
    required this.dishes,
    required this.onPlanUpdated,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _fadeCtrl;
  late Animation<double> _fadeAnim;

  final _storage = StorageService();

  @override
  void initState() {
    super.initState();
    _fadeCtrl =
        AnimationController(vsync: this, duration: const Duration(milliseconds: 600));
    _fadeAnim = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeIn);
    _fadeCtrl.forward();
  }

  @override
  void dispose() {
    _fadeCtrl.dispose();
    super.dispose();
  }

  // ──────────────────────────────── greeting ────────────────────────────────

  String get _greeting {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning! 👋';
    if (hour < 17) return 'Good Afternoon! 👋';
    return 'Good Evening! 👋';
  }

  // ──────────────────────────────── edit logic ─────────────────────────────

  void _editSlot(String slotLabel, String currentValue,
      void Function(String) onUpdate) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => SlotEditSheet(
        slotLabel: slotLabel,
        initialValue: currentValue,
        suggestions: widget.dishes,
        onSave: (newValue) async {
          onUpdate(newValue);
          final today = widget.weekPlan.todaysPlan;
          final updatedPlan = widget.weekPlan.withUpdatedDay(today);
          await _storage.saveWeekPlan(updatedPlan);
          widget.onPlanUpdated(updatedPlan);
          setState(() {});
        },
      ),
    );
  }

  // ──────────────────────────────── build ──────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final today = widget.weekPlan.todaysPlan;
    final now = DateTime.now();
    final dateStr = DateFormat('EEEE, d MMMM yyyy').format(now);

    return Scaffold(
      backgroundColor: const Color(0xFFFFF8F0),
      body: FadeTransition(
        opacity: _fadeAnim,
        child: CustomScrollView(
          slivers: [
            // ── App Bar ───────────────────────────────────────────────────
            SliverAppBar(
              expandedHeight: 160,
              pinned: true,
              backgroundColor: const Color(0xFFE65100),
              flexibleSpace: FlexibleSpaceBar(
                background: Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFFE65100), Color(0xFFFF8F00)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  padding: const EdgeInsets.fromLTRB(20, 60, 20, 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        _greeting,
                        style: GoogleFonts.poppins(
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        dateStr,
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          color: Colors.white.withValues(alpha: 0.85),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // ── Section label ─────────────────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                child: Text(
                  "Today's Menu",
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFFBF360C),
                  ),
                ),
              ),
            ),

            // ── Meal 1 card ───────────────────────────────────────────────
            SliverToBoxAdapter(
              child: MealCard(
                slotName: 'Meal 1 · Lunch',
                icon: Icons.restaurant_rounded,
                dishName: today.meal1,
                gradientColors: const [
                  Color(0xFFFF7043),
                  Color(0xFFE64A19),
                ],
                onEdit: () => _editSlot(
                  'Meal 1 (Lunch)',
                  today.meal1,
                  (v) => today.meal1 = v,
                ),
              ),
            ),

            // ── Meal 2 card ───────────────────────────────────────────────
            SliverToBoxAdapter(
              child: MealCard(
                slotName: 'Meal 2 · Dinner',
                icon: Icons.soup_kitchen_rounded,
                dishName: today.meal2,
                gradientColors: const [
                  Color(0xFFBF360C),
                  Color(0xFF870000),
                ],
                onEdit: () => _editSlot(
                  'Meal 2 (Dinner)',
                  today.meal2,
                  (v) => today.meal2 = v,
                ),
              ),
            ),

            // ── Tea card ──────────────────────────────────────────────────
            SliverToBoxAdapter(
              child: MealCard(
                slotName: '☕ Tea',
                icon: Icons.emoji_food_beverage_rounded,
                dishName: today.tea,
                gradientColors: const [
                  Color(0xFFFFB300),
                  Color(0xFFF57F17),
                ],
                onEdit: () => _editSlot(
                  'Tea',
                  today.tea,
                  (v) => today.tea = v,
                ),
              ),
            ),

            // ── Footer note ───────────────────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFE0B2),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.info_outline_rounded,
                          color: Color(0xFFE65100), size: 18),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Meal plan auto-rotates every Saturday with fresh dishes!',
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            color: const Color(0xFFBF360C),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 16)),
          ],
        ),
      ),
    );
  }
}
