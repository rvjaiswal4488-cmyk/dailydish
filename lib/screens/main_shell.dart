import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../models/week_plan.dart';
import 'home_screen.dart';
import 'manage_dishes_screen.dart';
import 'weekly_plan_screen.dart';

/// Root shell widget that owns the bottom navigation bar and tab state.
class MainShell extends StatefulWidget {
  final WeekPlan initialWeekPlan;
  final List<String> initialDrySabzis;
  final List<String> initialGravyDals;

  const MainShell({
    super.key,
    required this.initialWeekPlan,
    required this.initialDrySabzis,
    required this.initialGravyDals,
  });

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell>
    with SingleTickerProviderStateMixin {
  int _currentIndex = 0;
  late WeekPlan _weekPlan;
  late List<String> _drySabzis;
  late List<String> _gravyDals;

  // For a smooth tab-switch fade effect
  late AnimationController _tabFadeCtrl;
  late Animation<double> _tabFadeAnim;

  @override
  void initState() {
    super.initState();
    _weekPlan = widget.initialWeekPlan;
    _drySabzis = List<String>.from(widget.initialDrySabzis);
    _gravyDals = List<String>.from(widget.initialGravyDals);

    _tabFadeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
      value: 1,
    );
    _tabFadeAnim = CurvedAnimation(parent: _tabFadeCtrl, curve: Curves.easeIn);
  }

  @override
  void dispose() {
    _tabFadeCtrl.dispose();
    super.dispose();
  }

  Future<void> _switchTab(int index) async {
    if (index == _currentIndex) return;
    await _tabFadeCtrl.reverse();
    setState(() => _currentIndex = index);
    _tabFadeCtrl.forward();
  }

  // ──────────────────────────────── callbacks ───────────────────────────────

  void _onPlanUpdated(WeekPlan updated) {
    setState(() => _weekPlan = updated);
  }

  void _onDrySabzisUpdated(List<String> updated) {
    setState(() => _drySabzis = updated);
  }

  void _onGravyDalsUpdated(List<String> updated) {
    setState(() => _gravyDals = updated);
  }

  // ──────────────────────────────── build ──────────────────────────────────

  Widget _buildBody() {
    switch (_currentIndex) {
      case 0:
        return HomeScreen(
          weekPlan: _weekPlan,
          drySabzis: _drySabzis,
          gravyDals: _gravyDals,
          onPlanUpdated: _onPlanUpdated,
        );
      case 1:
        return WeeklyPlanScreen(
          weekPlan: _weekPlan,
          drySabzis: _drySabzis,
          gravyDals: _gravyDals,
          onPlanUpdated: _onPlanUpdated,
        );
      case 2:
      default:
        return ManageDishesScreen(
          drySabzis: _drySabzis,
          gravyDals: _gravyDals,
          onDrySabzisUpdated: _onDrySabzisUpdated,
          onGravyDalsUpdated: _onGravyDalsUpdated,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FadeTransition(
        opacity: _tabFadeAnim,
        child: _buildBody(),
      ),
      bottomNavigationBar: _BottomBar(
        currentIndex: _currentIndex,
        onTap: _switchTab,
      ),
    );
  }
}

// ──────────────────────────────── _BottomBar ──────────────────────────────────

class _BottomBar extends StatelessWidget {
  final int currentIndex;
  final void Function(int) onTap;

  const _BottomBar({required this.currentIndex, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: SafeArea(
        child: SizedBox(
          height: 60,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _NavItem(
                icon: Icons.wb_sunny_rounded,
                label: 'Today',
                selected: currentIndex == 0,
                onTap: () => onTap(0),
              ),
              _NavItem(
                icon: Icons.calendar_month_rounded,
                label: 'Weekly',
                selected: currentIndex == 1,
                onTap: () => onTap(1),
              ),
              _NavItem(
                icon: Icons.menu_book_rounded,
                label: 'Dishes',
                selected: currentIndex == 2,
                onTap: () => onTap(2),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color =
        selected ? const Color(0xFFE65100) : Colors.grey.shade500;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
        decoration: BoxDecoration(
          color: selected
              ? const Color(0xFFE65100).withValues(alpha: 0.10)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(height: 2),
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 10,
                fontWeight:
                    selected ? FontWeight.w700 : FontWeight.w500,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
