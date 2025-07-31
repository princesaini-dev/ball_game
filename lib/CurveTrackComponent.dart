import 'package:flame/components.dart';
import 'package:flutter/painting.dart';
import 'dart:math';

class CurveTrackComponent extends Component {
  final double width;
  final double baseY;
  final double trackHeight = 30; // Reduced height of the elevated track
  final double curveAmplitude = 70; // Height variation of the curve
  final double curveFrequency = 0.015; // How often the curve repeats

  CurveTrackComponent({
    required this.width,
    required this.baseY,
  });

  // Calculate the curve height at a given x position
  double getCurveHeightAtX(double x) {
    return sin(x * curveFrequency) * curveAmplitude;
  }

  // Get the top Y position of the track at a given x position
  double getTrackTopY(double x) {
    return baseY - trackHeight + getCurveHeightAtX(x);
  }

  @override
  void render(Canvas canvas) {
    final trackPaint = Paint()
      ..color = const Color(0x00000000)
      ..style = PaintingStyle.fill;

    final supportPaint = Paint()
      ..color = const Color(0x00000000)
      ..strokeWidth = 0
      ..style = PaintingStyle.stroke;

    final edgePaint = Paint()
      ..color = const Color(0xFF333333)
      ..strokeWidth = 4
      ..style = PaintingStyle.stroke;

    // Draw the curved track surface using a path
    final trackPath = Path();
    trackPath.moveTo(0, baseY - trackHeight + getCurveHeightAtX(0));

    // Create smooth curve using quadratic bezier curves
    for (double x = 0; x <= width; x += 10) {
      final y = baseY - trackHeight + getCurveHeightAtX(x);
      trackPath.lineTo(x, y);
    }

    // Complete the track shape by going down to create the platform
    trackPath.lineTo(width, baseY + 10);
    trackPath.lineTo(0, baseY + 10);
    trackPath.close();

    canvas.drawPath(trackPath, trackPaint);

    // Draw support pillars every 100 pixels
    for (double x = 0; x <= width; x += 100) {
      final trackTopY = getTrackTopY(x);
      canvas.drawLine(
        Offset(x, trackTopY),
        Offset(x, baseY + 40), // Extend below base for visual effect
        supportPaint,
      );
    }

    // Draw curved track edges (rails)
    final railPath1 = Path();
    final railPath2 = Path();

    for (double x = 0; x <= width; x += 5) {
      final trackTopY = getTrackTopY(x);

      if (x == 0) {
        railPath1.moveTo(x, trackTopY + 2);
        railPath2.moveTo(x, trackTopY + trackHeight - 2);
      } else {
        railPath1.lineTo(x, trackTopY + 2);
        railPath2.lineTo(x, trackTopY + trackHeight - 2);
      }
    }

    canvas.drawPath(railPath1, edgePaint);
    canvas.drawPath(railPath2, edgePaint);

    // Draw track ties (cross beams) every 50 pixels - following the curve
    final tiePaint = Paint()
      ..color = const Color(0xFF030303)
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    for (double x = 25; x <= width; x += 50) {
      final trackTopY = getTrackTopY(x);
      canvas.drawLine(
        Offset(x, trackTopY + 3),
        Offset(x, trackTopY + trackHeight - 3),
        tiePaint,
      );
    }
  }
}
