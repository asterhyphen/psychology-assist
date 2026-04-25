import 'package:flutter/material.dart';

/// Purple-white wellness palette with soft neon accents.
class AppColors {
  static const Color deepViolet = Color(0xFF4C1D95);
  static const Color neonViolet = Color(0xFF8B5CF6);
  static const Color neonPink = Color(0xFFEC5CFF);
  static const Color neonCyan = Color(0xFF22D3EE);
  static const Color gradientStart = Color(0xFFFFFFFF);
  static const Color gradientMid = Color(0xFFF4E8FF);
  static const Color gradientEnd = Color(0xFFE9D5FF);

  // Light Theme Colors
  static const Color lightBg = Color(0xFFFBF7FF);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightPrimary = neonViolet;
  static const Color lightSecondary = neonCyan;
  static const Color lightAccent = neonPink;
  static const Color lightText = Color(0xFF241334);
  static const Color lightSubtext = Color(0xFF746086);
  static const Color lightBorder = Color(0xFFEADCF8);
  static const Color lightDivider = Color(0xFFF4ECFB);

  // Dark Theme Colors
  static const Color darkBg = Color(0xFF0F1419);
  static const Color darkSurface = Color(0xFF1A1E27);
  static const Color darkPrimary = Color(0xFF7BA3FF); // Lighter blue for dark
  static const Color darkSecondary = Color(0xFF7FD9BE); // Lighter green
  static const Color darkAccent = Color(0xFFF5B5AA); // Lighter coral
  static const Color darkText = Color(0xFFF3F4F6); // Light gray
  static const Color darkSubtext = Color(0xFFD1D5DB); // Medium gray
  static const Color darkBorder = Color(0xFF374151); // Dark gray
  static const Color darkDivider = Color(0xFF1F2937); // Very dark gray

  // Universal semantic colors
  static const Color success = Color(0xFF10B981);
  static const Color warning = Color(0xFFF59E0B);
  static const Color error = Color(0xFFEF4444);
  static const Color info = Color(0xFF3B82F6);

  // Mood colors (for mood logging)
  static const Color moodExcellent = Color(0xFF22D3EE); // Cyan
  static const Color moodGood = Color(0xFF8B5CF6); // Violet
  static const Color moodNeutral = Color(0xFFFCD34D); // Yellow
  static const Color moodPoor = Color(0xFFF87171); // Red
  static const Color moodTerrible = Color(0xFF9333EA); // Purple

  // Overlay & transparency
  static const Color overlayDark = Color(0x80000000);
  static const Color overlayLight = Color(0x1A000000);
}
