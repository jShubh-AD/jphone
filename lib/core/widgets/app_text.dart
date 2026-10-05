import 'package:flutter/cupertino.dart';

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
    return Text(
      text,
      textAlign: textAlign,
      overflow: TextOverflow.ellipsis,
      style: TextStyle(
        fontFamily: 'PlusJakartaSans',
        fontSize: fontSize,
        fontWeight: fontWeight,
        color: color,
        letterSpacing: letterSpacing,
        height: height
      ),
    );
  }
}