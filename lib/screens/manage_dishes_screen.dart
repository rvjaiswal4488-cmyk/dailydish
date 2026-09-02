import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../services/storage_service.dart';

/// Screen for managing the household's dish library.
/// Users can add and delete dish names; these are used as quick-fill suggestions.
class ManageDishesScreen extends StatefulWidget {
  final List<String> dishes;
  final void Function(List<String>) onDishesUpdated;

  const ManageDishesScreen({
    super.key,
    required this.dishes,
    required this.onDishesUpdated,
  });

  @override
  State<ManageDishesScreen> createState() => _ManageDishesScreenState();
}

class _ManageDishesScreenState extends State<ManageDishesScreen> {
  late List<String> _dishes;
  final _storage = StorageService();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _dishes = List<String>.from(widget.dishes);
  }

  // ──────────────────────────────── CRUD ───────────────────────────────────

  Future<void> _addDish() async {
    final ctrl = TextEditingController();
    final result = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: const Color(0xFFFFF8F0),
        title: Text(
          'Add Dish',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w700,
            color: const Color(0xFFE65100),
          ),
        ),
        content: TextField(
          controller: ctrl,
          autofocus: true,
          style: GoogleFonts.inter(),
          decoration: InputDecoration(
            hintText: 'Dish name…',
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFE65100), width: 2),
            ),
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
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFE65100),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            child: Text('Add',
                style: GoogleFonts.inter(
                    fontWeight: FontWeight.w600, color: Colors.white)),
          ),
        ],
      ),
    );

    if (result != null && result.isNotEmpty && !_dishes.contains(result)) {
      setState(() => _dishes.add(result));
      await _storage.saveDishList(_dishes);
      widget.onDishesUpdated(_dishes);
    }
  }

  Future<void> _deleteDish(String dish) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: const Color(0xFFFFF8F0),
        title: Text('Remove Dish',
            style: GoogleFonts.poppins(fontWeight: FontWeight.w700)),
        content: Text(
          'Remove "$dish" from your dish library?',
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
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            child: Text('Remove',
                style: GoogleFonts.inter(
                    fontWeight: FontWeight.w600, color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      setState(() => _dishes.remove(dish));
      await _storage.saveDishList(_dishes);
      widget.onDishesUpdated(_dishes);
    }
  }

  // ──────────────────────────────── build ──────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final filtered = _searchQuery.isEmpty
        ? _dishes
        : _dishes
            .where((d) => d.toLowerCase().contains(_searchQuery.toLowerCase()))
            .toList();

    return Scaffold(
      backgroundColor: const Color(0xFFFFF8F0),
      appBar: AppBar(
        title: Text(
          'Dish Library',
          style: GoogleFonts.poppins(
              fontWeight: FontWeight.w700, color: Colors.white),
        ),
        backgroundColor: const Color(0xFFE65100),
        elevation: 0,
        centerTitle: false,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Padding(
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
        ),
      ),

      // ── Body ─────────────────────────────────────────────────────────────
      body: filtered.isEmpty
          ? _buildEmptyState()
          : ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              itemCount: filtered.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final dish = filtered[index];
                return _DishTile(
                  dish: dish,
                  onDelete: () => _deleteDish(dish),
                );
              },
            ),

      // ── FAB ───────────────────────────────────────────────────────────────
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addDish,
        backgroundColor: const Color(0xFFE65100),
        icon: const Icon(Icons.add_rounded, color: Colors.white),
        label: Text(
          'Add Dish',
          style: GoogleFonts.poppins(
              fontWeight: FontWeight.w600, color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.no_food_rounded, size: 72, color: Colors.orange.shade200),
          const SizedBox(height: 16),
          Text(
            _searchQuery.isNotEmpty
                ? 'No dishes match "$_searchQuery"'
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
}

// ──────────────────────────────── _DishTile ──────────────────────────────────

class _DishTile extends StatelessWidget {
  final String dish;
  final VoidCallback onDelete;

  const _DishTile({required this.dish, required this.onDelete});

  @override
  Widget build(BuildContext context) {
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
              color: const Color(0xFFFFE0B2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.restaurant_menu_rounded,
              color: Color(0xFFE65100),
              size: 18,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
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
