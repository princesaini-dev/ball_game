import 'dart:math';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import '../config/game_constants.dart';

/// Track control point for curve generation
class TrackControlPoint {
  double x;
  double y;

  TrackControlPoint(this.x, this.y);

  TrackControlPoint copy() => TrackControlPoint(x, y);
}

/// Track segment with visual properties
class TrackSegment {
  double startX;
  double endX;
  List<TrackControlPoint> controlPoints;
  bool isConnectedToPrevious;

  TrackSegment({
    required this.startX,
    required this.endX,
    required this.controlPoints,
    this.isConnectedToPrevious = true,
  });
}

/// Enhanced track component with neon theme and curves
class TrackComponent extends Component {
  final double width;
  final double baseY;
  final double trackHeight = GameConfig.trackHeight;

  // Track segments for disconnected platforms
  List<TrackSegment> trackSegments = [];

  // Pre-calculated smooth curve points per segment
  late List<List<Vector2>> segmentTrackPoints;
  final int smoothnessResolution = 2;

  late Paint trackPaint;
  late Paint shadowPaint;
  late Paint surfacePaint;
  late Paint glowPaint;
  late Paint controlPointPaint;

  bool showControlPoints = false;

  TrackComponent({required this.width, required this.baseY}) {
    _initializePaints();
    _initializeDefaultTrack();
    _preCalculateTrackPoints();
  }

  void _initializePaints() {
    // Neon gradient for track
    trackPaint =
        Paint()
          ..shader = LinearGradient(
            colors: [NeonTheme.trackPrimary, NeonTheme.trackSecondary],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ).createShader(Rect.fromLTWH(0, 0, width, trackHeight * 2))
          ..style = PaintingStyle.fill;

    shadowPaint =
        Paint()
          ..color = Colors.black.withValues(alpha: 0.5)
          ..style = PaintingStyle.fill
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10);

    surfacePaint =
        Paint()
          ..color = NeonTheme.trackGlow
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2);

    glowPaint =
        Paint()
          ..shader = LinearGradient(
            colors: [
              NeonTheme.trackPrimary.withValues(alpha: 0.6),
              NeonTheme.trackSecondary.withValues(alpha: 0.6),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ).createShader(Rect.fromLTWH(0, 0, width, trackHeight * 3))
          ..style = PaintingStyle.fill
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 15);

    controlPointPaint =
        Paint()
          ..color = const Color(0xFFFF5722)
          ..style = PaintingStyle.fill;
  }

  void _initializeDefaultTrack() {
    // Create 3-level track system (20000 units total)
    trackSegments = [
      // ========== LEVEL 1: EASY (0-7000) - Green/Nature Theme ==========
      // Starting platform
      TrackSegment(
        startX: -500,
        endX: 1000,
        controlPoints: [
          TrackControlPoint(-500, baseY),
          TrackControlPoint(0, baseY),
          TrackControlPoint(1000, baseY),
        ],
        isConnectedToPrevious: true,
      ),

      TrackSegment(
        startX: 1200,
        endX: 1800,
        controlPoints: [
          TrackControlPoint(1200, baseY),
          TrackControlPoint(1800, baseY),
        ],
        isConnectedToPrevious: false,
      ),

      TrackSegment(
        startX: 2000,
        endX: 2800,
        controlPoints: [
          TrackControlPoint(2000, baseY - 50),
          TrackControlPoint(2400, baseY - 80),
          TrackControlPoint(2800, baseY - 50),
        ],
        isConnectedToPrevious: false,
      ),

      TrackSegment(
        startX: 3000,
        endX: 3800,
        controlPoints: [
          TrackControlPoint(3000, baseY - 100),
          TrackControlPoint(3800, baseY - 100),
        ],
        isConnectedToPrevious: false,
      ),

      TrackSegment(
        startX: 4000,
        endX: 5000,
        controlPoints: [
          TrackControlPoint(4000, baseY - 80),
          TrackControlPoint(4500, baseY - 120),
          TrackControlPoint(5000, baseY - 80),
        ],
        isConnectedToPrevious: false,
      ),

      TrackSegment(
        startX: 5200,
        endX: 6200,
        controlPoints: [
          TrackControlPoint(5200, baseY - 60),
          TrackControlPoint(5700, baseY - 40),
          TrackControlPoint(6200, baseY - 20),
        ],
        isConnectedToPrevious: false,
      ),

      TrackSegment(
        startX: 6400,
        endX: 7000,
        controlPoints: [
          TrackControlPoint(6400, baseY),
          TrackControlPoint(7000, baseY),
        ],
        isConnectedToPrevious: false,
      ),

      // ========== LEVEL 2: MEDIUM (7000-14000) - Neon City Theme ==========
      TrackSegment(
        startX: 7200,
        endX: 8000,
        controlPoints: [
          TrackControlPoint(7200, baseY - 50),
          TrackControlPoint(7600, baseY - 100),
          TrackControlPoint(8000, baseY - 80),
        ],
        isConnectedToPrevious: false,
      ),

      TrackSegment(
        startX: 8300,
        endX: 9200,
        controlPoints: [
          TrackControlPoint(8300, baseY - 140),
          TrackControlPoint(8750, baseY - 180),
          TrackControlPoint(9200, baseY - 140),
        ],
        isConnectedToPrevious: false,
      ),

      TrackSegment(
        startX: 9500,
        endX: 10300,
        controlPoints: [
          TrackControlPoint(9500, baseY - 100),
          TrackControlPoint(9900, baseY - 60),
          TrackControlPoint(10300, baseY - 100),
        ],
        isConnectedToPrevious: false,
      ),

      TrackSegment(
        startX: 10600,
        endX: 11400,
        controlPoints: [
          TrackControlPoint(10600, baseY - 160),
          TrackControlPoint(11000, baseY - 200),
          TrackControlPoint(11400, baseY - 160),
        ],
        isConnectedToPrevious: false,
      ),

      TrackSegment(
        startX: 11700,
        endX: 12600,
        controlPoints: [
          TrackControlPoint(11700, baseY - 120),
          TrackControlPoint(12150, baseY - 80),
          TrackControlPoint(12600, baseY - 120),
        ],
        isConnectedToPrevious: false,
      ),

      TrackSegment(
        startX: 12900,
        endX: 13700,
        controlPoints: [
          TrackControlPoint(12900, baseY - 180),
          TrackControlPoint(13300, baseY - 220),
          TrackControlPoint(13700, baseY - 180),
        ],
        isConnectedToPrevious: false,
      ),

      TrackSegment(
        startX: 14000,
        endX: 14000,
        controlPoints: [TrackControlPoint(14000, baseY - 140)],
        isConnectedToPrevious: false,
      ),

      // ========== LEVEL 3: HARD (14000-20000) - Dark/Danger Theme ==========
      TrackSegment(
        startX: 14300,
        endX: 15000,
        controlPoints: [
          TrackControlPoint(14300, baseY - 100),
          TrackControlPoint(14650, baseY - 140),
          TrackControlPoint(15000, baseY - 100),
        ],
        isConnectedToPrevious: false,
      ),

      TrackSegment(
        startX: 15400,
        endX: 16000,
        controlPoints: [
          TrackControlPoint(15400, baseY - 200),
          TrackControlPoint(15700, baseY - 250),
          TrackControlPoint(16000, baseY - 200),
        ],
        isConnectedToPrevious: false,
      ),

      TrackSegment(
        startX: 16400,
        endX: 17000,
        controlPoints: [
          TrackControlPoint(16400, baseY - 150),
          TrackControlPoint(16700, baseY - 100),
          TrackControlPoint(17000, baseY - 150),
        ],
        isConnectedToPrevious: false,
      ),

      TrackSegment(
        startX: 17400,
        endX: 18200,
        controlPoints: [
          TrackControlPoint(17400, baseY - 220),
          TrackControlPoint(17800, baseY - 280),
          TrackControlPoint(18200, baseY - 220),
        ],
        isConnectedToPrevious: false,
      ),

      TrackSegment(
        startX: 18600,
        endX: 19400,
        controlPoints: [
          TrackControlPoint(18600, baseY - 160),
          TrackControlPoint(19000, baseY - 100),
          TrackControlPoint(19400, baseY - 60),
        ],
        isConnectedToPrevious: false,
      ),

      // Final platform
      TrackSegment(
        startX: 19600,
        endX: 20500,
        controlPoints: [
          TrackControlPoint(19600, baseY),
          TrackControlPoint(20000, baseY),
          TrackControlPoint(20500, baseY),
        ],
        isConnectedToPrevious: false,
      ),
    ];
  }

  /// Add a new track segment
  void addTrackSegment(
    double startX,
    double endX,
    List<TrackControlPoint> points, {
    bool connected = false,
  }) {
    final segment = TrackSegment(
      startX: startX,
      endX: endX,
      controlPoints: points,
      isConnectedToPrevious: connected,
    );

    // Insert in correct position based on startX
    int insertIndex = trackSegments.length;
    for (int i = 0; i < trackSegments.length; i++) {
      if (trackSegments[i].startX > startX) {
        insertIndex = i;
        break;
      }
    }

    trackSegments.insert(insertIndex, segment);
    _preCalculateTrackPoints();
  }

  /// Create a platform at specific position with height
  void createPlatform(
    double startX,
    double endX,
    double height, {
    bool connected = false,
  }) {
    final platformY = baseY - height;
    final points = [
      TrackControlPoint(startX, platformY),
      TrackControlPoint(endX, platformY),
    ];

    addTrackSegment(startX, endX, points, connected: connected);
  }

  /// Create a curved platform (hill or valley)
  void createCurvedPlatform(
    double startX,
    double endX,
    double peakHeight, {
    bool connected = false,
    bool isValley = false,
  }) {
    final centerX = (startX + endX) / 2;
    final heightMultiplier = isValley ? -1 : 1;

    final points = [
      TrackControlPoint(startX, baseY - peakHeight * 0.3 * heightMultiplier),
      TrackControlPoint(centerX, baseY - peakHeight * heightMultiplier),
      TrackControlPoint(endX, baseY - peakHeight * 0.3 * heightMultiplier),
    ];

    addTrackSegment(startX, endX, points, connected: connected);
  }

  /// Create a wave pattern
  void createWaveSection(
    double startX,
    double endX,
    int waveCount,
    double amplitude, {
    bool connected = false,
  }) {
    final points = <TrackControlPoint>[];
    final segmentWidth = (endX - startX) / (waveCount * 2);

    for (int i = 0; i <= waveCount * 2; i++) {
      final x = startX + (i * segmentWidth);
      final y = baseY - amplitude * sin(i * pi);
      points.add(TrackControlPoint(x, y));
    }

    addTrackSegment(startX, endX, points, connected: connected);
  }

  /// Remove all segments and start fresh
  void clearAllSegments() {
    trackSegments.clear();
    _preCalculateTrackPoints();
  }

  /// Load a predefined track pattern
  void loadTrackPattern(String pattern) {
    clearAllSegments();

    switch (pattern) {
      case 'neon_city':
        _initializeDefaultTrack();
        break;

      case 'wave_rider':
        createPlatform(0, width * 0.1, 0, connected: true);
        createWaveSection(width * 0.15, width * 0.85, 5, 80);
        createPlatform(width * 0.9, width, 0, connected: false);
        break;

      case 'mountain_climb':
        createPlatform(0, width * 0.1, 0, connected: true);
        createCurvedPlatform(width * 0.15, width * 0.3, 80, connected: false);
        createCurvedPlatform(width * 0.35, width * 0.5, 140, connected: false);
        createCurvedPlatform(width * 0.55, width * 0.7, 200, connected: false);
        createPlatform(width * 0.75, width * 0.9, 180, connected: false);
        createCurvedPlatform(width * 0.92, width, 60, connected: false);
        break;

      case 'obstacle_course':
        createPlatform(0, width * 0.12, 0, connected: true);
        createPlatform(width * 0.18, width * 0.28, 100, connected: false);
        createWaveSection(width * 0.33, width * 0.53, 3, 60, connected: false);
        createPlatform(width * 0.58, width * 0.68, 150, connected: false);
        createCurvedPlatform(width * 0.73, width * 0.88, 120, connected: false);
        createPlatform(width * 0.93, width, 20, connected: false);
        break;

      default:
        _initializeDefaultTrack();
        break;
    }

    _preCalculateTrackPoints();
  }

  void _preCalculateTrackPoints() {
    segmentTrackPoints = [];

    for (final segment in trackSegments) {
      final points = <Vector2>[];

      if (segment.controlPoints.length < 2) continue;

      // Pre-calculate all track points for this segment
      for (
        double x = segment.startX;
        x <= segment.endX;
        x += smoothnessResolution
      ) {
        final y = _interpolateHeightInSegment(x, segment);
        points.add(Vector2(x, y));
      }

      // Ensure we have the final point
      if (points.isEmpty || points.last.x < segment.endX) {
        final y = _interpolateHeightInSegment(segment.endX, segment);
        points.add(Vector2(segment.endX, y));
      }

      segmentTrackPoints.add(points);
    }
  }

  /// Find which segment contains the given x position
  TrackSegment? findSegmentAtX(double x) {
    for (final segment in trackSegments) {
      if (x >= segment.startX && x <= segment.endX) {
        return segment;
      }
    }
    return null;
  }

  /// Check if there's a gap at position x
  bool hasGapAt(double x) {
    return findSegmentAtX(x) == null;
  }

  /// Interpolate height within a specific segment using Catmull-Rom spline
  double _interpolateHeightInSegment(double x, TrackSegment segment) {
    final controlPoints = segment.controlPoints;
    if (controlPoints.length < 2) return baseY;

    // Find surrounding control points within this segment
    TrackControlPoint? leftPoint;
    TrackControlPoint? rightPoint;

    for (int i = 0; i < controlPoints.length - 1; i++) {
      if (x >= controlPoints[i].x && x <= controlPoints[i + 1].x) {
        leftPoint = controlPoints[i];
        rightPoint = controlPoints[i + 1];
        break;
      }
    }

    // Handle edge cases
    if (leftPoint == null || rightPoint == null) {
      if (x <= controlPoints.first.x) return controlPoints.first.y;
      if (x >= controlPoints.last.x) return controlPoints.last.y;
      return baseY;
    }

    // Smooth interpolation
    final t = (x - leftPoint.x) / (rightPoint.x - leftPoint.x);
    final smoothT = t * t * (3 - 2 * t); // Smoothstep
    return leftPoint.y + smoothT * (rightPoint.y - leftPoint.y);
  }

  @override
  void render(Canvas canvas) {
    _renderTrackSegments(canvas);

    if (showControlPoints) {
      _renderControlPoints(canvas);
    }
  }

  void _renderTrackSegments(Canvas canvas) {
    for (
      int segmentIndex = 0;
      segmentIndex < segmentTrackPoints.length;
      segmentIndex++
    ) {
      final points = segmentTrackPoints[segmentIndex];
      if (points.isEmpty) continue;

      final path = Path();
      final glowPath = Path();

      // Start path
      path.moveTo(points.first.x, points.first.y);
      glowPath.moveTo(points.first.x, points.first.y - 10);

      // Create smooth curves
      for (int i = 1; i < points.length; i++) {
        final current = points[i];
        path.lineTo(current.x, current.y);
        glowPath.lineTo(current.x, current.y - 10);
      }

      // Close the segment shape
      final lastPoint = points.last;
      path.lineTo(lastPoint.x, baseY + 200);
      path.lineTo(points.first.x, baseY + 200);
      path.close();

      glowPath.lineTo(lastPoint.x, lastPoint.y + trackHeight);
      glowPath.lineTo(points.first.x, points.first.y + trackHeight);
      glowPath.close();

      // Render glow first
      canvas.drawPath(glowPath, glowPaint);

      // Render shadow
      canvas.drawPath(path, shadowPaint);

      // Render main track
      canvas.drawPath(path, trackPaint);

      // Draw surface line with glow
      final surfacePath = Path();
      surfacePath.moveTo(points.first.x, points.first.y);
      for (int i = 1; i < points.length; i++) {
        surfacePath.lineTo(points[i].x, points[i].y);
      }
      canvas.drawPath(surfacePath, surfacePaint);
    }
  }

  void _renderControlPoints(Canvas canvas) {
    for (final segment in trackSegments) {
      for (final point in segment.controlPoints) {
        canvas.drawCircle(Offset(point.x, point.y), 6, controlPointPaint);
      }
    }
  }

  /// Get track height at position (returns null if gap)
  double? getTrackTopY(double x) {
    final segment = findSegmentAtX(x);
    if (segment == null) return null; // Gap!

    return _interpolateHeightInSegment(x, segment);
  }

  void toggleControlPointsVisibility() {
    showControlPoints = !showControlPoints;
  }
}
