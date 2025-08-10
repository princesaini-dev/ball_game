import 'package:flame/components.dart';
import 'package:flutter/material.dart';

class TrackControlPoint {
  double x;
  double y;

  TrackControlPoint(this.x, this.y);

  TrackControlPoint copy() => TrackControlPoint(x, y);
}

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

class CustomTrackComponent extends Component {
  final double width;
  final double baseY;
  final double trackHeight = 40;

  // Track segments for disconnected platforms
  List<TrackSegment> trackSegments = [];

  // Performance optimization: Pre-calculated smooth curve points per segment
  late List<List<Vector2>> segmentTrackPoints;
  final int smoothnessResolution = 2;

  late Paint trackPaint;
  late Paint shadowPaint;
  late Paint surfacePaint;
  late Paint controlPointPaint;

  bool showControlPoints = false;

  CustomTrackComponent({required this.width, required this.baseY}) {
    trackPaint = Paint()
      ..color = const Color(0xFF4CAF50)
      ..style = PaintingStyle.fill;

    shadowPaint = Paint()
      ..color = const Color(0xFF2E7D32)
      ..style = PaintingStyle.fill;

    surfacePaint = Paint()
      ..color = const Color(0xFF66BB6A)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    controlPointPaint = Paint()
      ..color = const Color(0xFFFF5722)
      ..style = PaintingStyle.fill;

    _initializeDefaultTrack();
    _preCalculateTrackPoints();
  }

  void _initializeDefaultTrack() {
    // Create multiple track segments with gaps and height differences
    trackSegments = [
      // First segment - ground level
      TrackSegment(
        startX: 0,
        endX: width * 0.3,
        controlPoints: [
          TrackControlPoint(0, baseY),
          TrackControlPoint(width * 0.1, baseY),
          TrackControlPoint(width * 0.25, baseY - 60),
          TrackControlPoint(width * 0.3, baseY - 10),
        ],
        isConnectedToPrevious: true,
      ),

      // Second segment - elevated platform (gap before it)
      TrackSegment(
        startX: width * 0.45,
        endX: width * 0.65,
        controlPoints: [
          TrackControlPoint(width * 0.45, baseY - 100),
          TrackControlPoint(width * 0.55, baseY - 120),
          TrackControlPoint(width * 0.65, baseY - 100),
        ],
        isConnectedToPrevious: false, // Gap before this segment
      ),

      // Third segment - even higher platform
      TrackSegment(
        startX: width * 0.75,
        endX: width * 0.9,
        controlPoints: [
          TrackControlPoint(width * 0.75, baseY - 150),
          TrackControlPoint(width * 0.82, baseY - 180),
          TrackControlPoint(width * 0.9, baseY - 150),
        ],
        isConnectedToPrevious: false, // Gap before this segment
      ),

      // Final segment - back to ground level
      TrackSegment(
        startX: width * 0.95,
        endX: width,
        controlPoints: [
          TrackControlPoint(width * 0.95, baseY),
          TrackControlPoint(width, baseY),
        ],
        isConnectedToPrevious: false, // Gap before this segment
      ),
    ];
  }

  // Add a new track segment
  void addTrackSegment(double startX, double endX, List<TrackControlPoint> points, {bool connected = false}) {
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

  // Create a platform at specific position with height
  void createPlatform(double startX, double endX, double height, {bool connected = false}) {
    final platformY = baseY - height;
    final points = [
      TrackControlPoint(startX, platformY),
      TrackControlPoint(endX, platformY),
    ];

    addTrackSegment(startX, endX, points, connected: connected);
  }

  // Create a stair-like platform
  void createStairs(double startX, double stepWidth, int numSteps, double stepHeight, {bool connected = false}) {
    for (int i = 0; i < numSteps; i++) {
      final stepStartX = startX + (i * stepWidth);
      final stepEndX = stepStartX + stepWidth;
      final stepY = baseY - (stepHeight * (i + 1));

      final points = [
        TrackControlPoint(stepStartX, stepY),
        TrackControlPoint(stepEndX, stepY),
      ];

      addTrackSegment(stepStartX, stepEndX, points, connected: (i == 0) ? connected : false);
    }
  }

  // Create a hill platform
  void createHillPlatform(double startX, double endX, double peakHeight, {bool connected = false}) {
    final centerX = (startX + endX) / 2;
    final points = [
      TrackControlPoint(startX, baseY - peakHeight * 0.3),
      TrackControlPoint(centerX, baseY - peakHeight),
      TrackControlPoint(endX, baseY - peakHeight * 0.3),
    ];

    addTrackSegment(startX, endX, points, connected: connected);
  }

  // Remove all segments and start fresh
  void clearAllSegments() {
    trackSegments.clear();
    _preCalculateTrackPoints();
  }

  // Load a predefined track pattern with gaps
  void loadTrackPattern(String pattern) {
    clearAllSegments();

    switch (pattern) {
      case 'platformer':
        createPlatform(0, width * 0.1, 0, connected: true);
        createPlatform(width * 0.1, width * 0.3, 120, connected: false);
        createPlatform(width * 0.3, width * 0.8, 150, connected: false);
        createPlatform(width * 0.9, width, 50, connected: false);
        break;

      case 'scattered_platforms':
        createPlatform(0, width * 0.15, 0, connected: true);
        createPlatform(width * 0.25, width * 0.35, 100, connected: false);
        createPlatform(width * 0.5, width * 0.6, 60, connected: false);
        createPlatform(width * 0.75, width * 0.85, 120, connected: false);
        createPlatform(width * 0.95, width, 0, connected: false);
        break;

      case 'mountain_peaks':
        createHillPlatform(0, width * 0.2, 40, connected: true);
        createHillPlatform(width * 0.35, width * 0.55, 100, connected: false);
        createHillPlatform(width * 0.7, width * 0.9, 150, connected: false);
        break;

      case 'continuous':
      default:
        // Original continuous track
        trackSegments = [
          TrackSegment(
            startX: 0,
            endX: width,
            controlPoints: [
              TrackControlPoint(0, baseY),
              TrackControlPoint(width * 0.1, baseY),
              TrackControlPoint(width * 0.25, baseY - 60),
              TrackControlPoint(width * 0.4, baseY - 10),
              TrackControlPoint(width * 0.55, baseY + 40),
              TrackControlPoint(width * 0.7, baseY - 30),
              TrackControlPoint(width * 0.85, baseY + 20),
              TrackControlPoint(width, baseY),
            ],
            isConnectedToPrevious: true,
          ),
        ];
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
      for (double x = segment.startX; x <= segment.endX; x += smoothnessResolution) {
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

  // Find which segment contains the given x position (made public for game logic)
  TrackSegment? findSegmentAtX(double x) {
    for (final segment in trackSegments) {
      if (x >= segment.startX && x <= segment.endX) {
        return segment;
      }
    }
    return null;
  }

  // Check if there's a gap at position x
  bool hasGapAt(double x) {
    return findSegmentAtX(x) == null;
  }

  // Get the height of the next platform after a gap
  double? getNextPlatformHeight(double x) {
    for (final segment in trackSegments) {
      if (segment.startX > x) {
        return segment.controlPoints.first.y;
      }
    }
    return null;
  }

  // Interpolate height within a specific segment
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

    // Linear interpolation for simplicity (can be made smoother later)
    final t = (x - leftPoint.x) / (rightPoint.x - leftPoint.x);
    return leftPoint.y + t * (rightPoint.y - leftPoint.y);
  }

  @override
  void render(Canvas canvas) {
    _renderTrackSegments(canvas);

    if (showControlPoints) {
      _renderControlPoints(canvas);
    }
  }

  void _renderTrackSegments(Canvas canvas) {
    for (int segmentIndex = 0; segmentIndex < segmentTrackPoints.length; segmentIndex++) {
      final points = segmentTrackPoints[segmentIndex];
      if (points.isEmpty) continue;

      final path = Path();
      final shadowPath = Path();

      // Start path
      path.moveTo(points.first.x, points.first.y);
      shadowPath.moveTo(points.first.x, points.first.y + trackHeight);

      // Create smooth curves
      for (int i = 1; i < points.length; i++) {
        final current = points[i];
        path.lineTo(current.x, current.y);
        shadowPath.lineTo(current.x, current.y + trackHeight);
      }

      // Close the segment shape
      final lastPoint = points.last;
      path.lineTo(lastPoint.x, baseY + 200);
      path.lineTo(points.first.x, baseY + 200);
      path.close();

      shadowPath.lineTo(lastPoint.x, baseY + 200);
      shadowPath.lineTo(points.first.x, baseY + 200);
      shadowPath.close();

      // Render shadow first, then main track
      canvas.drawPath(shadowPath, shadowPaint);
      canvas.drawPath(path, trackPaint);

      // Draw surface line
      final surfacePath = Path();
      surfacePath.moveTo(points.first.x, points.first.y);
      for (int i = 1; i < points.length; i++) {
        surfacePath.lineTo(points[i].x, points[i].y);
      }
      canvas.drawPath(surfacePath, surfacePaint);
    }
  }

  void _drawDashedLine(Canvas canvas, Offset start, Offset end, Paint paint) {
    const dashWidth = 5.0;
    const dashSpace = 5.0;

    final distance = (end - start).distance;
    final dashCount = (distance / (dashWidth + dashSpace)).floor();

    for (int i = 0; i < dashCount; i++) {
      final startRatio = (i * (dashWidth + dashSpace)) / distance;
      final endRatio = ((i * (dashWidth + dashSpace)) + dashWidth) / distance;

      final dashStart = Offset.lerp(start, end, startRatio)!;
      final dashEnd = Offset.lerp(start, end, endRatio)!;

      canvas.drawLine(dashStart, dashEnd, paint);
    }
  }

  void _renderControlPoints(Canvas canvas) {
    for (final segment in trackSegments) {
      for (final point in segment.controlPoints) {
        canvas.drawCircle(
          Offset(point.x, point.y),
          6,
          controlPointPaint,
        );
      }
    }
  }

  // Get track height at position (returns null if gap)
  double? getTrackTopY(double x) {
    final segment = findSegmentAtX(x);
    if (segment == null) return null; // Gap!

    return _interpolateHeightInSegment(x, segment);
  }

  void toggleControlPointsVisibility() {
    showControlPoints = !showControlPoints;
  }
}
