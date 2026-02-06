import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:avalanche/core/theme/glassmorphism.dart';
import 'package:avalanche/features/proxy/model/server_location.dart';

/// Server marker widget for world map
class ServerMarker extends StatefulWidget {
  const ServerMarker({
    super.key,
    required this.location,
    required this.serverName,
    this.delay,
    this.isSelected = false,
    this.isConnected = false,
    this.onTap,
  });

  final ServerLocation location;
  final String serverName;
  final int? delay;
  final bool isSelected;
  final bool isConnected;
  final VoidCallback? onTap;

  @override
  State<ServerMarker> createState() => _ServerMarkerState();
}

class _ServerMarkerState extends State<ServerMarker>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _rippleController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _rippleAnimation;
  
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.3).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
    
    _rippleController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _rippleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _rippleController, curve: Curves.easeOut),
    );
    
    if (widget.isConnected) {
      _pulseController.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(ServerMarker oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    if (widget.isConnected && !oldWidget.isConnected) {
      _rippleController.forward(from: 0);
      _pulseController.repeat(reverse: true);
    } else if (!widget.isConnected && oldWidget.isConnected) {
      _pulseController.stop();
      _pulseController.value = 0;
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _rippleController.dispose();
    super.dispose();
  }

  Color _getMarkerColor(BuildContext context) {
    final theme = Theme.of(context).extension<GlassmorphismTheme>() ??
        GlassmorphismTheme.dark;
    
    if (widget.isConnected) {
      return const Color(0xFF4CAF50); // Green for connected
    }
    if (widget.isSelected) {
      return theme.glowColor;
    }
    
    // Color based on delay
    if (widget.delay != null) {
      if (widget.delay! < 100) return const Color(0xFF4CAF50);
      if (widget.delay! < 300) return const Color(0xFF8BC34A);
      if (widget.delay! < 500) return const Color(0xFFFFC107);
      if (widget.delay! < 1000) return const Color(0xFFFF9800);
      return const Color(0xFFFF5722);
    }
    
    return theme.glowColor.withOpacity(0.7);
  }

  @override
  Widget build(BuildContext context) {
    final markerColor = _getMarkerColor(context);
    const markerSize = 12.0;
    
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: Stack(
          alignment: Alignment.center,
          clipBehavior: Clip.none,
          children: [
            // Ripple effect on connection
            if (widget.isConnected)
              AnimatedBuilder(
                animation: _rippleAnimation,
                builder: (context, child) {
                  return Container(
                    width: 40 + (60 * _rippleAnimation.value),
                    height: 40 + (60 * _rippleAnimation.value),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: markerColor.withOpacity(
                          0.5 * (1 - _rippleAnimation.value),
                        ),
                        width: 2,
                      ),
                    ),
                  );
                },
              ),
            
            // Outer glow
            AnimatedBuilder(
              animation: _pulseAnimation,
              builder: (context, child) {
                return Container(
                  width: markerSize * 2 * 
                      (widget.isConnected ? _pulseAnimation.value : 1),
                  height: markerSize * 2 * 
                      (widget.isConnected ? _pulseAnimation.value : 1),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: markerColor.withOpacity(
                          widget.isConnected ? 0.6 : (_isHovered ? 0.4 : 0.2),
                        ),
                        blurRadius: widget.isConnected ? 15 : 10,
                        spreadRadius: widget.isConnected ? 5 : 2,
                      ),
                    ],
                  ),
                );
              },
            ),
            
            // Main marker dot
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: _isHovered || widget.isSelected ? markerSize + 4 : markerSize,
              height: _isHovered || widget.isSelected ? markerSize + 4 : markerSize,
              decoration: BoxDecoration(
                color: markerColor,
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white.withOpacity(0.8),
                  width: 2,
                ),
              ),
            ),
            
            // Hover popup
            if (_isHovered)
              Positioned(
                bottom: markerSize + 10,
                child: _ServerPopup(
                  serverName: widget.serverName,
                  location: widget.location,
                  delay: widget.delay,
                  isConnected: widget.isConnected,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _ServerPopup extends StatelessWidget {
  const _ServerPopup({
    required this.serverName,
    required this.location,
    this.delay,
    this.isConnected = false,
  });

  final String serverName;
  final ServerLocation location;
  final int? delay;
  final bool isConnected;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          constraints: const BoxConstraints(maxWidth: 180),
          decoration: BoxDecoration(
            color: (theme.brightness == Brightness.dark
                    ? Colors.black
                    : Colors.white)
                .withOpacity(0.7),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Colors.white.withOpacity(0.2),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    location.displayName,
                    style: theme.textTheme.labelMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (isConnected) ...[
                    const SizedBox(width: 6),
                    Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: Color(0xFF4CAF50),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ],
                ],
              ),
              Text(
                serverName,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.textTheme.bodySmall?.color?.withOpacity(0.7),
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              if (delay != null) ...[
                const SizedBox(height: 4),
                Text(
                  '${delay}ms',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: _getDelayColor(delay!),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Color _getDelayColor(int delay) {
    if (delay < 100) return const Color(0xFF4CAF50);
    if (delay < 300) return const Color(0xFF8BC34A);
    if (delay < 500) return const Color(0xFFFFC107);
    if (delay < 1000) return const Color(0xFFFF9800);
    return const Color(0xFFFF5722);
  }
}
