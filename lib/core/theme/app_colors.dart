/// App color palette for DevPostBox
/// Black and white monochrome theme for developer-tool aesthetic
library;

import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Primary - Blue
  static const Color primaryLight = Color(0xFF4285F4);
  static const Color primaryDark = Color(0xFF4285F4);

  // Secondary - Green
  static const Color secondary = Color(0xFF34A853);

  // Surface colors - Light theme
  static const Color surfaceLight = Color(0xFFFFFFFF); // Pure white
  static const Color cardLight = Color(0xFFFFFFFF);
  static const Color backgroundLight = Color(0xFFF8F9FA); // Google App Light Gray

  // Surface colors - Dark theme
  static const Color surfaceDark = Color(0xFF202124); // Google Dark Gray
  static const Color cardDark = Color(0xFF202124);
  static const Color backgroundDark = Color(0xFF171717);

  // Text colors
  static const Color textPrimaryLight = Color(0xFF202124); // Google Text Gray
  static const Color textSecondaryLight = Color(0xFF5F6368); // Google Secondary Text
  static const Color textPrimaryDark = Color(0xFFE8EAED); // Light Gray
  static const Color textSecondaryDark = Color(0xFF9AA0A6); // Medium Gray

  // Status colors
  static const Color success = Color(0xFF34A853); // Green
  static const Color error = Color(0xFFEA4335); // Red
  static const Color warning = Color(0xFFFBBC05); // Yellow
  static const Color info = Color(0xFF4285F4); // Blue

  // Unread indicator 
  static const Color unreadDot = Color(0xFF4285F4); // Blue
  static const Color unreadDotDark = Color(0xFF4285F4);

  // Code/developer aesthetic 
  static const Color codeBackground = Color(0xFFF1F3F4); // Very light gray
  static const Color codeForeground = Color(0xFF202124);

  // Dividers
  static const Color dividerLight = Color(0xFFDADCE0); // Google Border Gray
  static const Color dividerDark = Color(0xFF3C4043); // Dark Border Gray
}
