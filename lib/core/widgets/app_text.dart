
import 'package:flutter/material.dart';

import '../const/theme/app_color.dart';

class AppText extends StatelessWidget {
  final String text;
  final double? fontSize;
  final double? letterSpacing;
  final double? height;
  final FontWeight? fontWeight;
  final Color? color;
  final TextAlign? textAlign;

  const AppText(
      this.text, {
        super.key,
        this.fontSize,
        this.letterSpacing,
        this.height,
        this.fontWeight,
        this.color,
        this.textAlign,
      });

  @override
  Widget build(BuildContext context) {
    return AnimatedDefaultTextStyle(
      duration: const Duration(milliseconds: 180),
      style: TextStyle(
        fontFamily: 'PlusJakartaSans',
        fontSize: fontSize,
        fontWeight: fontWeight,
        color: color ?? AppColors.neutral,
        letterSpacing: letterSpacing,
        height: height,
      ),
      child: Text(
        text,
        textAlign: textAlign,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}
