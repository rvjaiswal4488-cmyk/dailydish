import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../models/week_plan.dart';
import '../services/storage_service.dart';
import '../widgets/meal_card.dart';
import '../widgets/slot_edit_sheet.dart';
import '../widgets/bread_count_editor.dart';
import '../widgets/toggle_chip.dart';

class HomeScreen extends StatefulWidget {
  final WeekPlan weekPlan;
  final List<String> drySabzis;
  final List<String> gravyDals;
  final void Function(WeekPlan) onPlanUpdated;

  const HomeScreen({
    super.key,
    required this.weekPlan,
    required this.drySabzis,
    required this.gravyDals,
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

  String get _greeting {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning! 👋';
    if (hour < 17) return 'Good Afternoon! 👋';
    return 'Good Evening! 👋';
  }

  void _editSlot(String slotLabel, String currentValue,
      List<String> suggestions, void Function(String) onUpdate) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => SlotEditSheet(
        slotLabel: slotLabel,
        initialValue: currentValue,
        suggestions: suggestions,
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

  void _saveInstantly() async {
    final today = widget.weekPlan.todaysPlan;
    final updatedPlan = widget.weekPlan.withUpdatedDay(today);
    await _storage.saveWeekPlan(updatedPlan);
    widget.onPlanUpdated(updatedPlan);
    setState(() {});
  }

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
                  "Today's Menu (Afternoon Prep)",
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
                slotName: 'Meal 1 · Afternoon (Dry)',
                icon: Icons.wb_sunny_rounded,
                dishName: today.meal1Sabzi,
                gradientColors: const [
                  Color(0xFFFF7043),
                  Color(0xFFE64A19),
                ],
                onEdit: today.isSunday ? null : () => _editSlot(
                  'Meal 1 (Dry Sabzi)',
                  today.meal1Sabzi,
                  widget.drySabzis,
                  (v) => today.meal1Sabzi = v,
                ),
                breadRow: today.isSunday ? null : Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ToggleChip(
                      option1: 'Roti',
                      option2: 'Parantha',
                      currentValue: today.meal1BreadType,
                      color: Colors.white,
                      onChanged: (v) {
                        today.meal1BreadType = v;
                        _saveInstantly();
                      },
                    ),
                    const SizedBox(width: 8),
                    BreadCountEditor(
                      count: today.meal1BreadCount,
                      color: Colors.white,
                      onChanged: (v) {
                        today.meal1BreadCount = v;
                        _saveInstantly();
                      },
                    ),
                  ],
                ),
                riceRow: today.isSunday ? null : ToggleChip(
                  option1: 'Rice',
                  option2: 'Pulao',
                  currentValue: today.meal1RiceType,
                  color: Colors.white,
                  onChanged: (v) {
                    today.meal1RiceType = v;
                    _saveInstantly();
                  },
                ),
              ),
            ),

            // ── Meal 2 card ───────────────────────────────────────────────
            SliverToBoxAdapter(
              child: MealCard(
                slotName: 'Meal 2 · Night (Gravy / Dal)',
                icon: Icons.nightlight_round,
                dishName: today.meal2Main,
                gradientColors: const [
                  Color(0xFFBF360C),
                  Color(0xFF870000),
                ],
                onEdit: () => _editSlot(
                  'Meal 2 (Gravy/Dal)',
                  today.meal2Main,
                  widget.gravyDals,
                  (v) => today.meal2Main = v,
                ),
                breadRow: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Roti ',
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: Colors.white.withValues(alpha: 0.8),
                      ),
                    ),
                    const SizedBox(width: 8),
                    BreadCountEditor(
                      count: today.meal2BreadCount,
                      color: Colors.white,
                      onChanged: (v) {
                        today.meal2BreadCount = v;
                        _saveInstantly();
                      },
                    ),
                  ],
                ),
                riceRow: ToggleChip(
                  option1: 'Rice',
                  option2: 'Pulao',
                  currentValue: today.meal2RiceType,
                  color: Colors.white,
                  onChanged: (v) {
                    today.meal2RiceType = v;
                    _saveInstantly();
                  },
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
                  // Pass both lists or an empty list, doesn't matter much for tea
                  [...widget.drySabzis, ...widget.gravyDals],
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
