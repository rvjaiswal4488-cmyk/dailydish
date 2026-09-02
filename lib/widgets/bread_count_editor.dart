import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class BreadCountEditor extends StatelessWidget {
  final int count;
  final ValueChanged<int> onChanged;
  final Color color;

  const BreadCountEditor({
    Key? key,
    required this.count,
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
          _buildButton(
            icon: Icons.remove,
            onTap: () {
              if (count > 1) {
                onChanged(count - 1);
              }
            },
          ),
          SizedBox(
            width: 32,
            child: Text(
              '$count',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ),
          _buildButton(
            icon: Icons.add,
            onTap: () {
              if (count < 50) {
                onChanged(count + 1);
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildButton({required IconData icon, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Icon(
          icon,
          size: 16,
          color: color,
        ),
      ),
    );
  }
}
