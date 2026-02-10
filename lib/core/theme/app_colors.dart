/// App color palette for TestMail Reader
/// Black and white monochrome theme for developer-tool aesthetic
library;

import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Primary - Warm Orange
  static const Color primaryLight = Color(0xFFFF9800); // Orange
  static const Color primaryDark = Color(0xFFFF9800);  // Same for single theme

  // Secondary - Yellow
  static const Color secondary = Color(0xFFFFEB3B); // Yellow

  // Surface colors - Light theme (Cream/White)
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color cardLight = Color(0xFFFFFFFF);
  static const Color backgroundLight = Color(0xFFFFFDE7); // Cream

  // Surface colors - Dark theme (Unused/Same)
  static const Color surfaceDark = Color(0xFFFFFFFF);
  static const Color cardDark = Color(0xFFFFFFFF);
  static const Color backgroundDark = Color(0xFFFFFDE7);

  // Text colors
  static const Color textPrimaryLight = Color(0xFF212121);
  static const Color textSecondaryLight = Color(0xFF757575);
  static const Color textPrimaryDark = Color(0xFF212121);
  static const Color textSecondaryDark = Color(0xFF757575);

  // Status colors
  static const Color success = Color(0xFF4CAF50);
  static const Color error = Color(0xFFE64A19); // Deep Orange
  static const Color warning = Color(0xFFFBC02D); // Darker Yellow
  static const Color info = Color(0xFF2196F3);

  // Unread indicator
  static const Color unreadDot = Color(0xFFFF9800); // Orange
  static const Color unreadDotDark = Color(0xFFFF9800);

  // Code/developer aesthetic (Kept for details if needed, or adapted)
  static const Color codeBackground = Color(0xFFFFF59D); // Light Yellow
  static const Color codeForeground = Color(0xFF212121);

  // Dividers
  static const Color dividerLight = Color(0xFFFFE0B2); // Light Orange
  static const Color dividerDark = Color(0xFFFFE0B2); 
}
