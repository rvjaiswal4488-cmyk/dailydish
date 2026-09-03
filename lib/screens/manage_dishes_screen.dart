import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../models/week_plan.dart';
import '../models/day_plan.dart';
import '../services/storage_service.dart';
import '../services/translation_service.dart';

/// Screen for managing the household's dish library.
/// Split into "Dry Sabzis" (Afternoon) and "Gravy / Dal" (Night).
class ManageDishesScreen extends StatefulWidget {
  final WeekPlan weekPlan;
  final List<String> drySabzis;
  final List<String> gravyDals;
  final void Function(WeekPlan) onPlanUpdated;
  final void Function(List<String>) onDrySabzisUpdated;
  final void Function(List<String>) onGravyDalsUpdated;
  final VoidCallback onToggleTranslation;

  const ManageDishesScreen({
    super.key,
    required this.weekPlan,
    required this.drySabzis,
    required this.gravyDals,
    required this.onPlanUpdated,
    required this.onDrySabzisUpdated,
    required this.onGravyDalsUpdated,
    required this.onToggleTranslation,
  });

  @override
  State<ManageDishesScreen> createState() => _ManageDishesScreenState();
}

class _ManageDishesScreenState extends State<ManageDishesScreen>
    with SingleTickerProviderStateMixin {
  late List<String> _drySabzis;
  late List<String> _gravyDals;
  final _storage = StorageService();
  String _searchQuery = '';
  late TabController _tabCtrl;

  @override
  void initState() {
    super.initState();
    _drySabzis = List<String>.from(widget.drySabzis);
    _gravyDals = List<String>.from(widget.gravyDals);
    _tabCtrl = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    super.dispose();
  }

  // ──────────────────────────────── CRUD ───────────────────────────────────

  Future<void> _addDish() async {
    final isDry = _tabCtrl.index == 0;
    final ctrl = TextEditingController();
    
    final result = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        title: Text(
          isDry ? 'Add Dry Sabzi' : 'Add Gravy / Dal',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w700,
            color: Theme.of(context).primaryColor,
          ),
        ),
        content: TextField(
          controller: ctrl,
          autofocus: true,
          style: GoogleFonts.inter(),
          decoration: InputDecoration(
            hintText: 'Dish name…',
          ),
          onSubmitted: (v) => Navigator.of(ctx).pop(v.trim()),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text('Cancel', style: GoogleFonts.inter()),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(ctx).pop(ctrl.text.trim()),
            child: Text('Add', style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );

    if (result != null && result.isNotEmpty) {
      if (isDry && !_drySabzis.contains(result)) {
        setState(() => _drySabzis.add(result));
        await _storage.saveDrySabzis(_drySabzis);
        widget.onDrySabzisUpdated(_drySabzis);
      } else if (!isDry && !_gravyDals.contains(result)) {
        setState(() => _gravyDals.add(result));
        await _storage.saveGravyDals(_gravyDals);
        widget.onGravyDalsUpdated(_gravyDals);
      }
    }
  }

  Future<void> _deleteDish(String dish, bool isDry) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        title: Text('Remove Dish',
            style: GoogleFonts.poppins(fontWeight: FontWeight.w700)),
        content: Text(
          'Remove "$dish"?',
          style: GoogleFonts.inter(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text('Cancel', style: GoogleFonts.inter()),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade600,
            ),
            child: Text('Remove', style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      if (isDry) {
        setState(() => _drySabzis.remove(dish));
        await _storage.saveDrySabzis(_drySabzis);
        widget.onDrySabzisUpdated(_drySabzis);
      } else {
        setState(() => _gravyDals.remove(dish));
        await _storage.saveGravyDals(_gravyDals);
        widget.onGravyDalsUpdated(_gravyDals);
      }

      // Synchronize deletion with the weekly plan
      bool planChanged = false;
      final newDays = <DayPlan>[];
      for (final day in widget.weekPlan.days) {
        final newDay = DayPlan(
          weekday: day.weekday,
          memberCount: day.memberCount,
          riceType: day.riceType,
          meal1Sabzi: day.meal1Sabzi == dish ? '' : day.meal1Sabzi,
          meal1BreadType: day.meal1BreadType,
          meal1BreadCount: day.meal1BreadCount,
          meal2Main: day.meal2Main == dish ? '' : day.meal2Main,
          meal2BreadCount: day.meal2BreadCount,
          tea: day.tea == dish ? '' : day.tea,
        );
        if (newDay.meal1Sabzi != day.meal1Sabzi ||
            newDay.meal2Main != day.meal2Main ||
            newDay.tea != day.tea) {
          planChanged = true;
        }
        newDays.add(newDay);
      }

      if (planChanged) {
        final updatedPlan = WeekPlan(days: newDays);
        await _storage.saveWeekPlan(updatedPlan);
        widget.onPlanUpdated(updatedPlan);
      }
    }
  }

  // ──────────────────────────────── build ──────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          TranslationService.tr('Dish Library'),
          style: GoogleFonts.poppins(
              fontWeight: FontWeight.w700, color: Colors.white),
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
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(110),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
                child: TextField(
                  onChanged: (v) => setState(() => _searchQuery = v),
                  style: GoogleFonts.inter(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: 'Search dishes…',
                    hintStyle:
                        GoogleFonts.inter(color: Colors.white.withValues(alpha: 0.65)),
                    filled: true,
                    fillColor: Colors.white.withValues(alpha: 0.18),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    prefixIcon:
                        const Icon(Icons.search_rounded, color: Colors.white),
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              ),
              TabBar(
                controller: _tabCtrl,
                indicatorColor: Colors.white,
                labelColor: Colors.white,
                unselectedLabelColor: Colors.white.withValues(alpha: 0.6),
                labelStyle: GoogleFonts.inter(fontWeight: FontWeight.w700),
                tabs: [
                  Tab(text: TranslationService.tr('Afternoon (Dry)')),
                  Tab(text: TranslationService.tr('Night (Gravy/Dal)')),
                ],
              ),
            ],
          ),
        ),
      ),

      // ── Body ─────────────────────────────────────────────────────────────
      body: TabBarView(
        controller: _tabCtrl,
        children: [
          _buildList(_drySabzis, true),
          _buildList(_gravyDals, false),
        ],
      ),

      // ── FAB ───────────────────────────────────────────────────────────────
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addDish,
        backgroundColor: Theme.of(context).primaryColor,
        icon: const Icon(Icons.add_rounded, color: Colors.white),
        label: Text(
          TranslationService.tr('Add Dish'),
          style: GoogleFonts.poppins(
              fontWeight: FontWeight.w600, color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildList(List<String> list, bool isDry) {
    final filtered = _searchQuery.isEmpty
        ? list
        : list
            .where((d) => d.toLowerCase().contains(_searchQuery.toLowerCase()))
            .toList();

    if (filtered.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.no_food_rounded, size: 72, color: Colors.orange.shade200),
            const SizedBox(height: 16),
            Text(
              _searchQuery.isNotEmpty
                  ? 'No matching dishes'
                  : 'No dishes yet.\nTap + to add your first!',
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 16,
                color: Colors.grey.shade500,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      itemCount: filtered.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final dish = filtered[index];
        return _DishTile(
          dish: dish,
          onDelete: () => _deleteDish(dish, isDry),
        );
      },
    );
  }
}

// ──────────────────────────────── _DishTile ──────────────────────────────────

class _DishTile extends StatelessWidget {
  final String dish;
  final VoidCallback onDelete;

  const _DishTile({required this.dish, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).primaryColor;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: primaryColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              Icons.restaurant_menu_rounded,
              color: primaryColor,
              size: 18,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: DynamicTranslatedText(
              dish,
              style: GoogleFonts.inter(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: const Color(0xFF3E2723),
              ),
            ),
          ),
          IconButton(
            onPressed: onDelete,
            icon: Icon(Icons.delete_outline_rounded,
                color: Colors.red.shade400, size: 20),
            tooltip: 'Delete',
          ),
        ],
      ),
    );
  }
}
