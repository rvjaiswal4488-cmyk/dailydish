import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import 'models/week_plan.dart';
import 'screens/main_shell.dart';
import 'services/rotation_service.dart';
import 'services/storage_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Force portrait orientation for a cleaner mobile experience.
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Set system overlay style to complement the warm app bar.
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
  ));

  // Load persisted data.
  final storage = StorageService();

  WeekPlan weekPlan = await storage.loadWeekPlan();
  final drySabzis = await storage.loadDrySabzis();
  final gravyDals = await storage.loadGravyDals();

  runApp(DailyMealApp(
    initialWeekPlan: weekPlan, 
    initialDrySabzis: drySabzis,
    initialGravyDals: gravyDals,
  ));
}

class DailyMealApp extends StatelessWidget {
  final WeekPlan initialWeekPlan;
  final List<String> initialDrySabzis;
  final List<String> initialGravyDals;

  const DailyMealApp({
    super.key,
    required this.initialWeekPlan,
    required this.initialDrySabzis,
    required this.initialGravyDals,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'DailyMeal',
      debugShowCheckedModeBanner: false,
      theme: _buildTheme(),
      home: MainShell(
        initialWeekPlan: initialWeekPlan,
        initialDrySabzis: initialDrySabzis,
        initialGravyDals: initialGravyDals,
      ),
    );
  }

  ThemeData _buildTheme() {
    // New premium palette
    const primaryColor = Color(0xFFD9534F); // Terracotta Red
    const backgroundColor = Color(0xFFFDFBF7); // Clean Off-White
    const textColor = Color(0xFF3E2723);

    final base = ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryColor,
        primary: primaryColor,
        secondary: const Color(0xFFFFA07A),
        surface: backgroundColor,
        brightness: Brightness.light,
      ),
      scaffoldBackgroundColor: backgroundColor,
    );

    return base.copyWith(
      textTheme: GoogleFonts.interTextTheme(base.textTheme).copyWith(
        displayLarge: GoogleFonts.poppins(
          fontSize: 32,
          fontWeight: FontWeight.w800,
          color: textColor,
        ),
        headlineMedium: GoogleFonts.poppins(
          fontSize: 22,
          fontWeight: FontWeight.w700,
          color: textColor,
        ),
        titleLarge: GoogleFonts.poppins(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: textColor,
        ),
        bodyMedium: GoogleFonts.inter(
          fontSize: 14,
          color: const Color(0xFF5D4037),
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        titleTextStyle: GoogleFonts.poppins(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: Colors.white,
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            fontSize: 15,
          ),
        ),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: primaryColor, width: 2),
        ),
      ),
    );
  }
}
