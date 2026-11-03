import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../const/theme/app_color.dart';
import 'app_text.dart';

/// JPhone Primary Elevated Button.
///
/// Implemented as a declarative [StatelessWidget] following standard Flutter framework
/// design practices (similar to [ElevatedButton] / [FilledButton]):
/// - Acts as the primary elevated button with flagship gradient & pill defaults.
/// - Encapsulates tactile spring-punch feedback on tap with haptics.
/// - Features an integrated specular gloss sweep via [flutter_animate].
class AppElevatedButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;

  final AppText? textWidget;
  final double fontSize;
  final FontWeight fontWeight;
  final Color textColor;
  final double letterSpacing;
  final double? textHeight;
  final TextAlign textAlign;

  final IconData? icon;
  final ImageProvider<Object>? image;
  final double iconSize;
  final double iconSpacing;

  final double? width;
  final double? height;
  final EdgeInsetsGeometry padding;

  final double borderRadius;

  final Color? backgroundColor;
  final Gradient? gradient;

  final Color? borderColor;
  final double borderWidth;

  final Color? shadowColor;
  final double shadowBlurRadius;
  final double shadowSpreadRadius;
  final Offset shadowOffset;

  final Duration animationDuration;
  final double pressedScale;

  /// Enables the subtle specular gloss sweep.
  final bool enableShine;

  /// Total period duration for the sweep + rest cycle.
  final Duration shineDuration;

  final bool isLoading;
  final Widget? loadingWidget;

  const AppElevatedButton({
    super.key,
    required this.text,
    required this.onPressed,

    this.textWidget,
    this.fontSize = 14,
    this.fontWeight = FontWeight.w700,
    this.textColor = Colors.white,
    this.letterSpacing = 0.2,
    this.textHeight,
    this.textAlign = TextAlign.center,

    this.icon,
    this.image,
    this.iconSize = 18,
    this.iconSpacing = 8,

    this.width,
    this.height = 48,
    this.padding = const EdgeInsets.symmetric(horizontal: 24, vertical: 12),

    this.borderRadius = 100,

    this.backgroundColor,
    this.gradient,

    this.borderColor,
    this.borderWidth = 1,

    this.shadowColor,
    this.shadowBlurRadius = 18,
    this.shadowSpreadRadius = 0,
    this.shadowOffset = const Offset(0, 6),

    this.animationDuration = const Duration(milliseconds: 180),
    this.pressedScale = 0.93,

    this.enableShine = true,
    this.shineDuration = const Duration(milliseconds: 3800),

    this.isLoading = false,
    this.loadingWidget,
  }) : assert(
         gradient == null || backgroundColor == null,
         'Provide either gradient or backgroundColor, not both.',
       ),
       assert(
         icon == null || image == null,
         'Provide either icon or image, not both.',
       );

  bool get _disabled => onPressed == null || isLoading;

  /// Flagship primary gradient (Sunset Tangerine -> Magenta -> Violet)
  Gradient get _defaultPrimaryGradient => const LinearGradient(
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
        colors: [
          AppColors.buttonGradient,  // Vibrant Tangerine
          AppColors.buttonGradient2, // Electric Magenta
          AppColors.buttonGradient3, // Modern Violet
        ],
      );

  Color get _defaultShadowColor => gradient != null || backgroundColor == null
      ? const Color(0xFFD946EF).withValues(alpha: 0.28)
      : const Color(0x1A000000);

  @override
  Widget build(BuildContext context) {
    final effectiveGradient =
        backgroundColor == null ? (gradient ?? _defaultPrimaryGradient) : null;
    final effectiveShadowColor = shadowColor ?? _defaultShadowColor;

    // 1. Base Container shell
    Widget buttonShell = Container(
      decoration: BoxDecoration(
        color: effectiveGradient == null
            ? backgroundColor ?? Theme.of(context).colorScheme.primary
            : null,
        gradient: effectiveGradient,
        borderRadius: BorderRadius.circular(borderRadius),
        border: borderColor != null
            ? Border.all(
                color: borderColor!,
                width: borderWidth,
              )
            : null,
        boxShadow: _disabled
            ? null
            : [
                BoxShadow(
                  color: effectiveShadowColor,
                  blurRadius: shadowBlurRadius,
                  spreadRadius: shadowSpreadRadius,
                  offset: shadowOffset,
                ),
              ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: Padding(
          padding: padding,
          child: _buildContent(),
        ),
      ),
    );

    // 2. Specular Gloss Sweep (flutter_animate)
    if (enableShine && !_disabled) {
      buttonShell = buttonShell
          .animate(
            onPlay: (c) => c.repeat(period: shineDuration),
          )
          .shimmer(
            duration: 1200.ms,
            color: Colors.white.withValues(alpha: 0.16),
            angle: math.pi / 4,
          );
    }

    // 3. Tactile Spring Scale Wrapper (isolated micro-state)
    Widget button = _PressScale(
      disabled: _disabled,
      pressedScale: pressedScale,
      animationDuration: animationDuration,
      onPressed: onPressed,
      child: buttonShell,
    );

    if (width != null || height != null) {
      return SizedBox(
        width: width,
        height: height,
        child: button,
      );
    }

    return button;
  }

  Widget _buildContent() {
    if (isLoading) {
      return loadingWidget ??
          SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2.2,
              valueColor: AlwaysStoppedAnimation<Color>(textColor),
            ),
          );
    }

    final Color contentColor =
        _disabled ? textColor.withValues(alpha: 0.5) : textColor;

    final Widget textChild = textWidget ??
        AppText(
          text,
          fontSize: fontSize,
          fontWeight: fontWeight,
          color: contentColor,
          letterSpacing: letterSpacing,
          height: textHeight,
          textAlign: textAlign,
        );

    if (icon == null && image == null) {
      return textChild;
    }

    final Widget leading = icon != null
        ? Icon(icon, size: iconSize, color: contentColor)
        : Image(
            image: image!,
            width: iconSize,
            height: iconSize,
            fit: BoxFit.contain,
            opacity: _disabled ? const AlwaysStoppedAnimation<double>(0.5) : null,
          );

    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        leading,
        SizedBox(width: iconSpacing),
        textChild,
      ],
    );
  }
}

/// Dedicated, isolated micro-widget handling the tap-down / tap-up scale spring.
///
/// Keeps [AppElevatedButton] completely stateless, immutable, and clean.
class _PressScale extends StatefulWidget {
  final Widget child;
  final bool disabled;
  final double pressedScale;
  final Duration animationDuration;
  final VoidCallback? onPressed;

  const _PressScale({
    required this.child,
    required this.disabled,
    required this.pressedScale,
    required this.animationDuration,
    required this.onPressed,
  });

  @override
  State<_PressScale> createState() => _PressScaleState();
}

class _PressScaleState extends State<_PressScale> {
  bool _isPressed = false;

  void _handleTapDown(TapDownDetails details) {
    if (widget.disabled) return;
    HapticFeedback.lightImpact();
    setState(() => _isPressed = true);
  }

  void _handleTapUp(TapUpDetails details) {
    if (widget.disabled) return;
    setState(() => _isPressed = false);
    widget.onPressed?.call();
  }

  void _handleTapCancel() {
    if (widget.disabled) return;
    setState(() => _isPressed = false);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: widget.disabled ? null : _handleTapDown,
      onTapUp: widget.disabled ? null : _handleTapUp,
      onTapCancel: widget.disabled ? null : _handleTapCancel,
      child: widget.child
          .animate(target: _isPressed ? 1.0 : 0.0)
          .scaleXY(
            end: widget.pressedScale,
            duration: widget.animationDuration,
            curve: _isPressed ? Curves.easeOutCubic : Curves.easeOutBack,
          ),
    );
  }
}
