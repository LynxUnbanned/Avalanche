/// Frosted Glass Container Widget
/// 
/// Reusable widget that applies frosted glass effect with blur and transparency
library;

import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:avalanche/core/theme/avalanche_theme.dart';

/// A container with frosted glass effect
class FrostedContainer extends StatelessWidget {
  const FrostedContainer({
    super.key,
    required this.child,
    this.blur = FrostedGlass.blurIntensity,
    this.borderRadius = FrostedGlass.borderRadius,
    this.backgroundColor,
    this.padding,
    this.margin,
    this.width,
    this.height,
    this.showBorder = true,
  });

  final Widget child;
  final double blur;
  final double borderRadius;
  final Color? backgroundColor;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double? width;
  final double? height;
  final bool showBorder;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      width: width,
      height: height,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
          child: Container(
            padding: padding,
            decoration: BoxDecoration(
              color: backgroundColor ?? AvalancheColors.frostedSurface,
              borderRadius: BorderRadius.circular(borderRadius),
              border: showBorder
                  ? Border.all(
                      color: AvalancheColors.frostedBorder,
                      width: FrostedGlass.borderWidth,
                    )
                  : null,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.15),
                  blurRadius: 20,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}

/// A card with frosted glass effect
class FrostedCard extends StatelessWidget {
  const FrostedCard({
    super.key,
    required this.child,
    this.blur = FrostedGlass.blurIntensity,
    this.borderRadius = FrostedGlass.borderRadius,
    this.padding = const EdgeInsets.all(16),
    this.margin,
    this.onTap,
  });

  final Widget child;
  final double blur;
  final double borderRadius;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry? margin;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final card = FrostedContainer(
      blur: blur,
      borderRadius: borderRadius,
      padding: padding,
      margin: margin,
      child: child,
    );

    if (onTap != null) {
      return GestureDetector(
        onTap: onTap,
        child: MouseRegion(
          cursor: SystemMouseCursors.click,
          child: card,
        ),
      );
    }

    return card;
  }
}

/// Frosted glass app bar
class FrostedAppBar extends StatelessWidget implements PreferredSizeWidget {
  const FrostedAppBar({
    super.key,
    this.title,
    this.leading,
    this.actions,
    this.centerTitle = true,
    this.blur = FrostedGlass.blurIntensity,
  });

  final Widget? title;
  final Widget? leading;
  final List<Widget>? actions;
  final bool centerTitle;
  final double blur;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
        child: Container(
          decoration: BoxDecoration(
            color: AvalancheColors.frostedSurface,
            border: Border(
              bottom: BorderSide(
                color: AvalancheColors.frostedBorder,
                width: FrostedGlass.borderWidth,
              ),
            ),
          ),
          child: SafeArea(
            child: AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              leading: leading,
              title: title,
              centerTitle: centerTitle,
              actions: actions,
            ),
          ),
        ),
      ),
    );
  }
}

/// A button with frosted glass effect
class FrostedButton extends StatefulWidget {
  const FrostedButton({
    super.key,
    required this.onPressed,
    required this.child,
    this.blur = 8.0,
    this.borderRadius = 12.0,
    this.padding = const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
    this.backgroundColor,
    this.enabled = true,
  });

  final VoidCallback? onPressed;
  final Widget child;
  final double blur;
  final double borderRadius;
  final EdgeInsetsGeometry padding;
  final Color? backgroundColor;
  final bool enabled;

  @override
  State<FrostedButton> createState() => _FrostedButtonState();
}

class _FrostedButtonState extends State<FrostedButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: widget.enabled ? SystemMouseCursors.click : SystemMouseCursors.basic,
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.enabled ? widget.onPressed : null,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(widget.borderRadius),
            child: BackdropFilter(
              filter: ImageFilter.blur(
                sigmaX: widget.blur,
                sigmaY: widget.blur,
              ),
              child: Container(
                padding: widget.padding,
                decoration: BoxDecoration(
                  color: widget.backgroundColor ??
                      (_isHovered
                          ? AvalancheColors.iceBlue.withOpacity(0.3)
                          : AvalancheColors.frostedSurface),
                  borderRadius: BorderRadius.circular(widget.borderRadius),
                  border: Border.all(
                    color: _isHovered
                        ? AvalancheColors.iceBlue
                        : AvalancheColors.frostedBorder,
                    width: FrostedGlass.borderWidth,
                  ),
                ),
                child: DefaultTextStyle(
                  style: TextStyle(
                    color: widget.enabled
                        ? AvalancheColors.frostWhite
                        : AvalancheColors.frostWhite.withOpacity(0.5),
                    fontWeight: FontWeight.w500,
                  ),
                  child: widget.child,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
