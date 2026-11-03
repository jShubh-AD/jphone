import 'package:flutter/material.dart';
import '../../../../core/widgets/app_text.dart';

class DashboardCardContainer extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final Color backgroundColor;
  final double borderRadius;

  const DashboardCardContainer({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
    this.onTap,
    this.onLongPress,
    this.backgroundColor = Colors.white,
    this.borderRadius = 22.0,
  });

  @override
  Widget build(BuildContext context) {
    final card = Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(color: const Color(0xFFF1F5F9), width: 1.2),
        boxShadow: const [
          BoxShadow(
            color: Color(0x06000000),
            blurRadius: 12,
            spreadRadius: 0,
            offset: Offset(0, 4),
          ),
          BoxShadow(
            color: Color(0x04000000),
            blurRadius: 4,
            spreadRadius: 0,
            offset: Offset(0, 1),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: Padding(padding: padding, child: child),
      ),
    );

    if (onTap == null && onLongPress == null) {
      return card;
    }

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        onLongPress: onLongPress,
        borderRadius: BorderRadius.circular(borderRadius),
        child: card,
      ),
    );
  }
}

class DashboardCardHeader extends StatelessWidget {
  final String title;
  final IconData? icon;
  final Color? iconColor;
  final Widget? badge;
  final Widget? trailing;

  const DashboardCardHeader({
    super.key,
    required this.title,
    this.icon,
    this.iconColor,
    this.badge,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        if (icon != null) ...[
          Icon(icon, size: 18, color: iconColor ?? const Color(0xFF0F172A)),
          const SizedBox(width: 6),
        ],
        Expanded(
          child: AppText(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF0F172A),
            letterSpacing: -0.2,
          ),
        ),
        if (badge != null) ...[const SizedBox(width: 6), badge!],
        if (trailing != null) ...[const SizedBox(width: 6), trailing!],
      ],
    );
  }
}

class DashboardBadge extends StatelessWidget {
  final String label;
  final Color backgroundColor;
  final Color textColor;
  final double fontSize;
  final EdgeInsetsGeometry padding;

  const DashboardBadge({
    super.key,
    required this.label,
    required this.backgroundColor,
    required this.textColor,
    this.fontSize = 11,
    this.padding = const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(100),
      ),
      child: AppText(
        label,
        fontSize: fontSize,
        fontWeight: FontWeight.w700,
        color: textColor,
        letterSpacing: 0.2,
      ),
    );
  }
}
