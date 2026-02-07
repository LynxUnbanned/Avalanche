import 'package:flutter/material.dart';
import 'package:avalanche/core/theme/glassmorphism.dart';
import 'package:avalanche/features/home/widget/server_marker.dart';
import 'package:avalanche/features/home/widget/connection_line_painter.dart';
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
    this.userCountryCode = 'US', // Default to US, can be detected via IP later
  });

  final List<MapServerData> servers;
  final void Function(MapServerData server) onServerSelected;
  final String? connectedServerId;
  final String userCountryCode;

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

    // Get user location
    final userLocation = getServerLocation(widget.userCountryCode);
    
    // Find connected server location
    ServerLocation? connectedServerLocation;
    if (widget.connectedServerId != null) {
      final connectedServer = widget.servers.firstWhere(
        (s) => s.id == widget.connectedServerId,
        orElse: () => const MapServerData(id: '', name: '', countryCode: ''),
      );
      if (connectedServer.countryCode.isNotEmpty) {
        connectedServerLocation = getServerLocation(connectedServer.countryCode);
      }
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final mapSize = Size(constraints.maxWidth, constraints.maxHeight);
        
        // Calculate pixel positions for connection line
        Offset? userPos;
        Offset? serverPos;
        
        if (userLocation != null) {
          final pos = userLocation.toMapPosition();
          userPos = Offset(pos.x * mapSize.width, pos.y * mapSize.height);
        }
        
        if (connectedServerLocation != null) {
          final pos = connectedServerLocation.toMapPosition();
          serverPos = Offset(pos.x * mapSize.width, pos.y * mapSize.height);
        }
        
        return InteractiveViewer(
          transformationController: _transformController,
          minScale: 0.5,
          maxScale: 4.0,
          boundaryMargin: EdgeInsets.all(constraints.maxWidth * 0.2),
          child: Stack(
            children: [
              // World map background
              CustomPaint(
                size: mapSize,
                painter: WorldMapPainter(
                  mapColor: theme.borderColor.withOpacity(0.3),
                  outlineColor: theme.borderColor,
                ),
              ),
              
              // Grid overlay for visual effect
              CustomPaint(
                size: mapSize,
                painter: MapGridPainter(
                  gridColor: theme.borderColor.withOpacity(0.1),
                ),
              ),
              
              // Connection line (user → server)
              if (userPos != null && serverPos != null && widget.connectedServerId != null)
                SizedBox(
                  width: mapSize.width,
                  height: mapSize.height,
                  child: AnimatedConnectionLine(
                    userPosition: userPos,
                    serverPosition: serverPos,
                    isConnected: true,
                    color: const Color(0xFF00BCD4), // Avalanche cyan
                  ),
                ),
              
              // User location marker
              if (userLocation != null)
                Builder(
                  builder: (context) {
                    final pos = userLocation.toMapPosition();
                    return Positioned(
                      left: pos.x * mapSize.width - 10,
                      top: pos.y * mapSize.height - 10,
                      child: _UserLocationMarker(
                        isConnected: widget.connectedServerId != null,
                      ),
                    );
                  },
                ),
              
              // Server markers
              ...widget.servers.map((server) {
                final location = getServerLocation(server.countryCode);
                if (location == null) return const SizedBox.shrink();
                
                final pos = location.toMapPosition();
                
                return Positioned(
                  left: pos.x * mapSize.width - 12,
                  top: pos.y * mapSize.height - 12,
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

/// User location marker with pulsing animation
class _UserLocationMarker extends StatefulWidget {
  const _UserLocationMarker({required this.isConnected});

  final bool isConnected;

  @override
  State<_UserLocationMarker> createState() => _UserLocationMarkerState();
}

class _UserLocationMarkerState extends State<_UserLocationMarker>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _pulseController,
      builder: (context, child) {
        final scale = 1.0 + (_pulseController.value * 0.3);
        return Stack(
          alignment: Alignment.center,
          children: [
            // Outer pulse ring
            Transform.scale(
              scale: scale,
              child: Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white.withOpacity(0.3 * (1 - _pulseController.value)),
                    width: 2,
                  ),
                ),
              ),
            ),
            // Inner marker
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: widget.isConnected 
                    ? const Color(0xFF00BCD4) // Cyan when connected
                    : Colors.white,
                border: Border.all(
                  color: Colors.white,
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: (widget.isConnected 
                        ? const Color(0xFF00BCD4) 
                        : Colors.white).withOpacity(0.5),
                    blurRadius: 8,
                    spreadRadius: 2,
                  ),
                ],
              ),
            ),
          ],
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
