import 'dart:math';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';

class CurveTrackComponent extends Component {
  final double width;
  final double baseY;
  final double curveHeight = 40;
  final double curveFrequency = 1.6;
  final double trackHeight = 40;

  // Performance optimization: Pre-calculated smooth curve points
  late List<Vector2> trackPoints;
  final int smoothnessResolution = 2; // Higher = smoother (less chunky)

  late Paint trackPaint;
  late Paint shadowPaint;
  late Paint surfacePaint;

  CurveTrackComponent({required this.width, required this.baseY}) {
    trackPaint = Paint()
      ..color = const Color(0xFF4CAF50)
      ..style = PaintingStyle.fill;

    shadowPaint = Paint()
      ..color = const Color(0xFF2E7D32)
      ..style = PaintingStyle.fill;

    // Smooth surface paint for better collision detection
    surfacePaint = Paint()
      ..color = const Color(0xFF66BB6A)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    _preCalculateTrackPoints();
  }

  void _preCalculateTrackPoints() {
    trackPoints = [];
    // Pre-calculate all track points for smooth rendering
    for (double x = 0; x <= width; x += smoothnessResolution) {
      final y = baseY + curveHeight * sin(x * curveFrequency * pi / 180);
      trackPoints.add(Vector2(x, y));
    }
    // Ensure we have the final point
    if (trackPoints.last.x < width) {
      final y = baseY + curveHeight * sin(width * curveFrequency * pi / 180);
      trackPoints.add(Vector2(width, y));
    }
  }

  @override
  void render(Canvas canvas) {
    _renderSmoothTrack(canvas);
  }

  void _renderSmoothTrack(Canvas canvas) {
    if (trackPoints.isEmpty) return;

    final path = Path();
    final shadowPath = Path();

    // FIXED: Start track rendering from absolute world coordinate x=0
    // to align properly with parallax layers that start from left edge
    path.moveTo(0, trackPoints.first.y); // Start from world x=0
    shadowPath.moveTo(0, trackPoints.first.y + trackHeight);

    // Create smooth curve using quadratic bezier curves
    for (int i = 1; i < trackPoints.length; i++) {
      final current = trackPoints[i];

      // Create smooth curves between points
      if (i < trackPoints.length - 1) {
        final next = trackPoints[i + 1];
        final controlX = current.x;
        final controlY = current.y;
        final endX = (current.x + next.x) / 2;
        final endY = (current.y + next.y) / 2;

        path.quadraticBezierTo(controlX, controlY, endX, endY);
        shadowPath.quadraticBezierTo(controlX, controlY + trackHeight, endX, endY + trackHeight);
      } else {
        // Last point
        path.lineTo(current.x, current.y);
        shadowPath.lineTo(current.x, current.y + trackHeight);
      }
    }

    // Close the track shape to create solid ground
    final lastPoint = trackPoints.last;
    path.lineTo(lastPoint.x, baseY + 200); // Extend down
    path.lineTo(0, baseY + 200); // Back to x=0, not trackPoints.first.x
    path.close();

    shadowPath.lineTo(lastPoint.x, baseY + 200);
    shadowPath.lineTo(0, baseY + 200); // Back to x=0
    shadowPath.close();

    // Render shadow first, then main track
    canvas.drawPath(shadowPath, shadowPaint);
    canvas.drawPath(path, trackPaint);

    // Draw smooth surface line for visual appeal
    final surfacePath = Path();
    for (int i = 1; i < trackPoints.length; i++) {
      final current = trackPoints[i];
      if (i < trackPoints.length - 1) {
        final next = trackPoints[i + 1];
        final controlX = current.x;
        final controlY = current.y;
        final endX = (current.x + next.x) / 2;
        final endY = (current.y + next.y) / 2;
        surfacePath.quadraticBezierTo(controlX, controlY, endX, endY);
      } else {
        surfacePath.lineTo(current.x, current.y);
      }
    }
    canvas.drawPath(surfacePath, surfacePaint);
  }

  // Smooth interpolated height calculation to prevent vibration
  double getTrackTopY(double x) {
    if (trackPoints.isEmpty) {
      return baseY + curveHeight * sin(x * curveFrequency * pi / 180);
    }

    // Find the closest pre-calculated points and interpolate
    if (x <= trackPoints.first.x) return trackPoints.first.y;
    if (x >= trackPoints.last.x) return trackPoints.last.y;

    // Binary search for efficiency with large track
    int left = 0;
    int right = trackPoints.length - 1;

    while (right - left > 1) {
      int mid = (left + right) ~/ 2;
      if (trackPoints[mid].x <= x) {
        left = mid;
      } else {
        right = mid;
      }
    }

    final leftPoint = trackPoints[left];
    final rightPoint = trackPoints[right];

    // Linear interpolation for smooth height
    final t = (x - leftPoint.x) / (rightPoint.x - leftPoint.x);
    return leftPoint.y + t * (rightPoint.y - leftPoint.y);
  }

  void clearCache() {
    // Cache is now pre-calculated, no need to clear
  }
}
