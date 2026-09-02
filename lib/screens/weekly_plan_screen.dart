import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../models/day_plan.dart';
import '../models/week_plan.dart';
import '../services/storage_service.dart';
import '../widgets/slot_edit_sheet.dart';

/// Displays all 7 days of the week plan as expandable tiles.
class WeeklyPlanScreen extends StatefulWidget {
  final WeekPlan weekPlan;
  final List<String> dishes;
  final void Function(WeekPlan) onPlanUpdated;

  const WeeklyPlanScreen({
    super.key,
    required this.weekPlan,
    required this.dishes,
    required this.onPlanUpdated,
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
    required void Function(String) onUpdate,
  }) async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => SlotEditSheet(
        slotLabel: slotLabel,
        initialValue: currentValue,
        suggestions: widget.dishes,
        onSave: (newValue) async {
          setState(() => onUpdate(newValue));
          final updatedPlan = widget.weekPlan.withUpdatedDay(day);
          await _storage.saveWeekPlan(updatedPlan);
          widget.onPlanUpdated(updatedPlan);
        },
      ),
    );
  }

  // ──────────────────────────────── build ──────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF8F0),
      appBar: AppBar(
        title: Text(
          'Weekly Plan',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
        backgroundColor: const Color(0xFFE65100),
        elevation: 0,
        centerTitle: false,
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
              slotLabel: 'Meal 1 (Lunch)',
              currentValue: day.meal1,
              onUpdate: (v) => day.meal1 = v,
            ),
            onEditMeal2: () => _editSlot(
              day: day,
              slotLabel: 'Meal 2 (Dinner)',
              currentValue: day.meal2,
              onUpdate: (v) => day.meal2 = v,
            ),
            onEditTea: () => _editSlot(
              day: day,
              slotLabel: 'Tea',
              currentValue: day.tea,
              onUpdate: (v) => day.tea = v,
            ),
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

  const _DayTile({
    required this.day,
    required this.isToday,
    required this.onEditMeal1,
    required this.onEditMeal2,
    required this.onEditTea,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: isToday
            ? Border.all(color: const Color(0xFFE65100), width: 2)
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
                  ? const Color(0xFFE65100)
                  : const Color(0xFFFFE0B2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(
                day.shortName,
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: isToday ? Colors.white : const Color(0xFFBF360C),
                ),
              ),
            ),
          ),
          title: Row(
            children: [
              Text(
                day.dayName,
                style: GoogleFonts.poppins(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: isToday
                      ? const Color(0xFFE65100)
                      : const Color(0xFF3E2723),
                ),
              ),
              if (isToday) ...[
                const SizedBox(width: 8),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFE0B2),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Text(
                    'Today',
                    style: GoogleFonts.inter(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFFE65100),
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
              icon: Icons.restaurant_rounded,
              label: 'Meal 1',
              value: day.meal1,
              color: const Color(0xFFFF7043),
              onEdit: onEditMeal1,
            ),
            _SlotRow(
              icon: Icons.soup_kitchen_rounded,
              label: 'Meal 2',
              value: day.meal2,
              color: const Color(0xFFBF360C),
              onEdit: onEditMeal2,
            ),
            _SlotRow(
              icon: Icons.emoji_food_beverage_rounded,
              label: 'Tea',
              value: day.tea,
              color: const Color(0xFFFFB300),
              onEdit: onEditTea,
            ),
            const SizedBox(height: 8),
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
  final VoidCallback onEdit;

  const _SlotRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Row(
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
                  label,
                  style: GoogleFonts.inter(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade500,
                    letterSpacing: 0.8,
                  ),
                ),
                Text(
                  value.isEmpty ? '— Not set' : value,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF3E2723),
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: onEdit,
            icon: Icon(Icons.edit_rounded, color: color, size: 18),
            tooltip: 'Edit $label',
          ),
        ],
      ),
    );
  }
}
