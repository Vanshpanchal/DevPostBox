/// Custom Scrollbar Theme for Web
/// Provides a clean, modern scrollbar appearance
library;

import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class CustomScrollBehavior extends MaterialScrollBehavior {
  @override
  Widget buildScrollbar(
    BuildContext context,
    Widget child,
    ScrollableDetails details,
  ) {
    return Scrollbar(
      controller: details.controller,
      thumbVisibility: false,
      thickness: 6,
      radius: const Radius.circular(8),
      child: child,
    );
  }
}

/// Styled scrollbar for explicit use
class WebScrollbar extends StatelessWidget {
  final Widget child;
  final ScrollController? controller;

  const WebScrollbar({super.key, required this.child, this.controller});

  @override
  Widget build(BuildContext context) {
    return RawScrollbar(
      controller: controller,
      thumbColor: AppColors.primaryLight.withValues(alpha: 0.3),
      radius: const Radius.circular(8),
      thickness: 6,
      thumbVisibility: false,
      child: child,
    );
  }
}
