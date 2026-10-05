import 'package:flutter/material.dart';
import 'package:sliver_dashboard/sliver_dashboard.dart';

/// Centralized style definitions for the JPhone Dashboard.
///
/// Ensures package default chrome (borders, displaced outlines, "L"-shaped resize handles)
/// are completely disabled/transparent so JPhone's custom visual editor chrome owns the presentation.
class JPhoneDashboardStyles {
  const JPhoneDashboardStyles._();

  static DashboardItemStyle get itemStyle {
    return const DashboardItemStyle(
      // Providing an empty BoxDecoration completely disables the package's
      // default focus/selection border without leaving any stroke or padding inset.
      focusDecoration: BoxDecoration(),
      focusColor: Colors.transparent,
      activeColor: Colors.transparent,

      borderRadius: BorderRadius.all(Radius.circular(16)),

      // Suppress displaced & nest target outlines to avoid visual conflicts
      nestTargetDecoration: BoxDecoration(),
      nestTargetColor: Colors.transparent,
      displacedDecoration: BoxDecoration(),
      displacedColor: Colors.transparent,
    );
  }

  static GridStyle get gridStyle {
    return GridStyle(
      lineColor: Colors.black.withValues(alpha: 0.04),
      lineWidth: 1,

      fillColor: const Color(0xFF000000).withValues(alpha: 0.08),

      // Setting handleColor to transparent completely suppresses the package's
      // default "L"-shaped resize handles while preserving the underlying hit-test engine.
      handleColor: Colors.transparent,
    );
  }
}