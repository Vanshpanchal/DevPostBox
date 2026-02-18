/// DevPostBox - Main Entry Point
/// A secure test email reader for developers
///
/// This app connects to testmail.com API and displays
/// test emails in a clean, readable interface.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app.dart';
import 'core/services/hive_service.dart';
import 'core/services/tag_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Hive services
  final hiveService = HiveService();
  await hiveService.init();

  final tagService = TagService();
  await tagService.init();

  runApp(const ProviderScope(child: TestMailApp()));
}
