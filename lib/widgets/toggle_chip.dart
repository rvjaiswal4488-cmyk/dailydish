import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ToggleChip extends StatelessWidget {
  final String option1;
  final String option2;
  final String currentValue;
  final ValueChanged<String> onChanged;
  final Color color;

  const ToggleChip({
    Key? key,
    required this.option1,
    required this.option2,
    required this.currentValue,
    required this.onChanged,
    required this.color,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildOption(option1),
          _buildOption(option2),
        ],
      ),
    );
  }

  Widget _buildOption(String option) {
    final isSelected = option == currentValue;
    return GestureDetector(
      onTap: () {
        if (!isSelected) {
          onChanged(option);
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? color.withValues(alpha: 0.2) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          option,
          style: GoogleFonts.inter(
            fontSize: 13,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
            color: isSelected ? color : color.withValues(alpha: 0.6),
          ),
        ),
      ),
    );
  }
}
