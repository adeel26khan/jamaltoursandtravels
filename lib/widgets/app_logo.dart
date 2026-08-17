import 'package:flutter/material.dart';
import '../core/constants.dart';

class AppLogo extends StatelessWidget {
  final double size;
  final double? width;
  final double? height;
  final double borderRadius;
  final bool showBackground;
  final Color? backgroundColor;
  final EdgeInsetsGeometry? padding;

  const AppLogo({
    super.key,
    this.size = 36.0,
    this.width,
    this.height,
    this.borderRadius = 8.0,
    this.showBackground = true,
    this.backgroundColor,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveWidth = width ?? size;
    final effectiveHeight = height ?? size;

    Widget logoImage = Image.asset(
      AppConstants.appLogo,
      width: effectiveWidth,
      height: effectiveHeight,
      fit: BoxFit.contain,
      errorBuilder: (context, error, stackTrace) {
        return Icon(
          Icons.mosque,
          size: effectiveWidth * 0.7,
          color: AppConstants.deepGreen,
        );
      },
    );

    if (!showBackground) {
      return logoImage;
    }

    return Container(
      padding: padding ?? EdgeInsets.all(effectiveWidth * 0.15),
      decoration: BoxDecoration(
        color: backgroundColor ?? AppConstants.primaryGold,
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: [
          BoxShadow(
            color: (backgroundColor ?? AppConstants.primaryGold).withValues(alpha: 0.25),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: logoImage,
    );
  }
}
