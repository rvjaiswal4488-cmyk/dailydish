import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../services/translation_service.dart';

/// A reusable, beautifully styled meal slot card.
///
/// Displays the slot name (e.g. "Meal 1"), the dish name in large text,
/// and optionally sub-rows for Bread and Rice.
class MealCard extends StatelessWidget {
  final String slotName;
  final IconData icon;
  final String dishName;
  final List<Color> gradientColors;
  final VoidCallback? onEdit;
  final Widget? breadRow;
  final Widget? riceRow;

  const MealCard({
    super.key,
    required this.slotName,
    required this.icon,
    required this.dishName,
    required this.gradientColors,
    required this.onEdit,
    this.breadRow,
    this.riceRow,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: gradientColors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: gradientColors.last.withValues(alpha: 0.20), // Softer shadow for DailyMeal
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Top Row: Icon, Slot Name, Dish Name, Edit Button ──────────────
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Icon bubble
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.25),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(icon, color: Colors.white, size: 28),
                ),
                const SizedBox(width: 16),
                
                // Text block
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        TranslationService.tr(slotName).toUpperCase(),
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: Colors.white.withValues(alpha: 0.80),
                          letterSpacing: 1.2,
                        ),
                      ),
                      const SizedBox(height: 4),
                      DynamicTranslatedText(
                        dishName.isEmpty ? TranslationService.tr('— Not set') : dishName,
                        style: GoogleFonts.poppins(
                          fontSize: 19,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Edit / Locked indicator
                if (onEdit != null)
                  GestureDetector(
                    onTap: onEdit,
                    child: Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.20),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.edit_rounded,
                        color: Colors.white,
                        size: 18,
                      ),
                    ),
                  )
                else
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.10),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.lock_outline_rounded,
                      color: Colors.white,
                      size: 18,
                    ),
                  ),
              ],
            ),
            
            // ── Optional Sub Rows (Bread, Rice) ─────────────────────────────
            if (breadRow != null || riceRow != null) ...[
              const SizedBox(height: 20),
              if (breadRow != null) ...[
                _buildSubRow('Bread', breadRow!),
                if (riceRow != null) const SizedBox(height: 12),
              ],
              if (riceRow != null) ...[
                _buildSubRow('Rice', riceRow!),
              ],
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSubRow(String label, Widget content) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            TranslationService.tr(label),
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          content,
        ],
      ),
    );
  }
}
