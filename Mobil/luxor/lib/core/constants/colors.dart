import 'package:flutter/material.dart';

class LuxorColors {
  // Brand
  static const primary = Color(0xFFFF4D6D);
  static const secondary = Color(0xFFFF8A00);
  static const tertiary = Color(0xFF7000FF);

  // Backgrounds
  static const background = Color(0xFF0A0B14);
  static const surface = Color(0xFF161828);
  static const surfaceElevated = Color(0xFF1E2035);
  static const cardDark = Color(0xFF141625);

  // Text
  static const textPrimary = Color(0xFFFFFFFF);
  static const textSecondary = Color(0xFF8E90A6);
  static const textMuted = Color(0xFF5A5C72);

  // Accent
  static const diamond = Color(0xFF7EDDFF);
  static const success = Color(0xFF4CAF50);
  static const error = Color(0xFFFF5252);
  static const warning = Color(0xFFFFB74D);
  static const live = Color(0xFFFF1744);

  // Gradients
  static const gradientPrimary = LinearGradient(
    colors: [Color(0xFFFF4D6D), Color(0xFFFF8A00)],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  static const gradientPrimaryVertical = LinearGradient(
    colors: [Color(0xFFFF4D6D), Color(0xFFFF8A00)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const gradientCard = LinearGradient(
    colors: [Color(0xFFFF4D6D), Color(0xFFD32F2F)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const gradientSurface = LinearGradient(
    colors: [Color(0xFF1A1D2E), Color(0xFF0A0B14)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
}
