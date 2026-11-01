import 'package:flutter/material.dart';
import 'app_text.dart';

class AppElevatedButton extends StatefulWidget {
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
  final double pressOffset;
  final double pressedScale;

  /// Enables the glass-like shine sweep when the button is tapped.
  final bool enableShine;

  /// Duration of the left -> right shine sweep.
  final Duration shineDuration;

  /// Width of the shine streak relative to the button.
  final double shineWidth;

  final bool isLoading;
  final Widget? loadingWidget;

  const AppElevatedButton({
    super.key,
    required this.text,
    required this.onPressed,

    this.textWidget,
    this.fontSize = 14,
    this.fontWeight = FontWeight.w800,
    this.textColor = Colors.white,
    this.letterSpacing = 0.14,
    this.textHeight,
    this.textAlign = TextAlign.center,

    this.icon,
    this.image,
    this.iconSize = 15,
    this.iconSpacing = 8,

    this.width,
    this.height,
    this.padding = const EdgeInsets.symmetric(horizontal: 24),

    this.borderRadius = 100,

    this.backgroundColor,
    this.gradient,

    this.borderColor,
    this.borderWidth = 1,

    this.shadowColor,
    this.shadowBlurRadius = 24,
    this.shadowSpreadRadius = 0,
    this.shadowOffset = const Offset(0, 8),

    this.animationDuration = const Duration(milliseconds: 140),
    this.pressOffset = 4,
    this.pressedScale = 0.985,

    this.enableShine = true,
    this.shineDuration = const Duration(milliseconds: 3500),
    this.shineWidth = 0.8,

    this.isLoading = false,
    this.loadingWidget,
  }) : assert(
         gradient == null || backgroundColor == null,
         'Provide either gradient or backgroundColor, not both.',
       ),
       assert(
         icon == null || image == null,
         'Provide either icon or image, not both.',
       ),
       assert(
         shineWidth > 0 && shineWidth <= 1,
         'shineWidth must be between 0 and 1.',
       );

  @override
  State<AppElevatedButton> createState() => _AppElevatedButtonState();
}

class _AppElevatedButtonState extends State<AppElevatedButton>
    with SingleTickerProviderStateMixin {
  bool _isPressed = false;

  late final AnimationController _shineController;

  bool get _disabled => widget.onPressed == null || widget.isLoading;

  @override
  void initState() {
    super.initState();

    _shineController = AnimationController(
      vsync: this,
      duration: widget.shineDuration,
    )..repeat();
  }

  @override
  void didUpdateWidget(covariant AppElevatedButton oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.shineDuration != widget.shineDuration) {
      _shineController.duration = widget.shineDuration;
    }
  }

  @override
  void dispose() {
    _shineController.dispose();
    super.dispose();
  }

  // ---------------------------------------------------------------------------
  // PRESS HANDLING
  // ---------------------------------------------------------------------------

  void _handleTapDown(TapDownDetails details) {
    if (_disabled) return;
    if(!context.mounted) return;
    setState(() => _isPressed = true);
    _playShine();
  }

  void _handleTapUp(TapUpDetails details) {
    if(!context.mounted) return;
    if (_disabled) return;
    setState(() => _isPressed = false);
    widget.onPressed?.call();
  }

  void _handleTapCancel() {
    if(!context.mounted) return;
    if (_disabled) return;
    setState(() => _isPressed = false);
  }

  void _playShine() {
    if(!context.mounted) return;
    if (!widget.enableShine || _disabled) return;
    _shineController..stop()..forward(from: 0);
  }

  // ---------------------------------------------------------------------------
  // BUILD
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final double shadowDepth = _isPressed
        ? widget.shadowOffset.dy * 0.25
        : widget.shadowOffset.dy;

    final double shadowBlur = _isPressed
        ? widget.shadowBlurRadius * 0.65
        : widget.shadowBlurRadius;

    final double shadowSpread = _isPressed
        ? widget.shadowSpreadRadius * 0.5
        : widget.shadowSpreadRadius;

    final button = GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: _disabled ? null : _handleTapDown,
      onTapUp: _disabled ? null : _handleTapUp,
      onTapCancel: _disabled ? null : () => _handleTapCancel(),
      child: AnimatedScale(
        scale: _isPressed ? widget.pressedScale : 1.0,
        duration: widget.animationDuration,
        curve: Curves.easeOutCubic,
        child: AnimatedContainer(
          duration: widget.animationDuration,
          curve: Curves.easeOutCubic,

          transform: Matrix4.translationValues(
            0,
            _isPressed ? widget.pressOffset : 0,
            0,
          ),

          decoration: BoxDecoration(
            color: widget.gradient == null
                ? widget.backgroundColor ??
                      Theme.of(context).colorScheme.primary
                : null,
            gradient: widget.gradient,
            borderRadius: BorderRadius.circular(widget.borderRadius),

            border: widget.borderColor != null
                ? Border.all(
                    color: widget.borderColor!,
                    width: widget.borderWidth,
                  )
                : null,

            boxShadow: _disabled || widget.shadowColor == null
                ? null
                : [
                    BoxShadow(
                      color: widget.shadowColor!,
                      blurRadius: shadowBlur,
                      spreadRadius: shadowSpread,
                      offset: Offset(widget.shadowOffset.dx, shadowDepth),
                    ),
                  ],
          ),

          child: ClipRRect(
            borderRadius: BorderRadius.circular(widget.borderRadius),
            child: Stack(
              fit: StackFit.passthrough,
              children: [
                // -------------------------------------------------------------
                // BUTTON CONTENT
                // -------------------------------------------------------------
                Padding(padding: widget.padding, child: _buildContent()),

                // -------------------------------------------------------------
                // GLASS SHINE
                // -------------------------------------------------------------
                if (widget.enableShine)
                  Positioned.fill(child: IgnorePointer(child: _buildShine())),
              ],
            ),
          ),
        ),
      ),
    );

    if (widget.width != null || widget.height != null) {
      return SizedBox(
        width: widget.width,
        height: widget.height,
        child: button,
      );
    }

    return UnconstrainedBox(
      constrainedAxis: Axis.vertical,
      child: ConstrainedBox(
        constraints: BoxConstraints(minHeight: widget.height ?? 56),
        child: button,
      ),
    );
  }

  // shine widget
  Widget _buildShine() {
    return AnimatedBuilder(
      animation: _shineController,
      builder: (context, child) {
        final progress = _shineController.value;
        final dx = (progress * 3.0) - 1.5;

        return ShaderMask(
          shaderCallback: (bounds) {
            return LinearGradient(
              begin: Alignment(dx - 0.6, -0.8),
              end: Alignment(dx + 0.6, 0.8),
              colors: [
                Colors.white.withValues(alpha: 0.0),
                Colors.white.withValues(alpha: 0.05),
                Colors.white.withValues(alpha: 0.3),
                Colors.white.withValues(alpha: 0.05),
                Colors.white.withValues(alpha: 0.0),
              ],
              stops: const [
                0.0,
                0.35,
                0.50,
                0.65,
                1.0,
              ],
            ).createShader(bounds);
          },
          child: const ColoredBox(
            color: Colors.white,
          ),
        );
      },
    );
  }

  // content
  Widget _buildContent() {
    if (widget.isLoading) {
      return widget.loadingWidget ??
          SizedBox(
            width: 22,
            height: 22,
            child: CircularProgressIndicator(
              strokeWidth: 2.5,
              valueColor: AlwaysStoppedAnimation<Color>(widget.textColor),
            ),
          );
    }

    final Color contentColor = _disabled
        ? widget.textColor.withValues(alpha: 0.5)
        : widget.textColor;

    final Widget text =
        widget.textWidget ??
        AppText(
          widget.text,
          fontSize: widget.fontSize,
          fontWeight: widget.fontWeight,
          color: contentColor,
          letterSpacing: widget.letterSpacing,
          height: widget.textHeight,
          textAlign: widget.textAlign,
        );

    if (widget.icon == null && widget.image == null) {
      return text;
    }

    final Widget leading;

    if (widget.icon != null) {
      leading = Icon(widget.icon, size: widget.iconSize, color: contentColor);
    } else {
      leading = Image(
        image: widget.image!,
        width: widget.iconSize,
        height: widget.iconSize,
        fit: BoxFit.contain,
        opacity: _disabled ? const AlwaysStoppedAnimation<double>(0.5) : null,
      );
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        leading,
        SizedBox(width: widget.iconSpacing),
        text,
      ],
    );
  }
}
