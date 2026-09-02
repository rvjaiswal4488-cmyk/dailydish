import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../models/week_plan.dart';
import '../services/storage_service.dart';
import '../services/translation_service.dart';
import '../widgets/meal_card.dart';
import '../widgets/slot_edit_sheet.dart';
import '../widgets/bread_count_editor.dart';
import '../widgets/toggle_chip.dart';

class HomeScreen extends StatefulWidget {
  final WeekPlan weekPlan;
  final List<String> drySabzis;
  final List<String> gravyDals;
  final void Function(WeekPlan) onPlanUpdated;
  final VoidCallback onToggleTranslation;

  const HomeScreen({
    super.key,
    required this.weekPlan,
    required this.drySabzis,
    required this.gravyDals,
    required this.onPlanUpdated,
    required this.onToggleTranslation,
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
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: FadeTransition(
        opacity: _fadeAnim,
        child: CustomScrollView(
          slivers: [
            // ── App Bar ───────────────────────────────────────────────────
            SliverAppBar(
              expandedHeight: 180,
              pinned: true,
              backgroundColor: Theme.of(context).primaryColor,
              actions: [
                IconButton(
                  icon: const Icon(Icons.translate_rounded),
                  onPressed: widget.onToggleTranslation,
                  tooltip: 'Translate to Hindi',
                ),
              ],
              flexibleSpace: FlexibleSpaceBar(
                background: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Theme.of(context).primaryColor, const Color(0xFFE57373)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  padding: const EdgeInsets.fromLTRB(20, 80, 20, 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        TranslationService.tr(_greeting),
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

            // ── Members Count & Title ──────────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        TranslationService.tr("Today's Menu (Afternoon Prep)"),
                        style: GoogleFonts.poppins(
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF8E0000), // Deep red
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          )
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            TranslationService.tr('Members'),
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey.shade700,
                            ),
                          ),
                          const SizedBox(width: 8),
                          BreadCountEditor(
                            count: today.memberCount,
                            color: Theme.of(context).primaryColor,
                            onChanged: (v) {
                              today.memberCount = v;
                              _saveInstantly();
                            },
                          ),
                        ],
                      ),
                    )
                  ],
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
                  Color(0xFFFFA07A),
                  Color(0xFFFF7F50),
                ],
                onEdit: today.isSunday ? null : () => _editSlot(
                  TranslationService.tr('Afternoon (Dry)'),
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
                riceRow: null, // Rice is now only configured in Meal 2
              ),
            ),

            // ── Meal 2 card ───────────────────────────────────────────────
            SliverToBoxAdapter(
              child: MealCard(
                slotName: 'Meal 2 · Night (Gravy / Dal)',
                icon: Icons.nightlight_round,
                dishName: today.meal2Main,
                gradientColors: const [
                  Color(0xFF43A047), // Fresh Green
                  Color(0xFF1B5E20), // Dark Green
                ],
                onEdit: () => _editSlot(
                  TranslationService.tr('Night (Gravy/Dal)'),
                  today.meal2Main,
                  widget.gravyDals,
                  (v) => today.meal2Main = v,
                ),
                breadRow: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      TranslationService.tr('Roti'),
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
                  currentValue: today.riceType,
                  color: Colors.white,
                  onChanged: (v) {
                    today.riceType = v;
                    _saveInstantly();
                  },
                ),
              ),
            ),

            // ── Tea card ──────────────────────────────────────────────────
            SliverToBoxAdapter(
              child: MealCard(
                slotName: 'Tea',
                icon: Icons.emoji_food_beverage_rounded,
                dishName: today.tea,
                gradientColors: const [
                  Color(0xFFFBC02D),
                  Color(0xFFF57F17),
                ],
                onEdit: () => _editSlot(
                  TranslationService.tr('Tea'),
                  today.tea,
                  [...widget.drySabzis, ...widget.gravyDals],
                  (v) => today.tea = v,
                ),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 32)),
          ],
        ),
      ),
    );
  }
}
