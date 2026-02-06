import 'dart:ui';
import 'package:flutter/material.dart';

/// Glassmorphism theme extension for consistent frosted glass styling
class GlassmorphismTheme extends ThemeExtension<GlassmorphismTheme> {
  const GlassmorphismTheme({
    required this.blurIntensity,
    required this.surfaceOpacity,
    required this.borderColor,
    required this.borderWidth,
    required this.gradientColors,
    required this.glowColor,
    required this.shadowColor,
  });

  /// Blur intensity for BackdropFilter (typically 10-30)
  final double blurIntensity;
  
  /// Opacity for surface backgrounds (typically 0.1-0.3)
  final double surfaceOpacity;
  
  /// Border color for glass containers
  final Color borderColor;
  
  /// Border width
  final double borderWidth;
  
  /// Gradient colors for background
  final List<Color> gradientColors;
  
  /// Glow color for active/connected states
  final Color glowColor;
  
  /// Shadow color for depth
  final Color shadowColor;

  /// Dark theme preset - deep space blue aesthetic
  static const dark = GlassmorphismTheme(
    blurIntensity: 20.0,
    surfaceOpacity: 0.15,
    borderColor: Color(0x20FFFFFF),
    borderWidth: 1.0,
    gradientColors: [
      Color(0xFF0a0f1a),  // Deep navy
      Color(0xFF1a1f35),  // Dark indigo
      Color(0xFF0f1525),  // Dark blue-gray
    ],
    glowColor: Color(0xFF4FC3F7),  // Cyan glow
    shadowColor: Color(0x40000000),
  );

  /// Light theme preset - frosted crystal aesthetic
  static const light = GlassmorphismTheme(
    blurIntensity: 15.0,
    surfaceOpacity: 0.6,
    borderColor: Color(0x30000000),
    borderWidth: 1.0,
    gradientColors: [
      Color(0xFFe8f4fd),  // Light blue
      Color(0xFFf0f4ff),  // Lavender white
      Color(0xFFffffff),  // Pure white
    ],
    glowColor: Color(0xFF2196F3),  // Blue glow
    shadowColor: Color(0x20000000),
  );

  @override
  GlassmorphismTheme copyWith({
    double? blurIntensity,
    double? surfaceOpacity,
    Color? borderColor,
    double? borderWidth,
    List<Color>? gradientColors,
    Color? glowColor,
    Color? shadowColor,
  }) {
    return GlassmorphismTheme(
      blurIntensity: blurIntensity ?? this.blurIntensity,
      surfaceOpacity: surfaceOpacity ?? this.surfaceOpacity,
      borderColor: borderColor ?? this.borderColor,
      borderWidth: borderWidth ?? this.borderWidth,
      gradientColors: gradientColors ?? this.gradientColors,
      glowColor: glowColor ?? this.glowColor,
      shadowColor: shadowColor ?? this.shadowColor,
    );
  }

  @override
  GlassmorphismTheme lerp(ThemeExtension<GlassmorphismTheme>? other, double t) {
    if (other is! GlassmorphismTheme) return this;
    return GlassmorphismTheme(
      blurIntensity: lerpDouble(blurIntensity, other.blurIntensity, t)!,
      surfaceOpacity: lerpDouble(surfaceOpacity, other.surfaceOpacity, t)!,
      borderColor: Color.lerp(borderColor, other.borderColor, t)!,
      borderWidth: lerpDouble(borderWidth, other.borderWidth, t)!,
      gradientColors: _lerpColorList(gradientColors, other.gradientColors, t),
      glowColor: Color.lerp(glowColor, other.glowColor, t)!,
      shadowColor: Color.lerp(shadowColor, other.shadowColor, t)!,
    );
  }

  List<Color> _lerpColorList(List<Color> a, List<Color> b, double t) {
    final length = a.length < b.length ? a.length : b.length;
    return List.generate(length, (i) => Color.lerp(a[i], b[i], t)!);
  }
}

/// A container with frosted glass (glassmorphism) effect
class FrostedContainer extends StatelessWidget {
  const FrostedContainer({
    super.key,
    required this.child,
    this.borderRadius = 16.0,
    this.padding,
    this.margin,
    this.blurIntensity,
    this.surfaceOpacity,
    this.borderColor,
    this.showGlow = false,
    this.glowIntensity = 0.5,
  });

  final Widget child;
  final double borderRadius;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double? blurIntensity;
  final double? surfaceOpacity;
  final Color? borderColor;
  final bool showGlow;
  final double glowIntensity;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).extension<GlassmorphismTheme>() ?? 
                  GlassmorphismTheme.dark;
    
    final blur = blurIntensity ?? theme.blurIntensity;
    final opacity = surfaceOpacity ?? theme.surfaceOpacity;
    final border = borderColor ?? theme.borderColor;

    return Container(
      margin: margin,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: [
          if (showGlow)
            BoxShadow(
              color: theme.glowColor.withOpacity(glowIntensity * 0.3),
              blurRadius: 20,
              spreadRadius: 2,
            ),
          BoxShadow(
            color: theme.shadowColor,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
          child: Container(
            padding: padding,
            decoration: BoxDecoration(
              color: (Theme.of(context).brightness == Brightness.dark
                  ? Colors.white
                  : Colors.black)
                  .withOpacity(opacity),
              borderRadius: BorderRadius.circular(borderRadius),
              border: Border.all(
                color: border,
                width: theme.borderWidth,
              ),
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}

/// A pre-styled card with glassmorphism effect
class FrostedCard extends StatelessWidget {
  const FrostedCard({
    super.key,
    required this.child,
    this.onTap,
    this.padding = const EdgeInsets.all(16),
    this.margin,
    this.isActive = false,
  });

  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry? margin;
  final bool isActive;

  @override
  Widget build(BuildContext context) {
    return FrostedContainer(
      margin: margin,
      padding: EdgeInsets.zero,
      showGlow: isActive,
      glowIntensity: isActive ? 0.6 : 0.0,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: padding,
            child: child,
          ),
        ),
      ),
    );
  }
}

/// Gradient background widget for the app
class GradientBackground extends StatelessWidget {
  const GradientBackground({
    super.key,
    this.child,
  });

  final Widget? child;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).extension<GlassmorphismTheme>() ?? 
                  GlassmorphismTheme.dark;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: theme.gradientColors,
        ),
      ),
      child: child,
    );
  }
}

/// An animated pulsing glow effect
class PulsingGlow extends StatefulWidget {
  const PulsingGlow({
    super.key,
    required this.child,
    this.isActive = true,
    this.glowColor,
    this.duration = const Duration(milliseconds: 1500),
  });

  final Widget child;
  final bool isActive;
  final Color? glowColor;
  final Duration duration;

  @override
  State<PulsingGlow> createState() => _PulsingGlowState();
}

class _PulsingGlowState extends State<PulsingGlow>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );
    _animation = Tween<double>(begin: 0.3, end: 0.8).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
    if (widget.isActive) {
      _controller.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(PulsingGlow oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isActive && !_controller.isAnimating) {
      _controller.repeat(reverse: true);
    } else if (!widget.isActive && _controller.isAnimating) {
      _controller.stop();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).extension<GlassmorphismTheme>() ?? 
                  GlassmorphismTheme.dark;
    final glowColor = widget.glowColor ?? theme.glowColor;

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: widget.isActive
                ? [
                    BoxShadow(
                      color: glowColor.withOpacity(_animation.value * 0.5),
                      blurRadius: 30 * _animation.value,
                      spreadRadius: 10 * _animation.value,
                    ),
                  ]
                : null,
          ),
          child: widget.child,
        );
      },
    );
  }
}
