/// TestMail Reader - Main Entry Point
/// A secure test email reader for developers
///
/// This app connects to testmail.com API and displays
/// test emails in a clean, readable interface.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app.dart';
import 'core/services/hive_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  final hiveService = HiveService();
  await hiveService.init();
  
  runApp(
    const ProviderScope(
      child: TestMailApp(),
    ),
  );
}
