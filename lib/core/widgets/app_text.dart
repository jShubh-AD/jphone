import 'package:flutter/material.dart';
import '../const/theme/app_color.dart';

/// Centralized Text component for JPhone using the PlusJakartaSans typography system.
///
/// Pure, non-animated [Text] wrapper with consistent default styling and full property support.
class AppText extends StatelessWidget {
  final String text;
  final double? fontSize;
  final double? letterSpacing;
  final double? height;
  final FontWeight? fontWeight;
  final Color? color;
  final TextAlign? textAlign;
  final int? maxLines;
  final TextOverflow? overflow;
  final TextStyle? style;
  final TextDecoration? decoration;

  const AppText(
    this.text, {
    super.key,
    this.fontSize,
    this.letterSpacing,
    this.height,
    this.fontWeight,
    this.color,
    this.textAlign,
    this.maxLines,
    this.overflow,
    this.style,
    this.decoration,
  });

  @override
  Widget build(BuildContext context) {
    final baseStyle = TextStyle(
      fontFamily: 'PlusJakartaSans',
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color ?? AppColors.neutral,
      letterSpacing: letterSpacing,
      height: height,
      decoration: decoration,
    );

    return Text(
      text,
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow,
      style: style != null ? baseStyle.merge(style) : baseStyle,
    );
  }
}
