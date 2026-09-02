import 'package:flutter/material.dart';
import 'package:translator/translator.dart';

class TranslationService {
  static final _translator = GoogleTranslator();
  static bool isHindi = false;
  
  // Cache for dynamic translations
  static final Map<String, String> _cache = {};

  // Static dictionary for instant UI translation
  static const Map<String, String> _staticDict = {
    'Today': 'आज',
    'Weekly': 'साप्ताहिक',
    'Dishes': 'व्यंजन',
    'DailyMeal': 'DailyMeal',
    "Today's Menu (Afternoon Prep)": 'आज का मेनू (दोपहर की तैयारी)',
    'Meal 1 · Afternoon (Dry)': 'भोजन 1 · दोपहर (सूखी सब्जी)',
    'Meal 2 · Night (Gravy / Dal)': 'भोजन 2 · रात (ग्रेवी / दाल)',
    'Tea': 'चाय',
    'Roti': 'रोटी',
    'Parantha': 'पराठा',
    'Rice': 'चावल',
    'Pulao': 'पुलाव',
    'Members': 'सदस्य',
    'Rice Selection': 'चावल का चयन',
    'Weekly Plan': 'साप्ताहिक योजना',
    'Dish Library': 'व्यंजन सूची',
    'Afternoon (Dry)': 'दोपहर (सूखी)',
    'Night (Gravy/Dal)': 'रात (ग्रेवी/दाल)',
    'Add Dish': 'व्यंजन जोड़ें',
  };

  /// Translates static UI text instantly using the dictionary.
  static String tr(String text) {
    if (!isHindi) return text;
    return _staticDict[text] ?? text;
  }

  /// Translates dynamic text (like custom dish names) using Google Translate API.
  /// Caches the result to avoid rate limits.
  static Future<String> translateDynamic(String text) async {
    if (!isHindi || text.isEmpty || text == '—  Not set' || text == '— Not set') return text;
    
    if (_cache.containsKey(text)) {
      return _cache[text]!;
    }
    
    try {
      final translation = await _translator.translate(text, from: 'en', to: 'hi');
      _cache[text] = translation.text;
      return translation.text;
    } catch (e) {
      return text; // fallback to English on error
    }
  }
}

class DynamicTranslatedText extends StatefulWidget {
  final String text;
  final TextStyle? style;
  final TextAlign? textAlign;

  const DynamicTranslatedText(
    this.text, {
    super.key,
    this.style,
    this.textAlign,
  });

  @override
  State<DynamicTranslatedText> createState() => _DynamicTranslatedTextState();
}

class _DynamicTranslatedTextState extends State<DynamicTranslatedText> {
  String _translatedText = '';

  @override
  void initState() {
    super.initState();
    _translate();
  }

  @override
  void didUpdateWidget(DynamicTranslatedText oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.text != widget.text || TranslationService.isHindi) {
      _translate();
    }
  }

  Future<void> _translate() async {
    _translatedText = widget.text;
    if (TranslationService.isHindi) {
      final t = await TranslationService.translateDynamic(widget.text);
      if (mounted) {
        setState(() {
          _translatedText = t;
        });
      }
    } else {
      if (mounted) {
        setState(() {});
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // If not Hindi, fast return original
    if (!TranslationService.isHindi) {
      return Text(widget.text, style: widget.style, textAlign: widget.textAlign);
    }
    return Text(_translatedText, style: widget.style, textAlign: widget.textAlign);
  }
}
