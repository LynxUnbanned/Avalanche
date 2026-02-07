import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:avalanche/core/theme/glassmorphism.dart';

/// Floating Quick Connect button that connects to the best available server
class QuickConnectButton extends HookConsumerWidget {
  const QuickConnectButton({
    super.key,
    required this.onQuickConnect,
    required this.isConnected,
    this.bestServerName,
    this.bestServerLatency,
  });

  final VoidCallback onQuickConnect;
  final bool isConnected;
  final String? bestServerName;
  final int? bestServerLatency;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isHovered = useState(false);
    final glassTheme = Theme.of(context).extension<GlassmorphismTheme>() ??
        GlassmorphismTheme.dark;

    // Animation for the lightning bolt
    final pulseAnimation = useAnimationController(
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    return MouseRegion(
      onEnter: (_) => isHovered.value = true,
      onExit: (_) => isHovered.value = false,
      child: GestureDetector(
        onTap: onQuickConnect,
        child: AnimatedBuilder(
          animation: pulseAnimation,
          builder: (context, child) {
            final scale = isHovered.value 
                ? 1.05 
                : 1.0 + (pulseAnimation.value * 0.03);
            
            return Transform.scale(
              scale: scale,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: EdgeInsets.symmetric(
                  horizontal: isHovered.value ? 24 : 16,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: isConnected
                        ? [
                            const Color(0xFF43A047),
                            const Color(0xFF2E7D32),
                          ]
                        : [
                            const Color(0xFF00BCD4),
                            const Color(0xFF00838F),
                          ],
                  ),
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                      color: (isConnected 
                          ? const Color(0xFF43A047) 
                          : const Color(0xFF00BCD4)
                      ).withOpacity(0.4 + pulseAnimation.value * 0.2),
                      blurRadius: 16 + pulseAnimation.value * 8,
                      spreadRadius: 0,
                    ),
                  ],
                  border: Border.all(
                    color: Colors.white.withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isConnected 
                          ? FluentIcons.lightning_24_filled
                          : FluentIcons.flash_24_filled,
                      color: Colors.white,
                      size: 22,
                    ),
                    AnimatedSize(
                      duration: const Duration(milliseconds: 200),
                      child: isHovered.value
                          ? Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const SizedBox(width: 8),
                                Text(
                                  isConnected ? 'Connected' : 'Quick Connect',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14,
                                  ),
                                ),
                                if (bestServerLatency != null && !isConnected) ...[
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Text(
                                      '${bestServerLatency}ms',
                                      style: TextStyle(
                                        color: Colors.white.withOpacity(0.9),
                                        fontSize: 11,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ],
                              ],
                            )
                          : const SizedBox.shrink(),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

/// Positioned Quick Connect button overlay
class QuickConnectOverlay extends StatelessWidget {
  const QuickConnectOverlay({
    super.key,
    required this.onQuickConnect,
    required this.isConnected,
    this.bestServerName,
    this.bestServerLatency,
  });

  final VoidCallback onQuickConnect;
  final bool isConnected;
  final String? bestServerName;
  final int? bestServerLatency;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      right: 16,
      bottom: 16,
      child: QuickConnectButton(
        onQuickConnect: onQuickConnect,
        isConnected: isConnected,
        bestServerName: bestServerName,
        bestServerLatency: bestServerLatency,
      ),
    );
  }
}
