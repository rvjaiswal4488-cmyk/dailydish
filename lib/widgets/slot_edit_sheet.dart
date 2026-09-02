import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// A bottom sheet that lets the user type a dish name or pick a suggestion.
///
/// [initialValue] pre-fills the text field.
/// [suggestions] is the full dish library shown as chips.
/// [onSave] is called with the final dish name string when saved.
class SlotEditSheet extends StatefulWidget {
  final String slotLabel;
  final String initialValue;
  final List<String> suggestions;
  final void Function(String) onSave;

  const SlotEditSheet({
    super.key,
    required this.slotLabel,
    required this.initialValue,
    required this.suggestions,
    required this.onSave,
  });

  @override
  State<SlotEditSheet> createState() => _SlotEditSheetState();
}

class _SlotEditSheetState extends State<SlotEditSheet> {
  late final TextEditingController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = TextEditingController(text: widget.initialValue);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _save() {
    final value = _ctrl.text.trim();
    widget.onSave(value);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      // Push the sheet up when the keyboard appears.
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
        decoration: const BoxDecoration(
          color: Color(0xFFFFF8F0),
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Drag handle ─────────────────────────────────────────────
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // ── Title ────────────────────────────────────────────────────
            Text(
              'Edit ${widget.slotLabel}',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: const Color(0xFFE65100),
              ),
            ),
            const SizedBox(height: 14),

            // ── TextField ────────────────────────────────────────────────
            TextField(
              controller: _ctrl,
              autofocus: true,
              style: GoogleFonts.inter(fontSize: 16),
              decoration: InputDecoration(
                hintText: 'Type dish name…',
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(
                    color: Color(0xFFE65100),
                    width: 2,
                  ),
                ),
                prefixIcon: const Icon(Icons.restaurant_rounded,
                    color: Color(0xFFE65100)),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.clear_rounded),
                  onPressed: () => _ctrl.clear(),
                ),
              ),
              onSubmitted: (_) => _save(),
            ),
            const SizedBox(height: 16),

            // ── Suggestions label ────────────────────────────────────────
            Text(
              'Quick suggestions',
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade600,
                letterSpacing: 0.8,
              ),
            ),
            const SizedBox(height: 8),

            // ── Suggestion chips ─────────────────────────────────────────
            SizedBox(
              height: 110,
              child: SingleChildScrollView(
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: widget.suggestions.map((dish) {
                    final isSelected =
                        _ctrl.text.trim().toLowerCase() == dish.toLowerCase();
                    return GestureDetector(
                      onTap: () {
                        setState(() => _ctrl.text = dish);
                        _ctrl.selection = TextSelection.fromPosition(
                          TextPosition(offset: dish.length),
                        );
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 180),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 7,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? const Color(0xFFE65100)
                              : Colors.white,
                          borderRadius: BorderRadius.circular(30),
                          border: Border.all(
                            color: isSelected
                                ? const Color(0xFFE65100)
                                : Colors.grey.shade300,
                          ),
                        ),
                        child: Text(
                          dish,
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: isSelected
                                ? Colors.white
                                : Colors.grey.shade800,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // ── Save button ──────────────────────────────────────────────
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _save,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFE65100),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  'Save',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
