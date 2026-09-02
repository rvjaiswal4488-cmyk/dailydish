import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../models/day_plan.dart';
import '../models/week_plan.dart';
import '../services/storage_service.dart';
import '../services/translation_service.dart';
import '../widgets/slot_edit_sheet.dart';
import '../widgets/bread_count_editor.dart';
import '../widgets/toggle_chip.dart';

/// Displays all 7 days of the week plan as expandable tiles.
class WeeklyPlanScreen extends StatefulWidget {
  final WeekPlan weekPlan;
  final List<String> drySabzis;
  final List<String> gravyDals;
  final void Function(WeekPlan) onPlanUpdated;
  final VoidCallback onToggleTranslation;

  const WeeklyPlanScreen({
    super.key,
    required this.weekPlan,
    required this.drySabzis,
    required this.gravyDals,
    required this.onPlanUpdated,
    required this.onToggleTranslation,
  });

  @override
  State<WeeklyPlanScreen> createState() => _WeeklyPlanScreenState();
}

class _WeeklyPlanScreenState extends State<WeeklyPlanScreen> {
  final _storage = StorageService();
  final int _todayWeekday = DateTime.now().weekday;

  // ──────────────────────────────── helpers ────────────────────────────────

  Future<void> _editSlot({
    required DayPlan day,
    required String slotLabel,
    required String currentValue,
    required List<String> suggestions,
    required void Function(String) onUpdate,
  }) async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => SlotEditSheet(
        slotLabel: slotLabel,
        initialValue: currentValue,
        suggestions: suggestions,
        onSave: (newValue) async {
          setState(() => onUpdate(newValue));
          final updatedPlan = widget.weekPlan.withUpdatedDay(day);
          await _storage.saveWeekPlan(updatedPlan);
          widget.onPlanUpdated(updatedPlan);
        },
      ),
    );
  }

  Future<void> _saveInstantly(DayPlan day) async {
    final updatedPlan = widget.weekPlan.withUpdatedDay(day);
    await _storage.saveWeekPlan(updatedPlan);
    widget.onPlanUpdated(updatedPlan);
    setState(() {});
  }

  // ──────────────────────────────── build ──────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          TranslationService.tr('Weekly Plan'),
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
        backgroundColor: Theme.of(context).primaryColor,
        elevation: 0,
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.translate_rounded),
            onPressed: widget.onToggleTranslation,
            tooltip: 'Translate to Hindi',
          ),
        ],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 12),
        itemCount: widget.weekPlan.days.length,
        itemBuilder: (context, index) {
          final day = widget.weekPlan.days[index];
          final isToday = day.weekday == _todayWeekday;
          return _DayTile(
            day: day,
            isToday: isToday,
            onEditMeal1: () => _editSlot(
              day: day,
              slotLabel: TranslationService.tr('Afternoon (Dry)'),
              currentValue: day.meal1Sabzi,
              suggestions: widget.drySabzis,
              onUpdate: (v) => day.meal1Sabzi = v,
            ),
            onEditMeal2: () => _editSlot(
              day: day,
              slotLabel: TranslationService.tr('Night (Gravy/Dal)'),
              currentValue: day.meal2Main,
              suggestions: widget.gravyDals,
              onUpdate: (v) => day.meal2Main = v,
            ),
            onEditTea: () => _editSlot(
              day: day,
              slotLabel: TranslationService.tr('Tea'),
              currentValue: day.tea,
              suggestions: [...widget.drySabzis, ...widget.gravyDals],
              onUpdate: (v) => day.tea = v,
            ),
            onSaveState: () => _saveInstantly(day),
          );
        },
      ),
    );
  }
}

// ──────────────────────────────── _DayTile ────────────────────────────────────

class _DayTile extends StatelessWidget {
  final DayPlan day;
  final bool isToday;
  final VoidCallback onEditMeal1;
  final VoidCallback onEditMeal2;
  final VoidCallback onEditTea;
  final VoidCallback onSaveState;

  const _DayTile({
    required this.day,
    required this.isToday,
    required this.onEditMeal1,
    required this.onEditMeal2,
    required this.onEditTea,
    required this.onSaveState,
  });

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).primaryColor;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: isToday
            ? Border.all(color: primaryColor, width: 2)
            : Border.all(color: Colors.grey.shade100),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          initiallyExpanded: isToday,
          tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          leading: Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: isToday
                  ? primaryColor
                  : primaryColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(
                TranslationService.tr(day.shortName),
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: isToday ? Colors.white : primaryColor,
                ),
              ),
            ),
          ),
          title: Row(
            children: [
              Text(
                TranslationService.tr(day.dayName),
                style: GoogleFonts.poppins(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: isToday
                      ? primaryColor
                      : const Color(0xFF3E2723),
                ),
              ),
              if (isToday) ...[
                const SizedBox(width: 8),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: primaryColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Text(
                    TranslationService.tr('Today'),
                    style: GoogleFonts.inter(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: primaryColor,
                    ),
                  ),
                ),
              ],
            ],
          ),
          children: [
            const Divider(height: 1, indent: 16, endIndent: 16),
            const SizedBox(height: 8),
            _SlotRow(
              icon: Icons.wb_sunny_rounded,
              label: 'Meal 1 · Afternoon (Dry)',
              value: day.meal1Sabzi,
              color: const Color(0xFFFFA07A),
              onEdit: day.isSunday ? null : onEditMeal1,
              isLocked: day.isSunday,
              subItems: day.isSunday ? null : Column(
                children: [
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      ToggleChip(
                        option1: 'Roti',
                        option2: 'Parantha',
                        currentValue: day.meal1BreadType,
                        color: const Color(0xFFFFA07A),
                        onChanged: (v) {
                          day.meal1BreadType = v;
                          onSaveState();
                        },
                      ),
                      BreadCountEditor(
                        count: day.meal1BreadCount,
                        color: const Color(0xFFFFA07A),
                        onChanged: (v) {
                          day.meal1BreadCount = v;
                          onSaveState();
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const Divider(height: 16, indent: 64, endIndent: 16),
            _SlotRow(
              icon: Icons.nightlight_round,
              label: 'Meal 2 · Night (Gravy / Dal)',
              value: day.meal2Main,
              color: const Color(0xFF43A047), // Green
              onEdit: onEditMeal2,
              subItems: Column(
                children: [
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(TranslationService.tr('Roti'), style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, color: const Color(0xFF43A047))),
                      BreadCountEditor(
                        count: day.meal2BreadCount,
                        color: const Color(0xFF43A047),
                        onChanged: (v) {
                          day.meal2BreadCount = v;
                          onSaveState();
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(TranslationService.tr('Rice Selection'), style: GoogleFonts.inter(fontSize: 12, color: Colors.grey.shade600)),
                      ToggleChip(
                        option1: 'Rice',
                        option2: 'Pulao',
                        currentValue: day.riceType,
                        color: const Color(0xFF43A047),
                        onChanged: (v) {
                          day.riceType = v;
                          onSaveState();
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const Divider(height: 16, indent: 64, endIndent: 16),
            _SlotRow(
              icon: Icons.emoji_food_beverage_rounded,
              label: 'Tea',
              value: day.tea,
              color: const Color(0xFFFBC02D),
              onEdit: onEditTea,
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }
}

// ──────────────────────────────── _SlotRow ────────────────────────────────────

class _SlotRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;
  final VoidCallback? onEdit;
  final bool isLocked;
  final Widget? subItems;

  const _SlotRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
    this.onEdit,
    this.isLocked = false,
    this.subItems,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 16),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      TranslationService.tr(label),
                      style: GoogleFonts.inter(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey.shade500,
                        letterSpacing: 0.8,
                      ),
                    ),
                    DynamicTranslatedText(
                      value.isEmpty ? TranslationService.tr('— Not set') : value,
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFF3E2723),
                      ),
                    ),
                  ],
                ),
              ),
              if (isLocked)
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(Icons.lock_outline_rounded, color: Colors.grey.shade400, size: 18),
                )
              else if (onEdit != null)
                IconButton(
                  onPressed: onEdit,
                  icon: Icon(Icons.edit_rounded, color: color, size: 18),
                  tooltip: 'Edit $label',
                ),
            ],
          ),
          if (subItems != null)
            Padding(
              padding: const EdgeInsets.only(left: 44, top: 4),
              child: subItems!,
            ),
        ],
      ),
    );
  }
}
