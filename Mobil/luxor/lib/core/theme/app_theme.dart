import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants/colors.dart';

final appTheme = ThemeData(
  useMaterial3: true,
  brightness: Brightness.dark,
  scaffoldBackgroundColor: LuxorColors.background,
  colorScheme: const ColorScheme.dark(
    primary: LuxorColors.primary,
    secondary: LuxorColors.secondary,
    tertiary: LuxorColors.tertiary,
    surface: LuxorColors.surface,
    error: LuxorColors.error,
  ),
  textTheme: GoogleFonts.beVietnamProTextTheme(
    const TextTheme(
      displayLarge: TextStyle(fontSize: 32, fontWeight: FontWeight.w700, color: LuxorColors.textPrimary),
      displayMedium: TextStyle(fontSize: 28, fontWeight: FontWeight.w600, color: LuxorColors.textPrimary),
      headlineLarge: TextStyle(fontSize: 24, fontWeight: FontWeight.w600, color: LuxorColors.textPrimary),
      headlineMedium: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: LuxorColors.textPrimary),
      bodyLarge: TextStyle(fontSize: 16, fontWeight: FontWeight.w400, color: LuxorColors.textPrimary),
      bodyMedium: TextStyle(fontSize: 14, fontWeight: FontWeight.w400, color: LuxorColors.textPrimary),
      labelLarge: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: LuxorColors.textPrimary),
      labelSmall: TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: LuxorColors.textSecondary),
    ),
  ),
  appBarTheme: const AppBarTheme(
    backgroundColor: LuxorColors.background,
    elevation: 0,
    centerTitle: true,
  ),
  cardTheme: CardThemeData(
    color: LuxorColors.surface,
    elevation: 0,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
  ),
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: LuxorColors.surface,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide.none,
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: LuxorColors.surface),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: LuxorColors.primary),
    ),
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: LuxorColors.primary,
      foregroundColor: LuxorColors.textPrimary,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
  ),
);