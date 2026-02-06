import 'package:flutter/material.dart';
import 'package:avalanche/core/theme/glassmorphism.dart';
import 'package:avalanche/features/home/widget/server_marker.dart';
import 'package:avalanche/features/proxy/model/server_location.dart';

/// Server data for map display
class MapServerData {
  const MapServerData({
    required this.id,
    required this.name,
    required this.countryCode,
    this.delay,
    this.isSelected = false,
  });

  final String id;
  final String name;
  final String countryCode;
  final int? delay;
  final bool isSelected;
}

/// Interactive world map widget with server markers
class WorldMapWidget extends StatefulWidget {
  const WorldMapWidget({
    super.key,
    required this.servers,
    required this.onServerSelected,
    this.connectedServerId,
  });

  final List<MapServerData> servers;
  final void Function(MapServerData server) onServerSelected;
  final String? connectedServerId;

  @override
  State<WorldMapWidget> createState() => _WorldMapWidgetState();
}

class _WorldMapWidgetState extends State<WorldMapWidget> {
  final TransformationController _transformController = TransformationController();
  
  @override
  void dispose() {
    _transformController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).extension<GlassmorphismTheme>() ??
        GlassmorphismTheme.dark;

    return LayoutBuilder(
      builder: (context, constraints) {
        return InteractiveViewer(
          transformationController: _transformController,
          minScale: 0.5,
          maxScale: 4.0,
          boundaryMargin: EdgeInsets.all(constraints.maxWidth * 0.2),
          child: Stack(
            children: [
              // World map background
              CustomPaint(
                size: Size(constraints.maxWidth, constraints.maxHeight),
                painter: WorldMapPainter(
                  mapColor: theme.borderColor.withOpacity(0.3),
                  outlineColor: theme.borderColor,
                ),
              ),
              
              // Grid overlay for visual effect
              CustomPaint(
                size: Size(constraints.maxWidth, constraints.maxHeight),
                painter: MapGridPainter(
                  gridColor: theme.borderColor.withOpacity(0.1),
                ),
              ),
              
              // Server markers
              ...widget.servers.map((server) {
                final location = getServerLocation(server.countryCode);
                if (location == null) return const SizedBox.shrink();
                
                final pos = location.toMapPosition();
                
                return Positioned(
                  left: pos.x * constraints.maxWidth - 12,
                  top: pos.y * constraints.maxHeight - 12,
                  child: ServerMarker(
                    location: location,
                    serverName: server.name,
                    delay: server.delay,
                    isSelected: server.isSelected,
                    isConnected: server.id == widget.connectedServerId,
                    onTap: () => widget.onServerSelected(server),
                  ),
                );
              }),
            ],
          ),
        );
      },
    );
  }
}

/// Custom painter for simplified world map
class WorldMapPainter extends CustomPainter {
  WorldMapPainter({
    required this.mapColor,
    required this.outlineColor,
  });

  final Color mapColor;
  final Color outlineColor;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = mapColor
      ..style = PaintingStyle.fill;

    final outlinePaint = Paint()
      ..color = outlineColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.5;

    // Simplified continent shapes (normalized 0-1 coordinates)
    // North America
    _drawContinent(canvas, size, paint, outlinePaint, [
      const Offset(0.05, 0.15), const Offset(0.15, 0.10),
      const Offset(0.25, 0.12), const Offset(0.28, 0.20),
      const Offset(0.30, 0.35), const Offset(0.28, 0.42),
      const Offset(0.22, 0.48), const Offset(0.18, 0.52),
      const Offset(0.12, 0.48), const Offset(0.08, 0.38),
      const Offset(0.05, 0.25),
    ]);

    // South America
    _drawContinent(canvas, size, paint, outlinePaint, [
      const Offset(0.22, 0.52), const Offset(0.28, 0.55),
      const Offset(0.32, 0.65), const Offset(0.30, 0.78),
      const Offset(0.25, 0.90), const Offset(0.20, 0.85),
      const Offset(0.18, 0.70), const Offset(0.20, 0.58),
    ]);

    // Europe
    _drawContinent(canvas, size, paint, outlinePaint, [
      const Offset(0.45, 0.15), const Offset(0.55, 0.12),
      const Offset(0.58, 0.18), const Offset(0.56, 0.28),
      const Offset(0.52, 0.32), const Offset(0.48, 0.30),
      const Offset(0.42, 0.28), const Offset(0.40, 0.22),
    ]);

    // Africa
    _drawContinent(canvas, size, paint, outlinePaint, [
      const Offset(0.45, 0.35), const Offset(0.55, 0.32),
      const Offset(0.60, 0.40), const Offset(0.58, 0.52),
      const Offset(0.55, 0.68), const Offset(0.48, 0.72),
      const Offset(0.42, 0.65), const Offset(0.40, 0.50),
      const Offset(0.42, 0.38),
    ]);

    // Asia
    _drawContinent(canvas, size, paint, outlinePaint, [
      const Offset(0.58, 0.12), const Offset(0.72, 0.08),
      const Offset(0.85, 0.15), const Offset(0.95, 0.22),
      const Offset(0.92, 0.35), const Offset(0.85, 0.42),
      const Offset(0.78, 0.48), const Offset(0.70, 0.45),
      const Offset(0.62, 0.38), const Offset(0.60, 0.28),
    ]);

    // Australia
    _drawContinent(canvas, size, paint, outlinePaint, [
      const Offset(0.82, 0.62), const Offset(0.92, 0.60),
      const Offset(0.95, 0.68), const Offset(0.92, 0.78),
      const Offset(0.85, 0.82), const Offset(0.78, 0.75),
      const Offset(0.80, 0.65),
    ]);
  }

  void _drawContinent(
    Canvas canvas,
    Size size,
    Paint fill,
    Paint outline,
    List<Offset> normalizedPoints,
  ) {
    if (normalizedPoints.isEmpty) return;
    
    final path = Path();
    final scaledPoints = normalizedPoints
        .map((p) => Offset(p.dx * size.width, p.dy * size.height))
        .toList();
    
    path.moveTo(scaledPoints.first.dx, scaledPoints.first.dy);
    for (int i = 1; i < scaledPoints.length; i++) {
      path.lineTo(scaledPoints[i].dx, scaledPoints[i].dy);
    }
    path.close();
    
    canvas.drawPath(path, fill);
    canvas.drawPath(path, outline);
  }

  @override
  bool shouldRepaint(covariant WorldMapPainter oldDelegate) =>
      mapColor != oldDelegate.mapColor || outlineColor != oldDelegate.outlineColor;
}

/// Custom painter for decorative grid overlay
class MapGridPainter extends CustomPainter {
  MapGridPainter({required this.gridColor});

  final Color gridColor;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = gridColor
      ..strokeWidth = 0.5
      ..style = PaintingStyle.stroke;

    // Horizontal lines (latitude)
    const latitudeCount = 12;
    for (int i = 0; i <= latitudeCount; i++) {
      final y = (i / latitudeCount) * size.height;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }

    // Vertical lines (longitude)
    const longitudeCount = 24;
    for (int i = 0; i <= longitudeCount; i++) {
      final x = (i / longitudeCount) * size.width;
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
  }

  @override
  bool shouldRepaint(covariant MapGridPainter oldDelegate) =>
      gridColor != oldDelegate.gridColor;
}
