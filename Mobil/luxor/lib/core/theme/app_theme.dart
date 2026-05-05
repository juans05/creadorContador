import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
  textTheme: const TextTheme(
    displayLarge: TextStyle(fontSize: 32, fontWeight: FontWeight.w800, color: LuxorColors.textPrimary, letterSpacing: -0.5),
    displayMedium: TextStyle(fontSize: 28, fontWeight: FontWeight.w700, color: LuxorColors.textPrimary),
    headlineLarge: TextStyle(fontSize: 24, fontWeight: FontWeight.w700, color: LuxorColors.textPrimary),
    headlineMedium: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: LuxorColors.textPrimary),
    headlineSmall: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: LuxorColors.textPrimary),
    bodyLarge: TextStyle(fontSize: 16, fontWeight: FontWeight.w400, color: LuxorColors.textPrimary),
    bodyMedium: TextStyle(fontSize: 14, fontWeight: FontWeight.w400, color: LuxorColors.textPrimary),
    bodySmall: TextStyle(fontSize: 12, fontWeight: FontWeight.w400, color: LuxorColors.textSecondary),
    labelLarge: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: LuxorColors.textPrimary),
    labelSmall: TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: LuxorColors.textSecondary),
  ),
  appBarTheme: const AppBarTheme(
    backgroundColor: LuxorColors.background,
    elevation: 0,
    centerTitle: false,
    systemOverlayStyle: SystemUiOverlayStyle.light,
    titleTextStyle: TextStyle(
      color: LuxorColors.textPrimary,
      fontSize: 20,
      fontWeight: FontWeight.w700,
    ),
    iconTheme: IconThemeData(color: LuxorColors.textPrimary),
  ),
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: LuxorColors.surface,
    hintStyle: const TextStyle(color: LuxorColors.textMuted, fontSize: 14),
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: LuxorColors.surfaceElevated.withValues(alpha: 0.5)),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: LuxorColors.surfaceElevated.withValues(alpha: 0.5)),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: LuxorColors.primary, width: 1.5),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: LuxorColors.error),
    ),
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: LuxorColors.primary,
      foregroundColor: LuxorColors.textPrimary,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      textStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
    ),
  ),
  outlinedButtonTheme: OutlinedButtonThemeData(
    style: OutlinedButton.styleFrom(
      foregroundColor: LuxorColors.textPrimary,
      side: const BorderSide(color: LuxorColors.surfaceElevated),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
    ),
  ),
  dividerColor: LuxorColors.surfaceElevated,
  bottomSheetTheme: const BottomSheetThemeData(
    backgroundColor: LuxorColors.surface,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
  ),
);
