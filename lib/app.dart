/// Main app widget
/// Handles theme and navigation based on configuration state
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/theme/app_theme.dart';
import 'core/utils/web_scrollbar.dart';
import 'features/config/presentation/config_screen.dart';
import 'features/config/providers/config_provider.dart';
import 'features/inbox/presentation/web_inbox_screen.dart';
import 'features/splash/presentation/splash_screen.dart';

class TestMailApp extends ConsumerStatefulWidget {
  const TestMailApp({super.key});

  @override
  ConsumerState<TestMailApp> createState() => _TestMailAppState();
}

class _TestMailAppState extends ConsumerState<TestMailApp> {
  @override
  void initState() {
    super.initState();
    // Check configuration on app start with minimum splash duration
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (mounted) {
        ref.read(configNotifierProvider.notifier).checkConfiguration();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final configState = ref.watch(configNotifierProvider);

    return MaterialApp(
      title: 'DevPostBox',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      // darkTheme: AppTheme.dark, // Disabled per user request
      themeMode: ThemeMode.light,
      scrollBehavior: CustomScrollBehavior(),
      home: _buildHome(configState),
    );
  }

  Widget _buildHome(ConfigState state) {
    switch (state) {
      case ConfigInitial():
      case ConfigLoading():
        return const SplashScreen();
      case ConfigNotConfigured():
      case ConfigError():
        return const ConfigScreen();
      case ConfigLoaded():
        return const WebInboxScreen();
    }
  }
}
