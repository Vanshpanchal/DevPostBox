/// Responsive Layout Wrapper
/// Provides responsive constraints and layouts for web
library;

import 'package:flutter/material.dart';

class ResponsiveLayout extends StatelessWidget {
  final Widget mobile;
  final Widget? tablet;
  final Widget? desktop;

  const ResponsiveLayout({
    super.key,
    required this.mobile,
    this.tablet,
    this.desktop,
  });

  static bool isMobile(BuildContext context) =>
      MediaQuery.of(context).size.width < 650;

  static bool isTablet(BuildContext context) =>
      MediaQuery.of(context).size.width >= 650 &&
      MediaQuery.of(context).size.width < 1100;

  static bool isDesktop(BuildContext context) =>
      MediaQuery.of(context).size.width >= 1100;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    if (width >= 1100) {
      return desktop ?? tablet ?? mobile;
    } else if (width >= 650) {
      return tablet ?? mobile;
    } else {
      return mobile;
    }
  }
}

/// Constrains content width for better readability on wide screens
class MaxWidthContainer extends StatelessWidget {
  final Widget child;
  final double maxWidth;
  final EdgeInsetsGeometry? padding;
  final bool center;

  const MaxWidthContainer({
    super.key,
    required this.child,
    this.maxWidth = 1200,
    this.padding,
    this.center = true,
  });

  @override
  Widget build(BuildContext context) {
    return center
        ? Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: maxWidth),
              child: padding != null
                  ? Padding(padding: padding!, child: child)
                  : child,
            ),
          )
        : ConstrainedBox(
            constraints: BoxConstraints(maxWidth: maxWidth),
            child: padding != null
                ? Padding(padding: padding!, child: child)
                : child,
          );
  }
}

/// Provides responsive padding based on screen size
class ResponsivePadding extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? mobilePadding;
  final EdgeInsetsGeometry? tabletPadding;
  final EdgeInsetsGeometry? desktopPadding;

  const ResponsivePadding({
    super.key,
    required this.child,
    this.mobilePadding,
    this.tabletPadding,
    this.desktopPadding,
  });

  @override
  Widget build(BuildContext context) {
    EdgeInsetsGeometry padding;

    if (ResponsiveLayout.isDesktop(context)) {
      padding =
          desktopPadding ?? tabletPadding ?? mobilePadding ?? EdgeInsets.zero;
    } else if (ResponsiveLayout.isTablet(context)) {
      padding = tabletPadding ?? mobilePadding ?? EdgeInsets.zero;
    } else {
      padding = mobilePadding ?? EdgeInsets.zero;
    }

    return Padding(padding: padding, child: child);
  }
}

/// Grid layout that adapts to screen size
class ResponsiveGrid extends StatelessWidget {
  final List<Widget> children;
  final int mobileColumns;
  final int tabletColumns;
  final int desktopColumns;
  final double spacing;
  final double runSpacing;

  const ResponsiveGrid({
    super.key,
    required this.children,
    this.mobileColumns = 1,
    this.tabletColumns = 2,
    this.desktopColumns = 3,
    this.spacing = 16,
    this.runSpacing = 16,
  });

  @override
  Widget build(BuildContext context) {
    int columns;

    if (ResponsiveLayout.isDesktop(context)) {
      columns = desktopColumns;
    } else if (ResponsiveLayout.isTablet(context)) {
      columns = tabletColumns;
    } else {
      columns = mobileColumns;
    }

    return Wrap(
      spacing: spacing,
      runSpacing: runSpacing,
      children: children.map((child) {
        return SizedBox(
          width:
              (MediaQuery.of(context).size.width - (spacing * (columns + 1))) /
              columns,
          child: child,
        );
      }).toList(),
    );
  }
}
