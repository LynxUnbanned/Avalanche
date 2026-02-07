/// Winter Background Widget
/// 
/// Supports both static images and video backgrounds
library;

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:avalanche/core/theme/avalanche_theme.dart';

/// Background type enumeration
enum BackgroundType { image, video }

/// Winter-themed background widget
class WinterBackground extends StatefulWidget {
  const WinterBackground({
    super.key,
    required this.child,
    this.imagePath,
    this.videoPath,
    this.fallbackColor = AvalancheColors.deepNavy,
    this.overlayOpacity = 0.3,
  });

  final Widget child;
  final String? imagePath;
  final String? videoPath;
  final Color fallbackColor;
  final double overlayOpacity;

  @override
  State<WinterBackground> createState() => _WinterBackgroundState();
}

class _WinterBackgroundState extends State<WinterBackground> {
  VideoPlayerController? _videoController;
  bool _videoInitialized = false;
  bool _useVideo = false;

  @override
  void initState() {
    super.initState();
    _initializeBackground();
  }

  Future<void> _initializeBackground() async {
    // Try video first if path is provided
    if (widget.videoPath != null) {
      try {
        final file = File(widget.videoPath!);
        if (await file.exists()) {
          _videoController = VideoPlayerController.file(file);
          await _videoController!.initialize();
          await _videoController!.setLooping(true);
          await _videoController!.setVolume(0); // Mute background video
          await _videoController!.play();
          
          if (mounted) {
            setState(() {
              _videoInitialized = true;
              _useVideo = true;
            });
          }
          return;
        }
      } catch (e) {
        debugPrint('Failed to load video background: $e');
      }
    }

    // Fall back to image or solid color
    if (mounted) {
      setState(() {
        _useVideo = false;
      });
    }
  }

  @override
  void dispose() {
    _videoController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        // Background layer
        _buildBackground(),
        
        // Dark overlay for readability
        Container(
          color: Colors.black.withOpacity(widget.overlayOpacity),
        ),
        
        // Subtle gradient overlay
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.transparent,
                AvalancheColors.deepNavy.withOpacity(0.5),
              ],
            ),
          ),
        ),
        
        // Content
        widget.child,
      ],
    );
  }

  Widget _buildBackground() {
    // Video background
    if (_useVideo && _videoInitialized && _videoController != null) {
      return SizedBox.expand(
        child: FittedBox(
          fit: BoxFit.cover,
          child: SizedBox(
            width: _videoController!.value.size.width,
            height: _videoController!.value.size.height,
            child: VideoPlayer(_videoController!),
          ),
        ),
      );
    }

    // Image background
    if (widget.imagePath != null) {
      // Check if it's an asset path or file path
      if (widget.imagePath!.startsWith('assets/')) {
        return Image.asset(
          widget.imagePath!,
          fit: BoxFit.cover,
          width: double.infinity,
          height: double.infinity,
          errorBuilder: (context, error, stackTrace) {
            return _buildFallbackBackground();
          },
        );
      } else {
        final file = File(widget.imagePath!);
        return Image.file(
          file,
          fit: BoxFit.cover,
          width: double.infinity,
          height: double.infinity,
          errorBuilder: (context, error, stackTrace) {
            return _buildFallbackBackground();
          },
        );
      }
    }

    // Fallback to gradient background
    return _buildFallbackBackground();
  }

  Widget _buildFallbackBackground() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AvalancheColors.deepNavy,
            AvalancheColors.midnightBlue,
            const Color(0xFF1A1A2E),
          ],
          stops: const [0.0, 0.5, 1.0],
        ),
      ),
    );
  }
}

/// Simple gradient background for screens without custom backgrounds
class GradientBackground extends StatelessWidget {
  const GradientBackground({
    super.key,
    required this.child,
  });

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AvalancheColors.deepNavy,
            AvalancheColors.midnightBlue,
            const Color(0xFF1A1A2E),
          ],
          stops: const [0.0, 0.5, 1.0],
        ),
      ),
      child: child,
    );
  }
}
